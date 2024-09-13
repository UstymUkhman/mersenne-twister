#!/bin/bash

clear
echo ""
zig build
./zig-out/bin/mersenne-twister.exe
