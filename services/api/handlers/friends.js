import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getAllFriendRequest = async(userId) => {
  try {
    return await prisma.friendRequest.findMany({
      where: {
        invitedUserId: userId,
      }
    })
  } catch (e){
    console.error(e);
    return ([]);
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
