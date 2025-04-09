/*
  Warnings:

  - Added the required column `track_id` to the `TrackVote` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "TrackVote" ADD COLUMN     "track_id" UUID NOT NULL;

-- AddForeignKey
ALTER TABLE "TrackVote" ADD CONSTRAINT "TrackVote_track_id_fkey" FOREIGN KEY ("track_id") REFERENCES "TrackPlaylist"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
