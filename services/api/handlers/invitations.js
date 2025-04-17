import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const createInvitation = async(playlist_id, invitedByUserId, invitedUserId) => {
  return await prisma.invitation.create({
    data: {
      playlist: {
        connect: {
          id: playlist_id,
        }
      },
      invitedBy: {
        connect: {
          id: invitedByUserId,
        }
      },
      invitedUser: {
        connect: {
          id: invitedUserId,
        }
      },
    }
  });
};

export const getAllInvitationsOfUser = async(user_id) => {
  const allInvitation = await prisma.invitation.findMany({
    where: {
      invitedUserId: user_id,
    },
    include: {
      invitedUser: true,
      invitedBy: true,
      playlist: true,
    },
  });
  allInvitation.forEach((invitation) => {
    invitation.invitedBy.password = undefined;
    invitation.invitedBy.token = undefined;
    invitation.invitedUser.password = undefined;
    invitation.invitedUser.token = undefined;
  });
  return (allInvitation);
};

export const deleteInvitation = async(invitedUserId, playlistId) => {
  try {
    return await prisma.invitation.deleteMany({
      where: {
        playlistId: playlistId,
        invitedUserId: invitedUserId,
      }
    });
  } catch (e) {
    console.error(e);
    return (null);
  }
};
