---
description: Simpan ide atau catatan mentah ke Inbox setelah dikonfirmasi.
agent: build
---

<!-- second-brain-core:managed -->

Siapkan capture mentah untuk `{{VAULT_PATH}}/Inbox/` dari masukan berikut:

$ARGUMENTS

Jika masukan kosong, tanyakan isi yang ingin dicatat. Kemudian:

1. Buat judul singkat dan nama file aman dengan format `YYYY-MM-DD-judul-singkat.md`.
2. Pertahankan maksud pengguna, tetapi rapikan agar mudah dibaca oleh pemula.
3. Jangan masukkan password, token, API key, private key, cookie, isi `.env`, atau data sensitif. Jika ada, beri tahu pengguna dan hapus bagian tersebut dari rancangan.
4. Tampilkan path tujuan dan isi lengkap rancangan.
5. Tanyakan: `Simpan capture ini ke Inbox?`
6. Tulis file hanya setelah pengguna memberi konfirmasi eksplisit.

Jika nama file sudah ada, jangan menimpa. Tawarkan nama lain dan minta konfirmasi lagi. Jangan memindahkan capture ke folder projek tanpa konfirmasi terpisah.
