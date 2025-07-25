import express from "express";
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';
import { validate as uuidValidate, v4 as uuidv4 } from 'uuid';
import { UAParser } from "ua-parser-js";

const app = express();
const port = process.env.port || 5001;
const prisma = new PrismaClient();

import { usersRouter } from "./routes/users.js";
import { playlistRouter } from "./routes/playlist.js";
import { trackRouter } from "./routes/track.js";
import { friendRouter } from "./routes/friends.js"; 

app.use(express.urlencoded({extended: false}));
app.set('trust proxy', true);

const _HALF_PROTECTED_ENDPINT = [
  "/users/gmail/auth",
  "/users/gmail/auth/",
  "/users/facebook/auth",
  "/users/facebook/auth/",
];

const _UNPROTECTED_ENDPOINT_ = [
  "/up",
  "/up/",
  "/users/email/signup",
  "/users/email/signin",
  "/users/email/signup/",
  "/users/email/signin/",
  "/users/email/validate",
  "/users/email/validate/",
  "/users/password/reset",
  "/users/password/reset/",
  "/users/password/confirm",
  "/users/password/confirm/",
  "/users/gmail/auth",
  "/users/gmail/auth/",
  "/users/facebook/auth",
  "/users/facebook/auth/",
]

app.use("/", async(req, res, next) => {
  const parser = new UAParser();
  const ua = parser.setUA(req.headers['user-agent']).getResult();

  console.info({
    platform: ua?.os?.name,
    user_agent: req.headers['user-agent'],
  });
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
  if (_HALF_PROTECTED_ENDPINT.includes(req.originalUrl)){
    const receivedToken = req.get("token");
    if (receivedToken){
      const user = await prisma.user.findUnique({
        where: {
          token: receivedToken,
        }
      });
      res.locals.user = user;
    }
  }
  next();
});


app.use("/users", usersRouter);
app.use("/playlist", playlistRouter);
app.use("/track", trackRouter);
app.use("/friends/", friendRouter);

app.get("/up", (req, res) => {
  res.status(200).send({
    status: "OK",
  });
});

app.listen(port, () => {
  console.info(`API running on ${port}`)
});

export default app;
