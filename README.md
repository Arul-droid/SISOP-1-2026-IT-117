# Laporan Praktikum1_SISOP

## Soal 1 (Argo Ngawi Jes Ngejes)
pada soal no 1 kami ditugaskan untuk membuat sebuah script AWK untuk menganalisa sebuah gerbong kereta.

### Mendownload file CSV
yang pertama kali yang harus kita lakukan adalah mendownload file csv ke ke dalam directory menggunakan terminal.

Maka dari itu kita perlu membuat sebuah script untuk downloadnya.

```bash
wget -O passenger.csv "https://docs.google.com/spreadsheets/d/1NHmyS6wRO7To7ta-NLOOLHkPS6valvNaX7tawsv1zfE/export?format=csv&gid=0"
```
setelah mendownload file tersebut ke dalam directory soal 1 baru kita bisa memulai membuat script analisanya.

### Memulai script analisa
#### Membuat perintah untuk input

pada soalnya diberikan beberapa subsoal untuk dikerjakan dari a hingga e.

yang dimana nanti cara untuk menjalankan script awknya adalah memberikan input sesuai dengan subsoal yang ada.

seperti:

```bash
awk -f KANJ.sh passenger.csv a   # total penumpang
awk -f KANJ.sh passenger.csv b   # jumlah gerbong
awk -f KANJ.sh passenger.csv c   # penumpang tertua
awk -f KANJ.sh passenger.csv d   # rata-rata usia
awk -f KANJ.sh passenger.csv e   # jumlah business class
```
agar dapat menjalankan script itu kita perlu membuat file .sh nya terlebih dahulu dengan

```bash
nano KANJ.sh
```

kemudian kita isi file tersebut dengan script awk.

pertama kita perlu menulis kode untuk inputnya dengan

```bash
BEGIN {
    FS = ","
    opsi = ARGV[2]
    ARGC = 2
}
```

Ini adalah blok `BEGIN` di awk script. Dijalankan sekali sebelum membaca file CSV.

`FS = ","` Menset pemisah kolom (Field Separator) menjadi koma, karena file CSV dipisahkan dengan koma. Tanpa ini, awk akan pakai spasi sebagai pemisah default.

`opsi = ARGV[2]` Mengambil argumen ketiga dari command line dan menyimpannya ke variabel opsi.

```bash
awk -f KANJ.sh passenger.csv a
```
```bash
Maka:

ARGV[0] = "awk"
ARGV[1] = "passenger.csv"
ARGV[2] = "a"          ← disimpan ke opsi
```

`ARGC = 2`
Membatasi jumlah argumen yang diproses awk menjadi 2 saja (awk dan passenger.csv).
Tanpa ini, awk akan mencoba membuka "a" sebagai file karena mengira itu nama file kedua, lalu error karena file "a" tidak ada.

#### Masuk ke subsoal
##### Soal a
Pada soal a kami ditugaskan untuk menghitung jumlah seluruh penumpang kereta.

dengan contoh output:
```bash
Jumlah seluruh penumpang KANJ adalah ${coutn_passenger} orang
```
untuk itu kita perlu menulis script
```bash
END {
    count = NR - 1
    if (opsi == "a") print "Jumlah seluruh penumpang KANJ adalah", count, "orang"
}
```
`END` merupakan block kode yang dijalankan setelah semua baris telah dibaca
`count = NR-1` menyimpan semua baris kecuali baris pertama kedalam variabel count
`if (opsi == "a") print "Jumlah seluruh penumpang KANJ adalah", count, "orang"` akan mengeprint 

```bash
Jumlah seluruh penumpang KANJ adalah 208 orang
```
jika memilih opsi a.

##### soal b
Pada soal b kami ditugaskan untuk menghitung jumlah gerbong kereta.

dengan contoh output:
```bash
Jumlah gerbong penumpang KANJ adalah ${carriege}
```
untuk itu kita perlu menulis script
```bash
NR > 1 {
    # b: hitung gerbong unik
    gsub(/\r/, "")      # hapus karakter windows (penyebab umum)
    gsub(/ /, "", $4)
    gerbong[$4] = 1
}

END {
    else if (opsi == "b") print "Jumlah gerbong penumpang KANJ adalah", length(gerbong)
}
```
`NR > 1`
Proses mulai dari baris ke-2, skip baris pertama (header `Nama Penumpang,Usia,Kursi Kelas,Gerbong`).

`gsub(/\r/, "")`
Menghapus karakter `\r` (carriage return) dari seluruh baris. Ini muncul karena file CSV dibuat di Windows yang menggunakan `\r\n` sebagai akhir baris, sedangkan Linux hanya pakai `\n`. Kalau tidak dihapus, nilai kolom bisa terbaca sebagai `"Gerbong1\r"` yang berbeda dengan `"Gerbong1"`.

`gsub(/ /, "", $4)`
Menghapus semua spasi di kolom ke-4 (kolom Gerbong). Mencegah `" Gerbong1"` dan `"Gerbong1"` dianggap berbeda karena ada spasi tersembunyi.

`gerbong[$4] = 1`
Menyimpan nama gerbong ke dalam array. Karena array tidak bisa punya key duplikat, otomatis hanya menyimpan gerbong yang unik:

```bash
gerbong["Gerbong1"] = 1
gerbong["Gerbong2"] = 1
gerbong["Gerbong2"] = 1  ← diabaikan, sudah ada
gerbong["Gerbong3"] = 1
gerbong["Gerbong4"] = 1
```

`END` merupakan block kode yang dijalankan setelah semua baris telah dibaca
`length(gerbong)`
Menghitung jumlah elemen dalam array `gerbong` = jumlah gerbong unik
`else if (opsi == "b") print "Jumlah gerbong penumpang KANJ adalah", length(gerbong)` akan mengeprint 

```bash
Jumlah gerbong penumpang KANJ adalah 4
```
jika memilih opsi b.

##### soal c
Pada soal c kami ditugaskan untuk mencari tau siapa penumpang tertua yang ada di dalam kereta serta menampilkan umurnya.

dengan contoh output:
```bash
${oldest} adalah penumpang kereta tertua dengan usia ${max_age} tahun
```
untuk itu kita perlu menulis script
```bash
NR > 1 {
    # c: cari penumpang tertua
    if ($2 > max_age) {
        max_age = $2
        oldest = $1
    }
}
END {
    else if (opsi == "c") print oldest, "adalah penumpang kereta tertua dengan usia", max_age, "tahun"
}
```
`NR > 1` akan membaca file csv dari baris 2 hingga akhir
`if ($2 > max_age) {
        max_age = $2
        oldest = $1
    }` akan menjalan kan `max_age = $2` dan `oldest = $1` jika kolom kedua yang berisi umur lebih besar dari variabel `max_age`
kemudian variabel `max_age` akan menyimpan umur ketika memenuhi syarat dan sekaligus varibel `oldest` akan menyimpan nama dari pemilik umur tersebut

`END` merupakan block kode yang dijalankan setelah semua baris telah dibaca
`(opsi == "c") print oldest, "adalah penumpang kereta tertua dengan usia", max_age, "tahun"` akan mengeprint 

```bash
Jaja Mihardja adalah penumpang kereta tertua dengan usia 85 tahun
```
jika memilih opsi c.

##### soal d
Pada soal d kami ditugaskan untuk menghitung rata-rata usia seluruh penumpang dengan membulatkan hasilnya tanpa koma.

dengan contoh output:
```bash
Rata-rata usia penumpang adalah ${average_age} tahun
```
untuk itu kita perlu menulis script
```bash
NR > 1 {
    # d: hitung rata-rata usia
    total_age += $2
}
END {
    else if (opsi == "d") print "Rata-rata usia penumpang adalah", int(total_age / count), "tahun"
}
```
`NR > 1` akan membaca file csv dari baris 2 hingga akhir
`total_age += $2` akan menambahkan dari baris ke dua hingga terkahir semua umur yang ada dan menjumlahkannya
`int(total_age / count)` akan membagi variabel `total_age` dengan variabel `count` yang tadi sudah dibuat pada opsi a

`END` merupakan block kode yang dijalankan setelah semua baris telah dibaca
`else if (opsi == "d") print "Rata-rata usia penumpang adalah", int(total_age / count), "tahun"` akan mengeprint 

```bash
Rata-rata usia penumpang adalah 37 tahun
```
jika memilih opsi d.

##### soal e
Pada soal e kami ditugaskan untuk menghitung jumlah penumpang yang berada pada kelas business pada kereta.

dengan contoh output:
```bash
Jumlah penumpang business class ada ${business_passenger} orang
```
untuk itu kita perlu menulis script
```bash
NR > 1 {
    # e: hitung penumpang business class
    if ($3 == "Business") business++
}
END {
    else if (opsi == "e") print "Jumlah penumpang business class ada", business, "orang"
}
```
`NR > 1` akan membaca file csv dari baris 2 hingga akhir
`if ($3 == "Business") business++` akan menambahkan jika pada kolom kelas terdapat strinh business ke variabel `business`

`END` merupakan block kode yang dijalankan setelah semua baris telah dibaca
`else if (opsi == "e") print "Jumlah penumpang business class ada", business, "orang"` akan mengeprint 

```bash
Jumlah penumpang business class ada 74 orang
```
jika memilih opsi e.

##### jika memilih selain a hingga e
jika kita memilih opsi selain a hingga e maka akan muncul output 

```bash
Soal tidak dikenali. Gunakan a, b, c, d, atau e
```

untuk itu kita perlu menulis script

```bash
END {
    else print "Soal tidak dikenali. Gunakan a, b, c, d, atau e"
}
```

`else print "Soal tidak dikenali. Gunakan a, b, c, d, atau e"` akan mengeprint 

```bash
Soal tidak dikenali. Gunakan a, b, c, d, atau e
```
jika memilih opsi selain a hingga e.

## Soal 2 (Ekspedisi Gunung Kawi)
Script bash untuk parsing koordinat dari file JSON.

## Soal 3 (Kost Slebew)
Script bash untuk manajemen kost berbasis CLI.
