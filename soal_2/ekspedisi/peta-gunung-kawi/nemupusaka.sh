#!/bin/bash

lat=$(awk -F',' 'NR==1{lat1=$3} NR==3{lat2=$3} END{printf "%.6f", (lat1+lat2)/2}' titik-penting.txt)
lon=$(awk -F',' 'NR==1{lon1=$4} NR==3{lon2=$4} END{printf "%.6f", (lon1+lon2)/2}' titik-penting.txt)

echo "$lat,$lon" > posisipusaka.txt

echo "Koordinat pusat:"
cat posisipusaka.txt
