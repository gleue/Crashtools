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

	general = 0;
	
	thread_id = "";
	thread_name = "";

	print "<!DOCTYPE html>";
	print "<html>";
}

/^Triggered by Thread: +[0-9]+$/ {

	if (general) {
	
		match($0, "[0-9]+$");
		prefix = substr($0, 1, RSTART - 1);
		id = substr($0, RSTART, RLENGTH);

		print "<tr><td>" prefix "</td><td><a href=\\"#" id "\\">Thread " id "</a></td></tr>";

		next;
	}
}
	
/^Thread +[0-9]+ +name: +(.*)$/ {

	match($0, "Thread +[0-9]+ +name: +");

	thread_id = $2;
	thread_name = substr($0, RSTART + RLENGTH);

	next;
}

/^Thread +[0-9]+ +crashed with(.*)$/ {

	print "<table>";

	match($0, "Thread +[0-9]+ +crashed with +");

	suffix = substr($0, RSTART + RLENGTH);
	print "<h2 id=\\"state\\">" suffix "</h2>";
	print "<pre>";

	next;
}
	
/^Thread +[0-9]+.*:$/ {

	print "</table>";

	if (general) {
	
		general = 0;
		
		print "<h2 id=\\"threads\\">Threads</h2>";
	}

	match($0, "Crashed:");
	class = (RLENGTH == 8) ? " class=\\"crashed\\"" : "";

	len = length($2);
	idx = index($2, ":"); if (idx > 0) len -= 1;
	id = substr($2, 0, len);

	if (thread_id == id) {
	
		print "<h3 id=\\"" thread_id "\\"" class "\\">" $0 " \\"" thread_name "\\"</h3>"; 

	} else {

		print "<h3 id=\\"" id "\\"" class "\\">" $0 "</h3>"; 
	}

	print "<table>";
	print "<tr><th>#</th><th>Image</th><th>Address</th><th>Symbol</th><th>File</th></tr>";

	next;
}

/^([0-9]+) +[^ ]+ *\\t?(0x[0-9a-fA-F]+) +(0x.[0-9a-fA-F]+) +\\+ +([0-9]+)$/ {

	if ($2 == app) {
	
		cmd = sprintf("atos -o %s.app/%s %s -l %s %s", $2, $2, arch, $4, $3);
		cmd | getline symbol;
	
		if (symbol) {
		
			match(symbol, " *\\\\([^\\\\)]*\\\\)");
			member = substr(symbol, RSTART, RLENGTH);
			sub(" *\\\\([^\\\\)]*\\\\)", "", symbol);

			match(symbol, "\\\\([^\\\\)]*\\\\)");

			method = substr(symbol, 0, RSTART - 1);
			location = substr(symbol, RSTART, RLENGTH);
	
			match(location, "\\\\([^:]*:");
			file = substr(location, RSTART + 1, RLENGTH - 2);
			match(location, ":[0-9]*\\\\)");
			line = substr(location, RSTART + 1, RLENGTH - 2);

			if (srcdir != "") {

				print "<tr><td>" $1 "</td><td><a href=\\"#" $2 "\\">" $2 "</a></td><td>" $3 "</td><td>" method "</td><td><a href=\\"file://" srcdir "/" file "\\">" file ":"line "</a>" member "</td></tr>"
				
			} else {

				print "<tr><td>" $1 "</td><td><a href=\\"#" $2 "\\">" $2 "</a></td><td>" $3 "</td><td>" method "</td><td>" file ":"line member "</td></tr>"
			}

		} else {

			match($0, "^([0-9]+) +[^ ]+ *\\t?(0x[0-9a-fA-F]+) +");
			suffix = substr($0, RSTART + RLENGTH);

			print "<tr><td>" $1 "</td><td><a href=\\"#" $2 "\\">" $2 "</a></td><td>" $3 "</td><td>" suffix "</td></tr>"
		}
				
	} else {

		match($0, "^([0-9]+) +[^ ]+ *\\t?(0x[0-9a-fA-F]+) +");
		suffix = substr($0, RSTART + RLENGTH);

		print "<tr><td>" $1 "</td><td><a href=\\"#" $2 "\\">" $2 "</a></td><td>" $3 "</td><td>" suffix "</td></tr>"
	}

	next;
}

/^([0-9]+) +[^ ]+ *\\t?(0x[0-9a-fA-F]+) +.*$/ {

	match($0, "^([0-9]+) +[^ ]+ *\\t?(0x[0-9a-fA-F]+) +");
	suffix = substr($0, RSTART + RLENGTH);

	print "<tr><td>" $1 "</td><td><a href=\\"#" $2 "\\">" $2 "</a></td><td>" $3 "</td><td>" suffix "</td></tr>"
	next;
}

/^Binary Images:$/ {

	print "</pre>";

	h2 = substr($0, 0, length($0) - 1);

	print "<h2 id=\\"images\\">" h2 "</h2>";
	print "<table>";
	print "<tr><th>Load Address</th><th>End Address</th><th>Image</th><th>Arch</th><th>Build</th><th>File</th></tr>";

	next;
}

/^(0x[0-9a-fA-F]+) +\\- +(0x[0-9a-fA-F]+) +.*$/ {

	len = length($6);
	uuid = substr($6, 2, len - 2);

	print "<tr id=\\"" $4 "\\"><td>" $1 "</td><td>" $3 "</td><td>" $4 "</td><td>" $5 "</td><td>" uuid "</td><td>" $7 "</td></tr>";

	next;
}

{
	if (NR == 1) {

		print "<head>";
		print "<title>" FILENAME " - " app "</title>";

		if (cssfile) {
		
			print "<link rel=\\"stylesheet\\" type=\\"text/css\\" href=\\"" cssfile "\\" />";

		} else {
		
			print "<style>";
			print "body { font-family: monospace; }"
			print "th { text-align: left; }"
			print "h3.crashed { color: red; }"
			print "</style>";
		}
		
		print "</head>";
		print "<body>";
		print "<h1>" FILENAME "</h1>";
		print "<h2 id=\\"general\\">General</h2>";
		print "<table>"
		
		general = 1;
	}
	
	if (general && $0 != "") {
	
		split($0, td, ":");
		match(td[2], "^ *");
		td[2] = substr(td[2], RLENGTH + 1);

		print "<tr><td>" td[1] ":</td><td>" td[2] "</td></tr>";
		
		next;
	}
	
	if (!general) {
	
		print $0;
	}
}
	
END {

	print "</table>";
	print "</body>";
	print "</html>";
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
	echo "          -c | --css filename     	Include css file in header instead of built-in styles"
	echo "          -s | --srcdir directory 	Set directory for source file links"
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
		-c|--cssfile)
			CSS_FILE=$(stat -f %N "$2")
			shift
			;;
		-s|--srcdir)
			SRC_DIR=$(stat -f %N "$2")
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
# Convert crash report if given
#
if [[ $# == 2 ]]; then

	awk -v app="$1" -v arch="$ARCH" -v srcdir="$SRC_DIR" -v cssfile="$CSS_FILE" "$awkscript" "$2"
	
else

	usage
	exit 1

fi
