-- CreateEnum
CREATE TYPE "MusicType" AS ENUM ('HIP_HOP', 'HOUSE', 'REGGEA', 'RNB');

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "musicPreferences" "MusicType";
