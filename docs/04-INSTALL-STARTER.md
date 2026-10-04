# 04 - Memasang Starter

Repository menyediakan `install.sh`, `update.sh`, `uninstall.sh`, dan skrip verifikasi. Bagian ini menjelaskan perilaku yang dapat diperiksa dari skrip tersebut pada versi repository saat ini. Baca kembali skrip jika Anda menggunakan versi lain.

## Prasyarat

- Obsidian sudah terpasang.
- Satu vault sudah dibuat.
- OpenCode sudah terpasang dan dapat diautentikasi.
- Path absolut vault diketahui dari lingkungan tempat OpenCode berjalan.
- Repository starter diperoleh dari sumber tepercaya.
- Git tersedia pada `PATH`.
- Sistem yang digunakan adalah Linux, macOS, atau WSL.

Contoh path vault:

```text
Linux:   /home/ayu/Documents/Second Brain
macOS:   /Users/ayu/Documents/Second Brain
WSL:     /mnt/c/Users/Ayu/Documents/Second Brain
```

Installer tidak mendukung Windows native. Pengguna Windows harus menjalankannya dari WSL dengan path vault `/mnt/<drive>/...`.

## 1. Periksa isi repository

Masuk ke direktori repository starter dan lihat berkas yang tersedia:

```bash
cd /path/absolut/opencode-second-brain-starter
ls
```

Baca `README.md`, dokumentasi, dan skrip sebelum menjalankannya. Pada versi saat ini, `install.sh`:

- memeriksa keberadaan command `opencode` dan `git`;
- menerima Linux, macOS, dan WSL;
- mensyaratkan vault yang sudah ada dan dapat ditulis;
- merender template command ke direktori konfigurasi OpenCode;
- menambahkan blok terkelola ke `AGENTS.md` global OpenCode;
- menambahkan blok aturan terkelola ke `AGENTS.md` di dalam vault;
- membuat `Inbox/` dan `Templates/` jika belum tersedia;
- memasang template `Project.md` dan `Log.md` tanpa menimpa template yang sudah ada;
- membuat manifest instalasi;
- menolak menimpa command existing yang tidak dikelolanya;
- membuat backup file konfigurasi existing yang akan diubah;
- menjalankan verifikasi setelah pemasangan.

Direktori konfigurasi default adalah:

```text
~/.config/opencode
```

Jika `XDG_CONFIG_HOME` disetel, installer menggunakan:

```text
$XDG_CONFIG_HOME/opencode
```

Backup konfigurasi yang dibuat installer berada di bawah `.second-brain-backups` dalam direktori konfigurasi OpenCode. Installer tidak memindahkan source code ke vault.

## 2. Cadangkan konfigurasi yang sudah ada

Jika Anda sudah memiliki konfigurasi OpenCode atau vault aktif, buat backup sebelum memasang starter. Jangan menimpa konfigurasi tanpa membaca perbedaannya.

Catat setidaknya:

- lokasi konfigurasi OpenCode;
- lokasi vault;
- daftar proyek yang sudah ada;
- custom command atau instruction yang sudah digunakan.

## 3. Instalasi interaktif

Masuk ke repository starter, lalu jalankan installer:

```bash
cd /path/absolut/opencode-second-brain-starter
./install.sh
```

Jika file belum memiliki izin eksekusi, jalankan dengan Bash tanpa mengubah file:

```bash
bash ./install.sh
```

Installer menanyakan:

```text
Your name:
Existing Obsidian vault path:
```

`Your name` adalah nama pengguna yang akan dirender ke template, bukan nama vault. Untuk path vault, masukkan path absolut yang sudah ada.

Contoh Linux:

```text
Your name: Ayu
Existing Obsidian vault path: /home/ayu/Documents/Second Brain
```

Contoh WSL:

```text
Your name: Ayu
Existing Obsidian vault path: /mnt/c/Users/Ayu/Documents/Second Brain
```

Contoh macOS:

```text
Your name: Ayu
Existing Obsidian vault path: /Users/ayu/Documents/Second Brain
```

## 4. Instalasi noninteraktif

Versi installer saat ini membaca dua environment variable berikut:

```bash
export SECOND_BRAIN_NAME="Ayu"
export SECOND_BRAIN_VAULT="/home/ayu/Documents/Second Brain"
```

Contoh WSL:

```bash
export SECOND_BRAIN_NAME="Ayu"
export SECOND_BRAIN_VAULT="/mnt/c/Users/Ayu/Documents/Second Brain"
```

Contoh macOS:

```bash
export SECOND_BRAIN_NAME="Ayu"
export SECOND_BRAIN_VAULT="/Users/ayu/Documents/Second Brain"
```

Catatan penting:

- `SECOND_BRAIN_NAME` adalah nama pengguna yang dirender ke template.
- `SECOND_BRAIN_VAULT` harus berupa path absolut.
- Jangan memasukkan source code sebagai nilai `SECOND_BRAIN_VAULT`.
- Vault harus sudah ada dan dapat ditulis.

Jalankan instalasi noninteraktif dalam shell yang sama:

```bash
SECOND_BRAIN_NAME="Ayu" \
SECOND_BRAIN_VAULT="/home/ayu/Documents/Second Brain" \
./install.sh
```

Contoh WSL:

```bash
SECOND_BRAIN_NAME="Ayu" \
SECOND_BRAIN_VAULT="/mnt/c/Users/Ayu/Documents/Second Brain" \
./install.sh
```

Jika input bukan terminal interaktif dan salah satu variabel tidak tersedia, installer berhenti dengan pesan error.

## 5. Permission vault di OpenCode

Vault berada di luar direktori source code sehingga OpenCode memerlukan izin `external_directory`.

Jika belum ada `opencode.jsonc` atau `opencode.json`, installer membuat `opencode.jsonc` terkelola. Sharing sesi dinonaktifkan, akses external directory diizinkan hanya untuk vault, dan operasi edit pada vault disetel ke `ask` agar OpenCode meminta persetujuan tool-level.

```text
<path-vault>/**
```

Jika file konfigurasi sudah ada dan izin vault belum tersedia, installer tidak menggabungkan JSON/JSONC secara otomatis. Installer menampilkan peringatan dan instruksi agar Anda menambahkan entri ke object `permission` yang sudah ada sambil mempertahankan provider, model, plugin, dan izin lain. Instalasi tetap selesai; sebelum permission ditambahkan, OpenCode dapat meminta izin ketika mencoba mengakses vault.

Contoh konsep konfigurasi:

```jsonc
{
  "permission": {
    "external_directory": {
      "/home/ayu/Documents/Second Brain/**": "allow"
    },
    "edit": {
      "*": "allow",
      "/home/ayu/Documents/Second Brain/**": "ask"
    }
  }
}
```

Di WSL:

```jsonc
{
  "permission": {
    "external_directory": {
      "/mnt/c/Users/Ayu/Documents/Second Brain/**": "allow"
    },
    "edit": {
      "*": "allow",
      "/mnt/c/Users/Ayu/Documents/Second Brain/**": "ask"
    }
  }
}
```

Gabungkan ke konfigurasi aktual; jangan mengganti seluruh file dengan contoh jika sudah ada pengaturan lain. Setelah mengedit izin secara manual, jalankan:

```bash
./scripts/verify.sh
```

## 6. Verifikasi hasil

Setelah instalasi, periksa hasil nyata daripada mengandalkan pesan sukses saja:

- konfigurasi berada di lokasi yang diharapkan;
- vault masih dapat dibuka Obsidian;
- catatan lama tidak terhapus;
- OpenCode masih dapat dijalankan;
- command starter yang dikelola muncul atau dikenali;
- tidak ada secret yang tersalin ke vault;
- source code tidak berpindah ke vault.

Verifikasi dapat dijalankan kembali:

```bash
./scripts/verify.sh
```

Skrip memeriksa command yang diperlukan, manifest, vault, kedua blok `AGENTS.md`, struktur awal vault, file command terkelola, placeholder template, serta rule permission vault secara best-effort. Permission yang belum ditambahkan pada konfigurasi existing dilaporkan sebagai peringatan, bukan kegagalan instalasi. Verifier bukan parser JSONC lengkap dan tidak membuktikan bahwa isi catatan proyek sudah benar; OpenCode tetap menjadi validator akhir konfigurasi saat dimulai ulang.

Periksa deskripsi `/brain-init`, `/start`, `/done`, `/capture`, `/brain-weekly`, dan `/brain-fix-paths` sebelum penggunaan pertama. Panduan alur tersedia di [06 - Alur Kerja Harian](06-DAILY-WORKFLOW.md).

## 7. Memperbarui starter

Setelah memperoleh versi repository yang lebih baru, baca perubahan lalu jalankan dari root starter:

```bash
./update.sh
```

`update.sh` memerlukan manifest instalasi. Skrip membuat backup file terkelola yang ada, memperbarui command serta blok global dan vault yang terkelola, membuang command lama yang tercatat dalam manifest tetapi tidak lagi ada pada template baru, lalu menjalankan verifikasi. Ia menolak menimpa command baru yang tidak dikelola.

Jika file permission awalnya dibuat dan dikelola installer, update mempertahankan blok tersebut. Untuk konfigurasi existing yang tidak dikelola, Anda mungkin tetap perlu menggabungkan permission secara manual.

## 8. Menghapus starter

Untuk menghapus komponen yang dikelola installer:

```bash
./uninstall.sh
```

Skrip memerlukan manifest, membuat backup file terkait, menghapus command yang tercatat, menghapus blok terkelola dari `AGENTS.md` global dan vault, serta menghapus permission hanya jika permission tersebut memang dibuat dalam mode terkelola. Folder proyek, Inbox, dan template vault tidak dihapus.

Tetap baca output dan backup sebelum menghapus file secara manual.

## Instalasi pada beberapa komputer

Pasang konfigurasi OpenCode pada setiap komputer sesuai kebutuhan. Jangan berasumsi sinkronisasi vault juga menyinkronkan konfigurasi OpenCode, dependency, kredensial, atau command lokal.

Untuk setiap komputer:

1. instal OpenCode secara resmi;
2. autentikasi secara terpisah dan aman;
3. sediakan vault pada path lokal yang benar;
4. jalankan `install.sh` pada komputer tersebut;
5. sesuaikan `code_paths` dengan path absolut aktual;
6. uji satu proyek.

Karena vault disinkronkan, satu `_project.md` dapat menyimpan path dari beberapa komputer. Pertahankan semua path absolut yang masih dipakai, misalnya `/home/ayu/code/kasir` di laptop Linux dan `/Users/ayu/Developer/kasir` di Mac. Path yang tidak tersedia di komputer saat ini boleh tetap tercatat; jangan menghapusnya tanpa memastikan komputer lain sudah tidak memakainya.

## Checklist

- [ ] Isi installer diperiksa sebelum dijalankan.
- [ ] Konfigurasi lama dicadangkan.
- [ ] Path vault bersifat absolut.
- [ ] Di WSL, path vault menggunakan `/mnt/c/...`, bukan `C:\...`.
- [ ] `SECOND_BRAIN_NAME` dan `SECOND_BRAIN_VAULT` digunakan bersama untuk mode noninteraktif.
- [ ] Permission `external_directory` sudah tersedia.
- [ ] Hasil instalasi diverifikasi dari filesystem dan OpenCode.
- [ ] Source code dan isi vault tidak dipindahkan oleh proses instalasi.

Berikutnya: [05 - Proyek Pertama, Baru, dan Existing](05-PROJECTS.md).
