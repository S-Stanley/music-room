-- CreateEnum
CREATE TYPE "PlaylistType" AS ENUM ('PRIVATE', 'PUBLIC');

-- CreateTable
CREATE TABLE "Playlist" (
    "id" UUID NOT NULL,
    "type" "PlaylistType" NOT NULL,
    "name" TEXT NOT NULL,
    "user_id" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Playlist_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Playlist" ADD CONSTRAINT "Playlist_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
