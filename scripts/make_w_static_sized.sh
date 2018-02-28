#!/bin/sh

SCRIPTS=scripts

touch GenomaBucket.[hm]
make EXTRALDFLAGS=-static -f $SCRIPTS/Makefile_W_big    -j4

touch GenomaBucket.[hm]
make EXTRALDFLAGS=-static -f $SCRIPTS/Makefile_W_medium -j4

touch GenomaBucket.[hm]
make EXTRALDFLAGS=-static -f $SCRIPTS/Makefile_W_small  -j4
