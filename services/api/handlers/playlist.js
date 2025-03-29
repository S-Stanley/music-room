import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getPlaylistById = async(playlist_id) => {
  const playlist = await prisma.playlist.findUnique(
    {
      where: { 
        id: playlist_id
      }
    }
  );
  return (playlist);
}
