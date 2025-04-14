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
