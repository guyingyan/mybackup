baseDir="/home/boardPackage"

board=`docker images|grep board`
#dev=`docker images|grep dev`

if [ -n "$board" ]; then
	echo "no board images, nothing need do!"
else
	docker rmi -f $(docker images|grep board|awk '{ print $3 }')
fi

#if [ -n "$dev"]; then
#	echo "no dev images, nothing need do!"
#else
#	docker rmi -f $(docker images|grep dev|awk '{ print $3 }')
#fi

if [ ! -d $baseDir ]; then
	mkdir $baseDir
else
	rm -rf $baseDir/*
fi
cd $baseDir
git clone http://10.110.18.40:10080/inspursoft/board.git
cd $baseDir/board
#make prepare
#make packageonestep
make compile_ui
make build
make package

dataTag=`date "+%Y-%m-%d_%H-%M-%S"`
cp board-offline-installer-latest.tgz /home/packages/$dataTag"board-offline-installer.tgz"
