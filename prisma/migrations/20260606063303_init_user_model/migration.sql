-- CreateEnum
CREATE TYPE "Role" AS ENUM ('PETANI', 'ADMIN');

-- CreateEnum
CREATE TYPE "StatusKYC" AS ENUM ('BELUM_VERIFIKASI', 'PENDING', 'TERVERIFIKASI', 'DITOLAK');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "nama" TEXT NOT NULL,
    "nomor_hp" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'PETANI',
    "status_kyc" "StatusKYC" NOT NULL DEFAULT 'BELUM_VERIFIKASI',
    "tanggal_daftar" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_nomor_hp_key" ON "users"("nomor_hp");
