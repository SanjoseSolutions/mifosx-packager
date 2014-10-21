#!/bin/sh

VER=$1
sed -i "/^VER=/s/=.*/=$1/" Makefile
echo $VER > VERSION

