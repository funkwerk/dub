/**
	Empty package initialization code.

	Copyright: © 2013 rejectedsoftware e.K.
	License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
	Authors: Sönke Ludwig
*/
module dub.init;

import dub.internal.std.process;
import dub.internal.vibecompat.core.file;
import dub.internal.vibecompat.core.log;
import dub.package_ : PackageJsonFilename;

import std.datetime;
import std.file;
import std.format;
import std.string;


void initPackage(Path root_path, string type)
{
	switch (type) {
		default: throw new Exception("Unknown package init type: "~type);
		case "minimal": initMinimalPackage(root_path); break;
		case "vibe.d": initVibeDPackage(root_path); break;
	}
}

void initMinimalPackage(Path root_path)
{
	writePackageJson(root_path, "A minimal D application.", null);
	createDirectory(root_path ~ "source");
	write((root_path ~ "source/app.d").toNativeString(), 
q{import std.stdio;

void main()
{
	writeln("Edit source/app.d to start your project.");
}
});
}

void initVibeDPackage(Path root_path)
{
	writePackageJson(root_path, "A simple vibe.d server application.", ["vibe-d": ">=0.7.17"]);
	createDirectory(root_path ~ "source");
	createDirectory(root_path ~ "views");
	createDirectory(root_path ~ "public");
	write((root_path ~ "source/app.d").toNativeString(), 
q{import vibe.d;

shared static this()
{
	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings, &hello);

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
}

void hello(HTTPServerRequest req, HTTPServerResponse res)
{
	res.writeBody("Hello, World!");
}
});
}

void writePackageJson(Path root_path, string description, string[string] dependencies)
{
	assert(!root_path.empty);

	string username;
	version (Windows) username = environment.get("USERNAME", "Peter Parker");
	else username = environment.get("USER", "Peter Parker");

	auto fil = openFile(root_path ~ PackageJsonFilename, FileMode.Append);
	scope(exit) fil.close();

	fil.formattedWrite("{\n\t\"name\": \"%s\",\n", root_path.head.toString().toLower());
	fil.formattedWrite("\t\"description\": \"%s\",\n", description);
	fil.formattedWrite("\t\"copyright\": \"Copyright © %s, %s\",\n", Clock.currTime().year, username);
	fil.formattedWrite("\t\"authors\": [\"%s\"],\n", username);
	fil.formattedWrite("\t\"dependencies\": {");
	bool first = true;
	foreach (dep, ver; dependencies) {
		if (first) first = false;
		else fil.write(",");
		fil.formattedWrite("\n\t\t\"%s\": \"%s\"", dep, ver);
	}
	fil.formattedWrite("\n\t}\n}\n");
}