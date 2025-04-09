import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const findUserVoteByPlaylistId = async(playlist_id, user_id, track_id) => {
  return await prisma.trackVote.findMany({
    where: {
      playlistId: playlist_id,
      userId: user_id,
      trackId: track_id,
    }
  }) 
};

export const createUserVote = async(playlist_id, user_id, track_id) => {
  return await prisma.trackVote.create({
    data: {
      user: {
        connect: {
          id: user_id,
        }
      },
      playlist: {
        connect: {
          id: playlist_id,
        }
      },
      track: {
        connect: {
          id: track_id,
        }
      }
    },
  });
};
