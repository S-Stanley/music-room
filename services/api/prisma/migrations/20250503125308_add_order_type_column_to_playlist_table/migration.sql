-- CreateEnum
CREATE TYPE "PlaylistOrderType" AS ENUM ('VOTE', 'POSITION');

-- AlterTable
ALTER TABLE "Playlist" ADD COLUMN     "order_type" "PlaylistOrderType" NOT NULL DEFAULT 'VOTE';
