import express from "express";
import { PrismaClient } from '@prisma/client';

const router = express.Router();
const prisma = new PrismaClient();

const PlaylistTypeEnum = ["PUBLIC", "PRIVATE"];

router.post("/", async(req, res) => {
  try {
    const { name, type } = req.body;
    if (!name || !type){
      return res.status(400).json({
        error: "Missing argument"
      });
    }
    console.log(Object.keys(PlaylistTypeEnum))
    if (!PlaylistTypeEnum.includes(type)){
      return res.status(400).json({
        error: "Unknow playlist type",
      });
    }
    console.log(name, type);
    const newPlaylist = await prisma.playlist.create({
      data: {
        name: name,
        type: type,
        user: {
          connect: {
            id: res.locals?.user?.id
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

export const playlistRouter = router;;
