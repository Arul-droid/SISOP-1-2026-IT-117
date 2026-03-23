BEGIN {
    FS = ","
    opsi = ARGV[2]
    ARGC = 2
}
NR > 1 {
    # b: hitung gerbong unik
    gsub(/\r/, "")      # hapus karakter windows (penyebab umum)
    gsub(/ /, "", $4)
    gerbong[$4] = 1

    # c: cari penumpang tertua
    if ($2 > max_age) {
        max_age = $2
        oldest = $1
    }

    # d: hitung rata-rata usia
    total_age += $2

    # e: hitung penumpang business class
    if ($3 == "Business") business++
}
END {
    count = NR - 1
    if (opsi == "a") print "Jumlah seluruh penumpang KANJ adalah", count, "orang"
    else if (opsi == "b") print "Jumlah gerbong penumpang KANJ adalah", length(gerbong)
    else if (opsi == "c") print oldest, "adalah penumpang kereta tertua dengan usia", max_age, "tahun"
    else if (opsi == "d") print "Rata-rata usia penumpang adalah", int(total_age / count), "tahun"
    else if (opsi == "e") print "Jumlah penumpang business class ada", business, "orang"
    else print "Soal tidak dikenali. Gunakan a, b, c, d, atau e"
}
