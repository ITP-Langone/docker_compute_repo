#!/bin/bash


sudo apt-get update
#sudo apt-get install virtualbox-guest-dkms 

#sudo apt-get install libhdf5-serial-dev h5utils cmake cmake-curses-gui libboost-all-dev doxygen git


cd $1

git clone https://github.com/ismrmrd/ismrmrd
cd ismrmrd/
mkdir build
cd build
cmake ../
make
sudo make install



