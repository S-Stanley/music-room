/*
  Warnings:

  - A unique constraint covering the columns `[friend_id]` on the table `Friend` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `friend_id` to the `Friend` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Friend" ADD COLUMN     "friend_id" UUID NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "Friend_friend_id_key" ON "Friend"("friend_id");

-- AddForeignKey
ALTER TABLE "Friend" ADD CONSTRAINT "Friend_friend_id_fkey" FOREIGN KEY ("friend_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
