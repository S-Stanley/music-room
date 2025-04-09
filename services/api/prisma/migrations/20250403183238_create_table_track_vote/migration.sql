-- CreateTable
CREATE TABLE "TrackVote" (
    "id" UUID NOT NULL,
    "playlist_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TrackVote_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "TrackVote" ADD CONSTRAINT "TrackVote_playlist_id_fkey" FOREIGN KEY ("playlist_id") REFERENCES "Playlist"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TrackVote" ADD CONSTRAINT "TrackVote_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
