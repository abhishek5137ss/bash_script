#!/bin/bash

gmt=${1};

if [ ${gmt} == 18 ];then
date1=`date -d "+ 0days" +%Y%m%d`; else date1=`date -d " + 0days" +%Y%m%d`;fi

cd /media1/Data/modelWRF/ARWV4.2/input
mkdir -p ${date1}${gmt}
cd ${date1}${gmt}
#for hr in {00..360..06};do wget -c -t 200 --no-check-certificate -nc -O  gfs.t${gmt}z.pgrb2.0p25.f${hr} "http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${gmt}z.pgrb2.0p25.f${hr}&all_lev=on&all_var=on&subregion=&leftlon=40&rightlon=120&toplat=40&bottomlat=0&dir=%2Fgfs.${date1}%2F${gmt}%2Fatmos";done

#for hr in {000..360..006};do wget -nc -c -t 200 --no-check-certificate -O gfs.t${gmt}z.pgrb2.0p25.f${hr} "http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${gmt}z.pgrb2.0p25.f${hr}&all_lev=on&all_var=on&subregion=&leftlon=40&rightlon=120&toplat=50&bottomlat=-10&dir=%2Fgfs.${date1}%2F${gmt}%2Fatmos";done


for hr in {000..360..006};do wget -nc -c -t 200 --no-check-certificate -O gfs.t${gmt}z.pgrb2.0p25.f${hr} "http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${gmt}z.pgrb2.0p25.f${hr}&all_lev=on&all_var=on&subregion=&leftlon=40&rightlon=120&toplat=55&bottomlat=-15&dir=%2Fgfs.${date1}%2F${gmt}%2Fatmos";done

#for hr in {000..360..006};do wget -nc -c -t 200 --no-check-certificate -O gfs.t${gmt}z.pgrb2.0p25.f${hr} "http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${gmt}z.pgrb2.0p25.f${hr}&all_lev=on&all_var=on&subregion=&leftlon=65&rightlon=100&toplat=35&bottomlat=6&dir=%2Fgfs.${date1}%2F${gmt}%2Fatmos";done


find . -name "gfs.t${gmt}z.pgrb2.0p25.f*" -size -10000k -delete

exit 0
