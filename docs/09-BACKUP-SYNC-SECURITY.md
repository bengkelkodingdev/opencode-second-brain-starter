# 09 - Backup, Sinkronisasi, dan Keamanan

Vault berisi konteks kerja yang bernilai dan mungkin sensitif. Perlakukan sebagai data penting, tetapi jangan gunakan vault sebagai tempat penyimpanan rahasia.

## Tiga konsep berbeda

| Konsep | Tujuan | Melindungi dari |
| --- | --- | --- |
| Backup | Memulihkan versi atau data yang hilang | Penghapusan, kerusakan, kesalahan manusia |
| Sinkronisasi | Menyamakan berkas antarperangkat | Keterlambatan akses antarperangkat |
| Keamanan | Membatasi akses dan kebocoran | Pengguna atau aplikasi yang tidak berwenang |

Sinkronisasi bukan backup. Jika sebuah file terhapus lalu penghapusan tersinkron, semua perangkat dapat kehilangan file tersebut.

## Strategi backup minimum

Gunakan prinsip 3-2-1 bila memungkinkan:

- tiga salinan data;
- dua jenis media atau lokasi;
- satu salinan berada di lokasi terpisah.

Contoh praktis:

- vault aktif di laptop;
- backup terjadwal ke drive eksternal;
- backup terenkripsi ke layanan cloud tepercaya.

Pastikan backup memiliki riwayat versi. Uji pemulihan secara berkala, bukan hanya memeriksa bahwa proses backup berjalan.

## Apa yang dicadangkan

Cadangkan:

- seluruh vault;
- konfigurasi penting yang aman untuk disimpan;
- dokumentasi cara memulihkan;
- daftar proyek dan path sebagai referensi, tanpa secret.

Source code dicadangkan secara terpisah melalui remote Git, backup repository privat, atau mekanisme organisasi. Jangan menyalin repository ke vault hanya demi backup.

Dependency dan build artifact umumnya tidak perlu dimasukkan ke backup source code jika dapat dibuat ulang.

Installer juga membuat backup konfigurasi yang disentuh di `~/.config/opencode/.second-brain-backups/`. Direktori ini dibuat dengan akses terbatas untuk pengguna saat installer berjalan. Karena konfigurasi lama mungkin berisi credential, jangan commit atau membagikan direktori backup tersebut. Tinjau dan hapus backup lama secara manual setelah instalasi stabil dan Anda yakin tidak memerlukannya untuk pemulihan.

## Memilih sinkronisasi

Pilihan dapat berupa Obsidian Sync atau layanan sinkronisasi filesystem yang sesuai dengan kebutuhan dan kebijakan organisasi. Sebelum memilih, periksa:

- enkripsi saat transit dan saat tersimpan;
- dukungan end-to-end encryption jika dibutuhkan;
- version history;
- lokasi penyimpanan data;
- batas ukuran dan jumlah file;
- perilaku konflik;
- kebijakan data perusahaan;
- dukungan lintas Windows, Linux, WSL, dan macOS.

Tidak ada layanan sinkronisasi yang diwajibkan oleh starter ini.

## Risiko sinkronisasi simultan

Hindari mengedit catatan yang sama secara bersamaan dari dua komputer. Konflik dapat menghasilkan:

- dua versi file;
- isi tertimpa;
- file conflict dengan nama tambahan;
- log dengan urutan membingungkan.

Praktik aman:

1. tunggu sinkronisasi selesai sebelum mulai bekerja;
2. gunakan satu perangkat sebagai penulis aktif;
3. tutup sesi OpenCode yang masih menulis sebelum berpindah perangkat;
4. periksa conflict file sebelum melanjutkan;
5. jangan menghapus versi konflik sebelum membandingkan isinya.

## Git untuk vault

Git dapat memberikan riwayat versi, tetapi bukan pilihan otomatis untuk semua pengguna. Jika menggunakan Git:

- gunakan repository privat;
- periksa setiap perubahan sebelum commit;
- jangan commit secret;
- pahami bahwa menghapus secret pada commit terbaru tidak menghapusnya dari history;
- batasi akses collaborator;
- gunakan backup tambahan di luar Git.

Community Plugin Obsidian tidak diperlukan untuk menggunakan Git. Operasi Git dapat dilakukan di luar Obsidian oleh pengguna yang memahaminya.

## Data yang tidak boleh masuk vault

Jangan simpan:

- API key dan access token;
- password;
- private key, recovery code, atau seed phrase;
- isi `.env`;
- cookie atau session dump;
- data produksi mentah;
- data pribadi pelanggan;
- credential cloud atau database;
- dokumen rahasia yang tidak diizinkan kebijakan organisasi.

Gunakan secret manager, password manager, atau mekanisme credential resmi. Di catatan, tulis referensi nonrahasia:

```text
Credential deployment disimpan di secret manager tim dengan nama deployment/fleettrack-prod.
```

Jangan tulis nilainya.

## Jika secret terlanjur tercatat

Anggap secret sudah bocor, terutama jika vault tersinkron atau masuk Git.

1. Cabut atau rotasi secret segera.
2. Hentikan sinkronisasi sementara jika membantu mencegah penyebaran lebih lanjut.
3. Hapus secret dari file aktif.
4. Bersihkan history dan backup sesuai prosedur layanan serta kebijakan organisasi.
5. Periksa log akses provider.
6. Beri tahu pihak keamanan atau pemilik sistem jika relevan.
7. Dokumentasikan insiden tanpa menyalin nilai secret.

Penghapusan biasa tidak cukup jika nilai sudah masuk version history, backup, atau perangkat lain.

## Izin filesystem

Batasi akses vault ke akun yang membutuhkannya. Pada komputer bersama:

- gunakan akun pengguna terpisah;
- aktifkan enkripsi disk;
- kunci layar saat meninggalkan komputer;
- hindari folder publik;
- periksa izin layanan sinkronisasi;
- jangan menjalankan tool yang tidak tepercaya terhadap vault.

Di perangkat organisasi, ikuti kebijakan IT dan klasifikasi data yang berlaku.

## WSL dan keamanan

Vault Windows yang diakses melalui `/mnt/c` tetap merupakan data pada drive Windows. Perlindungannya bergantung pada:

- akun Windows;
- enkripsi drive;
- izin filesystem Windows;
- keamanan distribusi WSL;
- aplikasi Windows dan Linux yang memiliki akses.

OpenCode di WSL tidak memerlukan Obsidian terbuka untuk membaca file. Tutup Obsidian bukan mekanisme pengamanan terhadap akses filesystem.

## Jadwal pemeliharaan

### Harian

- pastikan sinkronisasi tidak menampilkan konflik;
- periksa catatan baru agar tidak memuat secret.

### Mingguan

- pastikan backup terbaru berhasil;
- tinjau proyek aktif melalui `/brain-weekly` jika tersedia;
- periksa path yang sudah tidak valid.

### Bulanan

- lakukan uji restore ke folder sementara;
- periksa akses collaborator dan perangkat;
- perbarui aplikasi melalui sumber resmi;
- audit kebijakan retensi.

## Checklist

- [ ] Backup dan sinkronisasi dipahami sebagai hal berbeda.
- [ ] Ada lebih dari satu salinan vault.
- [ ] Restore pernah diuji.
- [ ] Source code dicadangkan di luar vault.
- [ ] Tidak ada secret di catatan.
- [ ] Vault Git, jika ada, bersifat privat.
- [ ] Konflik sinkronisasi diperiksa sebelum dihapus.
- [ ] Perangkat menggunakan kontrol akses dan enkripsi yang sesuai.

Berikutnya: [10 - Troubleshooting](10-TROUBLESHOOTING.md).
