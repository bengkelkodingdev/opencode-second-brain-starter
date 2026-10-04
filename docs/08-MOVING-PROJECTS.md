# 08 - Memindahkan Proyek atau Repository

Memindahkan repository, mengganti nama folder, atau memindahkan vault dapat membuat `code_paths` tidak valid. Lakukan perubahan secara terencana dan verifikasi dari lingkungan tempat OpenCode berjalan.

## Skenario yang berbeda

Ada tiga jenis pemindahan:

1. repository source code berpindah lokasi;
2. folder proyek di dalam vault berganti nama atau lokasi;
3. seluruh vault berpindah lokasi atau komputer.

Jangan mencampur ketiganya. Ubah satu lapisan, verifikasi, lalu lanjutkan.

## Memindahkan source code

Contoh path lama:

```text
/home/ayu/code-lama/toko-api
```

Path baru:

```text
/home/ayu/code/toko-api
```

Langkah aman:

1. selesaikan atau hentikan proses build, dev server, dan editor yang memakai repository;
2. pastikan perubahan source code sudah tersimpan;
3. catat remote Git dan branch aktif jika diperlukan;
4. pindahkan repository menggunakan tool filesystem yang sesuai;
5. masuk ke direktori baru dan verifikasi source code;
6. jalankan test atau command dasar yang relevan;
7. jalankan `/brain-fix-paths` dari OpenCode untuk meninjau usulan, atau perbarui `code_paths` menjadi path absolut baru secara manual;
8. cari referensi path lama di catatan proyek;
9. mulai OpenCode dari lokasi baru dan verifikasi deteksi;
10. hapus lokasi lama hanya setelah semuanya terkonfirmasi.

Perubahan metadata:

```yaml
# Sebelum
code_paths:
  - /home/ayu/code-lama/toko-api

# Sesudah
code_paths:
  - /home/ayu/code/toko-api
```

Jangan mempertahankan kedua path hanya untuk kompatibilitas jika lokasi lama sudah tidak ada. Path mati menimbulkan ambiguitas dan menyulitkan diagnosis.

## Mengganti nama repository

Mengubah nama direktori juga mengubah path absolut.

```text
/home/ayu/code/backend
```

menjadi:

```text
/home/ayu/code/toko-api
```

Perbarui `code_paths`, dokumentasi command lokal, workspace editor, dan konfigurasi lain yang memang mereferensikan path tersebut. Nama proyek logis di vault tidak harus berubah jika produknya tetap sama.

## Memindahkan folder proyek di dalam vault

Folder proyek harus tetap berada di tingkat teratas vault kecuali format starter menyatakan lain.

Sebelum mengganti nama:

1. tutup sesi OpenCode yang sedang menulis catatan;
2. buat backup vault;
3. periksa tautan Obsidian yang menuju folder tersebut;
4. ganti nama melalui Obsidian jika ingin Obsidian membantu memperbarui internal link;
5. verifikasi struktur yang diharapkan starter;
6. mulai sesi baru dari source code dan uji deteksi.

Mengganti nama folder vault tidak memindahkan source code dan tidak mengubah `code_paths` selama lokasi repository tetap sama.

## Memindahkan seluruh vault

Contoh Linux:

```text
Lama: /home/ayu/Documents/Second Brain
Baru: /home/ayu/Notes/Second Brain
```

Setelah memindahkan, lakukan migrasi instalasi starter berikut:

1. buka lokasi baru sebagai vault di Obsidian;
2. pastikan semua catatan tampil;
3. dari repository starter, jalankan `./uninstall.sh`; perintah ini melepas konfigurasi path lama tanpa menghapus catatan, Inbox, atau template vault;
4. pasang kembali starter ke path baru:

```bash
SECOND_BRAIN_NAME="Ayu" \
SECOND_BRAIN_VAULT="/home/ayu/Notes/Second Brain" \
./install.sh
```

5. jika konfigurasi OpenCode sebelumnya tidak dikelola installer, hapus permission path lama dan tambahkan permission path baru secara manual;
6. restart OpenCode;
7. uji satu proyek;
8. pastikan catatan baru ditulis ke lokasi baru, bukan membuat vault kedua di lokasi lama;
9. simpan backup hingga verifikasi selesai.

Jangan menjalankan `install.sh` langsung sebelum uninstall karena manifest instalasi lama memang mencegah instalasi ganda.

## Memindahkan vault Windows

Jika vault berpindah dari:

```text
C:\Users\Ayu\Documents\Second Brain
```

ke:

```text
D:\Notes\Second Brain
```

path WSL berubah dari:

```text
/mnt/c/Users/Ayu/Documents/Second Brain
```

menjadi:

```text
/mnt/d/Notes/Second Brain
```

Perbarui konfigurasi yang dibaca OpenCode dengan format WSL. Obsidian native membuka path `D:\Notes\Second Brain`.

## Pindah ke komputer baru

Path absolut mungkin berubah walaupun nama pengguna terlihat sama.

Urutan yang disarankan:

1. backup vault di komputer lama;
2. backup atau push source code melalui mekanisme yang sesuai;
3. siapkan komputer baru;
4. instal Obsidian;
5. salin atau sinkronkan vault;
6. buka vault dan verifikasi catatan;
7. instal serta autentikasi OpenCode secara terpisah;
8. clone source code di luar vault;
9. tambahkan path absolut komputer baru ke setiap `code_paths`; pertahankan path komputer lama jika masih dipakai;
10. pasang starter sesuai versi yang digunakan;
11. uji deteksi proyek satu per satu.

Jangan menyalin credential mentah melalui vault. Autentikasi ulang lebih aman.

## Verifikasi path

Di repository baru:

```bash
pwd
```

Periksa direktori:

```bash
ls "/path/absolut/repository"
```

Periksa vault:

```bash
ls "/path/absolut/vault"
```

Gunakan tanda kutip untuk path dengan spasi.

## Checklist

- [ ] Backup dibuat sebelum pemindahan.
- [ ] Proses yang menulis file dihentikan.
- [ ] `code_paths` diperbarui ke path absolut baru.
- [ ] Referensi path lama diperiksa.
- [ ] Format WSL digunakan pada Windows.
- [ ] Obsidian membuka vault baru.
- [ ] OpenCode diuji dari source code baru.
- [ ] Lokasi lama belum dihapus sebelum verifikasi.

Berikutnya: [09 - Backup, Sinkronisasi, dan Keamanan](09-BACKUP-SYNC-SECURITY.md).
