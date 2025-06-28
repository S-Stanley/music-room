import express from "express";
import { PrismaClient } from '@prisma/client';

const router = express.Router();
const prisma = new PrismaClient();

import {
  createFriendRequest,
  getAllFriendRequest,
  updateFriendRequest,
  findFriendRequestById,
  createFriendRelationship,
  getAllFriendsOfUser,
} from "../handlers/friends.js";
import {
  findUserById,
} from "../handlers/user.js";
import {
  FRIENDS_REQUEST_STATUS,
} from "../constants.js";

router.get("/", async(req, res) => {
  try {
    return res.status(200).json(await getAllFriendsOfUser(res.locals.user.id))
  } catch (e) {
    return res.status(500).json({
      error: "Server error"
    })
  }
});

router.post("/invitation/accept", async(req, res) => {
  console.log("user is acceping friend request");
  try {
    const { request_id } = req.body;
    if (!await findFriendRequestById(request_id)){
      return res.status(400).json({
        error: "Request id not found"
      }); 
    }
    const friendRequest = await findFriendRequestById(request_id);
    const acceptFriendRequest = await updateFriendRequest(request_id, FRIENDS_REQUEST_STATUS.ACCEPTED)
    await createFriendRelationship(friendRequest.requestedById, friendRequest.invitedUserId);
    await createFriendRelationship(friendRequest.invitedUserId, friendRequest.requestedById);
    return res.status(200).json(acceptFriendRequest); 
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    }); 
  }
});

router.post("/invitation/decline", async(req, res) => {
  console.log("user is declining friend request");
  try {
    const { request_id } = req.body;
    if (!await findFriendRequestById(request_id)){
      return res.status(400).json({
        error: "Request id not found"
      }); 
    }
    const declinedFriendRequest = await updateFriendRequest(request_id, FRIENDS_REQUEST_STATUS.DENIED)
    return res.status(200).json(declinedFriendRequest); 
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    }); 
  }
});

router.get("/invitation", async(req, res) => {
  console.log("User is listing his invitations");
  try {
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
