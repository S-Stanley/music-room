import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const createMember = async(user_id, playlist_id) => {
  return await prisma.members.create({
    data: {
      user: {
        connect: {
          id: user_id
        }
      },
      playlist: {
        connect: {
          id: playlist_id,
        }
      }
    }
  })
};

export const getAllPlaylistMembers = async(playlist_id) => {
  return await prisma.members.findMany({
    where: {
      playlistId: playlist_id,
    },
    include: {
      user: true,
      playlist: true,
    }
  })
};

export const isUserAlreadyJoinedPlaylist = async(playlist_id, user_id) => {
  const find = await prisma.members.findMany({
    where: {
      playlistId: playlist_id,
      userId: user_id,
    }
  });
  if (find.length === 0) {
    return (false);
  }
  return (true);
};

export const getAllPlaylistWhereUserIsMember = async(user_id) => {
  return await prisma.members.findMany({
    where: {
      userId: user_id,
    }
  });
};
