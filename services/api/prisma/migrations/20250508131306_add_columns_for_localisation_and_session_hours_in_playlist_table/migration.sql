-- AlterTable
ALTER TABLE "Playlist" ADD COLUMN     "endSession" TIMESTAMP(3),
ADD COLUMN     "lat" TEXT,
ADD COLUMN     "lon" TEXT,
ADD COLUMN     "startSession" TIMESTAMP(3);
