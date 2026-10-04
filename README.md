# OpenCode Second Brain Starter

Panduan membangun _second brain_ berbasis Obsidian untuk membantu OpenCode memahami konteks proyek dari sesi ke sesi.

Repository ini berisi dokumentasi, template, dan installer starter. Obsidian berfungsi sebagai penyimpan catatan Markdown; source code tetap berada di luar vault.

## Prinsip utama

- Gunakan satu vault Obsidian untuk seluruh second brain.
- Buat satu folder tingkat teratas di dalam vault untuk setiap proyek logis.
- Simpan source code di luar vault. Jangan menyalin repository aplikasi ke vault.
- Catat lokasi source code sebagai path absolut pada `code_paths`.
- Satu proyek logis boleh menunjuk ke beberapa repository melalui beberapa entri `code_paths`.
- Di Windows, jalankan Obsidian dan OpenCode secara native; gunakan PowerShell untuk command starter.
- Path vault dan `code_paths` harus memakai format native lingkungan yang menjalankan OpenCode.
- Obsidian tidak harus terbuka ketika OpenCode bekerja karena catatan disimpan sebagai berkas Markdown biasa.
- Tidak ada Community Plugin Obsidian yang diwajibkan.
- Jangan simpan password, token, private key, `.env`, atau rahasia lain di vault.

## Gambaran struktur

Contoh vault bernama `Second Brain`:

```text
Second Brain/
├── Inbox/
├── Templates/
├── Toko Online/
│   ├── _project.md
│   ├── _log.md
│   └── ...
├── Aplikasi Absensi/
│   ├── _project.md
│   ├── _log.md
│   └── ...
└── AGENTS.md
```

Source code berada di tempat terpisah:

```text
/home/andi/code/toko-api
/home/andi/code/toko-web
```

Kedua repository tersebut dapat menjadi satu proyek logis `Toko Online` di vault.

## Quick start

1. Instal Obsidian sesuai sistem operasi: [01 - Instalasi Obsidian](docs/01-INSTALL-OBSIDIAN.md).
2. Buat satu vault dan catat path native-nya: [02 - Membuat Vault](docs/02-CREATE-VAULT.md).
3. Instal dan autentikasi OpenCode menggunakan dokumentasi resminya: [03 - Instalasi OpenCode](docs/03-INSTALL-OPENCODE.md).
4. Clone dan pasang starter. Di Windows PowerShell:

```powershell
git clone https://github.com/bengkelkodingdev/opencode-second-brain-starter.git
Set-Location .\opencode-second-brain-starter
.\install.ps1
```

Jika kebijakan eksekusi memblokir skrip, gunakan proses PowerShell sekali pakai tanpa mengubah kebijakan sistem:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Di Linux atau macOS dengan Bash:

```bash
git clone https://github.com/bengkelkodingdev/opencode-second-brain-starter.git
cd opencode-second-brain-starter
./install.sh
```

5. Baca penjelasan installer dan permission: [04 - Memasang Starter](docs/04-INSTALL-STARTER.md).
6. Hubungkan proyek pertama, proyek baru, atau proyek yang sudah ada: [05 - Mengelola Proyek](docs/05-PROJECTS.md).
7. Mulai sesi dari direktori source code. Di Windows PowerShell:

```powershell
Set-Location "C:\Users\Ayu\source\project"
opencode
```

Di Linux atau macOS:

```bash
cd /home/andi/code/toko-api
opencode
```

8. Di dalam sesi OpenCode, gunakan alur berikut:

```text
/brain-init
/start
/capture
/done
/brain-weekly
/brain-fix-paths
```

Jangan menebak fungsi command. Baca [06 - Alur Harian](docs/06-DAILY-WORKFLOW.md) dan petunjuk yang tampil dari instalasi starter Anda.

## Windows native dalam satu contoh

Vault yang digunakan Obsidian dan OpenCode native:

```text
C:\Users\Ayu\Documents\Second Brain
```

Source code tetap di luar vault:

```text
C:\Users\Ayu\source\project
```

Nilai `code_paths` menggunakan format Windows native yang dipahami proses OpenCode:

```yaml
code_paths:
  - C:\Users\Ayu\source\project
```

Aturan yang sama berlaku di semua platform: gunakan `C:\...` ketika OpenCode berjalan native di Windows, `/home/...` di Linux, dan `/Users/...` di macOS. Jangan mencampur format path antarlingkungan.

### WSL opsional

WSL bukan persyaratan panduan ini. Jika Anda sengaja menjalankan OpenCode di WSL, seluruh path yang dibaca OpenCode harus memakai format Linux, misalnya `/mnt/c/Users/Ayu/Documents/Second Brain` untuk vault Windows atau `/home/ayu/code/project` untuk repository di filesystem WSL. Gunakan skrip Bash dari terminal WSL, bukan skrip PowerShell.

## Indeks dokumentasi

1. [Instalasi Obsidian di Windows, Linux, dan macOS](docs/01-INSTALL-OBSIDIAN.md)
2. [Membuat Satu Vault dan Memahami Path Native](docs/02-CREATE-VAULT.md)
3. [Instalasi dan Autentikasi OpenCode](docs/03-INSTALL-OPENCODE.md)
4. [Memasang Starter](docs/04-INSTALL-STARTER.md)
5. [Proyek Pertama, Baru, dan Existing](docs/05-PROJECTS.md)
6. [Alur Kerja Harian](docs/06-DAILY-WORKFLOW.md)
7. [Satu Proyek dengan Banyak Repository](docs/07-MULTI-REPO.md)
8. [Memindahkan Proyek atau Repository](docs/08-MOVING-PROJECTS.md)
9. [Backup, Sinkronisasi, dan Keamanan](docs/09-BACKUP-SYNC-SECURITY.md)
10. [Troubleshooting](docs/10-TROUBLESHOOTING.md)

## Istilah

| Istilah | Arti |
| --- | --- |
| Vault | Folder biasa yang dibuka Obsidian sebagai kumpulan catatan. |
| Proyek logis | Satu produk atau konteks kerja, walaupun source code-nya tersebar di beberapa repository. |
| `code_paths` | Daftar path absolut menuju direktori source code yang terkait dengan proyek. |
| Starter | Konfigurasi, template, command, atau installer yang disertakan oleh versi repository yang digunakan. |

## Lisensi

Dokumentasi ini dilisensikan dengan [MIT License](LICENSE).
