/*
  Warnings:

  - The values [PENDING,TERVERIFIKASI] on the enum `StatusKYC` will be removed. If these variants are still used in the database, this will fail.
  - You are about to drop the column `nama` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `tanggal_daftar` on the `users` table. All the data in the column will be lost.
  - Added the required column `updated_at` to the `users` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "StatusListing" AS ENUM ('DRAFT', 'AKTIF', 'DIPESAN', 'DISETOR', 'SELESAI', 'DIBATALKAN');

-- CreateEnum
CREATE TYPE "MetodePengantaran" AS ENUM ('ANTAR_SENDIRI', 'DIJEMPUT_PLATFORM');

-- CreateEnum
CREATE TYPE "StatusTiket" AS ENUM ('MENUNGGU_JADWAL', 'DIJADWALKAN', 'DALAM_PENGIRIMAN', 'DITERIMA_GUDANG', 'QC_SELESAI', 'MENUNGGU_VERIFIKASI', 'DIBAYARKAN', 'SELESAI', 'DIBATALKAN');

-- CreateEnum
CREATE TYPE "GradeKualitas" AS ENUM ('A', 'B', 'C', 'D');

-- CreateEnum
CREATE TYPE "TipeTransaksiWallet" AS ENUM ('KREDIT', 'DEBIT');

-- CreateEnum
CREATE TYPE "StatusWithdrawal" AS ENUM ('PENDING', 'DIPROSES', 'BERHASIL', 'GAGAL');

-- CreateEnum
CREATE TYPE "TipeNotifikasi" AS ENUM ('KYC_DISETUJUI', 'KYC_DITOLAK', 'TIKET_STATUS_BERUBAH', 'PEMBAYARAN_MASUK', 'WITHDRAWAL_DIPROSES', 'WITHDRAWAL_BERHASIL', 'WITHDRAWAL_GAGAL', 'HARGA_BERUBAH', 'PENGUMUMAN');

-- AlterEnum
ALTER TYPE "Role" ADD VALUE 'GUDANG';

-- AlterEnum
BEGIN;
CREATE TYPE "StatusKYC_new" AS ENUM ('BELUM_VERIFIKASI', 'MENUNGGU_REVIEW', 'DISETUJUI', 'DITOLAK');
ALTER TABLE "public"."users" ALTER COLUMN "status_kyc" DROP DEFAULT;
ALTER TABLE "users" ALTER COLUMN "status_kyc" TYPE "StatusKYC_new" USING ("status_kyc"::text::"StatusKYC_new");
ALTER TYPE "StatusKYC" RENAME TO "StatusKYC_old";
ALTER TYPE "StatusKYC_new" RENAME TO "StatusKYC";
DROP TYPE "public"."StatusKYC_old";
ALTER TABLE "users" ALTER COLUMN "status_kyc" SET DEFAULT 'BELUM_VERIFIKASI';
COMMIT;

-- AlterTable
ALTER TABLE "users" DROP COLUMN "nama",
DROP COLUMN "tanggal_daftar",
ADD COLUMN     "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL;

-- CreateTable
CREATE TABLE "user_profiles" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "nama_lengkap" TEXT NOT NULL,
    "nik" TEXT,
    "alamat" TEXT,
    "kota" TEXT,
    "provinsi" TEXT,
    "foto_profil_url" TEXT,
    "foto_ktp_url" TEXT,
    "foto_selfie_url" TEXT,
    "farm_lat" DECIMAL(10,8),
    "farm_lng" DECIMAL(11,8),
    "catatan_kyc" TEXT,
    "reviewed_at" TIMESTAMP(3),
    "reviewed_by" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bank_accounts" (
    "id" TEXT NOT NULL,
    "profile_id" TEXT NOT NULL,
    "nama_bank" TEXT NOT NULL,
    "nomor_rekening" TEXT NOT NULL,
    "nama_pemilik" TEXT NOT NULL,
    "is_default" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "bank_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "komoditas" (
    "id" TEXT NOT NULL,
    "nama" TEXT NOT NULL,
    "kategori" TEXT NOT NULL,
    "satuan" TEXT NOT NULL DEFAULT 'kg',
    "foto_url" TEXT,
    "is_aktif" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "komoditas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "varietas" (
    "id" TEXT NOT NULL,
    "komoditas_id" TEXT NOT NULL,
    "nama" TEXT NOT NULL,
    "is_aktif" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "varietas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "harga_harian" (
    "id" TEXT NOT NULL,
    "komoditas_id" TEXT NOT NULL,
    "varietas_id" TEXT,
    "wilayah" TEXT NOT NULL,
    "harga_per_kg" DECIMAL(12,2) NOT NULL,
    "tanggal_berlaku" DATE NOT NULL,
    "is_aktif" BOOLEAN NOT NULL DEFAULT true,
    "updated_by" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "harga_harian_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "log_harga" (
    "id" TEXT NOT NULL,
    "harga_harian_id" TEXT NOT NULL,
    "harga_lama" DECIMAL(12,2) NOT NULL,
    "harga_baru" DECIMAL(12,2) NOT NULL,
    "changed_by" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "log_harga_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "grade_config" (
    "id" TEXT NOT NULL,
    "grade" "GradeKualitas" NOT NULL,
    "faktor" DECIMAL(5,4) NOT NULL,
    "deskripsi" TEXT,
    "is_aktif" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "grade_config_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "listings" (
    "id" TEXT NOT NULL,
    "petani_id" TEXT NOT NULL,
    "komoditas_id" TEXT NOT NULL,
    "varietas_id" TEXT,
    "estimasi_qty_kg" DECIMAL(10,2) NOT NULL,
    "foto_urls" TEXT[],
    "tanggal_panen" DATE NOT NULL,
    "catatan" TEXT,
    "status" "StatusListing" NOT NULL DEFAULT 'DRAFT',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "listings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tikets" (
    "id" TEXT NOT NULL,
    "kode_tiket" TEXT NOT NULL,
    "listing_id" TEXT NOT NULL,
    "petani_id" TEXT NOT NULL,
    "harga_per_kg_locked" DECIMAL(12,2) NOT NULL,
    "estimasi_pembayaran" DECIMAL(14,2) NOT NULL,
    "metode_pengantaran" "MetodePengantaran" NOT NULL,
    "tanggal_pengantaran" DATE NOT NULL,
    "status" "StatusTiket" NOT NULL DEFAULT 'MENUNGGU_JADWAL',
    "catatan_pembatalan" TEXT,
    "dijadwalkan_oleh" TEXT,
    "dijadwalkan_at" TIMESTAMP(3),
    "diverifikasi_oleh" TEXT,
    "diverifikasi_at" TIMESTAMP(3),
    "catatan_verifikasi" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "tikets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tiket_status_logs" (
    "id" TEXT NOT NULL,
    "tiket_id" TEXT NOT NULL,
    "status_lama" "StatusTiket",
    "status_baru" "StatusTiket" NOT NULL,
    "catatan" TEXT,
    "changed_by" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tiket_status_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "qc_records" (
    "id" TEXT NOT NULL,
    "tiket_id" TEXT NOT NULL,
    "berat_aktual_kg" DECIMAL(10,2) NOT NULL,
    "grade" "GradeKualitas" NOT NULL,
    "foto_urls" TEXT[],
    "catatan" TEXT,
    "pembayaran_final" DECIMAL(14,2) NOT NULL,
    "faktor_grade" DECIMAL(5,4) NOT NULL,
    "diterima_oleh" TEXT NOT NULL,
    "is_ditolak" BOOLEAN NOT NULL DEFAULT false,
    "alasan_penolakan" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "qc_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "wallets" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "saldo_available" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "saldo_pending" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "total_earned" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "wallets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "transaksi_wallet" (
    "id" TEXT NOT NULL,
    "wallet_id" TEXT NOT NULL,
    "tipe" "TipeTransaksiWallet" NOT NULL,
    "nominal" DECIMAL(14,2) NOT NULL,
    "saldo_sebelum" DECIMAL(14,2) NOT NULL,
    "saldo_sesudah" DECIMAL(14,2) NOT NULL,
    "keterangan" TEXT,
    "referensi_tipe" TEXT,
    "referensi_id" TEXT,
    "tiket_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "transaksi_wallet_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "withdrawals" (
    "id" TEXT NOT NULL,
    "wallet_id" TEXT NOT NULL,
    "nominal" DECIMAL(14,2) NOT NULL,
    "bank_account_id" TEXT NOT NULL,
    "status" "StatusWithdrawal" NOT NULL DEFAULT 'PENDING',
    "catatan_admin" TEXT,
    "approved_by" TEXT,
    "approved_at" TIMESTAMP(3),
    "pg_reference" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "withdrawals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifikasi" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "tipe" "TipeNotifikasi" NOT NULL,
    "judul" TEXT NOT NULL,
    "pesan" TEXT NOT NULL,
    "referensi" TEXT,
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifikasi_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" TEXT NOT NULL,
    "user_id" TEXT,
    "aksi" TEXT NOT NULL,
    "entitas_tipe" TEXT NOT NULL,
    "entitas_id" TEXT NOT NULL,
    "nilai_lama" JSONB,
    "nilai_baru" JSONB,
    "ip_address" TEXT,
    "user_agent" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "user_profiles_user_id_key" ON "user_profiles"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "komoditas_nama_key" ON "komoditas"("nama");

-- CreateIndex
CREATE UNIQUE INDEX "varietas_komoditas_id_nama_key" ON "varietas"("komoditas_id", "nama");

-- CreateIndex
CREATE UNIQUE INDEX "harga_harian_komoditas_id_varietas_id_wilayah_tanggal_berla_key" ON "harga_harian"("komoditas_id", "varietas_id", "wilayah", "tanggal_berlaku");

-- CreateIndex
CREATE UNIQUE INDEX "grade_config_grade_key" ON "grade_config"("grade");

-- CreateIndex
CREATE UNIQUE INDEX "tikets_kode_tiket_key" ON "tikets"("kode_tiket");

-- CreateIndex
CREATE UNIQUE INDEX "qc_records_tiket_id_key" ON "qc_records"("tiket_id");

-- CreateIndex
CREATE UNIQUE INDEX "wallets_user_id_key" ON "wallets"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "transaksi_wallet_tiket_id_key" ON "transaksi_wallet"("tiket_id");

-- CreateIndex
CREATE INDEX "notifikasi_user_id_is_read_idx" ON "notifikasi"("user_id", "is_read");

-- CreateIndex
CREATE INDEX "audit_logs_entitas_tipe_entitas_id_idx" ON "audit_logs"("entitas_tipe", "entitas_id");

-- CreateIndex
CREATE INDEX "audit_logs_user_id_idx" ON "audit_logs"("user_id");

-- AddForeignKey
ALTER TABLE "user_profiles" ADD CONSTRAINT "user_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_profiles" ADD CONSTRAINT "user_profiles_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bank_accounts" ADD CONSTRAINT "bank_accounts_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "user_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "varietas" ADD CONSTRAINT "varietas_komoditas_id_fkey" FOREIGN KEY ("komoditas_id") REFERENCES "komoditas"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "harga_harian" ADD CONSTRAINT "harga_harian_komoditas_id_fkey" FOREIGN KEY ("komoditas_id") REFERENCES "komoditas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "harga_harian" ADD CONSTRAINT "harga_harian_varietas_id_fkey" FOREIGN KEY ("varietas_id") REFERENCES "varietas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "harga_harian" ADD CONSTRAINT "harga_harian_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "log_harga" ADD CONSTRAINT "log_harga_harga_harian_id_fkey" FOREIGN KEY ("harga_harian_id") REFERENCES "harga_harian"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listings" ADD CONSTRAINT "listings_petani_id_fkey" FOREIGN KEY ("petani_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listings" ADD CONSTRAINT "listings_komoditas_id_fkey" FOREIGN KEY ("komoditas_id") REFERENCES "komoditas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listings" ADD CONSTRAINT "listings_varietas_id_fkey" FOREIGN KEY ("varietas_id") REFERENCES "varietas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tikets" ADD CONSTRAINT "tikets_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "listings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tikets" ADD CONSTRAINT "tikets_petani_id_fkey" FOREIGN KEY ("petani_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tikets" ADD CONSTRAINT "tikets_dijadwalkan_oleh_fkey" FOREIGN KEY ("dijadwalkan_oleh") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tikets" ADD CONSTRAINT "tikets_diverifikasi_oleh_fkey" FOREIGN KEY ("diverifikasi_oleh") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tiket_status_logs" ADD CONSTRAINT "tiket_status_logs_tiket_id_fkey" FOREIGN KEY ("tiket_id") REFERENCES "tikets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qc_records" ADD CONSTRAINT "qc_records_tiket_id_fkey" FOREIGN KEY ("tiket_id") REFERENCES "tikets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qc_records" ADD CONSTRAINT "qc_records_diterima_oleh_fkey" FOREIGN KEY ("diterima_oleh") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wallets" ADD CONSTRAINT "wallets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transaksi_wallet" ADD CONSTRAINT "transaksi_wallet_wallet_id_fkey" FOREIGN KEY ("wallet_id") REFERENCES "wallets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transaksi_wallet" ADD CONSTRAINT "transaksi_wallet_tiket_id_fkey" FOREIGN KEY ("tiket_id") REFERENCES "tikets"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "withdrawals" ADD CONSTRAINT "withdrawals_wallet_id_fkey" FOREIGN KEY ("wallet_id") REFERENCES "wallets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "withdrawals" ADD CONSTRAINT "withdrawals_bank_account_id_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "bank_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "withdrawals" ADD CONSTRAINT "withdrawals_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifikasi" ADD CONSTRAINT "notifikasi_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
