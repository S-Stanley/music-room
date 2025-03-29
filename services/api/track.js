import express from "express";
import { PrismaClient } from '@prisma/client';

const router = express.Router();
const prisma = new PrismaClient();

const getPlaylistById = async(playlist_id) => {
  const playlist = await prisma.playlist.findUnique(
    {
      where: { 
        id: playlist_id
      }
    }
  );
  return (playlist);
}

const getAllTrackOfPlaylist = async(playlist_id) => {
  return await prisma.trackPlaylist.findMany({
    where: {
      playlistId: playlist_id,
    }
  });
};

router.get("/:playlist_id", async(req, res) => {
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

router.get("/search", async(req, res) => {
  try {
    const { q } = req.query;
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

export const trackRouter = router;;
