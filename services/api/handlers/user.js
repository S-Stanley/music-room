import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const findUserById = async(user_id) => {
  return await prisma.user.findUnique({
    where: {
      id: user_id,
    }
  })
};
