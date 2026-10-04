---
description: Akhiri sesi dan tawarkan catatan log projek.
agent: build
---

<!-- second-brain-core:managed -->

Akhiri sesi kerja saat ini.

Catatan tambahan dari pengguna: $ARGUMENTS

1. Tentukan projek dari `code_paths` absolut di `{{VAULT_PATH}}` seperti pada `/start`.
2. Ringkas file kode yang berubah, keputusan penting, hasil pengujian, dan blocker. Jangan mengklaim pekerjaan yang tidak dilakukan.
3. Buat usulan log singkat dengan format `- YYYY-MM-DD: ...`.
4. Hapus password, token, API key, private key, cookie, isi `.env`, dan data sensitif lain dari usulan.
5. Tampilkan path `_log.md` tujuan dan seluruh teks yang akan ditambahkan.
6. Tanyakan: `Tambahkan catatan ini ke akhir _log.md?`
7. Hanya setelah jawaban pengguna jelas menyetujui, tambahkan teks di akhir file. Jangan menulis ulang, merapikan, mengurutkan, atau menghapus isi lama.

Jika projek tidak ditemukan atau masih ambigu, tanyakan dulu. Jangan menulis ke vault yang ditebak.
