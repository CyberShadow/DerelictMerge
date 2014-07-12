import std.net.curl;
import std.json;
import std.stdio;
import std.file;
import std.string;
import core.thread;

void main()
{
	auto http = HTTP();
	http.verifyPeer = false;

	enum tokenFileName = "token.txt";
	if (tokenFileName.exists)
		http.addRequestHeader("Authorization", "token " ~ readText(tokenFileName).strip());

	auto repos = get("https://api.github.com/users/DerelictOrg/repos", http).parseJSON().array;
	foreach (repo; repos)
	{
		auto name = repo["name"].str;
		//writeln(name, ":");
		Thread.sleep(1.seconds);
		auto packages = get("https://api.github.com/repos/DerelictOrg/" ~ name ~ "/contents/source/derelict/", http).parseJSON().array;
		auto p = packages[0]["name"].str;
		//foreach (p; packages)
		//	writeln(p["name"].str);
		writefln("%s\t%s\tsource/derelict/%s", p, repo["clone_url"].str, p);
		stdout.flush();
	}
}
