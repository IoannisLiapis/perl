# this is a build script for ARM-linux cross-compiling.
# it builds miniperl on HOST and then perl for TARGET
# this approach is like Perl-CE cross-compiling, and allows
# for full TARGET perl (as opposed to renamed miniperl)

# some trick is different, however - the file extension for objects files
# are choosen to be .${CROSS_NAME}, .armo in our case

# note how invoked Makefile.PL for cross-compilation:
#   miniperl -MCross Makefile.PL

# steps are:
# - run HOST configure
# - build HOST miniperl
# given freshly-created HOST makefile and existing miniperl fix makefile
# to use 

CROSS_NAME=arm

# suppose compiler is in /opt/arm-2006q3
CCPATH=/opt/arm-2006q3
PATH=$CCPATH/bin:$PATH
CCPREF=arm-none-linux-gnueabi-

CROSSCC=${CCPREF}gcc
export CROSSCC
export CROSS_NAME

cp config.sh-arm-linux-n770 config-${CROSS_NAME}.sh

# following should be done better:
cd ..

if false
then
# do miniperl on HOST
./Configure -des -D prefix=./dummy -Dusedevel
make miniperl
make uudmap.h
# fake uudmap, which should be on HOST
# TODO - all host utilities should be clearly stated and not built for TARGET
cp generate_uudmap generate_uudmap.${CROSS_NAME}
fi

#?? cd Cross

# do the rest for TARGET
$CROSSCC --version

# call make thusly so it will crosscompile...
XCOREDIR=xlib/$CROSS_NAME/CORE
PERL_CONFIG_SH=Cross/config-${CROSS_NAME}.sh

#?? . $PERL_CONFIG_SH 

# make cflags do cross-compile work (now its hackish, will be improved!)
rm cflags-cross-$CROSS_NAME
cp Cross/cflags-cross-$CROSS_NAME .
rm Makefile-cross-$CROSS_NAME
sh Cross/Makefile-cross.SH
cp Cross/Makefile-cross-$CROSS_NAME .
# makefile hack-patching TODO generation from Makefile.SH
#./miniperl -pi.bak -w0777ne "s{^(CCCMD.*?)cflags}{\$1cflags-cross-$CROSS_NAME}gm" Makefile-cross-$CROSS_NAME

mkdir xlib
mkdir xlib/$CROSS_NAME
mkdir ${XCOREDIR}

#??OBJ_EXT=.${CROSS_NAME}o
# TODO these -- AR=${CCPREF}ar LD=${CCPREF}ld
make -f Makefile-cross-$CROSS_NAME xconfig.h
make -f Makefile-cross-$CROSS_NAME libperl.${CROSS_NAME}a  OBJ_EXT=.${CROSS_NAME}o EXE_EXT=.$CROSS_NAME LIB_EXT=.${CROSS_NAME}a  AR=${CCPREF}ar LD=${CCPREF}ld
make -f Makefile-cross-$CROSS_NAME DynaLoader.${CROSS_NAME}o  OBJ_EXT=.${CROSS_NAME}o EXE_EXT=.$CROSS_NAME LIB_EXT=.${CROSS_NAME}a  AR=${CCPREF}ar LD=${CCPREF}ld
make -f Makefile-cross-$CROSS_NAME perl.${CROSS_NAME}
