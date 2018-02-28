#!/bin/sh

SCRIPTS=scripts

touch GenomaBucket.[hm]
make EXTRALDFLAGS=-static -f $SCRIPTS/Makefile_S_big    -j4

touch GenomaBucket.[hm]
make EXTRALDFLAGS=-static -f $SCRIPTS/Makefile_S_medium -j4

touch GenomaBucket.[hm]
make EXTRALDFLAGS=-static -f $SCRIPTS/Makefile_S_small  -j4
