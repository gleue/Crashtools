#! /bin/sh

# Copyright (c) 2015 Tim Gleue (http://gleue-interactive.com)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

#############################
#
# AWK script as here document
#
read -d '' awkscript << 'EOF'
BEGIN {

	if (arch != "") arch = sprintf("-arch %s", arch);
}

/^([0-9]+) +[^ ]+ *\\t?(0x[0-9a-fA-F]+) +(0x.[0-9a-fA-F]+) +\\+ +([0-9]+)$/ {

	if ($2 == app) {

		match($0, "^([0-9]+) +[^ ]+ *\\t?(0x[0-9a-fA-F]+) +");
		prefix = substr($0, RSTART, RLENGTH);

		cmd = sprintf("atos -o %s.app/%s %s -l %s %s", $2, $2, arch, $4, $3);
		cmd | getline symbol;
	
		if (symbol) {

			print prefix symbol;
			next;
		}
	}
}

{
	print $0;
}
EOF

#############################
#
# Helper functions
#
function usage {

	echo "usage: `basename $0` [options] appname crashlog"
	echo
	echo "Reads crash report file <crashlog> and symbolicates"
	echo "stack trace addresses within image <appname> to standard"
	echo "output."
	echo
	echo "The image must be located at ./<appname>.app/<appname>"
	echo "and the corresponding symbol file at ./<appname>.app.dSYM."
	echo	
	echo "options:"
	echo "          -h | --help             	Show this help and exit"
	echo "          -a | --arch architecture	Use architecture's symbols"
}

#############################
#
# Parse command line options
#
# see: http://stackoverflow.com/a/14203146

while [[ ${1:0:1} == "-" ]] ; do

	case "$1" in

		-h|--help)
			usage
			exit
			shift
			;;
		-a|--arch)
			ARCH="$2"
			shift
			;;
		*)
			# unknown option
			usage
			exit
			;;
	esac

	shift
done

#############################
#
# Process crash report if given
#
if [[ $# == 2 ]]; then

	awk -v app="$1" -v arch="$ARCH" "$awkscript" "$2"
	
else

	usage
	exit 1

fi
