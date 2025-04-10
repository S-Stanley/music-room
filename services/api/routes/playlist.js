import express from "express";
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';

import {
  getPlaylistById,
} from "../handlers/playlist.js";
import {
  getTrackDefaultPosition,
  getAllTrackOfPlaylist,
  getTrackById,
} from "../handlers/track.js";
import {
  findUserById
} from "../handlers/user.js"
import {
  findUserVoteByPlaylistId,
  createUserVote,
} from "../handlers/votes.js";

const router = express.Router();
const prisma = new PrismaClient();

const PlaylistTypeEnum = {
  PUBLIC: "PUBLIC",
  PRIVATE: "PRIVATE",
};

const _PAGINATION_MAX_TAKE = 50;

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
      await getAllTrackOfPlaylist(playlist_id)
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
    const allPlaylists = await prisma.playlist.findMany({
      select: {
        id: true,
        name: true,
        type: true,
        user: {
          select: {
            id: true,
            email: true,
          },
        },
      },
      skip: parseInt(skip ?? 0, 10),
      take: (!take || parseInt(take, 10) > _PAGINATION_MAX_TAKE)
        ? _PAGINATION_MAX_TAKE
        : parseInt(take),
    });
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
    const { name, type, password } = req.body;
    if (!name || !type){
      return res.status(400).json({
        error: "Missing argument"
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
        user: {
          select: {
            id: true,
            email: true,
          }
        }
      }
    });
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
    if (playlist.type === PlaylistTypeEnum.PRIVATE){
      if (!password){
        return res.status(400).json({
          error: "Missing parameter password for private playlist"
        });
      }
      if (!await bcrypt.compare(password, playlist.password)){
        return res.status(400).json({
          error: "Invalid password"
        })
      }
    }
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
    console.log(checkIsUserAlreadyVoted)
    if ((checkIsUserAlreadyVoted ?? []).length > 0){
      return res.status(400).json({
        error: "User already voted"
      });
    }
    const newVote = await createUserVote(playlist?.id, user?.id, track?.id);
    return res.status(201).json(newVote);
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

export const playlistRouter = router;
