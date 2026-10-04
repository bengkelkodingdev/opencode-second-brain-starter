# 04 - Memasang Starter

Repository menyediakan skrip PowerShell untuk Windows serta skrip Bash untuk Linux/macOS. Bagian ini menjelaskan alur instalasi, pembaruan, penghapusan, dan verifikasi. Baca kembali skrip jika Anda menggunakan versi lain.

## Prasyarat

- Obsidian sudah terpasang.
- Satu vault sudah dibuat.
- OpenCode sudah terpasang dan dapat diautentikasi.
- Path absolut vault diketahui dari lingkungan tempat OpenCode berjalan.
- Repository starter diperoleh dari sumber tepercaya.
- Git tersedia pada `PATH`.
- Sistem yang digunakan adalah Windows native, Linux, atau macOS.

Contoh path vault:

```text
Windows: C:\Users\Ayu\Documents\Second Brain
Linux:   /home/ayu/Documents/Second Brain
macOS:   /Users/ayu/Documents/Second Brain
```

Gunakan path native lingkungan yang menjalankan OpenCode dan installer. Di Windows native, pertahankan format `C:\...`.

## 1. Periksa isi repository

Masuk ke direktori repository starter dan lihat berkas yang tersedia.

Windows PowerShell:

```powershell
Set-Location "C:\path\absolut\opencode-second-brain-starter"
Get-ChildItem
```

Linux atau macOS:

```bash
cd /path/absolut/opencode-second-brain-starter
ls
```

Baca `README.md`, dokumentasi, dan skrip sebelum menjalankannya. `install.ps1` dan `install.sh`:

- memeriksa keberadaan command `opencode` dan `git`;
- menggunakan lingkungan native tempat skrip dijalankan;
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

Di Linux dan macOS, direktori konfigurasi default adalah:

```text
~/.config/opencode
```

Jika `XDG_CONFIG_HOME` disetel, installer menggunakan:

```text
$XDG_CONFIG_HOME/opencode
```

Di Windows, gunakan lokasi konfigurasi yang dilaporkan installer atau dokumentasi OpenCode native.

Backup konfigurasi yang dibuat installer berada di bawah `.second-brain-backups` dalam direktori konfigurasi OpenCode. Installer tidak memindahkan source code ke vault.

## 2. Cadangkan konfigurasi yang sudah ada

Jika Anda sudah memiliki konfigurasi OpenCode atau vault aktif, buat backup sebelum memasang starter. Jangan menimpa konfigurasi tanpa membaca perbedaannya.

Catat setidaknya:

- lokasi konfigurasi OpenCode;
- lokasi vault;
- daftar proyek yang sudah ada;
- custom command atau instruction yang sudah digunakan.

## 3. Instalasi interaktif

Masuk ke repository starter, lalu jalankan installer.

Windows PowerShell:

```powershell
Set-Location "C:\path\absolut\opencode-second-brain-starter"
.\install.ps1
```

Jika eksekusi skrip diblokir oleh policy, jalankan proses sekali pakai berikut. Perintah ini tidak mengubah execution policy sistem:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Linux atau macOS:

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

Contoh Windows native:

```text
Your name: Ayu
Existing Obsidian vault path: C:\Users\Ayu\Documents\Second Brain
```

Contoh Linux:

```text
Your name: Ayu
Existing Obsidian vault path: /home/ayu/Documents/Second Brain
```

Contoh macOS:

```text
Your name: Ayu
Existing Obsidian vault path: /Users/ayu/Documents/Second Brain
```

## 4. Instalasi noninteraktif

Installer membaca `SECOND_BRAIN_NAME` dan `SECOND_BRAIN_VAULT`. Di Windows PowerShell:

```powershell
$env:SECOND_BRAIN_NAME = "Ayu"
$env:SECOND_BRAIN_VAULT = "C:\Users\Ayu\Documents\Second Brain"
.\install.ps1
```

Untuk menjalankan mode yang sama tanpa terhalang execution policy:

```powershell
$env:SECOND_BRAIN_NAME = "Ayu"
$env:SECOND_BRAIN_VAULT = "C:\Users\Ayu\Documents\Second Brain"
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Di Linux atau macOS:

```bash
export SECOND_BRAIN_NAME="Ayu"
export SECOND_BRAIN_VAULT="/home/ayu/Documents/Second Brain"
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

Jika input bukan terminal interaktif dan salah satu variabel tidak tersedia, installer berhenti dengan pesan error.

## 5. Permission vault di OpenCode

Vault berada di luar direktori source code sehingga OpenCode memerlukan izin `external_directory`.

Jika belum ada `opencode.jsonc` atau `opencode.json`, installer membuat `opencode.jsonc` terkelola. Sharing sesi dinonaktifkan, akses external directory diizinkan hanya untuk vault, dan operasi edit pada vault disetel ke `ask` agar OpenCode meminta persetujuan tool-level.

```text
<path-vault>/**
```

Jika file konfigurasi sudah ada dan izin vault belum tersedia, installer tidak menggabungkan JSON/JSONC secara otomatis. Installer menampilkan peringatan dan instruksi agar Anda menambahkan entri ke object `permission` yang sudah ada sambil mempertahankan provider, model, plugin, dan izin lain. Instalasi tetap selesai; sebelum permission ditambahkan, OpenCode dapat meminta izin ketika mencoba mengakses vault.

Contoh konsep konfigurasi Windows native. Backslash ditulis ganda karena contoh ini menggunakan JSONC:

```jsonc
{
  "permission": {
    "external_directory": {
      "C:\\Users\\Ayu\\Documents\\Second Brain\\**": "allow"
    },
    "edit": {
      "*": "allow",
      "C:\\Users\\Ayu\\Documents\\Second Brain\\**": "ask"
    }
  }
}
```

Contoh konsep konfigurasi Linux:

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

Gabungkan ke konfigurasi aktual; jangan mengganti seluruh file dengan contoh jika sudah ada pengaturan lain. Setelah mengedit izin secara manual, jalankan verifikasi.

Windows PowerShell:

```powershell
.\scripts\verify.ps1
```

Linux atau macOS:

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

Verifikasi dapat dijalankan kembali.

Windows PowerShell:

```powershell
.\scripts\verify.ps1
```

Linux atau macOS:

```bash
./scripts/verify.sh
```

Skrip memeriksa command yang diperlukan, manifest, vault, kedua blok `AGENTS.md`, struktur awal vault, file command terkelola, placeholder template, serta rule permission vault secara best-effort. Permission yang belum ditambahkan pada konfigurasi existing dilaporkan sebagai peringatan, bukan kegagalan instalasi. Verifier bukan parser JSONC lengkap dan tidak membuktikan bahwa isi catatan proyek sudah benar; OpenCode tetap menjadi validator akhir konfigurasi saat dimulai ulang.

Periksa deskripsi `/brain-init`, `/start`, `/done`, `/capture`, `/brain-weekly`, dan `/brain-fix-paths` sebelum penggunaan pertama. Panduan alur tersedia di [06 - Alur Kerja Harian](06-DAILY-WORKFLOW.md).

## 7. Memperbarui starter

Setelah memperoleh versi repository yang lebih baru, baca perubahan lalu jalankan dari root starter.

Windows PowerShell:

```powershell
.\update.ps1
```

Linux atau macOS:

```bash
./update.sh
```

`update.ps1` dan `update.sh` memerlukan manifest instalasi. Skrip membuat backup file terkelola yang ada, memperbarui command serta blok global dan vault yang terkelola, membuang command lama yang tercatat dalam manifest tetapi tidak lagi ada pada template baru, lalu menjalankan verifikasi. Skrip menolak menimpa command baru yang tidak dikelola.

Jika file permission awalnya dibuat dan dikelola installer, update mempertahankan blok tersebut. Untuk konfigurasi existing yang tidak dikelola, Anda mungkin tetap perlu menggabungkan permission secara manual.

## 8. Menghapus starter

Untuk menghapus komponen yang dikelola installer, gunakan command sesuai platform.

Windows PowerShell:

```powershell
.\uninstall.ps1
```

Linux atau macOS:

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
4. jalankan `install.ps1` di Windows atau `install.sh` di Linux/macOS;
5. sesuaikan `code_paths` dengan path absolut aktual;
6. uji satu proyek.

Karena vault disinkronkan, satu `_project.md` dapat menyimpan path dari beberapa komputer. Pertahankan semua path absolut yang masih dipakai, misalnya `C:\Users\Ayu\source\kasir` di Windows, `/home/ayu/code/kasir` di Linux, dan `/Users/ayu/Developer/kasir` di macOS. Path yang tidak tersedia di komputer saat ini boleh tetap tercatat; jangan menghapusnya tanpa memastikan komputer lain sudah tidak memakainya.

## Checklist

- [ ] Isi installer diperiksa sebelum dijalankan.
- [ ] Konfigurasi lama dicadangkan.
- [ ] Path vault bersifat absolut.
- [ ] Format path sesuai lingkungan yang menjalankan OpenCode.
- [ ] `SECOND_BRAIN_NAME` dan `SECOND_BRAIN_VAULT` digunakan bersama untuk mode noninteraktif.
- [ ] Permission `external_directory` sudah tersedia.
- [ ] Hasil instalasi diverifikasi dari filesystem dan OpenCode.
- [ ] Source code dan isi vault tidak dipindahkan oleh proses instalasi.

## WSL opsional

Jika Anda sengaja menjalankan OpenCode di WSL, gunakan skrip Bash dan path Linux dari terminal WSL:

```bash
SECOND_BRAIN_NAME="Ayu" \
SECOND_BRAIN_VAULT="/mnt/c/Users/Ayu/Documents/Second Brain" \
./install.sh
```

Gunakan `./update.sh`, `./uninstall.sh`, dan `./scripts/verify.sh` untuk siklus berikutnya. Jangan menjalankan skrip PowerShell native untuk mengelola instalasi OpenCode yang berada di WSL.

Berikutnya: [05 - Proyek Pertama, Baru, dan Existing](05-PROJECTS.md).
