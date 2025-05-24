import express from "express";
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import NodeGeocoder from 'node-geocoder';

import {
  getPlaylistById,
  getAllPlaylistByUserId,
  updatePlaylistSession,
  updatePlaylistLocation,
} from "../handlers/playlist.js";
import {
  getTrackDefaultPosition,
  getAllTrackOfPlaylist,
  getTrackById,
  getNumberOfTracksInPlaylist,
  getAllTrackToUpdatePosition,
  updateTrackPosition,
  getAllTrackOfPlaylistOrderByPosition,
} from "../handlers/track.js";
import {
  findUserById
} from "../handlers/user.js"
import {
  findUserVoteByPlaylistId,
  createUserVote,
} from "../handlers/votes.js";
import {
  createInvitation,
  deleteInvitation,
  checkIfUserIsInvitedToPlaylist,
} from "../handlers/invitations.js";
import {
  createMember,
  getAllPlaylistMembers,
  isUserAlreadyJoinedPlaylist,
} from "../handlers/members.js";
import {
  reorderTracks,
} from "../utils/track.js"
import {
  getLocationFromIpAddr,
  computeDistanceBetweenTwoLocations,
} from "../providers/geoloc.js";

const router = express.Router();
const prisma = new PrismaClient();
const geocoder = NodeGeocoder({
  provider: 'openstreetmap'
});

const PlaylistTypeEnum = {
  PUBLIC: "PUBLIC",
  PRIVATE: "PRIVATE",
};

const _PAGINATION_MAX_TAKE = 50;

const getLocalisationOfAddress = async(address) => {
  const res = await geocoder.geocode(address);
  if (res.length > 0){
    const { latitude, longitude } = res[0];
    return {
      latitude: latitude ?? null,
      longitude: longitude ?? null,
    }
  };
  return {
    latitude: null,
    longitude: null,
  };
};

router.post("/:playlist_id/edit/session", async(req, res) => {
  console.info("User is trying to ad lon, lat, session start and session end to playlist");
  try {
    const { playlist_id } = req.params;
    const playlist = await getPlaylistById(playlist_id);
    if (!playlist){
      return res.status(400).json({
        error: "Playlist not found"
      });
    }

    const { addr, start, end } = req.body;

    if (
      (start && !end)
      ||
      (!start && end)
    ) {
      return res.status(400).json({
        error: "You need to specify begin AND end of session"
      });
    }
    if (start && end) {
      const startSession = new Date(start);
      const endSession = new Date(end);
      if (isNaN(startSession) || isNaN(endSession)){
        return res.status(400).json({
          error: "Invalide start or end session"
        });
      }
      await updatePlaylistSession(playlist_id, startSession, endSession);
    }
    if (!start && !end){
      await updatePlaylistSession(playlist_id, null, null);
    }

    if (addr) {
      const { latitude, longitude } = await getLocalisationOfAddress(addr);
      if (!latitude || !longitude){
        return res.status(400).json({
          error: "Address not found"
        });
      }
      await updatePlaylistLocation(playlist_id, latitude.toString(), longitude.toString());
    } else {
      await updatePlaylistLocation(playlist_id, null, null);
    }

    return res.status(200).json(playlist);
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

router.post("/:playlist_id/edit", async(req, res) => {
  console.info("User is trying to edit playlist order")
  try {
    const { playlist_id } = req.params;
    const { trackId, trackIdAfter } = req.body;
    const playlist = await getPlaylistById(playlist_id);
    if (!playlist){
      return res.status(400).json({
        error: "Playlist not found"
      }); 
    }
    if (playlist.type === PlaylistTypeEnum.PRIVATE){
      const isUserMemberOfPlaylist = await isUserAlreadyJoinedPlaylist(playlist_id, res?.locals?.user?.id);
      if (!isUserMemberOfPlaylist){
        return res.status(400).json({
          error: "Playlist is private and user is not member"
        });
      }
    }
    const track = await getTrackById(trackId);
    if (!track){
      return res.status(400).json({
        error: "Track not found"
      });
    }
    const newTrackList = reorderTracks(
      await getAllTrackToUpdatePosition(playlist_id, trackId),
      trackIdAfter,
      track,
    );
    let position = 1;
    for (const i in newTrackList){
      await updateTrackPosition(newTrackList[i]?.id, position);
      position++;
    }
    return res.status(200).json(await getAllTrackOfPlaylistOrderByPosition(playlist_id))
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

const ORDER_TRACKS_PLAYLIST_ENUM = {
  VOTE: "VOTE",
  POSITION: "POSITION",
};

router.get("/:playlist_id/track", async(req, res) => {
  console.log("User", res.locals?.user?.id, "getting all tracks of a playlist");
  try {
    const { playlist_id } = req.params;
    const playlist = await getPlaylistById(playlist_id);
    if (!playlist){
      return res.status(400).json({
        error: "Playlist not found"
      }); 
    }
    return res.status(200).json(
      playlist?.orderType === ORDER_TRACKS_PLAYLIST_ENUM.POSITION
      ? await getAllTrackOfPlaylistOrderByPosition(playlist_id)
      : await getAllTrackOfPlaylist(playlist_id)
    ); 
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    }); 
  }
});

router.post("/:playlist_id", async(req, res) => {
  console.log("User", res.locals?.user?.id, "adding music to playlist");
  try {
    const { trackId } = req.body;
    const { playlist_id } = req.params;
    if (!trackId || !playlist_id){
      return res.status(400).json({
        error: "Missing argument trackId or playlist_id"
      });
    }
    const playlist = await getPlaylistById(playlist_id);
    if (!playlist){
      return res.status(400).json({
        error: "Playlist not found"
      });
    }
    const numberOfTracks = await getNumberOfTracksInPlaylist(playlist_id);
    if (numberOfTracks >= 50){
      return res.status(400).json({
        error: "There is already 50 unplayed track in this playlist"
      });
    }
    const deezerTrack = await fetch(`https://api.deezer.com/track/${trackId}`);
    if (deezerTrack?.status !== 200){
      console.error(await deezerTracl.json());
      return res.status(400).json({
        error: "TrackId not found"
      });
    }
    const track = (await deezerTrack.json());
    const addedTrack = await prisma.trackPlaylist.create({
      data: {
        trackId: trackId,
        trackTitle: track?.title, 
        trackPreview: track?.preview, 
        albumCover: track?.album?.cover,
        position: await getTrackDefaultPosition(playlist_id),
        user: {
          connect: {
            id: res.locals?.user?.id
          }
        },
        playlist: {
          connect: {
            id: playlist_id,
          }
        },
      },
      select: {
        id: true,
        trackId: true,
        trackPreview: true,
        albumCover: true,
        position: true,
        user: {
          select: {
            id: true,
            email: true,
          }
        }
      }
    });
    return res.status(201).json(addedTrack); 
  } catch (e){
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    }); 
  }
});

router.get("/", async (req, res) => {
  console.info("User is reading all playlist");
  try {
    const { skip, take } = req.query;
    if (
      (skip && isNaN(skip))
      || (take && isNaN(take))
    ){
      return res.status(400).json({
        error: "skip and take query params should be parseable to Int"
      });
    }
    const allPlaylists = await getAllPlaylistByUserId(skip, take, res?.locals?.user?.id);
    return res.status(200).json(allPlaylists); 
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    }); 
  }
});

router.post("/", async(req, res) => {
  console.info("User is creating playlist");
  try {
    const { name, type, password, orderType } = req.body;
    if (!name || !type){
      return res.status(400).json({
        error: "Missing argument"
      });
    }
    if (!orderType || !Object.keys(ORDER_TRACKS_PLAYLIST_ENUM).includes(orderType)){
      return res.status(400).json({
        error: "Missing or unknow order type"
      });
    }
    if (type === PlaylistTypeEnum.PRIVATE && !password){
      return res.status(400).json({
        error: "Missing argument"
      });
    }
    if (!Object.keys(PlaylistTypeEnum).includes(type)){
      return res.status(400).json({
        error: "Unknow playlist type",
      });
    }
    const hashedPassowrd = password
      ? await bcrypt.hash(password, 7) 
      : undefined;
    const newPlaylist = await prisma.playlist.create({
      data: {
        name: name,
        type: type,
        password: hashedPassowrd,
        orderType: orderType,
        user: {
          connect: {
            id: res.locals?.user?.id
          }
        }
      },
      select: {
        id: true,
        name: true,
        createdAt: true,
        updatedAt: true,
        type: true,
        orderType: true,
        user: {
          select: {
            id: true,
            email: true,
          }
        }
      }
    });
    await createMember(res?.locals?.user?.id, newPlaylist?.id);
    return res.status(201).json(newPlaylist);
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

router.post("/:playlist_id/join", async (req, res) => {
  console.log("User is trying to join playlist");
  try {
    const { playlist_id } = req.params;
    const { password } = req.body;
    const playlist = await getPlaylistById(playlist_id);
    if (!playlist){
      return res.status(400).json({
        error: "Playlist not found"
      });
    }
    if (await isUserAlreadyJoinedPlaylist(playlist_id, res?.locals?.user?.id)){
      return res.status(200).json(playlist);
    }
    if (playlist.type === PlaylistTypeEnum.PRIVATE){
      const invitation = await checkIfUserIsInvitedToPlaylist(res?.locals?.user?.id);
      if (!password && !invitation){
        return res.status(400).json({
          error: "Missing parameter password for private playlist or invitation not found"
        });
      }
      if (password){
        if (!await bcrypt.compare(password, playlist.password)){
          return res.status(400).json({
            error: "Invalid password"
          })
        }
      }
    }
    await deleteInvitation(res?.locals?.user?.id, playlist_id);
    await createMember(res?.locals?.user?.id, playlist_id);
    return res.status(200).json(playlist);
  } catch (e){
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

router.post("/:playlist_id/vote/:track_id", async(req, res) => {
  console.log("User is voting for next playlist");
  try {
    const { playlist_id, track_id } = req.params;
    const { ip_addr } = req.body;
    const user = await findUserById(res?.locals?.user?.id);
    if (!user){
      return res.status(400).json({
        error: "User not found"
      });
    }
    const playlist = await getPlaylistById(playlist_id);
    if (!playlist){
      return res.status(400).json({
        error: "Playlist not found"
      });
    }
    const track = await getTrackById(track_id);
    if (!track){
      return res.status(400).json({
        error: "Track not found"
      });
    }
    const checkIsUserAlreadyVoted = await findUserVoteByPlaylistId(playlist?.id, user?.id, track?.id);
    if ((checkIsUserAlreadyVoted ?? []).length > 0){
      return res.status(400).json({
        error: "User already voted"
      });
    }
    if (playlist.lat && playlist.lon){
      if (!ip_addr){
        return res.status(400).json({
          error: "Playlist required geolocalisation and ip addr is not received"
        });
      }
      const userIpAddr = getLocationFromIpAddr(ip_addr);
      if (!userIpAddr){
        return res.status(400).json({
          error: "User IP addr error"
        });
      }
      const distanceWithUser = computeDistanceBetweenTwoLocations(
        { latitude: playlist.lat, longitude: playlist.long },
        userIpAddr,
      );
      if (distanceWithUser >= 10){
        return res.status(400).json({
          error: "User need to be near playlist location to vote"
        });
      }
    }
    if (playlist.startSession){
      if (new Date(playlist.startSession).getTime() > new Date().getTime()) {
        return res.status(400).json({
          error: "Vote for this playlist is not already open"
        });
      }
    }
    if (playlist.endSession){
      if (new Date(playlist.endSession).getTime() < new Date().getTime()) {
        return res.status(400).json({
          error: "Vote for this playlist is already close"
        });
      }
    }
    const newVote = await createUserVote(playlist?.id, user?.id, track?.id, track?.voteCount);
    return res.status(201).json(newVote);
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

router.post("/:playlist_id/invitations", async(req, res) => {
  try {
    const { playlist_id } = req.params;
    const { userId } = req.body;
    if (!playlist_id || !userId){
      return res.status(400).json({
        error: "Missing argument playlist id or user id"
      });
    }
    const playlist = await getPlaylistById(playlist_id);
    if (!playlist){
      return res.status(400).json({
        error: "Unknow playlist"
      });
    }
    const userToInvite = await findUserById(userId);
    if (!userToInvite){
      return res.status(400).json({
        error: "Unknow user"
      });
    }
    const invitation = await createInvitation(playlist_id, res?.locals?.user?.id, userId);
    return res.status(201).json(invitation);
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

router.get("/:playlist_id/members", async(req, res) => {
  try {
    const { playlist_id } = req.params;
    const playlist = await getPlaylistById(playlist_id);
    if (!playlist){
      return res.status(400).json({
        error: "Unknow playlist"
      });
    }
    return res.status(200).json(
      await getAllPlaylistMembers(playlist_id)
    );
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

export const playlistRouter = router;
