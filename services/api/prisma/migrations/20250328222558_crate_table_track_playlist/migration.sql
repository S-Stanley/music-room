-- CreateTable
CREATE TABLE "TrackPlaylist" (
    "id" UUID NOT NULL,
    "tracK_id" TEXT NOT NULL,
    "track_title" TEXT NOT NULL,
    "track_preview" TEXT NOT NULL,
    "album_cover" TEXT NOT NULL,
    "user_id" UUID NOT NULL,
    "playlist_id" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TrackPlaylist_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "TrackPlaylist" ADD CONSTRAINT "TrackPlaylist_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TrackPlaylist" ADD CONSTRAINT "TrackPlaylist_playlist_id_fkey" FOREIGN KEY ("playlist_id") REFERENCES "Playlist"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
