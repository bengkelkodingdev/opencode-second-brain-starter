# 07 - Satu Proyek dengan Banyak Repository

Satu produk sering terdiri dari backend, frontend, mobile, firmware, atau infrastructure repository. Jika semuanya berbagi tujuan dan keputusan produk, wakili sebagai satu proyek logis dengan satu folder tingkat teratas di vault.

## Contoh arsitektur

Produk `FleetTrack` memiliki empat repository:

```text
/home/ayu/code/fleettrack-api
/home/ayu/code/fleettrack-web
/home/ayu/code/fleettrack-mobile
/home/ayu/code/fleettrack-infra
```

Vault hanya memiliki satu folder proyek:

```text
Second Brain/
└── FleetTrack/
    ├── _project.md
    ├── _log.md
    └── ...
```

Contoh `code_paths`:

```yaml
code_paths:
  - /home/ayu/code/fleettrack-api
  - /home/ayu/code/fleettrack-web
  - /home/ayu/code/fleettrack-mobile
  - /home/ayu/code/fleettrack-infra
```

Semua nilai harus merupakan path absolut aktual pada lingkungan OpenCode.

## Kapan repository berada dalam satu proyek

Gabungkan jika:

- repository membangun satu produk;
- rilis atau roadmap saling terkait;
- perubahan kontrak API berdampak pada repository lain;
- keputusan keamanan dan domain perlu dibaca bersama;
- tim menganggapnya satu konteks kerja.

Pisahkan jika:

- produk dan roadmap benar-benar berbeda;
- akses informasi harus dipisahkan;
- repository hanya berbagi library generik;
- satu repository digunakan puluhan produk tanpa konteks dominan;
- penggabungan membuat catatan selalu membingungkan.

## Menambahkan repository kedua

Misalnya proyek awal hanya memiliki API:

```yaml
code_paths:
  - /home/ayu/code/fleettrack-api
```

Setelah web ditambahkan, ubah menjadi:

```yaml
code_paths:
  - /home/ayu/code/fleettrack-api
  - /home/ayu/code/fleettrack-web
```

Langkah aman:

1. pastikan direktori repository kedua ada;
2. dapatkan path absolutnya;
3. tambahkan ke proyek logis yang sama melalui mekanisme starter atau penyuntingan yang didukung;
4. jangan membuat folder vault kedua bernama `FleetTrack Web` tanpa alasan konteks yang kuat;
5. mulai sesi dari repository kedua;
6. verifikasi proyek `FleetTrack` terdeteksi.

Untuk memperoleh path direktori saat ini di Windows PowerShell:

```powershell
(Get-Location).Path
```

Di Linux atau macOS:

```bash
pwd
```

Salin hasil absolut yang terverifikasi, bukan asumsi.

## Windows native

Gunakan path absolut Windows untuk seluruh repository yang dibaca OpenCode native:

```yaml
code_paths:
  - C:\Users\Ayu\source\fleettrack-api
  - C:\Users\Ayu\source\fleettrack-web
```

Jangan campur notasi dari lingkungan lain:

```yaml
code_paths:
  - C:\Users\Ayu\source\fleettrack-api
  - /home/ayu/source/fleettrack-web
```

## WSL opsional

Jika Anda sengaja menjalankan OpenCode di WSL, seluruh nilai harus memakai format Linux:

```yaml
code_paths:
  - /home/ayu/code/fleettrack-api
  - /mnt/c/Users/Ayu/source/fleettrack-legacy
```

Keduanya valid bagi OpenCode di WSL selama path benar. Pertimbangkan karakteristik performa tool pengembangan untuk repository di `/mnt/c`.

## Catatan lintas repository

Catat hubungan yang tidak jelas hanya dari satu codebase, misalnya:

- API contract dan consumer;
- urutan deployment;
- version compatibility;
- ownership database migration;
- event schema;
- dependency firmware terhadap backend;
- test end-to-end lintas repository.

Contoh catatan yang berguna:

```text
Web memakai endpoint GET /vehicles dari API v2. Perubahan field status harus dirilis secara backward-compatible sebelum web production dideploy.
```

Contoh yang terlalu mudah basi:

```text
File Vehicle.ts ada di baris 83.
```

Referensi baris cenderung berubah. Gunakan nama modul, simbol, atau kontrak yang lebih stabil.

## Bekerja dari repository berbeda

Windows PowerShell, sesi backend:

```powershell
Set-Location "C:\Users\Ayu\source\fleettrack-api"
opencode
```

Windows PowerShell, sesi frontend:

```powershell
Set-Location "C:\Users\Ayu\source\fleettrack-web"
opencode
```

Linux atau macOS, sesi backend:

```bash
cd /home/ayu/code/fleettrack-api
opencode
```

Linux atau macOS, sesi frontend:

```bash
cd /home/ayu/code/fleettrack-web
opencode
```

Keduanya seharusnya mengarah ke proyek logis yang sama jika deteksi starter mendukung semua `code_paths`. Selalu verifikasi nama proyek pada awal sesi.

## Repository bersama

Library yang dipakai banyak produk memerlukan keputusan khusus:

- jadikan proyek terpisah jika library memiliki roadmap dan keputusan sendiri;
- hubungkan ke satu proyek jika secara praktis hanya dimiliki produk itu;
- hindari mendaftarkan path yang sama ke banyak proyek tanpa memahami cara starter menangani ambiguitas.

Jika path yang sama terdaftar pada dua proyek, deteksi dapat menjadi ambigu. Periksa implementasi starter dan pilih struktur yang membuat ownership jelas.

## Checklist

- [ ] Satu folder vault mewakili satu produk logis.
- [ ] Semua repository terkait tercantum sebagai path absolut.
- [ ] Tidak ada source code yang disalin ke vault.
- [ ] Hubungan lintas repository didokumentasikan.
- [ ] Deteksi diuji dari setiap repository.
- [ ] Path yang sama tidak didaftarkan secara ambigu.
- [ ] Format path sesuai lingkungan OpenCode.

Berikutnya: [08 - Memindahkan Proyek atau Repository](08-MOVING-PROJECTS.md).
