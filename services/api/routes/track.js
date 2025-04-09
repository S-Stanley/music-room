import express from "express";
import { PrismaClient } from '@prisma/client';

const router = express.Router();
const prisma = new PrismaClient();

import {
  getAllTrackOfPlaylist,
  getTrackById,
  setTrackAsPlayed,
} from "../handlers/track.js";

router.get("/search", async(req, res) => {
  try {
    const { q } = req.query;
    console.log(req.query);
  console.info("User in searching a track with:", q);
    if (!q){
      return res.status(400).json({
        error: "Search cannot be empty"
      });
    }
    const fetchDeezerAPI = await fetch(`https://api.deezer.com/search?q=${q}`);
    if (fetchDeezerAPI?.status !== 200){
      console.error(await fetchDeezerAPI.json());
      return res.status(500).json({
        error: "Error on our side..."
      });
    }
    return res.status(200).json((await fetchDeezerAPI.json())?.data); 
  } catch (e){
    console.error(e); 
    return res.status(500).json({
      error: "Server error"
    }); 
  }
});

router.patch("/:track_id/played", async(req, res) => {
  try {
    const { track_id } = req.params;
    const track = await getTrackById(track_id);
    if (!track){
      return res.status(400).json({
        error: "Track not found"
      });
    }
    if (!track?.alreadyPlayed){
      await setTrackAsPlayed(track?.id);
    }
    return res.status(200).json({
      updated: true,
    }); 
  } catch (e) {
    console.error(e);
    return res.status(500).json({
      error: "Server error"
    });
  }
});

export const trackRouter = router;;
