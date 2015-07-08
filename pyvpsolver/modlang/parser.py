"""
This code is part of the Arc-flow Vector Packing Solver (VPSolver).

Copyright (C) 2013-2015, Filipe Brandao
Faculdade de Ciencias, Universidade do Porto
Porto, Portugal. All rights reserved. E-mail: <fdabrandao@dcc.fc.up.pt>.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

import re
from .cmd import CmdSet, CmdParam, CmdFlow, CmdGraph, CmdLoadVBP


class AMPLParser(object):
    """Class for parsing AMPL files with modlang extensions"""

    RGX_CMD = "[a-zA-Z_][a-zA-Z0-9_]*"
    RGX_ARG1 = "[^\\]]*"
    RGX_ARG2 = """"(?:[^"]|\")*"|'(?:[^']|\')*'|{(?:[^}])*}|[^}]*"""
    RGX_STMT = (
        "(#|/\\*\\s*)?(?:"
        "\\$("+RGX_CMD+")\\s*(\\["+RGX_ARG1+"\\])?\\s*{("+RGX_ARG2+")}\\s*;"
        "|\\${("+RGX_ARG2+")}"
        ")(?:\\s*\\*/)?"
    )
    VALID_CMDS = (
        "EXEC", "EVAL", "SET", "PARAM", "LOAD_VBP", "FLOW", "GRAPH", None
    )

    def __init__(self, locals_=None, globals_=None):
        if locals_ is None:
            locals_ = {}
        if globals_ is None:
            globals_ = globals()

        pyvars = locals_
        sets, params = {}, {}
        pyvars["_model"] = ""
        pyvars["_sets"] = sets
        pyvars["_params"] = params
        pyvars["SET"] = CmdSet(pyvars, sets, params)
        pyvars["PARAM"] = CmdParam(pyvars, sets, params)
        pyvars["FLOW"] = CmdFlow(pyvars, sets, params)
        pyvars["GRAPH"] = CmdGraph(pyvars, sets, params)
        pyvars["LOAD_VBP"] = CmdLoadVBP(pyvars, sets, params)

        self._cmds = ("SET", "PARAM", "FLOW", "GRAPH", "LOAD_VBP")

        self._pyvars = pyvars
        self._locals = locals_
        self._globals = globals_
        self.input = ""
        self.output = ""

    def parse(self, mod_in=None, mod_out=None):
        """Parses the input file."""
        self._clear()
        if mod_in is not None:
            self.read(mod_in)
        self.output = self.input

        locals_ = self._locals
        globals_ = self._globals

        rgx = re.compile(self.RGX_STMT, re.DOTALL)
        for match in rgx.finditer(self.input):
            comment, call, args1, args2, args3 = match.groups()
            assert call in self.VALID_CMDS
            strmatch = self.input[match.start():match.end()]

            if comment is not None:
                self.output = self.output.replace(
                    strmatch, "/*IGNORED:"+strmatch.strip("/**/")+"*/"
                )
                continue
            if call is None:
                res = eval(args3, globals_, locals_)
            elif call == "EVAL":
                res = eval(args2, globals_, locals_)
            elif call == "EXEC":
                assert args1 is None
                locals_["_model"] = ""
                exec(args2, globals_, locals_)
                res = locals_["_model"]
            else:
                if args1 is None:
                    call = "%s[%s](%s)" % (call, args1, args2)
                else:
                    call = "%s['''%s'''](%s)" % (
                        call, args1.strip("[]"), args2
                    )
                locals_["_model"] = ""
                exec(call, globals_, locals_)
                res = locals_["_model"]

            self.output = self.output.replace(
                strmatch, "/*EVALUATED:%s*/%s" % (strmatch, res)
            )

        self._finalize()

        if mod_out is not None:
            self.write(mod_out)

    def _clear(self):
        """Clears definitions from previous models."""
        for cmd in self._cmds:
            self._pyvars[cmd].clear()

    def _finalize(self):
        """Adds definitions to the model."""
        for cmd in self._cmds:
            self._add_defs(self._pyvars[cmd].defs)
            self._add_data(self._pyvars[cmd].data)

    def _add_defs(self, defs):
        """Adds definitions to the model."""
        if defs != "":
            self.output = defs + self.output

    def _add_data(self, data):
        """Adds data to the model."""
        if data != "":
            data_stmt = re.search("data\\s*;", self.output, re.DOTALL)
            end_stmt = re.search("end\\s*;", self.output, re.DOTALL)
            if data_stmt is not None:
                match = data_stmt.group(0)
                self.output = self.output.replace(match, match+"\n"+data)
            else:
                if end_stmt is None:
                    self.output += "data;\n" + data + "\nend;"
                else:
                    match = end_stmt.group(0)
                    self.output = self.output.replace(
                        match, "data;\n" + data + "\nend;"
                    )

    def read(self, mod_in):
        """Reads the input file."""
        with open(mod_in, "r") as fin:
            self.input = fin.read()

    def write(self, mod_out):
        """Writes the output to a file."""
        with open(mod_out, "w") as fout:
            print >>fout, self.output

    @property
    def flow(self):
        """Returns the FLOW object for solution extraction"""
        return self._pyvars["FLOW"]
