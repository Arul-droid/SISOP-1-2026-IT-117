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
