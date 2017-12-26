#!/usr/bin/env bash

# BOPM provision script, written by Som
set -e
set -u

_author="Som / somsubhra1 [at] xshellz.com"
_package="BOPM"
_version="3.1.3"

echo "Running provision for package $_package version: $_version by $_author"

cd ~

dir="bopm-3.1.3"

if [ -d $dir ]
then
 echo "$dir is already present in $HOME. Aborting!"
 exit
fi

if pgrep bopm >/dev/null 2>&1
then
 echo "BOPM is already running. Aborting installation!"
 exit 
fi

if pgrep unrealircd >/dev/null 2>&1
then
 echo "UnrealIRCd is running."
else
 echo "UnrealIRCd is not running currently. You need to start unrealIRCd first to install BOPM. Aborting!"
 exit
fi

if pgrep services >/dev/null 2>&1
then
 echo "Anope is running."
else
 echo "Anope is not running currently. You need to start Anope first to install BOPM. Aborting!"
 exit
fi

wget http://static.blitzed.org/www.blitzed.org/bopm/files/bopm-3.1.3.tar.gz

tar xzvf bopm-3.1.3.tar.gz

cd bopm-3.1.3

./Configure

make
make install
cd ~
cd bopm/etc
rm -f bopm.conf

cat << EOF > bopm.conf
# https://www.xshellz.com

options {
	pidfile = "/$HOME/bopm/bopm.pid";
	dns_fdlimit = 64;
	scanlog = "/$HOME/bopm/scan.log";
};


IRC {
	nick = "$nick";
	realname = "$realname";
	username = "$user";
	server = "$serverip";
	port = $port;
	nickserv = "ns identify $nickpass";
	oper = "$operuser $operpass";
	mode = "+H-h";
	away = "";
	
	channel {
	 name = "$channel";
#	 key = "channelkey";
	};
 
 # DO NOT EDIT ANYTHING BELOW THIS LINE UNLESS
 # YOU KNOW WHAT YOU ARE DOING.
	
 connregex = "\\*\\*\\* Notice -- Client connecting.*: ([^ ]+) \\(([^@]+)@([^\\)]+)\\) \\[([0-9\\.]+)\\].*";
	kline = "KLINE *@%h :Open Proxy found on your host. Please visit www.blitzed.org/proxy?ip=%i for more information.";

	/* A GLINE example for IRCu: */
# kline = "GLINE +*@%i 1800 :Open proxy found on your host. Please visit www.blitzed.org/proxy?ip=%i for more information.";

 /* An AKILL example for services with OperServ
 * Your BOPM must have permission to AKILL for this to work! */

# kline = "PRIVMSG OpenServ :AKILL +3h *@%h Open proxy found on your host. Please visit www.blitzed.org/proxy?ip=%i for more information.";
 
	perform = "PROTOCTL HCN";
};

OPM {

 /* DroneBL - http://dronebl.org */
	blacklist {
	 name = "dnsbl.dronebl.org";
	 type = "A record reply";
	 ban_unknown = yes;
	 reply {
 2 = "Sample"; 
 3 = "IRC Drone"; 
 4 = "Tor"; 
 5 = "Bottler"; 
 6 = "Unknown spambot or drone";
 7 = "DDOS Drone";
 8 = "SOCKS Proxy"; 
 9 = "HTTP Proxy"; 
 10 = "ProxyChain"; 
 255 = "Unknown"; 
	 };
	 kline = "KLINE *@%h :You have a host listed in the DroneBL. For more information, visit http://dronebl.org/lookup_branded.do?ip=%i&network=Mp5IRC";
	};

# ircbl.ahbl.org - see http://ahbl.org/docs/ircbl
 blacklist {
 name = "ircbl.ahbl.org";
 type = "A record reply";
 ban_unknown = no;
 reply {
 2 = "Open proxy";
 };
 kline = "KLINE *@%h :Listed in ircbl.ahbl.org. See http://ahbl.org/removals";
 };

 /* tor.dnsbl.sectoor.de - http://www.sectoor.de/tor.php */
 blacklist {
 name = "tor.dnsbl.sectoor.de";
 type = "A record reply";
 reply {
 1 = "Tor exit server";
 };
 ban_unknown = no;
 kline = "KLINE *@%h :Tor exit server detected. See www.sectoor.de/tor.php?ip=%i";
 };

 /* rbl.efnet.org - http://rbl.efnet.org/ */
 blacklist {
 name = "rbl.efnet.org";
 type = "A record reply";
 reply {
 1 = "Open proxy";
 2 = "Trojan spreader";
 3 = "Trojan infected client";
 4 = "TOR exit server";
 5 = "Drones / Flooding";
 };
 ban_unknown = yes;
 kline = "KLINE *@%h :Listed in rbl.efnet.org. See rbl.efnet.org/?i=%i";
 };
		blacklist {
 name = "dnsbl.swiftbl.net";
 type = "A record reply";
 reply {
 2 = "SOCKS Proxy";
 3 = "IRC Proxy";
 4 = "HTTP Proxy";
 5 = "IRC Drone";
 6 = "TOR";
			};
 ban_unknown = no;
 kline = "gline +*@h 10000 :Your host is listed in SwiftBL. For further information and removal visit http://swiftbl.net/lookup";
	};
};

scanner {
	name="default";
	protocol = HTTP:80;
	protocol = HTTP:8080;
	protocol = HTTP:3128;
	protocol = HTTP:6588;
	protocol = SOCKS4:1080;
	protocol = SOCKS5:1080;
	protocol = ROUTER:23;
	protocol = WINGATE:23;
	protocol = HTTPPOST:80;
	fd = 512;
	max_read = 4096;
	timeout = 30;
	target_ip = "74.63.222.61";
	target_port = 6667;
	target_string = "*** Looking up your hostname...";
	target_string = "ERROR :Trying to reconnect too fast.";
	target_string = "ERROR :Your host is trying to (re)connect too fast -- throttled.";
};

scanner {
	name = "extended";

	protocol = HTTP:81;
	protocol = HTTP:8000;
	protocol = HTTP:8001;
	protocol = HTTP:8081;

	protocol = HTTPPOST:81;
	protocol = HTTPPOST:6588;
#	protocol = HTTPPOST:4480;
	protocol = HTTPPOST:8000;
	protocol = HTTPPOST:8001;
	protocol = HTTPPOST:8080;
	protocol = HTTPPOST:8081;

	protocol = SOCKS4:4914;
	protocol = SOCKS4:6826;
	protocol = SOCKS4:7198;
	protocol = SOCKS4:7366;
	protocol = SOCKS4:9036;

	protocol = SOCKS5:4438;
	protocol = SOCKS5:5104;
	protocol = SOCKS5:5113;
	protocol = SOCKS5:5262;
	protocol = SOCKS5:5634;
	protocol = SOCKS5:6552;
	protocol = SOCKS5:6561;
	protocol = SOCKS5:7464;
	protocol = SOCKS5:7810;
	protocol = SOCKS5:8130;
	protocol = SOCKS5:8148;
	protocol = SOCKS5:8520;
	protocol = SOCKS5:8814;
	protocol = SOCKS5:9100;
	protocol = SOCKS5:9186;
	protocol = SOCKS5:9447;
	protocol = SOCKS5:9578;

	protocol = SOCKS4:29992;
	protocol = SOCKS4:38884;
	protocol = SOCKS4:18844;
	protocol = SOCKS4:17771;
	protocol = SOCKS4:31121;

	fd = 400;
};

user {
	mask = "*!*@*";
	scanner = "default";
};

user {
#	mask = "*!~*@*";
	mask = "*!squid@*";
	mask = "*!nobody@*";
	mask = "*!www-data@*";
	mask = "*!cache@*";
	mask = "*!CacheFlowS@*";
	mask = "*!*@*www*";
	mask = "*!*@*proxy*";
	mask = "*!*@*cache*";

	scanner = "extended";
};

exempt {
	mask = "*!*@127.0.0.1";
};
EOF

cd ~
cd bopm/bin
chmod +x bopm
./bopm

#cleanup
cd ~
rm bopm-3.1.3.tar.gz

#Check if bopm ran successfully or not.
if pgrep bopm >/dev/null 2>&1
then
 echo "BOPM is running successfully"
else
 echo "Error occured"
 exit 
fi

echo "Provision done, successfully."
			