## Arc-flow Vector Packing Solver (VPSolver)

Copyright (C) 2013-2015, Filipe Brandão  
Faculdade de Ciencias, Universidade do Porto  
Porto, Portugal. All rights reserved. E-mail: <fdabrandao@dcc.fc.up.pt>.

---
[VPSolver](https://github.com/fdabrandao/vpsolver) is a vector packing solver based on an arc-flow formulation with graph
compression.  VPSolver generates very strong models (equivalent to Gilmore and
Gomory's) that can be solved using general-purpose mixed-integer programming
solvers such as Gurobi and GLPK [1]. VPSolver does not explicitly require any MIP
solver in particular, though a good  MIP solver may be necessary for solving
large models.

![](https://img.shields.io/badge/license-GPL-blue.svg)
[![](https://travis-ci.org/fdabrandao/vpsolver.svg?branch=master)](https://travis-ci.org/fdabrandao/vpsolver)

For modelling other problems easily, VPSolver includes a [Python API](https://github.com/fdabrandao/vpsolver/wiki/Python-API), a modelling toolbox ([PyMPL](https://github.com/fdabrandao/pympl/)), and a [Web App](#vpsolver-web-app). VPSolver has been successfully compiled and run on Linux and Mac OS X. VPSolver also runs on a large variety of platforms including Windows using a [Docker container](#docker).

For more details, please refer to the [project wiki](https://github.com/fdabrandao/vpsolver/wiki) or to the manual.

#### Repositories
* Project Homepage: <http://vpsolver.dcc.fc.up.pt>
* GiHub repository: <https://github.com/fdabrandao/vpsolver>
* BitBucket repository: <https://bitbucket.org/fdabrandao/vpsolver>
* Docker repository: <https://hub.docker.com/r/fdabrandao/vpsolver>
* PyPI repository: <https://pypi.python.org/pypi/pyvpsolver>

## Requirements
#### Mandatory

* MIP solver: Gurobi, CPLEX, GLPK, COIN-OR, SCIP, lp_solve, ...  
* UNIX-like operating system or a UNIX-like environment such as [Cygwin](https://www.cygwin.com/)
* `g++ >= 4.8`; `make >= 3.0`; `bash >= 3.0`
      
#### Optional

For the [Python API](https://github.com/fdabrandao/vpsolver/wiki/Python-API) and [Web App](#vpsolver-web-app):

* `python-2.7` or `python-3.x`
* `python-setuptools`
* `python-pip`
* `python-dev`
* `glpk-utils`
 
#### Platforms
It has been successfully compiled and run on the following platforms:

* **Linux**
* **Mac OS X**
* On a large variety of platforms including **Windows** using a [Docker container](#docker)
* It also runs on **Windows** using [Cygwin](https://www.cygwin.com/) (a Unix-like environment and command-line interface)

## Setup
Without the python interface: 

```bash
$ bash build.sh  
```
With the python interface: 

```
$ bash build.sh
$ pip install -r requirements.txt
$ pip install . --upgrade
$ bash test.sh
```
or simply:


```
$ bash install.sh
$ bash test.sh
```

## Docker

### Docker Setup

Docker is an open platform for building, shipping and running applications. Docker allows VPSolver to run on a large variety of platforms with very little effort.

Install Docker [[Docker installation instructions](https://docs.docker.com/installation/)].

Option 1: simply `pull` VPSolver from Docker repository (without building):

```bash
$ docker pull fdabrandao/vpsolver
```

Option 2: `clone` VPSolver and `build` locally:

```bash 
$ git clone git@github.com:fdabrandao/vpsolver.git vpsolver
$ docker build -t fdabrandao/vpsolver vpsolver
```

### Usage
Directly using the command line interface:

```bash
$ docker run --rm -it fdabrandao/vpsolver bash
root@55d14f6b6f32:~# source venv2.7/bin/activate # load a virtualenv
(venv2.7)root@55d14f6b6f32:~# python examples/vpsolver/example_vbp.py
...
```

or through the VPSolver Web App (example URL: `http://172.17.0.60:5555/`):

```bash
$ docker run --rm -it -p 5555 fdabrandao/vpsolver 
eth0      Link encap:Ethernet  HWaddr 02:42:ac:11:00:3c  
          inet addr:172.17.0.60  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:acff:fe11:3c/64 Scope:Link
          UP BROADCAST  MTU:1500  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:168 (168.0 B)  TX bytes:180 (180.0 B)

URL: http://172.17.0.60:5555/
 * Running on http://0.0.0.0:5555/
...
```

For more details, please refer to the [project wiki](https://github.com/fdabrandao/vpsolver/wiki/docker).

## VPSolver Web App
VPSolver includes a Web App that can be started as follows:

```
$ python -m pyvpsolver.webapp.app
```

The Web App can then be accessed on a web browser at `http://127.0.0.1:5555/`.

## VPSolver binaries

* `$ bin/vpsolver intance.vbp`: solves a vector packing instance using the method proposed in [1]. Note: requires Gurobi 5.0.0 or superior;
* `$ bin/vbp2afg instance.vbp graph.afg`: builds an arc-flow graph `graph.afg` for `instance.vbp`;
* `$ bin/afg2mps graph.afg model.mps`: creates a MPS model `model.mps` for `graph.afg`;
* `$ bin/afg2lp graph.afg model.lp`: creates a LP model `model.lp` for `graph.afg`;
* `$ bin/solve_gurobi model.mps vars.sol`: solves `model.mps` using Gurobi and writes the solution to `vars.sol`;
* `$ bin/solve_glpk model.mps vars.sol`: solves `model.mps` using GLPK and writes the solution to `vars.sol`;
* `$ bin/vbpsol graph.afg vars.sol`: extracts a vector packing solution from an arc-flow solution `vars.sol` associated with the graph `graph.afg`.

Usage:

```
# 1. Build the arc-flow graph graph.afg for example.vbp:  
$ bin/vbp2afg example.vbp graph.afg  
# 2. Convert the arc-flow graph into a .mps file model.mps:  
$ bin/afg2mps graph.afg model.mps  
# 3. Solve the MIP model and stores the solution in vars.sol:  
$ bin/solve_gurobi model.mps vars.sol  
# 4. Extract the vector packing solution:  
$ bin/vbpsol graph.afg vars.sol  
```

## VPSolver Scripts
VPSolver includes several scripts for solving arc-flow models using different
solvers:

* `scripts/vpsolver_gurobi.sh`: Gurobi
* `scripts/vpsolver_cplex.sh`: IBM CPLEX
* `scripts/vpsolver_coinor.sh`: COIN-OR CBC
* `scripts/vpsolver_glpk.sh`: GLPK
* `scripts/vpsolver_scip.sh`: SCIP
* `scripts/vpsolver_lpsolve.sh`: lp_solve

Usage:

```bash
$ vpsolver_X.sh --vbp instance.vbp
$ vpsolver_X.sh --afg graph.afg
$ vpsolver_X.sh --mps/--lp model.mps/.lp
$ vpsolver_X.sh --mps/--lp model.mps/.lp --afg graph.afg
```

## Folders

* `docs/`: documentation
* `scripts/`: vpsolver scripts
* `bin/`: vpsolver executables
* `src/`: vpsolver source code in C++
* `pyvpsolver/`: pyvpsolver source code in Python
* `examples/`: vpsolver and pyvpsolver examples
* `docs/reports/`: technical reports on the underlying algorithms and models

## Reports
VPSolver was proposed in:

* [1] Brandão, F. and Pedroso, J. P. (2013). Bin Packing and Related Problems:
General Arc-flow Formulation with Graph Compression. Technical Report
DCC-2013-08, Faculdade de Ciências da Universidade do Porto, Universidade do
Porto, Portugal.
Available at: [http://arxiv.org/abs/1310.6887](http://arxiv.org/abs/1310.6887).

See also:

* [2] Brandão, F. and Pedroso, J. P. (2013). Multiple-choice Vector Bin Packing:
Arc-flow Formulation with Graph Compression. Technical Report DCC-2013-13,
Faculdade de Ciências da Universidade do Porto, Universidade do Porto, Portugal.

* [3] Brandão, F. and Pedroso, J. P. (2013). Cutting Stock with Binary Patterns:
Arc-flow Formulation with Graph Compression. Technical Report DCC-2013-09,
Faculdade de Ciências da Universidade do Porto, Universidade do Porto, Portugal.

* [4] Brandão, F. (2012). Bin Packing and Related Problems: Pattern-Based Approaches 
Master’s thesis, Faculdade de Ciências da Universidade do Porto, Portugal.

* [5] Computational results on several benchmark test data sets:  
http://www.dcc.fc.up.pt/~fdabrandao/research/vpsolver/results/


***
Copyright © Filipe Brandão. All rights reserved.  
E-mail: <fdabrandao@dcc.fc.up.pt>. [[Homepage](http://www.dcc.fc.up.pt/~fdabrandao/)]
