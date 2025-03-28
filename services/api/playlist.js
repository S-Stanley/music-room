import express from "express";
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const router = express.Router();
const prisma = new PrismaClient();

const PlaylistTypeEnum = {
  PUBLIC: "PUBLIC",
  PRIVATE: "PRIVATE",
};

const _PAGINATION_MAX_TAKE = 50;

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

export const playlistRouter = router;;
