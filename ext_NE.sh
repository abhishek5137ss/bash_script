#!/bin/bash
set -x
homeDir=/media1/Data/modelWRF/ARWV4.2;inp=${homeDir}/input;wps=${homeDir}/WPS;ARW=${homeDir}/WRF/test/em_real;
geog=${homeDir}/geog;
source /media1/Data/modelWRF/reqSoft/compilerVars_4.sh
cd ${homeDir}
gmt="00"
start_day="17"
end_day="31"
if [ ${gmt} == 18 ];then
date1="202412${start_day}"; else date1="202412${start_day}";fi
cd ${wps}
rm -f GRIBFILE.* FILE* ungrib.log metgrid.log
cd ${ARW}
rm -rf rsl.error.0* rsl.out.0* met_em.d01.* wrfrst_d01_2020* wrfbdy_d01* wrfinput_d01*
################################Name List Process######################################
cd ${wps}
t_sdate="2024-12-${start_day}"
t_edate="2024-12-${end_day}"
cat << EOF > namelist.wps
&share
 wrf_core = 'ARW',
 max_dom = 1,
 start_date = '${t_sdate}_00:00:00',
 end_date   = '${t_edate}_00:00:00',
 interval_seconds = 21600
 io_form_geogrid = 2,

/
&geogrid
 parent_id            = 1
 parent_grid_ratio    = 1
 i_parent_start       = 1
 j_parent_start       = 1
 e_we                 = 136
 e_sn                 = 144
 geog_data_res        = 'modis_lake', 'modis_lake'
 dx                   = 6000
 dy                   = 6000
 map_proj             = 'mercator'
 ref_lat              = 25.923
 ref_lon              = 92.406
 truelat1             = 25.923
 pole_lat             = 90
 pole_lon             = 0
 stand_lon            = 92.406
 geog_data_path = '/media1/Data/modelWRF/ARWV4.2/geog'
/

&ungrib
 out_format = 'WPS',
 prefix = 'GFS',
/

&metgrid
 fg_name = 'GFS'
 io_form_metgrid = 2,
 opt_output_from_metgrid_path='/media1/Data/modelWRF/ARWV4.2/WRF/test/em_real'
/
EOF

cd ${ARW}
t_sday="${start_day}"
t_eday="${end_day}"
t_smonth="12"
t_emonth="12"
t_syear="2024"
t_eyear="2024"

cat << EOF > namelist.input
&time_control
 debug_level                         = 100
 run_days                            = 15,
 run_hours                           = 00,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = ${t_syear}, ${t_syear},
 start_month                         = ${t_smonth}, ${t_smonth},
 start_day                           = ${t_sday}, ${t_sday},
 start_hour                          = 00, 00,
 end_year                            = ${t_eyear}, ${t_eyear},
 end_month                           = ${t_emonth}, ${t_emonth},
 end_day                             = ${t_eday}, ${t_eday},
 end_hour                            = 00, 00,
 interval_seconds                    = 21600,
 input_from_file                     = .true., .true.,
 history_interval                    = 60, 60,
 frames_per_outfile                  = 1, 1,
 restart                             = .false.,
 restart_interval                    = 3600,
 io_form_history                     = 2,
 io_form_restart                     = 2,
 io_form_input                       = 2,
 io_form_boundary                    = 2,
 /


&domains
 time_step                           = 36,
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = 1,
 e_we                                = 136
 e_sn                                = 144
 dx                                  = 6000
 dy                                  = 6000
 e_vert                              = 50, 50,
 p_top_requested                     = 5000,
 num_metgrid_levels                  = 34,
 num_metgrid_soil_levels             = 4,
 grid_id                             = 1,
 parent_id                           = 1,
 i_parent_start                      = 1,
 j_parent_start                      = 1,
 parent_grid_ratio                   = 1,
 parent_time_step_ratio              = 1,
 feedback                            = 1,
 smooth_option                       = 0,
/

&physics
 physics_suite                       = 'CONUS',
 mp_physics                          = 8,8,
 cu_physics                          = 3,3,
 ra_lw_physics                       = 4,4,
 ra_sw_physics                       = 4,4,
 bl_pbl_physics                      = 3,3, 
 sf_sfclay_physics                   = 3,3,
 sf_surface_physics                  = 2, 2,
 radt                                = 30, 30,
 bldt                                = 0, 0,
 cudt                                = 5, 5,
 isfflx                              = 1
 ifsnow                              = 1
 icloud                              = 1,
 num_land_cat                        = 24,
 sf_urban_physics                    = 1,1,
 aer_opt                             = 1,
 /

 &fdda
 /

 &dynamics
 hybrid_opt                          = 2,
 w_damping                           = 1,
 diff_opt                            = 2, 2,
 km_opt                              = 4, 4,
 diff_6th_opt                        = 0, 0,
 diff_6th_factor                     = 0.12, 0.12,
 base_temp                           = 290.,
 damp_opt                            = 3,
 zdamp                               = 5000., 5000.,
 dampcoef                            = 0.2, 0.2,
 khdif                               = 0, 0,
 kvdif                               = 0, 0,
 non_hydrostatic                     = .true., .true.,
 moist_adv_opt                       = 1, 1,
 scalar_adv_opt                      = 1, 1,
 gwd_opt                             = 1,
 /

 &bdy_control
 spec_bdy_width                      = 5,
 specified                           = .true.
 /

 &grib2
 /

 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /

EOF
#echo "Name list created"
################ WRF Pre-processing ########################

cd ${wps}
ls geogrid/GEOGRID.TBL
./geogrid.exe
sleep 2
#cp -r /media1/Data/modelWRF/ARWV4.0/WPS/geo_em.d01.nc.18km ./geo_em.d01.nc
ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
sleep 5
./link_grib.csh ${inp}/${date1}${gmt}/gfs* .
sleep 5
./ungrib.exe > ungrib.log
sleep 5
ls metgrid/METGRID.TBL
sleep 2
./metgrid.exe > metgrid.log

echo "WPS Process END"
############################################################
sleep 5
############# WRF Processing ###############################
cd ${ARW}
./real.exe >real.log
sleep 5
mpirun -np 16 ./wrf.exe > wrf.log
sleep 5
mkdir -p /media3/test/test_output/${date1}${gmt}_NE
mv wrfout* /media3/test/test_output/${date1}${gmt}_NE
exit 0
