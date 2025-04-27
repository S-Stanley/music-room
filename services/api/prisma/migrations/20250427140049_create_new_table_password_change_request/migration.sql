-- CreateTable
CREATE TABLE "PasswordChange" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "password" TEXT NOT NULL,
    "code" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PasswordChange_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "PasswordChange_user_id_key" ON "PasswordChange"("user_id");

-- AddForeignKey
ALTER TABLE "PasswordChange" ADD CONSTRAINT "PasswordChange_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
