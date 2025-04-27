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
