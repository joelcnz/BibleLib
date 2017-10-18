import std.stdio;
import std.string;

/// Save writing the symbol twice each time
/// ---
/// mixin( trace( "xpos", "ypos" ) );
/// Output:
/// xpos: 1979
/// ypos: 30
/// ---
string trace(in string[] strs...) {
	string result;
	foreach( str; strs )
		result ~= `writeln( "` ~ str ~ `: ", ` ~ str ~ ` );` ~ "\n";

	return result;
}

/**
 * int a = 1; double b = 0.2; string c = "three";
 * 
 * eg. mixin( traceLine( "a b c".split ) );
 * 
 * Output:
 * 
 * (a: 1) (b: 0.2) (c: three)
 */
string traceLine(in string[] strs...) {
	string result;

	foreach( str; strs ) {
		result ~= `writef( "(` ~ str ~ `: %s) ", ` ~ str ~ ` );`;
	}
	result ~= `writeln();`;

	return result;
}

string jecho(in string str) {
	return `writeln("` ~ str ~ `"); ` ~ str;
}
