#!/bin/bash
# This code is part of the Arc-flow Vector Packing Solver (VPSolver).
#
# Copyright (C) 2013-2015, Filipe Brandao
# Faculdade de Ciencias, Universidade do Porto
# Porto, Portugal. All rights reserved. E-mail: <fdabrandao@dcc.fc.up.pt>.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
BASEDIR=`dirname $0`
cd $BASEDIR

build(){
    make bin/$1 2>/dev/null

    if [[ $? == 0 ]];
    then
        echo "  $1 [OK]";
        return 0;
    else
        echo "  $1 [Failed]";
        return 1;
    fi
}

#make clean

echo "mandatory:"
build "vbp2afg" || exit 1
build "afg2mps" || exit 1
build "afg2lp"  || exit 1
build "vbpsol"  || exit 1

if [[ "$@" != "minimal" ]]; then
    echo "optional:"
    build "vpsolver"
    exit 0;
fi;
