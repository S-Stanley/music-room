import { PrismaClient } from '@prisma/client';

import {
  getAllInvitationsOfUser,
} from "./invitations.js";
import {
  getAllPlaylistWhereUserIsMember,
} from "./members.js";

const prisma = new PrismaClient();

const _PAGINATION_MAX_TAKE = 50;

const PlaylistType = {
  PRIVATE: "PRIVATE",
  PUBLIC: "PUBLIC",
}

export const getManyPrivatePlaylistByIds = async(skip, take, playlistIds) => {
    return await prisma.playlist.findMany({
      where: {
        id: {
          in: playlistIds
        },
        type: PlaylistType.PRIVATE,
      },
      select: {
        id: true,
        name: true,
        type: true,
        orderType: true,
        user: {
          select: {
            id: true,
            email: true,
            name: true,
          },
        },
      },
      skip: parseInt(skip ?? 0, 10),
      take: (!take || parseInt(take, 10) > _PAGINATION_MAX_TAKE)
        ? _PAGINATION_MAX_TAKE
        : parseInt(take),
    });
};

export const getAllPublicPlaylists = async(skip, take) => {
    return await prisma.playlist.findMany({
      where: {
        type: PlaylistType.PUBLIC
      },
      select: {
        id: true,
        name: true,
        type: true,
        orderType: true,
        user: {
          select: {
            id: true,
            email: true,
            name: true,
          },
        },
      },
      skip: parseInt(skip ?? 0, 10),
      take: (!take || parseInt(take, 10) > _PAGINATION_MAX_TAKE)
        ? _PAGINATION_MAX_TAKE
        : parseInt(take),
    });
};

export const getAllPrivatePlaylistWhereUserIsInvited = async(skip, take, userId) => {
  const invitations = await getAllInvitationsOfUser(userId);
  if (invitations.length === 0){
    return ([]);
  }
  return await getManyPrivatePlaylistByIds(
    skip,
    take,
    invitations.map((invit) => invit?.playlistId)
  );
};

export const getAllPrivatePlaylistWhereUserIsMember = async(skip, take, user_id) => {
  const members = await getAllPlaylistWhereUserIsMember(user_id);
  return await getManyPrivatePlaylistByIds(
    skip,
    take,
    members.map((member) => member?.playlistId)
  );
};

export const getAllPlaylistByUserId = async(skip, take, user_id) => {
  const publicPlaylist = await getAllPublicPlaylists(skip, take);
  const invitedPlaylists = await getAllPrivatePlaylistWhereUserIsInvited(skip, take, user_id);
  const memberPlaylists = await getAllPrivatePlaylistWhereUserIsMember(
    skip,
    take,
    user_id,
  );
  return [
    ...publicPlaylist,
    ...invitedPlaylists,
    ...memberPlaylists,
  ]
};

export const getPlaylistById = async(playlist_id) => {
  const playlist = await prisma.playlist.findUnique(
    {
      where: { 
        id: playlist_id
      },
      include: {
        user: true,
      }
    }
  );
  playlist.user.password = undefined;
  playlist.user.token = undefined;
  return (playlist);
}
