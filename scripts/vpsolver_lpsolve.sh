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

set -e
echo "Copyright (C) 2013-2015, Filipe Brandao"

CMD="$0 $*"
BASEDIR=`dirname $0`
BIN_DIR=$BASEDIR/../bin/
TMP_DIR=`mktemp -d -t XXXXXXXXXX`
trap "rm -rf $TMP_DIR;" SIGHUP SIGINT SIGTERM EXIT

usage(){
    echo -e "Usage:"
    echo -e "  $0 --vbp instance.vbp"
    echo -e "  $0 --afg graph.afg"
    echo -e "  $0 --mps/--lp model.mps/.lp"
    echo -e "  $0 --mps/--lp model.mps/.lp --afg graph.afg"
}

error(){
    echo "Command line: "$CMD
    echo "Error: invalid arguments."
    usage
    exit 1
}

solve(){
    local model_file=$1
    echo -e "\n>>> solving the MIP model using lp_solve..."
    echo -e "Note: different parameter settings may improve the performance substantially!"
    if [[ $model_file =~ \.mps$ ]]; then
        lp_solve -mps $model_file $options > $TMP_DIR/sol.out  &
        local pid=$!
        trap "kill $pid &> /dev/null" SIGHUP SIGINT SIGTERM
        wait $pid
    else
        echo -e "Note: lp_solve requires xli_CPLEX to read CPLEX lp models"
        lp_solve -rxli xli_CPLEX $model_file $options > $TMP_DIR/sol.out &
        local pid=$!
        trap "kill $pid &> /dev/null" SIGHUP SIGINT SIGTERM
        wait $pid
    fi
    sed -e '1,/variables:/d' < $TMP_DIR/sol.out > $TMP_DIR/vars.sol
}

options=""
model_file=""
afg_file=""
vbp_file=""
sol_file=""

while true;
do
  case "$1" in
    --mps)
        if [[ -n "$2" && -e "$2" && "$2" =~ \.mps$ ]]; then
            model_file=$2
        else
            error
        fi
        shift 2;;

    --lp)
        if [[ -n "$2" && -e "$2" && "$2" =~ \.lp$ ]]; then
            model_file=$2
        else
            error
        fi
        shift 2;;

    --afg)
        if [[ -n "$2" && -e "$2" && "$2" =~ \.afg$ ]]; then
            afg_file=$2
        else
            error
        fi
        shift 2;;

    --vbp)
        if [[ -n "$2" && -e "$2" && "$2" =~ \.vbp$ ]]; then
            vbp_file=$2
        else
            error
        fi
        shift 2;;

    --wsol)
        if [[ -n "$2" ]]; then
            sol_file=$2
        else
            error
        fi
        shift 2;;

    --options)
        if [[ -n "$2" ]]; then
            options=$2
        else
            error
        fi
        shift 2;;

    *)
        if [[ -n "$1" ]]; then
            error
        else
            break
        fi
  esac
done

if [[ -z "$vbp_file" && -z "$model_file" && -z "$afg_file" ]]; then
    error
fi

if [[ -n "$vbp_file" ]]; then
    if [[ -n "$afg_file" || -n "$model_file" ]]; then
        error
    fi

    afg_file=$TMP_DIR/graph.afg
    model_file=$TMP_DIR/model.mps

    echo -e "\n>>> vbp2afg..."
    $BIN_DIR/vbp2afg $vbp_file $afg_file -2 &
    pid=$!
    trap "kill $pid &> /dev/null" SIGHUP SIGINT SIGTERM
    wait $pid

    echo -e "\n>>> afg2mps..."
    $BIN_DIR/afg2mps $afg_file $model_file
elif [[ -n "$afg_file" ]]; then
    if [[ -n "$vbp_file" ]]; then
        error
    fi

    if [[ -z $model_file ]]; then
      model_file=$TMP_DIR/model.mps

      echo -e "\n>>> afg2mps..."
      $BIN_DIR/afg2mps $afg_file $model_file
    fi
fi

solve $model_file;

if [[ -n "$afg_file" && -z "$sol_file" ]]; then
    echo -e "\n>>> vbpsol..."
    $BIN_DIR/vbpsol $afg_file $TMP_DIR/vars.sol
fi

if [[ -n "$sol_file" ]]; then
    cp $TMP_DIR/vars.sol $sol_file
fi
