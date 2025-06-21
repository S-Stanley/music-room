import express from "express";
import { PrismaClient } from '@prisma/client';

const router = express.Router();
const prisma = new PrismaClient();

import {
  createFriendRequest,
  getAllFriendRequest,
} from "../handlers/friends.js";
import {
  findUserById,
} from "../handlers/user.js";

router.get("/invitation", async(req, res) => {
  console.log("User is listing his invitations");
  try {
    console.log(await getAllFriendRequest(res.locals.user.id));
    return res.status(200).json(await getAllFriendRequest(res.locals.user.id) ?? []);
  } catch (e){
    console.error(e); 
    return res.status(500).json({
      error: "Server error"
    }); 
  }
});

router.post("/invitation", async(req, res) => {
  console.log("User is sending friend request");
  try {
    const { invitedUserId } = req.body;
    if (!invitedUserId){
      return res.status(400).json({
        error: "invitedUserId cannot be empty"
      });
    }
    const invitedUser = await findUserById(invitedUserId);
    if (!invitedUser){
      return res.status(400).json({
        error: "Invited user does not exist"
      });
    }
    const frientRequestCreated = await createFriendRequest(res.locals.user.id, invitedUserId);
    return res.status(201).json(frientRequestCreated);
  } catch (e){
    console.error(e); 
    return res.status(500).json({
      error: "Server error"
    }); 
  }
});

export const friendRouter = router;
