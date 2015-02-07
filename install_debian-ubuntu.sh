#!/bin/bash

POSTGRESQL_LIB_DIR=$(pg_config --pkglibdir)
OB_INSTALL_DIR=$POSTGRESQL_LIB_DIR/openbabel

# compile openbabel
cd src
mkdir openbabel-2.3.2/build
cd openbabel-2.3.2/build
cmake .. -DBUILD_SHARED=ON -DBUILD_GUI=OFF -DBUILD_TESTING=OFF -DCMAKE_INSTALL_PREFIX=$OB_INSTALL_DIR
make
sudo make install

# compile barsoi
cd ../../barsoi
make -f Makefile.linux

# compile pgchem
cd ..
mv openbabel-2.3.2/include/openbabel/locale.h openbabel-2.3.2/include/openbabel/_locale.h
cd openbabel-2.3.2/build/lib/
ln -s ./inchiformat.so ./libinchiformat.so
cd ../../../
USE_PGXS=1 make -f Makefile.linux.x64

# copy all libraries
sudo cp libpgchem.so $POSTGRESQL_LIB_DIR/
sudo cp barsoi/libbarsoi.so $POSTGRESQL_LIB_DIR/
sudo cp openbabel-2.3.2/build/lib/libinchi.so.0.4.1 $POSTGRESQL_LIB_DIR/libinchi.so.0.4.1
sudo cp openbabel-2.3.2/build/lib/libopenbabel.so.4.0.2 $POSTGRESQL_LIB_DIR/libopenbabel.so.4.0.2
sudo cp openbabel-2.3.2/build/lib/inchiformat.so $POSTGRESQL_LIB_DIR/inchiformat.so
sudo cp ../setup/tigress/obdata/dictionary* $POSTGRESQL_LIB_DIR/openbabel/share/openbabel/2.3.2/
cd $POSTGRESQL_LIB_DIR
sudo ln -s libinchi.so.0.4.1 libinchi.so.0
sudo ln -s libinchi.so.0 libinchi.so 
sudo ln -s libopenbabel.so.4.0.2 libopenbabel.so.4
sudo ln -s libopenbabel.so.4 libopenbabel.so
sudo ln -s inchiformat.so libinchiformat.so 

# if you havn't configured ldconf to use your postgres libdir run the following commented lines
echo $POSTGRESQL_LIB_DIR | sudo tee -a /etc/ld.so.conf.d/libc.conf
sudo ldconfig

