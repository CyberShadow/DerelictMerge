import core.thread;
import std.json;
import std.stdio;
import std.file;
import std.string;

version (AE)
{
	import ae.net.asockets;
	import ae.net.http.client;
	import ae.net.ssl.openssl;

	string httpGet(string url)
	{
		auto request = new HttpRequest;
		request.resource = url;

		enum tokenFileName = "token.txt";
		if (tokenFileName.exists)
			request.headers["Authorization"] = "token " ~ readText(tokenFileName).strip();

		string result;
		httpRequest(request,
			(Data data)
			{
				result = (cast(char[])data.contents).idup;
				std.utf.validate(result);
			},
			(string error) { throw new Exception(error); }
		);

		socketManager.loop();

		return result;
	}
}
else
{
	import std.net.curl;

	HTTP http;
	static this()
	{
		http = HTTP();
		http.verifyPeer = false;

		enum tokenFileName = "token.txt";
		if (tokenFileName.exists)
			http.addRequestHeader("Authorization", "token " ~ readText(tokenFileName).strip());
	}

	char[] httpGet(string url)
	{
		return get(url, http);
	}
}

void main()
{
	auto repos = httpGet("https://api.github.com/users/DerelictOrg/repos").parseJSON().array;
	foreach (repo; repos)
	{
		auto name = repo["name"].str;
		//writeln(name, ":");
		Thread.sleep(1.seconds);
		auto packages = httpGet("https://api.github.com/repos/DerelictOrg/" ~ name ~ "/contents/source/derelict/").parseJSON().array;
		auto p = packages[0]["name"].str;
		//foreach (p; packages)
		//	writeln(p["name"].str);
		writefln("%s\t%s\tsource/derelict/%s", p, repo["clone_url"].str, p);
		stdout.flush();
	}
}
