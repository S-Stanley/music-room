import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getAllTrackOfPlaylist = async(playlist_id) => {
  return await prisma.trackPlaylist.findMany({
    where: {
      playlistId: playlist_id,
    }
  });
};

export const getTrackDefaultPosition = async (playlist_id) => {
  return await prisma.trackPlaylist.count({
    where: {
      playlistId: playlist_id,
    }
  });
};
