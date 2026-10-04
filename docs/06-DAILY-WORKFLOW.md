# 06 - Alur Kerja Harian

Alur harian menjaga konteks tetap ringkas dan berguna. Command Core adalah `/brain-init`, `/start`, `/done`, `/capture`, `/brain-weekly`, dan `/brain-fix-paths`.

## Ringkasan command

| Command | Kapan digunakan | Tujuan umum |
| --- | --- | --- |
| `/brain-init` | Sekali saat menghubungkan proyek | Membuat atau menginisialisasi konteks proyek |
| `/start` | Awal sesi kerja | Memuat konteks yang relevan dan menyepakati fokus |
| `/capture` | Saat muncul ide mentah yang belum akan dikerjakan | Menaruh ide sementara di `Inbox/` |
| `/done` | Akhir sesi atau setelah satu unit kerja selesai | Merangkum hasil, keputusan, dan langkah berikutnya |
| `/brain-weekly` | Sekali per minggu | Meninjau, merapikan, dan menyaring konteks |
| `/brain-fix-paths` | Setelah repository dipindahkan | Memeriksa dan mengusulkan koreksi `code_paths` |

Jalankan command hanya jika tersedia di instalasi Anda. Baca definisinya jika output tidak sesuai harapan.

## `/brain-init`: menghubungkan proyek

Gunakan ketika:

- proyek belum memiliki folder di vault;
- repository existing baru pertama kali dihubungkan;
- proyek logis baru dibuat;
- beberapa repository akan digabungkan sebagai satu proyek logis.

Sebelum menjalankan:

1. pastikan current working directory adalah repository yang benar;
2. tentukan nama proyek logis;
3. siapkan path absolut semua repository terkait;
4. pastikan belum ada folder proyek duplikat;
5. pastikan vault dapat diakses.

Windows PowerShell:

```powershell
Set-Location "C:\Users\Ayu\source\project"
opencode
```

Linux atau macOS:

```bash
cd /home/ayu/code/kasir-api
opencode
```

Kemudian di OpenCode:

```text
/brain-init
```

Setelah selesai, verifikasi hasil secara manual. Jangan berasumsi command membuat backup, menambahkan semua repository, atau memperbaiki path secara otomatis.

## `/start`: membuka sesi dengan konteks

Gunakan pada awal sesi kerja, terutama setelah berpindah proyek atau kembali setelah beberapa hari.

Contoh:

Windows PowerShell:

```powershell
Set-Location "C:\Users\Ayu\source\project"
opencode
```

Linux atau macOS:

```bash
cd /home/ayu/code/kasir-api
opencode
```

Kemudian:

```text
/start
```

Setelah konteks dimuat, nyatakan tugas secara spesifik:

```text
Perbaiki validasi quantity pada endpoint POST /orders dan tambahkan regression test.
```

Hindari permintaan terlalu umum:

```text
Lanjutkan proyek.
```

Periksa bahwa konteks yang dipakai benar:

- nama proyek sesuai;
- path repository sesuai;
- status terakhir masih relevan;
- keputusan lama belum dibatalkan;
- tidak ada instruksi proyek lain yang tercampur.

## `/capture`: menyimpan ide mentah

Gunakan untuk ide yang belum diketahui tujuan akhirnya atau belum ingin dikerjakan, misalnya:

- ide fitur masa depan;
- pertanyaan yang ingin diteliti;
- bahan diskusi;
- pengingat yang belum menjadi task.

Contoh permintaan:

```text
/capture pertimbangkan export laporan ke format Excel
```

Contoh yang jangan dicatat:

```text
/capture
Password database produksi adalah ...
```

`/capture` selalu menyiapkan file mentah di `Inbox/`. Keputusan arsitektur, hasil test, blocker proyek, dan perubahan path sebaiknya dicatat melalui `/done` agar masuk ke konteks proyek. Jika ragu apakah informasi sensitif, jangan masukkan ke vault.

## `/done`: menutup sesi dengan rapi

Gunakan ketika satu unit kerja selesai atau sebelum meninggalkan sesi. Idealnya hasil akhir mencakup:

- apa yang berubah;
- file atau komponen utama yang terdampak;
- keputusan yang dibuat;
- test atau verifikasi yang dijalankan;
- test yang belum dapat dijalankan;
- blocker;
- langkah berikutnya yang konkret.

Contoh:

```text
/done
```

Sebelum menerima ringkasan, periksa fakta melalui source code, output test, dan status repository. Jangan mencatat test sebagai lulus jika tidak dijalankan.

Obsidian boleh tertutup selama proses ini. OpenCode berinteraksi dengan berkas Markdown di filesystem, bukan dengan jendela aplikasi Obsidian.

## `/brain-weekly`: pemeliharaan mingguan

Lakukan pada waktu yang konsisten, misalnya Jumat sore atau Senin pagi. Tujuannya bukan memperpanjang log, tetapi menjaga informasi penting mudah ditemukan.

Tinjau:

- proyek aktif dan proyek yang seharusnya diarsipkan;
- blocker yang sudah selesai;
- keputusan sementara yang sudah berubah;
- duplikasi catatan;
- `code_paths` yang tidak lagi valid;
- next step yang terlalu lama tertunda;
- catatan yang secara tidak sengaja mengandung data sensitif.

Contoh:

```text
/brain-weekly
```

Verifikasi perubahan sebelum menerima penghapusan atau pemindahan catatan. Perilaku command terhadap arsip dan ringkasan bergantung pada definisi starter Anda.

## `/brain-fix-paths`: memperbaiki lokasi repository

Gunakan setelah repository dipindahkan atau diganti nama. Jalankan OpenCode dari lokasi baru, lalu:

```text
/brain-fix-paths
```

Command memeriksa path lama, mencari kandidat lokasi aktual, dan menampilkan perubahan yang diusulkan. Ia tidak boleh mengubah `_project.md` atau `_log.md` sebelum pengguna menyetujui path lama, path baru, dan catatan log yang akan ditambahkan.

## Ritme kerja yang disarankan

Semua path yang digunakan dalam sesi harus memakai format native lingkungan OpenCode: `C:\...` di Windows native, `/home/...` di Linux, atau `/Users/...` di macOS.

### Awal hari

1. Masuk ke repository yang akan dikerjakan.
2. Jalankan OpenCode.
3. Jalankan `/start` jika tersedia.
4. Nyatakan satu hasil yang ingin dicapai.
5. Konfirmasi proyek dan konteks yang terdeteksi.

### Selama bekerja

1. Simpan source code dan test di repository, bukan vault.
2. Gunakan `/capture` untuk ide mentah.
3. Catat keputusan dan blocker terverifikasi melalui `/done`.
4. Jangan memenuhi vault dengan output build atau transcript mentah.

### Akhir sesi

1. Jalankan test yang relevan.
2. Periksa perubahan repository.
3. Gunakan `/done` jika tersedia.
4. Pastikan ringkasan membedakan fakta, asumsi, dan pekerjaan tersisa.
5. Hapus secret jika tanpa sengaja tercatat, lalu rotasi secret tersebut.

### Mingguan

1. Jalankan `/brain-weekly` jika tersedia.
2. Periksa seluruh proyek aktif.
3. Perbarui path yang berpindah.
4. Cadangkan vault.
5. Audit data sensitif dan konflik sinkronisasi.

## Contoh satu hari lengkap

Windows PowerShell:

```powershell
Set-Location "C:\Users\Ayu\source\toko-api"
opencode
```

Linux atau macOS:

```bash
cd /home/ayu/code/toko-api
opencode
```

```text
/start

Hari ini fokus menambahkan idempotency key pada pembuatan pembayaran. Periksa implementasi dan test yang ada sebelum mengubah kode.

/capture pertimbangkan dashboard untuk memantau request pembayaran duplikat

/done
```

Catatan hasil harus hanya menyimpan konteks yang tahan lama. Detail implementasi lengkap tetap dapat dibaca dari Git dan source code.

## Checklist kualitas catatan

- [ ] Tanggal dan status jelas.
- [ ] Keputusan menyertakan alasan.
- [ ] Fakta dibedakan dari dugaan.
- [ ] Hasil test tidak dikarang.
- [ ] Next step dapat langsung dikerjakan.
- [ ] Tidak ada secret.
- [ ] Source code tetap di repository.

Berikutnya: [07 - Satu Proyek dengan Banyak Repository](07-MULTI-REPO.md).
