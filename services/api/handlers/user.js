import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const findUserById = async(user_id) => {
  return await prisma.user.findUnique({
    where: {
      id: user_id,
    }
  })
};

export const getAllUsers = async(take, skip, userId) => {
  return await prisma.user.findMany({
    skip: skip,
    take: take,
    orderBy: {
      createdAt: "asc"
    },
    where: {
      id: {
        not: userId
      }
    }
  });
};
