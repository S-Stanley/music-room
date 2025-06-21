/*
  Warnings:

  - You are about to drop the column `invited_by` on the `FriendRequest` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[invited_user_id]` on the table `FriendRequest` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `invited_user_id` to the `FriendRequest` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "FriendRequest" DROP CONSTRAINT "FriendRequest_invited_by_fkey";

-- DropIndex
DROP INDEX "FriendRequest_invited_by_key";

-- AlterTable
ALTER TABLE "FriendRequest" DROP COLUMN "invited_by",
ADD COLUMN     "invited_user_id" UUID NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "FriendRequest_invited_user_id_key" ON "FriendRequest"("invited_user_id");

-- AddForeignKey
ALTER TABLE "FriendRequest" ADD CONSTRAINT "FriendRequest_invited_user_id_fkey" FOREIGN KEY ("invited_user_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
