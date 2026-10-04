---
description: Mulai sesi dan muat konteks projek dari Second Brain.
agent: build
---

<!-- second-brain-core:managed -->

Mulai sesi kerja dengan Second Brain di `{{VAULT_PATH}}`.

Konteks tambahan dari pengguna: $ARGUMENTS

Lakukan langkah berikut:

1. Dapatkan direktori kerja saat ini sebagai path absolut.
2. Cari `_project.md` di setiap folder projek tingkat atas dalam vault.
3. Cocokkan direktori kerja dengan setiap `code_paths` absolut. Sebuah projek cocok jika direktori kerja sama dengan atau berada di bawah salah satu path tersebut.
4. Jika tepat satu projek cocok, baca `_project.md` dan sekitar 20 baris terakhir `_log.md`.
5. Sebutkan satu baris: `Projek terdeteksi: <nama projek>` lalu ringkas konteks yang relevan, maksimal lima poin.
6. Jika tidak ada yang cocok, tanyakan apakah pengguna ingin memilih projek yang ada atau menjalankan `/brain-init` untuk projek baru.
7. Jika ada beberapa kandidat, tampilkan nama kandidat dan minta pengguna memilih.

8. Berdasarkan konteks tambahan dari pengguna, usulkan rencana kerja yang konkret dan singkat.
9. Berhenti dan tunggu persetujuan pengguna sebelum mengedit source code atau vault.

Pada tahap ini hanya membaca dan merencanakan. Jangan membuat atau mengubah file. Jangan menampilkan secret yang mungkin ditemukan secara tidak sengaja.
