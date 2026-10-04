# 10 - Troubleshooting

Gunakan panduan ini dari gejala menuju penyebab. Jangan langsung menghapus konfigurasi atau menjalankan ulang installer sebelum membuat backup dan memahami masalah.

## Pemeriksaan cepat

Kumpulkan fakta berikut:

```text
Sistem operasi:
Lingkungan OpenCode: Linux / WSL / macOS
Path vault menurut Obsidian:
Path vault menurut shell OpenCode:
Current working directory:
Nama proyek yang diharapkan:
Pesan error lengkap:
Perubahan terakhir:
```

Jangan menyertakan API key, token, password, atau data sensitif ketika membagikan informasi diagnosis.

## OpenCode tidak ditemukan

Gejala:

```text
command not found: opencode
```

Langkah:

1. Pastikan instalasi mengikuti [dokumentasi resmi OpenCode](https://opencode.ai/docs).
2. Pastikan terminal baru sudah dibuka setelah instalasi.
3. Pastikan metode instalasi sesuai sistem operasi dan shell.
4. Di Windows, pastikan command dijalankan dalam WSL, bukan PowerShell.
5. Periksa petunjuk PATH pada dokumentasi resmi.
6. Jangan memasang ulang dengan perintah dari tutorial lama.

## Obsidian tidak perlu terbuka

Gejala yang dianggap masalah:

```text
Obsidian tertutup, apakah OpenCode tetap dapat membaca catatan?
```

Jawaban: ya, selama vault tersedia sebagai folder filesystem dan izin akses benar. Obsidian adalah editor untuk file Markdown, bukan server yang harus terus berjalan.

Jika OpenCode tidak dapat membaca saat Obsidian tertutup, periksa path, mount, izin, atau layanan sinkronisasi. Masalahnya bukan karena jendela Obsidian tertutup.

## Vault tidak ditemukan di WSL

Contoh path Windows:

```text
C:\Users\Ayu\Documents\Second Brain
```

Path WSL yang seharusnya:

```text
/mnt/c/Users/Ayu/Documents/Second Brain
```

Uji:

```bash
ls "/mnt/c/Users/Ayu/Documents/Second Brain"
```

Jika gagal:

- periksa ejaan nama pengguna;
- periksa huruf drive;
- periksa kapitalisasi folder;
- pastikan drive ter-mount di WSL;
- pastikan path dengan spasi dikutip;
- pastikan vault tidak sebenarnya berada di OneDrive atau lokasi lain.

Contoh OneDrive dapat terlihat seperti:

```text
C:\Users\Ayu\OneDrive\Documents\Second Brain
```

yang dari WSL menjadi:

```text
/mnt/c/Users/Ayu/OneDrive/Documents/Second Brain
```

Gunakan lokasi aktual, jangan menebak.

## Format path salah di `code_paths`

Gejala:

- proyek tidak terdeteksi;
- OpenCode memilih proyek lain;
- direktori dianggap tidak ada.

Pastikan nilai berupa path absolut.

Benar di WSL:

```yaml
code_paths:
  - /home/ayu/code/toko-api
```

Salah di WSL:

```yaml
code_paths:
  - ~/code/toko-api
  - ../toko-api
  - C:\Users\Ayu\code\toko-api
```

Masuk ke repository dan jalankan:

```bash
pwd
```

Bandingkan hasilnya secara persis dengan `code_paths`.

## Proyek yang salah terdeteksi

Kemungkinan penyebab:

- path yang sama terdaftar pada dua proyek;
- parent directory terlalu luas didaftarkan;
- repository dipindahkan tetapi metadata belum diperbarui;
- sesi dimulai dari direktori yang tidak relevan;
- folder proyek duplikat ada di vault.

Langkah:

1. catat current working directory dengan `pwd`;
2. cari proyek yang memiliki `code_paths` tersebut;
3. pastikan hanya satu proyek yang semestinya cocok;
4. ganti path luas seperti `/home/ayu/code` menjadi repository spesifik;
5. mulai sesi baru dari repository;
6. verifikasi lagi sebelum bekerja.

## Repository ada, tetapi tidak dapat diakses

Periksa:

```bash
ls "/path/absolut/repository"
```

Kemungkinan penyebab:

- typo pada path;
- izin filesystem;
- drive eksternal belum terpasang;
- mount WSL belum tersedia;
- repository telah diganti nama;
- akun pengguna berbeda;
- symbolic link rusak.

Jangan mengubah izin secara luas tanpa memahami implikasi keamanan. Gunakan izin minimum yang dibutuhkan.

## Command `/brain-init`, `/start`, `/capture`, `/done`, atau `/brain-weekly` tidak tersedia

Kemungkinan penyebab:

- starter belum dipasang;
- pemasangan memakai versi berbeda;
- konfigurasi dipasang ke lokasi yang salah;
- OpenCode perlu dimulai ulang;
- format command berubah;
- file starter tidak ada pada distribusi tersebut.

Langkah:

1. periksa isi repository starter versi Anda;
2. baca petunjuk instalasi yang tersedia;
3. periksa lokasi konfigurasi OpenCode menurut dokumentasi resmi;
4. bandingkan file sumber dan file tujuan;
5. mulai ulang OpenCode;
6. jangan membuat command tiruan berdasarkan nama saja.

Panduan ini tidak mengklaim perilaku internal command. Definisi aktual pada instalasi Anda adalah acuan.

## Installer noninteraktif tidak membaca environment variable

Variabel yang diharapkan jika didukung:

```bash
export SECOND_BRAIN_NAME="Ayu"
export SECOND_BRAIN_VAULT="/path/absolut/Second Brain"
```

Periksa:

- apakah versi installer memang mendukung mode noninteraktif;
- apakah variabel diekspor pada shell yang sama;
- apakah path absolut benar;
- apakah tanda kutip digunakan untuk spasi;
- apakah nama variabel tepat;
- apakah installer memiliki parameter tambahan menurut dokumentasinya.

Ganti `SECOND_BRAIN_NAME` dengan nama pengguna, misalnya `Ayu`, bukan nama vault. Environment variable tersebut bukan jaminan perilaku untuk versi lain; gunakan mode yang didokumentasikan oleh versi aktual.

## Catatan tidak muncul di Obsidian

Langkah:

1. pastikan file dibuat di vault yang sedang dibuka, bukan vault lain dengan nama sama;
2. periksa path lengkap file dari filesystem;
3. gunakan refresh atau buka ulang vault;
4. periksa filter pencarian Obsidian;
5. periksa ekstensi file `.md`;
6. periksa apakah sinkronisasi memindahkan atau membuat conflict file.

Kasus umum adalah dua folder bernama `Second Brain` di lokasi berbeda. Bandingkan path absolut, bukan hanya nama vault.

## OpenCode menulis ke vault lama

Ini biasanya terjadi setelah vault dipindahkan tetapi konfigurasi belum diperbarui.

1. Hentikan sesi yang sedang menulis.
2. Backup kedua lokasi.
3. Tentukan vault yang menjadi sumber kebenaran.
4. Dari repository starter, jalankan `./uninstall.sh`; vault dan catatan tidak dihapus.
5. Jalankan kembali `install.sh` dengan `SECOND_BRAIN_NAME` dan `SECOND_BRAIN_VAULT` yang menunjuk lokasi baru.
6. Jika konfigurasi OpenCode tidak dikelola installer, perbarui permission path lama secara manual.
7. Restart OpenCode dan uji dengan perubahan kecil.
8. Gabungkan catatan yang terpisah secara manual dan hati-hati.
9. Hapus vault lama hanya setelah verifikasi.

## Performa lambat di Windows

Jika source code berada di `/mnt/c`, operasi dengan banyak file dapat lebih lambat dibanding filesystem Linux WSL.

Struktur yang disarankan:

```text
Vault:       /mnt/c/Users/Ayu/Documents/Second Brain
Source code: /home/ayu/code/toko-api
```

Obsidian native Windows tetap mudah mengakses vault, sedangkan Git dan build tools bekerja pada filesystem WSL. Jangan memindahkan source code ke vault untuk mengatasi performa.

## Konflik sinkronisasi

Jika muncul dua versi `_project.md` atau `_log.md`:

1. hentikan editing pada perangkat lain;
2. backup seluruh versi konflik;
3. bandingkan isi dan timestamp;
4. gabungkan informasi yang valid;
5. pertahankan format metadata yang benar;
6. verifikasi `code_paths`;
7. baru hapus conflict file;
8. tunggu sinkronisasi selesai sebelum bekerja lagi.

Jangan otomatis memilih file terbaru jika perangkat memiliki waktu sistem yang salah atau perubahan penting ada pada versi lama.

## Secret masuk ke vault atau Git

Jangan hanya menghapus baris tersebut.

1. Rotasi atau cabut secret.
2. Hapus dari file aktif.
3. Bersihkan history sesuai prosedur Git atau layanan sinkronisasi.
4. Periksa backup dan perangkat lain.
5. Audit penggunaan secret.
6. Laporkan insiden sesuai kebijakan organisasi.

## Metadata YAML rusak

Gejala:

- frontmatter tampil sebagai teks biasa;
- proyek tidak terbaca;
- parser melaporkan error.

Periksa:

- pembuka dan penutup `---`;
- indentasi menggunakan spasi konsisten;
- item daftar diawali `-`;
- tab tidak tercampur;
- karakter khusus pada nilai dikutip jika diperlukan;
- `code_paths` tetap berbentuk daftar.

Contoh:

```yaml
---
project: Toko Online
code_paths:
  - /home/ayu/code/toko-api
  - /home/ayu/code/toko-web
---
```

Jangan merombak field lain tanpa membaca template aktual starter.

## Kapan meminta bantuan

Sertakan:

- sistem operasi dan apakah memakai WSL;
- versi OpenCode dari mekanisme resmi;
- langkah reproduksi;
- pesan error lengkap yang sudah disensor;
- path vault dan repository yang dianonimkan bila perlu;
- hasil pemeriksaan filesystem;
- apakah masalah terjadi pada semua proyek atau satu proyek.

Jangan sertakan:

- token;
- password;
- private key;
- `.env` lengkap;
- data pelanggan;
- isi catatan rahasia.

## Checklist akhir

- [ ] Path diperiksa dari shell yang menjalankan OpenCode.
- [ ] Path WSL digunakan untuk Windows.
- [ ] `code_paths` absolut dan spesifik.
- [ ] Tidak ada folder proyek duplikat.
- [ ] Definisi command starter diperiksa dari instalasi aktual.
- [ ] Backup dibuat sebelum perubahan destruktif.
- [ ] Secret tidak dibagikan saat meminta bantuan.

Kembali ke [README](../README.md) untuk indeks seluruh dokumentasi.
