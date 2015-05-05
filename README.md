Crashtools
==========

Convenience scripts to symbolicate and format crash report files.

Usage
=====

`crashreport.sh <app name> <crash report>` reads the crash report file and symbolicates
any stack trace addresses within image `<app name>`. The processed report is written
to standard output without any further formatting.

`crash2html.sh <app name> <crash report>` reads the crash report file and symbolicates
any stack trace addresses within image `<app name>`. The report is converted to HTML
and written to standard output -- see `crash2html.sh --help` for options.

For both scripts the image must be located at `./<appname>.app/<appname>` and the
the corresponding symbol file at `./<appname>.app.dSYM`.

License
=======

Crashtools are available under the MIT License (MIT)

Copyright (c) 2015 Tim Gleue (http://gleue-interactive.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
