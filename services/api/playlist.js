import express from "express";
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const router = express.Router();
const prisma = new PrismaClient();

const PlaylistTypeEnum = {
  PUBLIC: "PUBLIC",
  PRIVATE: "PRIVATE",
};

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
