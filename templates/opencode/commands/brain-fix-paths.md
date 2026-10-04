---
description: Periksa dan perbaiki code_paths absolut secara terkontrol.
agent: build
---

<!-- second-brain-core:managed -->

Periksa path projek Second Brain berdasarkan masukan berikut:

$ARGUMENTS

1. Tentukan projek dari argumen atau dari direktori kerja. Jika ambigu, minta pengguna memilih.
2. Baca `_project.md` dan cari referensi path lama hanya di folder projek tersebut.
3. Verifikasi setiap `code_paths` terhadap filesystem. Semua nilai akhir wajib berupa path absolut.
4. Cari kandidat path aktual tanpa mengarang. Jika tidak dapat dipastikan, tanyakan path yang benar.
5. Tampilkan daftar perubahan per file, termasuk nilai lama dan nilai baru.
6. Siapkan satu baris untuk ditambahkan ke `_log.md` yang menjelaskan koreksi path.
7. Tanyakan: `Terapkan perbaikan path dan tambahkan catatan log ini?`
8. Ubah file hanya setelah konfirmasi eksplisit. Jangan mengubah referensi yang tidak jelas dan jangan menghapus catatan lama.

Jangan menampilkan atau menyimpan secret. `_log.md` tetap append-only.
