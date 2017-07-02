#Autopsy.pl
#Plugin by: PlayingSafe, Openkore
#Revision 3 by Rbin
#Openkore 2.0.0 (SVN) upper
#How to use
#At your config file put
#logDeath 1 <-- put 1 to enable logging
#logDeathSize # <--- put your desired number of lines to save
#deathMessage <-- put the "You have died" word on your local language if kore is set to local language
#example:
#logDeathSize 25 (this will save 25 lines of console messages)
#deathMessage You have died (Default language English)

package Autopsy;

use Utils;
use strict;
use Plugins;
use Globals;
use Settings;
use Log qw(message debug);

Plugins::register('Autopsy', 'Record console messages after bot died', \&unload);
my $cHook = Log::addHook(\&cHook, "DeathLog");

sub unload {
        Log::delHook('cHook', $cHook);
}

my @messages = ();

sub cHook {
        my $type = shift;
        my $domain = (shift or "console");
        my $level = (shift or 0);
        my $currentVerbosity = shift;
        my $message = shift;
        my $user_data = shift;
        my $logfile = shift;
        my $deathmsg = shift;
        my $location = shift;

if ($level <= $currentVerbosity && $config{'logDeath'} == 1) {

        my (undef, $microseconds) = Time::HiRes::gettimeofday;
        $microseconds = substr($microseconds, 0, 2);
        my $message2 = "[".getFormattedDate(int(time)).".$microseconds] ".$message;

        push(@messages, $message2);
        my $size = scalar @messages;
        if ($size == $config{'logDeathSize'} + 1) {
                        shift(@messages);
        }
        if ($config{logAppendUsername}) {
                $logfile = "$Settings::logs_folder/deathlog_$config{username}_$config{char}.txt";
        } else {
                $logfile = "$Settings::logs_folder/deathlog.txt";
        }
        $deathmsg = $config{'deathMessage'};
        if ($message =~ /$deathmsg/) {
                my $pos = calcPosition($char);
                $location = "\nYou died at " . $field->descName . " (" . $field->name . ") : $pos->{x}, $pos->{y}\n";
                                use encoding 'utf8';
                                open(DFILE, ">>:utf8", "$logfile"); {
                                print DFILE "\n*** Start of console death log ***\n\n";
                                print DFILE @messages;
                                print DFILE $location;
                                print DFILE "\n*** End of console death log ***\n\n";
                                close(DFILE);
                        }
                }
        }
}
return 1;