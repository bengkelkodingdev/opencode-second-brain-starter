---
description: Buat tinjauan mingguan projek dari catatan yang sudah ada.
agent: build
---

<!-- second-brain-core:managed -->

Buat tinjauan mingguan Second Brain untuk periode atau fokus berikut:

$ARGUMENTS

Jika periode tidak diberikan, gunakan tujuh hari terakhir dan sebutkan rentang tanggalnya.

1. Baca `_project.md` dan bagian `_log.md` yang masuk dalam periode untuk setiap projek aktif di `{{VAULT_PATH}}`.
2. Ringkas progres, keputusan, blocker, pekerjaan tertunda, dan path bermasalah. Bedakan fakta dari saran.
3. Jangan membaca file kode atau seluruh note lain kecuali benar-benar diperlukan untuk menjawab permintaan.
4. Jangan menyertakan secret atau data sensitif dalam hasil.
5. Tampilkan laporan di percakapan terlebih dahulu. Secara default, jangan menulis file.
6. Jika pengguna ingin menyimpan laporan, tanyakan lokasi tujuan, tampilkan isi dan path lengkap, lalu minta konfirmasi eksplisit sebelum menulis.
7. Jika laporan perlu dipindahkan atau catatan Inbox perlu ditriase, tampilkan rencana perpindahan dan minta konfirmasi terpisah.

Jangan mengubah `_log.md` lama. Jika pengguna meminta ringkasan ditambahkan ke log, tambahkan hanya baris baru di bagian akhir setelah konfirmasi.
