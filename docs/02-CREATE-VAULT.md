# 02 - Membuat Satu Vault dan Memahami Path Native

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
| Windows native | `C:\Users\Ayu\Documents\Second Brain` |
| Linux | `/home/ayu/Documents/Second Brain` |
| macOS | `/Users/ayu/Documents/Second Brain` |

Spasi pada nama `Second Brain` valid. Di shell, selalu beri tanda kutip.

Windows PowerShell:

```powershell
Get-ChildItem "C:\Users\Ayu\Documents\Second Brain"
```

Linux atau macOS:

```bash
ls "/home/ayu/Documents/Second Brain"
```

## Windows native

Jalankan Obsidian dan OpenCode secara native. Keduanya menggunakan notasi path Windows yang sama.

### Path vault

```text
C:\Users\Ayu\Documents\Second Brain
```

Contoh drive lain:

```text
D:\Catatan\Second Brain
```

Perhatikan hal berikut:

- sertakan huruf drive dan gunakan path absolut;
- gunakan backslash `\`;
- path yang mengandung spasi harus dikutip di PowerShell;
- gunakan path aktual, termasuk `OneDrive`, jika folder Documents diarahkan ke sana.

### Verifikasi dari PowerShell

Buka PowerShell, kemudian periksa folder:

```powershell
Test-Path "C:\Users\Ayu\Documents\Second Brain"
Get-ChildItem "C:\Users\Ayu\Documents\Second Brain"
```

Jika nama pengguna Windows mengandung spasi, tetap kutip seluruh path:

```powershell
Test-Path "C:\Users\Ayu Putri\Documents\Second Brain"
```

### Lokasi source code di Windows

Simpan source code di folder terpisah dari vault, misalnya:

```text
C:\Users\Ayu\source\project
```

Jangan menaruh source code di dalam:

```text
C:\Users\Ayu\Documents\Second Brain
```

Keduanya boleh berada di drive Windows yang sama; yang penting source code bukan anak folder vault.

## Memahami `code_paths`

Setiap proyek mencatat repository terkait dalam `code_paths`. Gunakan path absolut, bukan path relatif.

Benar di Windows native:

```yaml
code_paths:
  - C:\Users\Ayu\source\project
```

Benar di Linux:

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
```

Alasannya:

- `../` bergantung pada direktori saat ini;
- `~` perlu ekspansi shell dan bukan path absolut literal.

## Aturan format path

Path vault dan setiap nilai `code_paths` harus memakai format native lingkungan yang menjalankan OpenCode, bukan sekadar format sistem tempat folder terlihat di Obsidian:

- OpenCode native Windows: `C:\Users\Ayu\source\project`;
- OpenCode Linux: `/home/ayu/source/project`;
- OpenCode macOS: `/Users/ayu/source/project`.

Jangan mencampur format Windows `C:\...` dan format Unix `/home/...` dalam konfigurasi untuk satu lingkungan OpenCode.

## Uji akses dua arah

1. Buat catatan uji di Obsidian, misalnya `uji.md`.
2. Dari shell yang menjalankan OpenCode, pastikan berkas terlihat. Di Windows PowerShell:

```powershell
Test-Path "C:\Users\Ayu\Documents\Second Brain\uji.md"
```

3. Ubah isi catatan melalui Obsidian dan pastikan perubahan tersimpan.
4. Hapus catatan uji jika tidak dibutuhkan.

Tidak perlu menjalankan Obsidian saat melakukan langkah kedua. File tetap ada di disk.

## WSL opsional

Gunakan bagian ini hanya jika Anda sengaja menjalankan OpenCode di WSL. Dalam kondisi tersebut, format native lingkungan OpenCode adalah format Linux: vault Windows `C:\Users\Ayu\Documents\Second Brain` terlihat sebagai `/mnt/c/Users/Ayu/Documents/Second Brain`, dan repository sebaiknya menggunakan path seperti `/home/ayu/source/project`. Jalankan verifikasi dengan Bash:

```bash
ls "/mnt/c/Users/Ayu/Documents/Second Brain"
```

Jangan memasukkan path `C:\...` ke `code_paths` yang dibaca OpenCode di WSL.

## Checklist

- [ ] Hanya ada satu vault second brain.
- [ ] Lokasi vault diketahui dalam format path sistem operasi.
- [ ] Path vault memakai format lingkungan yang menjalankan OpenCode.
- [ ] Source code tetap di luar vault.
- [ ] Setiap produk akan memiliki satu folder tingkat teratas.
- [ ] Semua `code_paths` akan menggunakan path absolut.

Berikutnya: [03 - Instalasi dan Autentikasi OpenCode](03-INSTALL-OPENCODE.md).
