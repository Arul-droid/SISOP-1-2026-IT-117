# Laporan Praktikum1_SISOP

## Soal 1 (Argo Ngawi Jes Ngejes)
pada soal no 1 kami ditugaskan untuk membuat sebuah script AWK untuk menganalisa sebuah gerbong kereta.

## Penjelasan

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

### Output
![alt text](image.png)

## Soal 2 (Ekspedisi Gunung Kawi)
Script bash untuk parsing koordinat dari file JSON.

pada soal ke dua ada beberapa step yang harus kita lakukan berdasarkan deskripsi soal

#### Step 1: Buat folder ekspedisi
```bash
mkdir -p ~/praktikum1/soal_2/ekspedisi
cd ~/praktikum1/soal_2/ekspedisi
```

#### Step 2: Install pip dan buat virtual environment
```bash
cd ~
sudo apt install python3.12-venv
python3 -m venv myenv
source ~/myenv/bin/activate
pip install gdown
```

#### Step 3: Download file PDF
```bash
cd ~/praktikum1/soal_2/ekspedisi
gdown https://drive.google.com/uc?id=1q10pHSC3KFfvEiCN3V6PTroPR7YGHF6Q -O peta-ekspedisi-amba.pdf
```

#### Step 4: Baca isi PDF (concatenate)
```bash
cat peta-ekspedisi-amba.pdf | grep -a "https"
Cari link GitHub di dalamnya.
```
![alt text](image.png)

#### Step 5: Install git dan clone repo
```bash
sudo apt install git
git clone https://github.com/pocongcyber77/peta-gunung-kawi.git
```

#### Step 6: Buat parserkoordinat.sh
```bash
cd ~/praktikum1/soal_2/ekspedisi
nano parserkoordinat.sh
Isi script untuk parsing gsxtrack.json → ambil id, site_name, latitude, longitude → simpan ke titik-penting.txt
bashchmod +x parserkoordinat.sh
./parserkoordinat.sh
```
Script ini membaca file `gsxtrack.json` dan mengekstrak data koordinat menggunakan AWK dengan regex.
```bash
#!/bin/bash

awk '
/"id":/ { gsub(/.*"id": "|",/, "", $0); id = $0 }
/"site_name":/ { gsub(/.*"site_name": "|",/, "", $0); site = $0 }
/"latitude":/ { gsub(/.*"latitude": |,/, "", $0); lat = $0 }
/"longitude":/ { gsub(/.*"longitude": |,/, "", $0); lon = $0; print id "," site "," lat "," lon }
' gsxtrack.json | sort > titik-penting.txt

cat titik-penting.txt
```
- `/"id":/` → mendeteksi baris yang mengandung kata `"id"` di file JSON
- `gsub(/.*"id": "|",/, "", $0)` → membersihkan karakter yang tidak diperlukan, menyisakan nilai id saja
- Hal yang sama dilakukan untuk `site_name`, `latitude`, dan `longitude`
- `print id "," site "," lat "," lon` → mencetak hasil dalam format CSV ketika baris `longitude` ditemukan (karena longitude adalah field terakhir)
- `| sort` → mengurutkan hasil berdasarkan id (node_001, node_002, dst)
- `> titik-penting.txt` → menyimpan hasil ke file `titik-penting.txt`
##### output
![alt text](image-1.png)


#### Step 7: Buat nemupusaka.sh
```bash
nano nemupusaka.sh
Isi script untuk hitung titik tengah diagonal dari titik-penting.txt → simpan ke posisipusaka.txt
bashchmod +x nemupusaka.sh
./nemupusaka.sh
```
Script ini menghitung titik tengah diagonal persegi dari 4 koordinat menggunakan rumus titik tengah.
```bash
#!/bin/bash

lat=$(awk -F',' 'NR==1{lat1=$3} NR==3{lat2=$3} END{printf "%.6f", (lat1+lat2)/2}' titik-penting.txt)
lon=$(awk -F',' 'NR==1{lon1=$4} NR==3{lon2=$4} END{printf "%.6f", (lon1+lon2)/2}' titik-penting.txt)

echo "$lat,$lon" > posisipusaka.txt

echo "Koordinat pusat:"
cat posisipusaka.txt
```
- `-F','` → set pemisah kolom dengan koma
- `NR==1` → ambil data dari baris pertama (node_001)
- `NR==3` → ambil data dari baris ketiga (node_003)
- node_001 dan node_003 dipilih karena keduanya adalah **diagonal** dari persegi yang dibentuk 4 node
- `(lat1+lat2)/2` → menghitung rata-rata latitude (rumus titik tengah)
- `(lon1+lon2)/2` → menghitung rata-rata longitude (rumus titik tengah)
- `printf "%.6f"` → memformat hasil dengan 6 angka di belakang koma
- `echo "$lat,$lon" > posisipusaka.txt` → menyimpan hasil ke file

**Rumus yang digunakan:**
```
Titik Tengah = ( (x1+x2)/2 , (y1+y2)/2 )
             = ( (lon1+lon2)/2 , (lat1+lat2)/2 )
```
**Output**
![alt text](image-2.png)

#### Step 8: Push ke GitHub
```bash
cd ~/praktikum1
git add .
git commit -m "selesai soal 2"
git push
```

## Soal 3 (Kost Slebew)
Script bash untuk manajemen kost berbasis CLI.

#### Step 1: Buat struktur folder
```bash
mkdir -p ~/praktikum1/soal_3/data ~/praktikum1/soal_3/log ~/praktikum1/soal_3/rekap ~/praktikum1/soal_3/sampah
cd ~/praktikum1/soal_3
```

#### Step 2: Buat file database
```bash
touch data/penghuni.csv log/tagihan.log rekap/laporan_bulanan.txt sampah/history_hapus.csv
```

#### Step 3: Buat script utama
```bash
nano kost_slebew.sh
```

#### Step 4: Beri izin eksekusi dan jalankan
```bash
chmod +x kost_slebew.sh
./kost_slebew.sh
```
Script bash interaktif untuk manajemen kost berbasis CLI menggunakan AWK.
```bash
#!/bin/bash

DB="data/penghuni.csv"
LOG="log/tagihan.log"
REKAP="rekap/laporan_bulanan.txt"
SAMPAH="sampah/history_hapus.csv"
SCRIPT=$(realpath "$0")

# Inisialisasi file jika kosong
[ ! -s "$DB" ] && echo "Nama,Kamar,Harga_Sewa,Tanggal_Masuk,Status" > "$DB"
[ ! -s "$SAMPAH" ] && echo "Nama,Kamar,Harga_Sewa,Tanggal_Masuk,Status,Tanggal_Hapus" > "$SAMPAH"

tampil_menu(){
    clear
    cat << 'EOF'
 _  _____  ___  _____ 
| |/ / _ \/ __||_   _|
|   < (_) \__ \  | |  
|_|\_\___/|___/  |_|  
 ___  _     ___ ___ ___ _    _ 
/ __|| |   | __| _ ) __| |  | |
\__ \| |__ | _|| _ \ _|| |__| |__
|___/|____|___|___/___|____|____|
EOF
    echo "============================================="
    echo "      SISTEM MANAJEMEN KOST SLEBEW           "
    echo "============================================="
    echo "ID | OPTION"
    echo "---------------------------------------------"
    echo " 1 | Tambah Penghuni Baru"
    echo " 2 | Hapus Penghuni"
    echo " 3 | Tampilkan Daftar Penghuni"
    echo " 4 | Update Status Penghuni"
    echo " 5 | Cetak Laporan Keuangan"
    echo " 6 | Kelola Cron (Pengingat Tagihan)"
    echo " 7 | Exit Program"
    echo "============================================="
}

tambah_penghuni(){
    clear
    echo "============================================="
    echo "              TAMBAH PENGHUNI                "
    echo "============================================="

    read -p "Masukkan Nama: " nama
    read -p "Masukkan Kamar: " kamar

    # Cek kamar unik
    if awk -F',' -v k="$kamar" 'NR>1 {if($2==k) found=1} END{exit !found}' "$DB"; then
        echo "[X] Kamar $kamar sudah ditempati!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    read -p "Masukkan Harga Sewa: " harga

    # Validasi harga positif
    if ! [[ "$harga" =~ ^[0-9]+$ ]] || [ "$harga" -le 0 ]; then
        echo "[X] Harga sewa harus angka positif!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    read -p "Masukkan Tanggal Masuk (YYYY-MM-DD): " tanggal

    # Validasi format tanggal
    if ! [[ "$tanggal" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "[X] Format tanggal salah! Gunakan YYYY-MM-DD"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Validasi tanggal tidak melebihi hari ini
    today=$(date +%Y-%m-%d)
    if [[ "$tanggal" > "$today" ]]; then
        echo "[X] Tanggal tidak boleh melebihi hari ini!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    read -p "Masukkan Status Awal (Aktif/Menunggak): " status

    # Validasi status
    status_lower=$(echo "$status" | tr '[:upper:]' '[:lower:]')
    if [ "$status_lower" != "aktif" ] && [ "$status_lower" != "menunggak" ]; then
        echo "[X] Status harus Aktif atau Menunggak!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Kapitalisasi status
    if [ "$status_lower" == "aktif" ]; then status="Aktif"; else status="Menunggak"; fi

    echo "$nama,$kamar,$harga,$tanggal,$status" >> "$DB"
    echo ""
    echo "[√] Penghuni \"$nama\" berhasil ditambahkan"
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

hapus_penghuni(){
    clear
    echo "============================================="
    echo "              HAPUS PENGHUNI                 "
    echo "============================================="

    read -p "Masukkan nama penghuni yang akan dihapus: " nama

    if ! awk -F',' -v n="$nama" 'NR>1 {if($1==n) found=1} END{exit !found}' "$DB"; then
        echo "[X] Penghuni \"$nama\" tidak ditemukan!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    today=$(date +%Y-%m-%d)
    # Arsipkan ke sampah
    awk -F',' -v n="$nama" -v d="$today" 'NR>1 && $1==n {print $0","d}' "$DB" >> "$SAMPAH"
    # Hapus dari database
    awk -F',' -v n="$nama" 'NR==1 || $1!=n' "$DB" > /tmp/penghuni_tmp.csv && mv /tmp/penghuni_tmp.csv "$DB"

    echo ""
    echo "[√] Data penghuni \"$nama\" berhasil diarsipkan ke sampah/history_hapus.csv"
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

tampil_penghuni(){
    clear
    echo "============================================="
    echo "        DAFTAR PENGHUNI KOST SLEBEW          "
    echo "============================================="
    awk -F',' '
    NR==1 { printf "%-4s| %-20s| %-6s| %-12s| %-10s| %s\n", "No", "Nama", "Kamar", "Harga Sewa", "Status", "Tgl Masuk"
             print "-----+---------------------+-------+-------------+-----------+-----------" }
    NR>1  { printf "%-4s| %-20s| %-6s| %-12s| %-10s| %s\n", NR-1, $1, $2, "Rp"$3, $5, $4 }
    ' "$DB"
    echo "============================================="
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

update_status(){
    clear
    echo "============================================="
    echo "              UPDATE STATUS                  "
    echo "============================================="

    read -p "Masukkan Nama Penghuni: " nama

    if ! awk -F',' -v n="$nama" 'NR>1 {if($1==n) found=1} END{exit !found}' "$DB"; then
        echo "[X] Penghuni \"$nama\" tidak ditemukan!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    read -p "Masukkan Status Baru (Aktif/Menunggak): " status
    status_lower=$(echo "$status" | tr '[:upper:]' '[:lower:]')

    if [ "$status_lower" != "aktif" ] && [ "$status_lower" != "menunggak" ]; then
        echo "[X] Status harus Aktif atau Menunggak!"
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    if [ "$status_lower" == "aktif" ]; then status="Aktif"; else status="Menunggak"; fi

    awk -F',' -v n="$nama" -v s="$status" 'BEGIN{OFS=","} NR==1{print} NR>1{if($1==n) $5=s; print}' "$DB" > /tmp/penghuni_tmp.csv && mv /tmp/penghuni_tmp.csv "$DB"

    echo ""
    echo "[√] Status $nama berhasil diubah menjadi $status"
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

laporan_keuangan(){
    clear
    echo "============================================="
    echo "       LAPORAN KEUANGAN KOST SLEBEW          "
    echo "============================================="

    awk -F',' '
    NR>1 {
        if ($5=="Aktif") { total_aktif += $3; kamar++ }
        else if ($5=="Menunggak") { total_nunggak += $3; nunggak_list = nunggak_list "\n  " $1 " (Kamar "$2") - Menunggak Rp"$3 }
    }
    END {
        printf "  Total pemasukan (Aktif)  : Rp%d\n", total_aktif
        printf "  Total tunggakan          : Rp%d\n", total_nunggak
        printf "  Jumlah kamar terisi      : %d\n", kamar+length(nunggak_list>0)
        print  "---------------------------------------------"
        print  "  Daftar penghuni menunggak:"
        if (nunggak_list == "") print "    Tidak ada tunggakan."
        else print nunggak_list
    }
    ' "$DB"

    # Simpan ke file
    {
        echo "============================================="
        echo "       LAPORAN KEUANGAN KOST SLEBEW          "
        echo "  Tanggal: $(date +%Y-%m-%d)"
        echo "============================================="
        awk -F',' '
        NR>1 {
            if ($5=="Aktif") { total_aktif += $3 }
            else if ($5=="Menunggak") { total_nunggak += $3; nunggak_list = nunggak_list "\n  " $1 " (Kamar "$2") - Menunggak Rp"$3 }
        }
        END {
            printf "  Total pemasukan (Aktif)  : Rp%d\n", total_aktif
            printf "  Total tunggakan          : Rp%d\n", total_nunggak
            if (nunggak_list == "") print "  Tidak ada tunggakan."
            else print nunggak_list
        }
        ' "$DB"
    } > "$REKAP"

    echo "============================================="
    echo "[√] Laporan berhasil disimpan ke $REKAP"
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

check_tagihan(){
    today=$(date +%Y-%m-%d)
    now=$(date +"%Y-%m-%d %H:%M:%S")
    awk -F',' -v d="$now" 'NR>1 && $5=="Menunggak" {
        print "["d"] TAGIHAN: "$1" (Kamar "$2") - Menunggak Rp"$3
    }' "$DB" >> "$LOG"
}

kelola_cron(){
    while true; do
        clear
        echo "====================================="
        echo "          MENU KELOLA CRON           "
        echo "====================================="
        echo " 1. Lihat Cron Job Aktif"
        echo " 2. Daftarkan Cron Job Pengingat"
        echo " 3. Hapus Cron Job Pengingat"
        echo " 4. Kembali"
        echo "====================================="
        read -p "Pilih [1-4]: " pilih

        case $pilih in
            1)
                echo ""
                echo "--- Daftar Cron Job Pengingat Tagihan ---"
                crontab -l 2>/dev/null | grep "check-tagihan" || echo "Tidak ada cron job aktif."
                read -p "Tekan [ENTER] untuk kembali ke menu..."
                ;;
            2)
                read -p "Masukkan Jam (0-23): " jam
                read -p "Masukkan Menit (0-59): " menit

                # Validasi
                if ! [[ "$jam" =~ ^[0-9]+$ ]] || [ "$jam" -lt 0 ] || [ "$jam" -gt 23 ]; then
                    echo "[X] Jam tidak valid!"
                    read -p "Tekan [ENTER]..."; continue
                fi
                if ! [[ "$menit" =~ ^[0-9]+$ ]] || [ "$menit" -lt 0 ] || [ "$menit" -gt 59 ]; then
                    echo "[X] Menit tidak valid!"
                    read -p "Tekan [ENTER]..."; continue
                fi

                # Hapus cron lama, tambah baru (overwrite)
                crontab -l 2>/dev/null | grep -v "check-tagihan" > /tmp/cron_tmp
                echo "$menit $jam * * * $SCRIPT --check-tagihan" >> /tmp/cron_tmp
                crontab /tmp/cron_tmp
                rm /tmp/cron_tmp

                echo ""
                echo "[√] Cron job berhasil didaftarkan pukul $jam:$menit"
                read -p "Tekan [ENTER] untuk kembali ke menu..."
                ;;
            3)
                crontab -l 2>/dev/null | grep -v "check-tagihan" | crontab -
                echo ""
                echo "[√] Cron job pengingat tagihan berhasil dihapus"
                read -p "Tekan [ENTER] untuk kembali ke menu..."
                ;;
            4) break ;;
            *) echo "Pilihan tidak valid!" ; sleep 1 ;;
        esac
    done
}

# Handle argumen --check-tagihan (dipanggil oleh cron)
if [ "$1" == "--check-tagihan" ]; then
    check_tagihan
    exit 0
fi

# Main loop
while true; do
    tampil_menu
    read -p "Enter option [1-7]: " opsi
    case $opsi in
        1) tambah_penghuni ;;
        2) hapus_penghuni ;;
        3) tampil_penghuni ;;
        4) update_status ;;
        5) laporan_keuangan ;;
        6) kelola_cron ;;
        7) echo "Terima kasih sudah menggunakan Kost Slebew!"; exit 0 ;;
        *) echo "Pilihan tidak valid!"; sleep 1 ;;
    esac
done
```
#### Opsi 1: Tambah Penghuni
```bash
tambah_penghuni()
```
- Meminta input: Nama, Kamar, Harga Sewa, Tanggal Masuk, Status
- Validasi yang dilakukan:
  - Kamar tidak boleh bentrok (unik)
  - Harga sewa harus angka positif
  - Format tanggal harus YYYY-MM-DD
  - Tanggal tidak boleh melebihi hari ini
  - Status hanya boleh Aktif atau Menunggak (case-insensitive)
- Data disimpan ke `data/penghuni.csv`

---

#### Opsi 2: Hapus Penghuni
```bash
hapus_penghuni()
```
- Mencari penghuni berdasarkan nama
- Sebelum dihapus, data diarsipkan ke `sampah/history_hapus.csv` dengan tambahan tanggal penghapusan
- Menghapus baris dari database menggunakan AWK:
```bash
awk -F',' -v n="$nama" 'NR==1 || $1!=n' "$DB" > /tmp/penghuni_tmp.csv
```

---

#### Opsi 3: Tampilkan Daftar Penghuni
```bash
tampil_penghuni()
```
- Menampilkan seluruh penghuni dalam format tabel rapi menggunakan `printf` di AWK:
```bash
printf "%-4s| %-20s| %-6s| %-12s| %-10s| %s\n"
```
- `%-4s` → rata kiri dengan lebar 4 karakter

---

#### Opsi 4: Update Status
```bash
update_status()
```
- Mencari penghuni berdasarkan nama
- Mengubah status menjadi Aktif atau Menunggak
- Case-insensitive (aktif/AKTIF/Aktif semua diterima)
- Update dilakukan menggunakan AWK:
```bash
awk -F',' -v n="$nama" -v s="$status" 'BEGIN{OFS=","} NR>1{if($1==n) $5=s; print}'
```

---

#### Opsi 5: Cetak Laporan Keuangan
```bash
laporan_keuangan()
```
- Menghitung total pemasukan dari penghuni berstatus Aktif
- Menghitung total tunggakan dari penghuni berstatus Menunggak
- Menampilkan daftar penghuni yang menunggak
- Hasil disimpan ke `rekap/laporan_bulanan.txt`

---

#### Opsi 6: Kelola Cron
```bash
kelola_cron()
```
- **Lihat** → menampilkan cron job yang aktif
- **Daftarkan** → menambah jadwal pengingat harian, jika sudah ada jadwal lama otomatis diganti (overwrite):
```bash
crontab -l 2>/dev/null | grep -v "check-tagihan" > /tmp/cron_tmp
echo "$menit $jam * * * $SCRIPT --check-tagihan" >> /tmp/cron_tmp
crontab /tmp/cron_tmp
```
- **Hapus** → menghapus cron job pengingat

---

#### Check Tagihan (dipanggil Cron)
```bash
check_tagihan()
```
- Dipanggil otomatis oleh cron dengan argumen `--check-tagihan`
- Mencari penghuni berstatus Menunggak dan mencatatnya ke `log/tagihan.log`
- Format log:
```
[YYYY-MM-DD HH:MM:SS] TAGIHAN: <Nama> (Kamar <No>) - Menunggak Rp<Harga>
```

---

#### Opsi 7: Exit
```bash
7) echo "Terima kasih sudah menggunakan Kost Slebew!"; exit 0 ;;
```
Keluar dari program.

#### Step 5: Tambah penghuni (Opsi 1)
```bash
Masukkan Nama: Mas Rusdi
Masukkan Kamar: 2
Masukkan Harga Sewa: 600000
Masukkan Tanggal Masuk (YYYY-MM-DD): 2026-03-01
Masukkan Status Awal (Aktif/Menunggak): Aktif
```

#### Step 6: Test cron pengingat tagihan
```bash
./kost_slebew.sh --check-tagihan
cat log/tagihan.log
```
