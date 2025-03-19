import express from "express";
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';
import { validate as uuidValidate, v4 as uuidv4 } from 'uuid';

const app = express();
const port = process.env.port || 5001;
const prisma = new PrismaClient();

import { usersRouter } from "./users.js";

app.use(express.urlencoded({extended: false}));

const _UNPROTECTED_ENDPOINT_ = [
  "/users/email/signup",
  "/users/email/signin",
  "/users/email/signup/",
  "/users/email/signin/",
]

app.use("/", async(req, res, next) => {
  if (!_UNPROTECTED_ENDPOINT_.includes(req.originalUrl)){
    const receivedToken = req.get("token");
    if (!receivedToken){
      return res.status(401).send({
        error: "Unauthenticated"
      });
    }
    if (!uuidValidate(receivedToken)){
      return res.status(400).send({
        error: "Wrong token format"
      });
    }
    const user = await prisma.user.findUnique({
      where: {
        token: receivedToken,
      }
    });
    if (!user){
      return res.status(401).send({
        error: "Token is expired or erroned"
      });
    }
    res.locals.user = user;
    console.log("Connected as", res.locals?.user);
  }
  next();
});


app.use("/users", usersRouter);

app.get("/up", (req, res) => {
  res.status(200).send({
    status: "OK",
  });
});

app.listen(port, () => {
  console.info(`API running on ${port}`)
});

export default app;
