#!/bin/sh
CROSS=/opt/STM/STLinux-2.3/devkit/sh4/bin/sh4-linux-
CFLAGS+=-I/opt/STM/STLinux-2.3/devkit/sh4/target/usr/include/libxml2/ \
CC=${CROSS}gcc \
STRIP=${CROSS}strip \
make
if [ $? != 0 ]; then
	echo compile error
	exit 1
fi

[ -d tmp ] && rm -rf tmp

mkdir -p tmp/CONTROL
mkdir -p tmp/var/crossepg/aliases
mkdir -p tmp/var/crossepg/providers
mkdir -p tmp/var/crossepg/import
mkdir -p tmp/usr/lib/enigma2/python/Plugins/SystemPlugins/CrossEPG/skins
mkdir -p tmp/usr/lib/enigma2/python/Plugins/SystemPlugins/CrossEPG/images
mkdir -p tmp/usr/lib/enigma2/python/Plugins/SystemPlugins/CrossEPG/po/it/LC_MESSAGES

cp bin/* tmp/var/crossepg/

cp providers/* tmp/var/crossepg/providers/
cp src/enigma2/python/skins/*.xml tmp/usr/lib/enigma2/python/Plugins/SystemPlugins/CrossEPG/skins/
cp src/enigma2/python/images/*.png tmp/usr/lib/enigma2/python/Plugins/SystemPlugins/CrossEPG/images/
cp contrib/po/it/LC_MESSAGES/CrossEPG.mo tmp/usr/lib/enigma2/python/Plugins/SystemPlugins/CrossEPG/po/it/LC_MESSAGES/
cp contrib/crossepg_epgmove.sh tmp/var/crossepg/
cp contrib/control tmp/CONTROL/

chmod 755 tmp/var/crossepg/crossepg_*

# copy with tar so we clean .svn entries
cd contrib
tar --exclude-vcs -zc po | tar -zx -C ../tmp/usr/lib/enigma2/python/Plugins/SystemPlugins/CrossEPG/
cd ..

python compile.py

VERSION=`cat src/version.h | grep RELEASE | sed "s/.*RELEASE \"//" | sed "s/\"//" | sed "s/\ /-/" | sed "s/\ /-/" | sed "s/(//" | sed "s/)//"`
echo "Version: $VERSION" >> tmp/CONTROL/control
echo "Architecture: sh4" >> tmp/CONTROL/control

sh ipkg-build -o root -g root tmp/

[ ! -d out ] && mkdir out
mv *.ipk out
echo "Package moved in `pwd`/out folder"
cd tmp
tar zcf ../out/enigma2-plugin-systemplugins-crossepg_${VERSION}_sh4.tar.gz usr var
cd ..
