#!/bin/bash

# Setup script for Amazon EC2 GPU cloud server

export HOME=/home/ec2-user
export USER=<user>
export PASS=<pass>
export HOST=stratum.bitcoin.cz
export PORT=3333

# Get cpu numbers
export cpus=$(cat /proc/cpuinfo | grep ^processor | wc -l)

#
# Install prerequisites
#
sudo yum -y erase nvidia cudatoolkit
sudo yum -y update
sudo yum -y groupinstall "Development Tools"
sudo yum -y install git libcurl libcurl-devel python-devel screen rsync yasm numpy openssl-devel make pkg-config autoconf automake autoreconf libtool openssl-compat-bitcoin-devel.x86_64 openssh
sudo yum -y install kernel-devel-`uname -r`
sudo yum -y install python-pip pyserial libudev-devel
sudo pip install pyserial
sudo pip install numpy

#
# Install the GPU library CUDA 5.5
#
wget http://developer.download.nvidia.com/compute/cuda/5_5/rel/installers/cuda_5.5.22_linux_64.run
sudo sh cuda_5.5.22_linux_64.run -driver -toolkit -samples -verbose -silent

#
# Install the CPU miner
#
cd $HOME
git clone https://github.com/slush0/stratum-mining-proxy.git
cd stratum-mining-proxy
sudo python setup.py install

cd $HOME
git clone https://github.com/jgarzik/cpuminer.git
cd cpuminer
./autogen.sh
CFLAGS="-O3 -Wall -msse2" ./configure
make

#
# Setup cgminer
#
#cd $HOME
#git clone https://github.com/ckolivas/cgminer.git cgminer
#cd cgminer
#CFLAGS="-O2 -Wall -march=native -I /opt/AMDAPP/include/" LDFLAGS="-L/opt/AMDAPP/lib/x86_64"
#CFLAGS="-O2 -Wall -march=native" ./configure
#export CFLAGS="-I/usr/local/cuda-5.5/include"
#export LDFLAGS="-L/usr/local/cuda-5.5/lib64" 
#./autogen.sh
#export CFLAGS="-O2 -Wall -I/usr/local/cuda-5.5/include"
#export LDFLAGS="-L/usr/local/cuda-5.5/lib64" 
#./configure -enable-option-checking --enable-scrypt --enable-opencl
#make

#
# Setup poclbm
#
wget https://pypi.python.org/packages/source/p/pyopencl/pyopencl-2013.2.tar.gz
tar -vxzf pyopencl-2013.2.tar.gz 
cd pyopencl-2013.2
python configure.py --cl-inc-dir=/usr/local/cuda-5.5/include
sudo python setup.py install 
cd $HOME
git clone https://github.com/m0mchil/poclbm.git

#
# Setup launch script - update USER/PASS/HOST/PORT settings here
#
cat > ~/mine.sh <<EOF
#!/bin/bash

cd ~/stratum-mining-proxy
screen -d -m ./mining_proxy.py --stratum-host $HOST --stratum-port $PORT -cu $USER -cp $PORT

cd ~/cpuminer
screen -d -m ./minerd --url $POOL --user $USER --pass $PASS --threads $cpus

#cd ~/cgminer
#screen -d -m ./cgminer/cgminer --device all --syslog --verbose -o $POOL -u $USER -p $PASS

cd ~/poclbm
screen -d -m sudo python ./poclbm.py -v -w 256 --device 0 stratum://$USER:$PASS@$HOST:$PORT
screen -d -m sudo python ./poclbm.py -v -w 256 --device 1 stratum://$USER:$PASS@$HOST:$PORT

EOF

#
# Make it runnable
#
sudo chmod +x /home/ec2-user/mine.sh

