# 🗒️ Keeply

**Keeply** adalah aplikasi catatan sederhana yang terinspirasi dari Google Keep. Aplikasi ini dibuat menggunakan **Flutter** dengan penyimpanan lokal menggunakan **Hive**, sehingga dapat digunakan tanpa koneksi internet.

---

## Fitur Utama

* ✏️ Membuat dan mengedit catatan dengan cepat.
* 🎨 Memilih warna latar catatan agar tampilan lebih menarik.
* 🔍 Mencari catatan berdasarkan judul dan isi.
* ✅ Mendukung daftar tugas (checkbox).
* 💾 Menyimpan data secara lokal tanpa perlu internet.
* 📦 Ukuran aplikasi sangat kecil.

---

## Teknologi

* **Flutter** — Framework utama.
* **Statefull** — State management.
* **Hive** — Database lokal.

---

## Cara Menjalankan

1. Clone repository:

   ```bash
   git clone https://github.com/khoirul-mustofa/keeply.git
   ```
2. Masuk ke folder proyek:

   ```bash
   cd keeply
   ```
3. Jalankan perintah berikut:

   ```bash
   flutter pub get
   flutter run
   ```

---

## Struktur Proyek

```
lib/
  models/        # Model data catatan
  pages/         # Halaman utama aplikasi
  services/      # Layanan untuk Hive
  widgets/       # Widgets yang digunakan
  main.dart      # Titik masuk aplikasi
```

---

## Rencana Pengembangan

* Tambah mode gelap.
* Fitur pengingat dan arsip catatan.
* Sinkronisasi cloud untuk backup data.

---

## Cara Berkontribusi

Kontribusi sangat terbuka bagi siapa pun yang ingin membantu pengembangan **Keeply**. Berikut langkah-langkahnya:

1. Fork repository ini.
2. Buat branch baru untuk fitur atau perbaikan Anda:

   ```bash
   git checkout -b fitur-baru-anda
   ```
3. Lakukan perubahan, lalu commit:

   ```bash
   git commit -m "Menambahkan fitur baru"
   ```
4. Push ke branch Anda dan buat pull request.

Setiap kontribusi, besar maupun kecil, sangat berarti untuk pengembangan proyek ini.

---

Dikembangkan oleh **Khoirul Mustofa** dengan tujuan membuat aplikasi catatan yang ringan, rapi, dan mudah digunakan.

**Keeply — Catatan sederhana yang tetap ringan.**
