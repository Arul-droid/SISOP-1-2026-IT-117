#!/bin/bash

awk '
/"id":/ { gsub(/.*"id": "|",/, "", $0); id = $0 }
/"site_name":/ { gsub(/.*"site_name": "|",/, "", $0); site = $0 }
/"latitude":/ { gsub(/.*"latitude": |,/, "", $0); lat = $0 }
/"longitude":/ { gsub(/.*"longitude": |,/, "", $0); lon = $0; print id "," site "," lat "," lon }
' gsxtrack.json | sort > titik-penting.txt

cat titik-penting.txt
