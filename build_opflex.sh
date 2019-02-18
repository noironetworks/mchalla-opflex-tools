#!/bin/bash

set -x
if [ -z "$1" ]; then
   echo "Doing Dynamic build"
elif [ $1 == "static" ]; then
    echo "Doing Static build"
    BUILDOPTS="--with-static-boost --with-boost=/usr/local/boost_1_58_0"
fi

sudo rm /usr/local/lib/libmodelgbp*
sudo rm /usr/local/lib/libopflex*
sudo rm /usr/local/bin/opflex_agent
sudo rm /usr/local/bin/gbp_inspect
sudo rm /usr/local/bin/mcast_daemon
sudo rm /usr/local/bin/mock_server

pushd libopflex
make clean
./autogen.sh
./configure $BUILDOPTS
make -j12
sudo make install
popd

pushd genie
mvn compile exec:java
popd

pushd genie/target/libmodelgbp
make clean
bash autogen.sh
./configure
make -j12
sudo make install
popd

pushd agent-ovs
make clean
./autogen.sh
./configure $BUILDOPTS
make -j12
sudo make install
popd

pushd agent-ovs
make check
popd
