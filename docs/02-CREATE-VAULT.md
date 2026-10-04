# 02 - Membuat Satu Vault dan Pemetaan Path WSL

Gunakan satu vault untuk semua proyek. Di dalamnya, setiap proyek logis mendapatkan tepat satu folder tingkat teratas.

## Model penyimpanan

```text
Vault catatan                         Source code
Second Brain/                        ~/code/
├── Toko Online/                     ├── toko-api/
│   ├── _project.md                  └── toko-web/
│   └── _log.md
└── Website Perusahaan/
    ├── _project.md
    └── _log.md
```

Vault menyimpan konteks, keputusan, status, dan referensi. Repository source code tetap berada di luar vault.

## Aturan satu folder per proyek logis

Folder tingkat teratas mewakili produk atau konteks kerja, bukan selalu satu repository.

Contoh yang benar:

```text
Second Brain/
└── Toko Online/
```

Folder `Toko Online` boleh menunjuk ke:

```text
/home/andi/code/toko-api
/home/andi/code/toko-web
/home/andi/code/toko-mobile
```

Hindari membuat tiga folder vault terpisah jika ketiganya merupakan satu produk dan berbagi keputusan yang sama.

## Membuat vault

1. Buka Obsidian.
2. Pilih opsi untuk membuat vault baru.
3. Gunakan nama yang mudah dikenali, misalnya `Second Brain`.
4. Pilih folder yang stabil, mudah dicadangkan, dan hanya dapat diakses oleh akun Anda.
5. Selesaikan pembuatan vault.

Contoh lokasi:

| Sistem | Path vault |
| --- | --- |
| Windows di Obsidian | `C:\Users\Ayu\Documents\Second Brain` |
| Windows yang sama dari WSL | `/mnt/c/Users/Ayu/Documents/Second Brain` |
| Linux | `/home/ayu/Documents/Second Brain` |
| macOS | `/Users/ayu/Documents/Second Brain` |

Spasi pada nama `Second Brain` valid. Di shell, selalu beri tanda kutip:

```bash
ls "/home/ayu/Documents/Second Brain"
```

## Windows: pemetaan path WSL

OpenCode dijalankan di WSL, sedangkan Obsidian dijalankan native di Windows. Keduanya mengakses folder fisik yang sama menggunakan notasi path berbeda.

### Rumus pemetaan

```text
C:\Users\Ayu\Documents\Second Brain
```

menjadi:

```text
/mnt/c/Users/Ayu/Documents/Second Brain
```

Contoh drive lain:

```text
D:\Catatan\Second Brain
```

menjadi:

```text
/mnt/d/Catatan/Second Brain
```

Perhatikan perubahan berikut:

- huruf drive menjadi folder huruf kecil di bawah `/mnt`;
- backslash `\` menjadi slash `/`;
- kapitalisasi nama folder harus ditulis secara konsisten;
- path yang mengandung spasi harus dikutip di shell.

### Verifikasi dari WSL

Buka terminal WSL, kemudian periksa folder:

```bash
ls "/mnt/c/Users/Ayu/Documents/Second Brain"
```

Jika nama pengguna Windows mengandung spasi, tetap kutip seluruh path:

```bash
ls "/mnt/c/Users/Ayu Putri/Documents/Second Brain"
```

### Lokasi source code di Windows

Untuk performa Git, package manager, watcher, dan build tools, source code umumnya lebih baik berada di filesystem Linux WSL:

```text
/home/ayu/code/toko-api
```

Jangan menaruh source code di dalam:

```text
/mnt/c/Users/Ayu/Documents/Second Brain
```

Vault boleh berada di drive Windows agar mudah dibuka Obsidian native. Pemisahan ini memang disengaja.

## Memahami `code_paths`

Setiap proyek mencatat repository terkait dalam `code_paths`. Gunakan path absolut, bukan path relatif.

Benar di Linux atau WSL:

```yaml
code_paths:
  - /home/ayu/code/toko-api
  - /home/ayu/code/toko-web
```

Benar di macOS:

```yaml
code_paths:
  - /Users/ayu/code/toko-api
```

Salah:

```yaml
code_paths:
  - ../code/toko-api
  - ~/code/toko-web
  - C:\Users\Ayu\code\toko-api
```

Alasannya:

- `../` bergantung pada direktori saat ini;
- `~` perlu ekspansi shell dan bukan path absolut literal;
- format `C:\...` tidak sesuai untuk OpenCode yang berjalan di WSL.

## Uji akses dua arah

1. Buat catatan uji di Obsidian, misalnya `uji.md`.
2. Dari WSL, pastikan berkas terlihat:

```bash
ls "/mnt/c/Users/Ayu/Documents/Second Brain/uji.md"
```

3. Ubah isi catatan melalui Obsidian dan pastikan perubahan tersimpan.
4. Hapus catatan uji jika tidak dibutuhkan.

Tidak perlu menjalankan Obsidian saat melakukan langkah kedua. File tetap ada di disk.

## Checklist

- [ ] Hanya ada satu vault second brain.
- [ ] Lokasi vault diketahui dalam format path sistem operasi.
- [ ] Pengguna Windows mengetahui path WSL untuk vault yang sama.
- [ ] Source code tetap di luar vault.
- [ ] Setiap produk akan memiliki satu folder tingkat teratas.
- [ ] Semua `code_paths` akan menggunakan path absolut.

Berikutnya: [03 - Instalasi dan Autentikasi OpenCode](03-INSTALL-OPENCODE.md).
