# Aturan Vault {{USER_NAME}}

Lokasi vault: `{{VAULT_PATH}}`

Vault ini adalah Second Brain untuk membantu pekerjaan kode. Gunakan bahasa Indonesia yang sederhana dan singkat.

## Struktur

- Satu folder tingkat atas mewakili satu projek.
- `<Nama Projek>/_project.md` wajib ada dan menjadi sumber kebenaran projek.
- `<Nama Projek>/_log.md` wajib ada dan menjadi log kronologis append-only.
- `<Nama Projek>/_archive/` digunakan untuk catatan yang tidak lagi aktif. Jangan menghapus note.
- `Inbox/` digunakan untuk capture mentah yang belum ditentukan projeknya.
- `Templates/` berisi template dan bukan folder projek.

## Aturan data

- `code_paths` di `_project.md` harus berupa path absolut.
- Gunakan tanggal `YYYY-MM-DD`.
- Gunakan `[[wikilink]]` untuk menghubungkan note.
- Jangan simpan password, token, API key, private key, cookie, isi `.env`, atau secret lain.
- Jangan mencatat dugaan sebagai fakta. Tandai hal yang belum pasti atau tanyakan kepada pengguna.
- `_log.md` hanya boleh ditambah di bagian akhir. Jangan mengedit, mengurutkan ulang, atau menghapus entri lama.

## Aturan perubahan

- Membaca dan mencari konteks boleh dilakukan tanpa perubahan.
- Sebelum membuat, menulis, mengubah, atau memindahkan file, tampilkan path dan rencana perubahan.
- Minta konfirmasi eksplisit dari pengguna sebelum menjalankan perubahan tersebut.
- Konfirmasi untuk satu perubahan tidak otomatis berlaku untuk perubahan lain.
- Jika path lama salah, verifikasi path aktual, tampilkan nilai lama dan baru, lalu minta konfirmasi sebelum memperbaiki `_project.md` dan referensi terkait.
