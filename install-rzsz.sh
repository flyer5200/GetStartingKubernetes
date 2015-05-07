wget http://10.0.0.213/cloud_repository/rzsz-3.48.tar.gz
tar zxvf rzsz-3.48.tar.gz
cd src
make posix
cp rz sz /usr/bin

cd ../
rm -rf rzsz-*
rm -rf src
