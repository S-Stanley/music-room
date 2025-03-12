import express from "express";
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';
import { validate as uuidValidate, v4 as uuidv4 } from 'uuid';

const app = express();
const port = process.env.port || 5001;
const prisma = new PrismaClient();

app.use(express.urlencoded({extended: false}));

app.get("/up", (req, res) => {
  res.status(200).send({
    status: "OK",
  });
});

app.get("/users/:user_id", async(req, res) => {
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

app.post("/users/email/signin", async(req, res) => {
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
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

app.post("/users/email/signup", async(req, res) => {
  console.info("User trying to login with email");
  try {
    console.log(req.body)
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
    const token = uuidv4();
    const hashedPassword = await bcrypt.hash(req.body.password, 7);
    const userToCreate = await prisma.user.create({
      data: {
        email: req.body.email,
        password: hashedPassword,
        token: token,
      }
    });
    return res.status(201).json({
      id: userToCreate?.id,
      email: userToCreate?.email,
      token: userToCreate?.token,
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

app.listen(port, () => {
  console.info(`API running on ${port}`)
});

export default app;
