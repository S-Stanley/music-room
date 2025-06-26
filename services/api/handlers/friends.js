import { PrismaClient } from '@prisma/client';

import { FRIENDS_REQUEST_STATUS } from "../constants.js";

const prisma = new PrismaClient();

export const createFriendRelationship = async(userId, friendId) => {
  try {
    return await prisma.friend.create({
      data: {
        user: {
          connect: {
            id: userId,
          }
        },
        friend: {
          connect: {
            id: userId,
          }
        },
      }
    });
  } catch (e) {
    console.error(e);
    return (null);
  }
};

export const updateFriendRequest = async(requestId, state) => {
  try {
    return await prisma.friendRequest.update({
      where: {
        id: requestId,
      },
      data: {
        state: state,
      }
    })
  } catch (e) {
    console.error(e);
    return (null);
  }
};

export const getAllFriendRequest = async(userId) => {
  try {
    return await prisma.friendRequest.findMany({
      where: {
        invitedUserId: userId,
        state: FRIENDS_REQUEST_STATUS.PENDING,
      }
    })
  } catch (e){
    console.error(e);
    return ([]);
  }
};

export const findFriendRequestById = async(requestId) => {
  try {
    return await prisma.friendRequest.findFirst({
      where: {
        id: requestId
      }
    })
  }
  catch (e) {
    console.error(e);
    return (null);
  }
};

export const findFriendRequest = async(invitedBy, invitedUserId) => {
  try {
    return await prisma.friendRequest.findFirst({
      where: {
        requestedById: invitedBy,
        invitedUserId: invitedUserId,
      }
    })
  }
  catch (e) {
    console.error(e);
    return (null);
  }
};

export const createFriendRequest = async(invitedBy, invitedUserId) => {
  try {
    const existingFriendRequest = await findFriendRequest(invitedBy, invitedUserId);
    if (existingFriendRequest){
      return (existingFriendRequest);
    }
    return await prisma.friendRequest.create({
      data: {
        requestedBy: {
          connect: {
            id: invitedBy,
          }
        },
        invitedUser: {
          connect: {
            id: invitedUserId,
          }
        }
      }
    });
  } catch (e) {
    console.error(e);
    return null;
  }
};
