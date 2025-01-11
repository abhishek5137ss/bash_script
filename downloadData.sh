#!/bin/bash
set -x
homeDir=/media1/Data/modelWRF/ARWV4.2
date1=`date +%Y%m%d`
gmt="00";

cd ${homeDir}/input
mkdir -p ${date1}${gmt}

cd ${date1}${gmt}
#for hr in {000..360..006};do wget -c -t 200 --no-check-certificate -nc -O gfs.t${gmt}z.pgrb2.0p25.f${hr} "http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${gmt}z.pgrb2.0p25.f${hr}&all_lev=on&all_var=on&subregion=&leftlon=40&rightlon=120&toplat=40&bottomlat=0&dir=%2Fgfs.${date1}%2F${gmt}%2Fatmos";done


for hr in {000..360..006};do wget -nc -c -t 200 --no-check-certificate -O gfs.t${gmt}z.pgrb2.0p25.f${hr} "http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${gmt}z.pgrb2.0p25.f${hr}&all_lev=on&all_var=on&subregion=&leftlon=40&rightlon=120&toplat=55&bottomlat=-15&dir=%2Fgfs.${date1}%2F${gmt}%2Fatmos";done


##for hr in {000..360..006};do wget -nc -c -t 200 --no-check-certificate -O gfs.t${gmt}z.pgrb2.0p25.f${hr} "http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${gmt}z.pgrb2.0p25.f${hr}&all_lev=on&all_var=on&subregion=&leftlon=65&rightlon=100&toplat=35&bottomlat=6&dir=%2Fgfs.${date1}%2F${gmt}%2Fatmos";done


find . -name "gfs.t${gmt}z.pgrb2.0p25.f*" -size -10000k -delete

FIL=0
FIL=`ls gfs.t${gmt}z.pgrb2.0p25.f* | wc -l`
echo " $FIL files Downloaded "
while [ $FIL -lt 61 ]
do
sh ${homeDir}/input/downloadData_check.sh ${gmt}
sleep 2
FIL=`ls | wc -l`
done
cat ${homeDir}/input/${date1}${gmt}/gfs.t00z.pgrb2.0p25.f* > ${homeDir}/input/${date1}${gmt}/gfs.${date1}${gmt}

cd ${homeDir}/scripts
rm -fr ${homeDir}/scripts/nohup.out
cd ${homeDir}/scripts
nohup sh ${homeDir}/scripts/ext_WRF_complete_18km.sh >> ${homeDir}/scripts/nohup.out 2>&1 &

cd /media1/Data/modelWRF/ARWV4.2/input
date2=`date -d "- 2days" +%Y%m%d`
rm -rf ${date2}${gmt}
exit 0
