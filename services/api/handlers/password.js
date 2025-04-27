import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

export const deletePasswordChangeRequest = async(user_id) => {
  try {
    await prisma.passwordChange.delete({
      where: {
        userId: user_id,
      },
    })
  } catch (e){
    console.error(e);
    return (null);
  }
};

export const createPasswordChangeRequest = async(user_id, confirmationCode, newPassword) => {
  try {
    const hashedPassword = await bcrypt.hash(newPassword, 7);
    await deletePasswordChangeRequest(user_id);
    return await prisma.passwordChange.create({
      data: {
        userId: user_id,
        code: confirmationCode,
        password: hashedPassword,
      },
    })
  } catch (e) {
    console.error(e);
    return (null);
  }
};

export const findPasswordChangeRequest = async(user_id) => {
  try {
    return await prisma.passwordChange.findUnique({
      where: {
        userId: user_id,
      },
    });
  } catch (e) {
    console.error(e);
    return (null);
  }
};

export const checkUserConfirmationCodeForPasswordChange = async(user_id, confirmationCode) => {
  try {
    const passwordChangeRequest = await findPasswordChangeRequest(user_id);
    return (passwordChangeRequest?.code === confirmationCode)
  } catch (e) {
    console.error(e);
    return (false);
  }
};

export const updateUserPassword = async(user_id) => {
  try {
    const passwordChangeRequest = await findPasswordChangeRequest(user_id)
    await prisma.user.update({
      where: {
        id: user_id,
      },
      data: {
        password: passwordChangeRequest?.password,
      },
    });
    await deletePasswordChangeRequest(user_id);
  } catch (e) {
    console.error(e);
    return (null);
  }
};
