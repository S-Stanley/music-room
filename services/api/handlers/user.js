import { PrismaClient } from '@prisma/client';
import {
  generateConfirmationCode
} from "../utils/user.js";

const prisma = new PrismaClient();

export const findUserById = async(user_id) => {
  try {
    return await prisma.user.findUnique({
      where: {
        id: user_id,
      }
    })
  } catch (e) {
    console.error(e);
    return (false);
  }
};

export const findUserByEmail = async(user_email) => {
  const user = await prisma.user.findUnique({
    where: {
      email: user_email,
    }
  });
  if (user?.password){
    user.password = undefined;
  }
  return (user);
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

export const createNewConfirmationCode = async(user_id) => {
  return await prisma.confirmationCode.create({
    data: {
      user: {
        connect: {
          id: user_id,
        }
      },
      code: generateConfirmationCode(),
    }
  });
};

export const isUserEmailValidated = async(user_id) => {
  const code = await prisma.confirmationCode.findUnique({
    where: {
      userId: user_id,
    }
  });
  if (code?.id){
    return (false);
  }
  return (true);
};

export const deleteConfirmationCode = async(user_id) => {
  return await prisma.confirmationCode.delete({
    where: {
      userId: user_id,
    }
  })
};

export const getConfirmationCodeByUserId = async (user_id) => {
  const confirmationCode = await prisma.confirmationCode.findUnique({
    where: {
      userId: user_id,
    }
  })
  return (confirmationCode?.code);
};

export const checkConfirmationCode = async(user_id, input_confirmation_code) => {
  const confirmationCode = await getConfirmationCodeByUserId(user_id);
  if (confirmationCode !== parseInt(input_confirmation_code, 10)){
    return (false);
  };
  await deleteConfirmationCode(user_id);
  return (true);
};

export const createUserWithGoogle = async(user_id, email, token) => {
  const usr = await findUserByEmail(email);
  if (usr){
    return (usr);
  }
  return await prisma.user.create({
    data: {
      email: email,
      token: token,
      name: email.split("@")[0],
    },
    select: {
      id: true,
      email: true,
      name: true,
      token: true,
    }
  });
};

export const createUserWithFacebook = async(email, token) => {
  const usr = await findUserByEmail(email);
  if (usr){
    return (usr);
  }
  return await prisma.user.create({
    data: {
      email: email,
      token: token,
      name: email.split("@")[0],
    },
    select: {
      id: true,
      email: true,
      name: true,
      token: true,
    }
  });
};
