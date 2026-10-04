# 03 - Instalasi dan Autentikasi OpenCode

OpenCode berubah dari waktu ke waktu. Gunakan dokumentasi resmi untuk perintah instalasi, pembaruan, pemilihan provider, dan autentikasi. Jangan mengandalkan perintah hardcoded dari tutorial lama.

## Sumber resmi

- Dokumentasi: [https://opencode.ai/docs](https://opencode.ai/docs)
- Halaman utama: [https://opencode.ai](https://opencode.ai)
- Source repository resmi ditautkan dari situs atau dokumentasi resmi OpenCode.

Sebelum mengeksekusi perintah instalasi, baca perintah yang tercantum di dokumentasi resmi saat ini. Periksa domain, isi perintah, prasyarat, dan platform yang didukung.

## Windows native

Panduan utama menjalankan OpenCode secara native dari PowerShell.

Alur yang diharapkan:

```text
Windows
├── Obsidian native Windows
├── OpenCode native
├── Git dan alat pengembangan native
└── source code di C:\Users\<user>\source
```

Pilih metode Windows pada dokumentasi resmi OpenCode, lalu jalankan instalasi, autentikasi, dan OpenCode dari PowerShell.

## Instalasi

1. Buka dokumentasi instalasi resmi OpenCode.
2. Pilih metode yang direkomendasikan untuk sistem Anda saat ini.
3. Periksa prasyarat yang disebutkan dokumentasi.
4. Jalankan perintah resmi di terminal yang benar.
5. Tutup dan buka kembali terminal jika dokumentasi meminta pemuatan ulang environment.
6. Verifikasi command tersedia menggunakan mekanisme verifikasi yang dicantumkan dokumentasi resmi.

Dokumen ini sengaja tidak menyalin perintah instalasi karena nama paket, URL installer, dan prasyarat dapat berubah.

## Autentikasi provider

OpenCode dapat mendukung provider dan metode autentikasi yang berubah sesuai versi. Ikuti bagian Providers atau Authentication pada dokumentasi resmi.

Prinsip keamanan:

- autentikasi hanya melalui alur resmi;
- periksa URL browser sebelum login;
- jangan menempelkan API key ke catatan vault;
- jangan menyimpan token di `_project.md` atau `_log.md`;
- jangan melakukan commit terhadap `.env` atau file kredensial;
- gunakan penyimpanan kredensial atau environment yang direkomendasikan provider;
- berikan izin minimum yang diperlukan.

Jika menggunakan API key, isi hanya pada lokasi konfigurasi yang secara resmi didukung. Jangan menaruh nilai nyata dalam dokumentasi atau screenshot.

Contoh aman untuk dokumentasi internal:

```text
PROVIDER_API_KEY=<set melalui mekanisme rahasia yang disetujui>
```

Contoh tidak aman:

```text
PROVIDER_API_KEY=sk-nilai-rahasia-sebenarnya
```

## Menjalankan dari source code

Setelah instalasi dan autentikasi berhasil, masuk ke repository aplikasi, lalu mulai OpenCode menurut dokumentasi resminya.

Windows PowerShell:

```powershell
Set-Location "C:\Users\Ayu\source\project"
opencode
```

Linux:

```bash
cd /home/ayu/code/toko-api
opencode
```

Di macOS:

```bash
cd /Users/ayu/code/toko-api
opencode
```

OpenCode sebaiknya dimulai dari repository atau direktori kerja yang relevan agar konteks filesystem jelas. Vault tetap terpisah.

## WSL opsional

Jika Anda sengaja memilih WSL, ikuti metode instalasi Linux resmi di dalam WSL dan gunakan path Linux untuk vault maupun `code_paths`. Jangan mencampur instalasi native Windows dan WSL dalam satu alur kerja. WSL adalah pilihan lanjutan, bukan persyaratan panduan ini.

## Pembaruan

Gunakan metode pembaruan yang sesuai dengan metode instalasi Anda dan tercantum dalam dokumentasi resmi. Setelah pembaruan:

1. periksa catatan rilis jika tersedia;
2. verifikasi OpenCode masih dapat dijalankan;
3. verifikasi autentikasi provider;
4. uji satu proyek sebelum mengubah seluruh konfigurasi;
5. tinjau perubahan izin atau format konfigurasi.

## Checklist

- [ ] Instalasi mengikuti dokumentasi resmi terbaru.
- [ ] Instalasi OpenCode sesuai dengan lingkungan yang benar: PowerShell native Windows atau Bash di Linux/macOS.
- [ ] OpenCode dapat dijalankan dari terminal.
- [ ] Provider sudah dikonfigurasi dengan metode resmi.
- [ ] Tidak ada secret di vault atau repository dokumentasi.
- [ ] Source code tetap berada di luar vault.

Berikutnya: [04 - Memasang Starter](04-INSTALL-STARTER.md).
