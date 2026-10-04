---
description: Siapkan folder projek baru di vault dengan aman.
agent: build
---

<!-- second-brain-core:managed -->

Siapkan projek Second Brain baru di `{{VAULT_PATH}}` berdasarkan masukan berikut:

$ARGUMENTS

Kumpulkan informasi yang belum tersedia:

- Nama projek yang juga akan dipakai sebagai nama folder tingkat atas.
- Satu atau beberapa `code_paths` absolut.
- Status awal, misalnya `active`, `paused`, atau `done`.
- Ringkasan tujuan dan stack yang sudah diketahui.

Lalu lakukan pemeriksaan berikut:

1. Cari seluruh `_project.md` dan pastikan tidak ada `code_paths` yang sudah mencakup direktori kerja saat ini. Jika sudah terdaftar, jangan membuat duplikat; tampilkan projek yang ditemukan.
2. Pastikan setiap `code_paths` berbentuk absolut dan periksa apakah path tersedia. Jelaskan jika path belum ada.
3. Pastikan folder projek tujuan belum dipakai. Satu projek harus berada dalam satu folder tingkat atas, bukan di dalam folder projek lain.
4. Pindai README dan file dependency yang relevan untuk mengusulkan tujuan dan stack, tetapi tandai sebagai usulan yang perlu dikonfirmasi.
5. Siapkan pratinjau lengkap `_project.md` dan `_log.md` berdasarkan template vault.
6. Jangan menambahkan remote, organisasi GitHub, stack, atau status yang tidak ditemukan atau diberikan pengguna.
7. Jangan memasukkan secret atau isi `.env`.
8. Tampilkan semua path dan isi file yang akan dibuat, lalu tanyakan: `Buat projek ini di vault?`
9. Buat folder dan file hanya setelah konfirmasi eksplisit.

Setelah berhasil, laporkan file yang dibuat. Jangan mengubah projek vault lain.
