import kjv;

import std.file;

void main(string[] args) {
	kjv.kjv=new Bible(readText(`kjvtext.txt`));
	doArgs(args);
}
