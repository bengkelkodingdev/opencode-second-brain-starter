# 05 - Proyek Pertama, Baru, dan Existing

Satu proyek logis mendapatkan satu folder tingkat teratas di vault. Folder itu menyimpan pengetahuan proyek, sedangkan source code tetap di luar vault dan dihubungkan melalui `code_paths` absolut.

## Tiga konsep yang harus dibedakan

| Konsep | Contoh | Lokasi |
| --- | --- | --- |
| Nama proyek logis | `Toko Online` | Nama folder di vault |
| Catatan proyek | `_project.md`, `_log.md` | Di dalam folder proyek vault |
| Source code | `toko-api`, `toko-web` | Di luar vault |

## Sebelum membuat proyek

Tentukan batas proyek logis dengan pertanyaan berikut:

- Apakah repository berbagi tujuan produk yang sama?
- Apakah keputusan arsitekturnya saling terkait?
- Apakah pekerjaan biasanya direncanakan sebagai satu unit?
- Apakah konteksnya akan lebih mudah ditemukan dalam satu folder?

Jika jawabannya ya, gunakan satu folder proyek walaupun repository lebih dari satu.

## Proyek pertama

Misalnya Anda memiliki repository:

```text
/home/ayu/code/kasir-api
```

dan ingin membuat proyek logis `Aplikasi Kasir`.

1. Pastikan repository benar-benar ada:

```bash
ls /home/ayu/code/kasir-api
```

2. Jalankan OpenCode dari repository:

```bash
cd /home/ayu/code/kasir-api
opencode
```

3. Jika starter Anda menyediakan `/brain-init`, jalankan command tersebut dan ikuti pertanyaannya.
4. Gunakan nama proyek `Aplikasi Kasir`.
5. Berikan path absolut `/home/ayu/code/kasir-api` jika diminta.
6. Periksa folder proyek yang dihasilkan di vault.
7. Buka `_project.md` dan pastikan `code_paths` tepat.

Contoh frontmatter minimal yang mungkin digunakan oleh starter:

```yaml
---
project: Aplikasi Kasir
status: active
code_paths:
  - /home/ayu/code/kasir-api
---
```

Field wajib Core adalah `project`, `status`, dan `code_paths`. Status yang digunakan adalah `active`, `paused`, atau `done`. `/brain-weekly` memperlakukan `active` sebagai proyek yang masih aktif. Ikuti format template aktual dan jangan mengganti field secara massal hanya agar sama dengan contoh ini.

## Membuat proyek baru dari nol

Urutan yang aman:

1. Buat direktori source code di luar vault.
2. Inisialisasi proyek menggunakan tool stack Anda.
3. Pastikan proyek dapat dijalankan atau dites secara mandiri.
4. Mulai OpenCode dari direktori proyek.
5. Hubungkan proyek ke second brain menggunakan mekanisme starter.
6. Isi tujuan, stack, batasan, dan status awal pada catatan proyek.

Contoh lokasi:

```text
Vault: /home/ayu/Documents/Second Brain/Aplikasi Inventori
Kode:  /home/ayu/code/inventori
```

Jangan membuat source code di:

```text
/home/ayu/Documents/Second Brain/Aplikasi Inventori/source
```

Pemisahan menjaga vault tetap ringan, aman untuk sinkronisasi catatan, dan tidak dipenuhi dependency atau build artifact.

## Menghubungkan proyek yang sudah ada

Untuk existing project, jangan memindahkan repository ke vault. Daftarkan lokasi aktualnya.

Contoh Linux:

```yaml
code_paths:
  - /home/budi/work/client-portal
```

Contoh macOS:

```yaml
code_paths:
  - /Users/budi/Developer/client-portal
```

Contoh Windows dengan OpenCode di WSL dan repository di filesystem WSL:

```yaml
code_paths:
  - /home/budi/code/client-portal
```

Contoh Windows dengan repository lama masih di drive C, walaupun untuk performa pengembangan mungkin kurang ideal:

```yaml
code_paths:
  - /mnt/c/Users/Budi/source/client-portal
```

Jangan gunakan path Windows native di metadata yang dibaca OpenCode WSL:

```yaml
code_paths:
  - C:\Users\Budi\source\client-portal
```

## Memilih nama folder proyek

Nama folder sebaiknya:

- mewakili produk atau konteks, bukan nama komputer;
- stabil walaupun repository berganti nama;
- mudah dicari;
- tidak mengandung rahasia atau nama kredensial;
- berbeda dari proyek lain.

Contoh baik:

```text
Aplikasi Kasir
Portal Mahasiswa
Website BengkelKoding
```

Contoh yang sulit dipahami:

```text
project-1
baru
repo
test-final-fix
```

## Isi konteks awal

Catat informasi yang membantu sesi berikutnya:

- tujuan proyek;
- siapa pengguna utamanya;
- status aktif atau arsip;
- daftar `code_paths` absolut;
- stack teknologi yang sudah diverifikasi dari repository;
- cara menjalankan test yang sudah diketahui;
- batasan penting;
- keputusan arsitektur yang masih berlaku;
- tautan ke dokumentasi internal yang aman.

Jangan mencatat:

- API key;
- password database;
- token login;
- private key;
- isi `.env`;
- data pelanggan yang sensitif.

## Verifikasi deteksi proyek

Setelah proyek terhubung:

1. mulai sesi baru dari direktori yang ada di `code_paths`;
2. jalankan alur awal yang disediakan starter, biasanya `/start` jika tersedia;
3. periksa apakah proyek yang disebut adalah proyek yang benar;
4. pastikan OpenCode tidak memilih proyek lain;
5. koreksi path absolut jika repository tidak terdeteksi.

Jika path repository berada di bawah path yang terdaftar, deteksi mungkin bergantung pada implementasi starter. Verifikasi perilaku aktual dan jangan mengandalkan asumsi.

## Checklist

- [ ] Satu proyek logis memiliki satu folder tingkat teratas.
- [ ] Source code tetap di luar vault.
- [ ] `code_paths` berisi path absolut yang benar.
- [ ] Format WSL digunakan untuk sesi OpenCode di Windows.
- [ ] Konteks awal berisi fakta terverifikasi.
- [ ] Tidak ada secret atau data sensitif.
- [ ] Deteksi diuji dari repository yang sebenarnya.

Berikutnya: [06 - Alur Kerja Harian](06-DAILY-WORKFLOW.md).
