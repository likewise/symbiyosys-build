#!/bin/bash
set -e
set -e -o pipefail

function super_prove () {
	hg clone -r d7b71160dddb https://bitbucket.org/sterin/super_prove_build || true
	cd super_prove_build
	mkdir -p build

	cd abc-zz
	wget -nc "https://bitbucket.org/sterin/super_prove_build/issues/attachments/4/sterin/super_prove_build/1565269491.41/4/fix_super_prove_build.txt"
	patch -p1 -N -i fix_super_prove_build.txt || true
	cd .. # abc-zz

	cd build
	cmake -DCMAKE_BUILD_TYPE=Release -G Ninja ..

	ninja
	ninja package

	# install
	mkdir -p ~/opt/formal
	tar xzf super_prove*.tar.gz -C ~/opt/formal/
	cd .. # build

	# install wrapper
	mkdir -p $HOME/opt/formal/bin
	wget -nc -O $HOME/opt/formal/bin/suprove https://bitbucket.org/sterin/super_prove_build/issues/attachments/4/sterin/super_prove_build/1565269491.6/4/suprove
	chmod +x $HOME/opt/formal/bin/suprove
	sed -i 's@/usr/local@$HOME/opt/formal@' $HOME/opt/formal/bin/suprove

	cd .. # super_prove_build
}

function extavy () {
	cd extavy
	git submodule update --init
	mkdir -p build
	cd build
	cmake -DCMAKE_BUILD_TYPE=Release ..
	make -j8
	mkdir -p $HOME/opt/formal/bin
	cp avy/src/{avy,avybmc} $HOME/opt/formal/bin
	cd .. # build
	cd .. # extavy
}

#rm -rf $HOME/opt/formal
#mkdir -p $HOME/opt/formal

#super_prove
extavy

cd yosys
make -j8
make install DESTDIR=$HOME/opt/formal
cd ..

cd SymbiYosys
make install DESTDIR=$HOME/opt/formal
cd ..

cd yices2
autoconf
./configure --prefix=$HOME/opt/formal
make -j8
make install
cd ..

cd z3
python scripts/mk_make.py
cd build
make -j8
make install DESTDIR=$HOME/opt/formal
cd .. #z3
