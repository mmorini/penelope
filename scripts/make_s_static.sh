#!/bin/sh
SCRIPTS=scripts

make EXTRALDFLAGS=-static -f $SCRIPTS/Makefile_S -j4
