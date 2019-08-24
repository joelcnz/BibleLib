import std.process;

void main(string[] args) {
	if (args.length == 1)
		args ~= " ";
	foreach(exe; ["cat cf.d", "dmd "~args[1]~" -ofrun ../../*.d ../../arsd/*.d"]) {
		std.stdio.writeln('[', exe, ']');
		wait(spawnShell(exe));
	}
}
