/*
  Warnings:

  - Added the required column `position` to the `TrackPlaylist` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "TrackPlaylist" ADD COLUMN     "position" INTEGER NOT NULL;
