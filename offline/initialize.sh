#!/usr/bin/env bash

echo "Before running this script, make sure you"
echo "set up the database:"
echo ""
echo "   mysql -u<username> -p <database> < schema.sql"
echo "   vi ../modules/db.ph"
echo ""

for i in full11 full20 demoA1 demo20; do
  echo "Loading data from $i resources"
  mkdir -p ../$i
  mkdir -p ../$i/images
  mkdir -p ../$i/maps
  
  ./load_maps.pl $i < ../resources/$i/map.data
  ./extract_rsrc.pl dpin 128 < ../resources/$i/app.rsrc | ./load_dpin.pl $i

  ./strings2xml.pl < ../resources/$i/app.rsrc | ./pidinfo.pl $i > ../$i/info.ph
  ./pidshapes2xml.pl < ../resources/$i/shapes.rsrc | ./pidshapes2images.pl ../$i/images
  ./map_images.pl $i ../$i/images ../$i/maps
done
