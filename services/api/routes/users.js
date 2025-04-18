import express from "express";
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';
import { validate as uuidValidate, v4 as uuidv4 } from 'uuid';

import {
  getAllInvitationsOfUser,
} from "../handlers/invitations.js";
import {
  getAllUsers,
} from "../handlers/user.js";

const router = express.Router();
const prisma = new PrismaClient();

const _MAX_TAKE_ = 50;

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
    return res.status(201).json({
      id: userToCreate?.id,
      email: userToCreate?.email,
      token: userToCreate?.token,
      name: userToCreate?.name,
    });
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
