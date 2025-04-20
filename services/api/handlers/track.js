import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getAllTrackToUpdatePosition = async(playlist_id, track_id) => {
  return await prisma.trackPlaylist.findMany({
    where: {
      id: {
        not: track_id,
      },
      playlistId: playlist_id,
    },
    orderBy: {
      position: "asc",
    }
  });
};

export const updateTrackPosition = async(track_id, position) => {
  return await prisma.trackPlaylist.update({
    where: {
      id: track_id,
    },
    data: {
      position: position,
    }
  })
};

export const getAllTrackOfPlaylist = async(playlist_id) => {
  const tracks = await prisma.trackPlaylist.findMany({
    where: {
      playlistId: playlist_id,
      alreadyPlayed: false,
    },
    orderBy: {
      voteCount: "desc",
    },
    include: {
      user: true,
      playlist: {
        include: {
          user: true,
        },
      }
    }
  });
  (tracks ?? []).forEach((track) => {
    track.user.password = undefined;
    track.user.token = undefined;
    track.playlist.user.password = undefined;
    track.playlist.user.token = undefined;
  });
  return (tracks);
};

export const getAllTrackOfPlaylistOrderByPosition = async(playlist_id) => {
  const tracks = await prisma.trackPlaylist.findMany({
    where: {
      playlistId: playlist_id,
      alreadyPlayed: false,
    },
    orderBy: {
      position: "asc",
    },
    include: {
      user: true,
      playlist: {
        include: {
          user: true,
        },
      }
    }
  });
  (tracks ?? []).forEach((track) => {
    track.user.password = undefined;
    track.user.token = undefined;
    track.playlist.user.password = undefined;
    track.playlist.user.token = undefined;
  });
  return (tracks);
};

export const getNumberOfTracksInPlaylist = async(playlist_id) => {
  return await prisma.trackPlaylist.count({
    where: {
      playlistId: playlist_id,
      alreadyPlayed: false,
    }
  })
};

export const getTrackDefaultPosition = async (playlist_id) => {
  return await prisma.trackPlaylist.count({
    where: {
      playlistId: playlist_id,
    }
  });
};

export const getTrackById = async(track_id) => {
  try {
    return await prisma.trackPlaylist.findUnique({
      where: {
        id: track_id,
      }
    })
  } catch (e) {
    console.error(e);
    return (null);
  }
};

export const setTrackAsPlayed = async(track_id) => {
  return await prisma.trackPlaylist.update({
    where: {
      id: track_id,
    },
    data: {
      alreadyPlayed: true,
    }
  });
};
