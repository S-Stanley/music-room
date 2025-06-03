import express from "express";
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';
import { validate as uuidValidate, v4 as uuidv4 } from 'uuid';

import {
  getAllInvitationsOfUser,
} from "../handlers/invitations.js";
import {
  getAllUsers,
  createNewConfirmationCode,
  isUserEmailValidated,
  checkConfirmationCode,
  findUserByEmail,
  createUserWithGoogle,
} from "../handlers/user.js";
import {
  createPasswordChangeRequest,
  checkUserConfirmationCodeForPasswordChange,
  updateUserPassword,
} from "../handlers/password.js";
import {
  sendEmail,
} from "../utils/email.js";
import {
  generateConfirmationCode,
} from "../utils/user.js";
import {
  checkGoogleToken,
} from "../providers/google.js";

const router = express.Router();
const prisma = new PrismaClient();

const _MAX_TAKE_ = 50;

router.post("/password/reset", async(req, res) => {
  console.info("User asking for password reset");
  try {
    const { email, password } = req.body;
    if (!password || !email){
      return res.status(400).json({
        error: "Password or email cannot be empty"
      });
    }
    const user = await findUserByEmail(email);
    if (!user){
      return res.status(400).json({
        error: "User does not exist"
      });
    }
    const confirmationCode = generateConfirmationCode();
    await createPasswordChangeRequest(user.id, confirmationCode, password);
    console.info("Confirmation code:", confirmationCode);
    await sendEmail(
      user.email,
      "Your confirmation code for password change",
      `<p>Your confirmation code for password request change is: ${confirmationCode}</p>`
    );
    return res.status(201).json({
      user_id: user.id,
    });
  } catch (e) {
		console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

router.post("/password/confirm", async(req, res) => {
  try {
    const { code, email } = req.body;
    if (!code || isNaN(parseInt(code, 10))) {
      return res.status(400).json({
        error: "Confirmation code cannot be empty or wrong format"
      });
    }
    const user = await findUserByEmail(email);
    if (!user){
      return res.status(400).json({
        error: "User does not exist"
      });
    }
    const checkConfirmationCode = await checkUserConfirmationCodeForPasswordChange(user.id, parseInt(code, 10));
    if (!checkConfirmationCode) {
      return res.status(400).json({
        error: "Wrong confirmation code"
      });
    }
    await updateUserPassword(user.id);
    return res.status(200).json({
      user_id: user?.id,
    });
  } catch (e){
		console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

router.post("/info", async(req, res) => {
	try {
		const userUpdated = await prisma.user.update({
			where: {
				id: res.locals.user?.id,
			},
			data: {
				email: req.body?.email ?? undefined,
				password: req.body?.password
					? await bcrypt.hash(req.body?.password, 7) 
					: undefined,
			}
		});
		return res.status(200).send({
			id: userUpdated?.id,
			email: userUpdated?.email,
			password: userUpdated?.password,
			token: userUpdated?.token,
		});
	} catch (e) {
		console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
	}
});

router.get("/invitations", async(req, res) => {
  try {
    const allInvitations = await getAllInvitationsOfUser(res?.locals?.user?.id);
    res.status(200).json(allInvitations);
  } catch (e){
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

router.get("/:user_id", async(req, res) => {
  console.log("Reading user info");
  try {
    if (!uuidValidate(req.params.user_id)){
      return res.status(400).send({
        error: "User_id is not uuid format",
      });
    }
    const user = await prisma.user.findUnique({
      where: {
        id: req.params.user_id
      }
    });
    if (!user){
      return res.status(400).send({
        error: "Unknow user",
      });
    }
    return res.status(200).send({
      id: user?.id,
      email: user?.email,
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

router.post("/email/signin", async(req, res) => {
  console.info("User trying to login with email");
  try {
    if (!req.body?.email){
      return res.status(400).json({
        error: "Missing argument: email"
      })
    };
    if (!req.body?.password){
      return res.status(400).json({
        error: "Missing argument: password"
      })
    };
    const user = await prisma.user.findUnique({
      where: {
        email: req.body?.email,
      }
    });
    if (!user){
      return res.status(400).json({
        error: "Unknow email"
      })
    }
    if (!await bcrypt.compare(req.body.password, user.password)){
      return res.status(400).json({
        error: "Invalid identifiant"
      })
    }
    if (!(await isUserEmailValidated(user?.id))){
      return res.status(400).json({
        error: "User email is not validated yet"
      })
    };
    const token = uuidv4();
    await prisma.user.update({
      where: {
        id: user?.id
      },
      data: {
        token: token,
      }
    });
    return res.status(200).json({
      id: user?.id,
      email: user?.email,
      token: token,
      name: user?.name,
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

router.post("/gmail/auth", async(req, res) => {
  try {
    const { token } = req.body;
    if (!token){
      return res.status(400).json({
        error: "Google token not provided"
      });
    }
    const { user_id, email } = await checkGoogleToken(token);
    if (!user_id || !email){
      return res.status(400).json({
        error: "Error while trying to check user token from google"
      });
    }
    const connectionToken = uuidv4();
    const userCreated = createUserWithGoogle(user_id, email, connectionToken);
    return res.status(200).json(userCreated);
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

router.post("/email/signup", async(req, res) => {
  console.info("User trying to login with email");
  try {
    if (!req.body?.email){
      return res.status(400).json({
        error: "Missing argument: email"
      })
    };
    if (!req.body?.password){
      return res.status(400).json({
        error: "Missing argument: password"
      })
    };
    const user = await prisma.user.findUnique({
      where: {
        email: req.body?.email,
      }
    });
    if (user){
      return res.status(400).json({
        error: "User already exist"
      })
    }
    if (!req.body.email.indexOf("@") < 0){
      return res.status(400).json({
        error: "Email is not in the right format"
      });
    }
    const token = uuidv4();
    const hashedPassword = await bcrypt.hash(req.body.password, 7);
    const userToCreate = await prisma.user.create({
      data: {
        email: req.body.email,
        password: hashedPassword,
        token: token,
        name: req.body.email.split("@")[0]
      }
    });
    const confirmationCode = await createNewConfirmationCode(userToCreate?.id);
    console.info("CONFIRMATION CODE:", confirmationCode);
    await sendEmail(
      req.body.email,
      "Your music-room confirmation code",
      `<p>Your confirmation code is: ${confirmationCode?.code}</p>`
    );
    return res.status(201).json({
      id: userToCreate?.id,
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

router.post("/email/validate", async(req, res) => {
  console.log("Trying to validate email of user");
  try {
    const { email, confirmationCode } = req.body;
    if (!email || !confirmationCode){
      return res.status(400).json({
        error: "Missing parameter email or confirmationCode"
      });
    }
    const user = await findUserByEmail(email);
    if (!user?.id){
      return res.status(400).json({
        error: "User does not exist",
      });
    }
    if (!await checkConfirmationCode(user?.id, confirmationCode)){
      return res.status(400).json({
        error: "Wrong confirmation code",
      });
    }
    return res.status(200).json(user);
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

router.get("/", async(req, res) => {
  console.info("Getting all users");
  try {
    const { take, skip } = req.query;
    if (parseInt(take, 10) > _MAX_TAKE_){
      return res.status(500).json({
        error: `Could not take more than ${_MAX_TAKE_}`
      });
    }
    const allUsers = await getAllUsers(
      parseInt(take, 10) || _MAX_TAKE_,
      parseInt(skip, 10) || 0,
      res.locals.user.id,
    );
    return res.status(200).json(allUsers);
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

export const usersRouter = router;;
