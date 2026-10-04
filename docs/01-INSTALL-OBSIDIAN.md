# 01 - Instalasi Obsidian

Obsidian adalah aplikasi untuk membaca dan mengedit catatan Markdown di dalam sebuah folder yang disebut vault. Second brain tetap dapat dipakai OpenCode ketika Obsidian tertutup. Tidak ada Community Plugin yang diwajibkan oleh panduan ini.

## Sebelum mulai

Pastikan Anda mengetahui:

- sistem operasi yang digunakan;
- akun pengguna komputer Anda;
- lokasi folder Documents;
- bahwa vault bukan tempat source code aplikasi.

Gunakan installer dari [situs resmi Obsidian](https://obsidian.md/download). Hindari situs unduhan pihak ketiga.

## Windows

### Instalasi

1. Buka halaman unduhan resmi Obsidian.
2. Pilih installer Windows yang sesuai dengan arsitektur komputer.
3. Jalankan installer hasil unduhan.
4. Selesaikan proses instalasi dengan pilihan standar.
5. Jalankan Obsidian dari Start Menu.

Panduan utama menggunakan aplikasi native Windows:

| Kebutuhan | Lingkungan |
| --- | --- |
| Membuka dan mengedit vault secara visual | Obsidian native Windows |
| Menjalankan OpenCode dan alat pengembangan | Windows native melalui PowerShell |

Obsidian dan OpenCode native dapat menggunakan path Windows yang sama, misalnya `C:\Users\Ayu\Documents\Second Brain`.

### Verifikasi

Obsidian berhasil dipasang jika aplikasi terbuka dan menampilkan pilihan untuk membuat vault baru atau membuka folder sebagai vault.

Belum perlu membuat vault pada tahap ini. Lanjutkan ke [02 - Membuat Vault](02-CREATE-VAULT.md).

## Linux

Distribusi Linux memiliki format paket yang berbeda. Pilih format resmi yang sesuai dari halaman unduhan Obsidian, misalnya AppImage, deb, rpm, atau format lain yang saat ini didukung.

### Langkah umum

1. Unduh paket dari situs resmi.
2. Ikuti petunjuk untuk format paket dan distribusi Anda.
3. Jalankan Obsidian dari menu aplikasi.
4. Pastikan halaman awal Obsidian tampil.

Jika menggunakan AppImage, sistem mungkin meminta izin eksekusi. Ikuti dokumentasi AppImage dan distribusi Anda. Nama paket dan prosedur dapat berubah, sehingga panduan ini tidak mengunci perintah instalasi tertentu.

Contoh lokasi vault yang mudah dipahami:

```text
/home/budi/Documents/Second Brain
```

Contoh lokasi source code yang terpisah:

```text
/home/budi/code/aplikasi-kasir
```

## macOS

### Instalasi

1. Buka halaman unduhan resmi Obsidian.
2. Unduh versi macOS yang sesuai dengan perangkat Anda.
3. Buka berkas instalasi.
4. Pindahkan Obsidian ke folder Applications jika diminta.
5. Jalankan Obsidian dari Applications atau Spotlight.
6. Jika macOS menampilkan konfirmasi keamanan, pastikan aplikasi berasal dari sumber resmi sebelum melanjutkan.

Contoh lokasi vault:

```text
/Users/sari/Documents/Second Brain
```

Contoh lokasi source code:

```text
/Users/sari/code/aplikasi-kasir
```

## Pengaturan awal yang disarankan

Pengaturan berikut opsional dan tidak mengubah cara OpenCode membaca berkas:

- pilih bahasa antarmuka yang nyaman;
- aktifkan konfirmasi sebelum menghapus berkas jika diperlukan;
- gunakan nama berkas dan folder yang jelas;
- tampilkan ekstensi berkas di file manager agar mudah membedakan `.md` dari format lain.

Community Plugin tidak diperlukan. Mulailah tanpa plugin agar konfigurasi sederhana dan mudah diperiksa. Plugin dapat ditambahkan kemudian atas kebutuhan sendiri, tetapi pahami izin dan risiko keamanannya.

## Yang tidak perlu dilakukan

- Obsidian tidak harus terus berjalan.
- Tidak perlu membuat satu vault untuk setiap repository.
- Tidak perlu menaruh source code di dalam vault.
- Tidak perlu memasang plugin agar Markdown dapat dibaca OpenCode.
- Tidak perlu menggunakan layanan sinkronisasi untuk memulai.

## Checklist

- [ ] Obsidian diunduh dari sumber resmi.
- [ ] Aplikasi dapat dibuka.
- [ ] Pengguna Windows dapat membuka Obsidian dan PowerShell secara native.
- [ ] Belum ada source code yang dipindahkan ke vault.

Berikutnya: [02 - Membuat Satu Vault dan Memahami Path Native](02-CREATE-VAULT.md).
