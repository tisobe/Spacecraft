#!/usr/bin/perl 

#################################################################################################
#                                                                                               #
#       restore_rej_event.perl: extract data and restore acis rjected event data files          #
#                                                                                               #
#               author: t. isobe (tisobe@cfa.harvard.edu)                                       #
#                                                                                               #
#               last update: Apr. 13, 2015                                                      #
#                                                                                               #
#################################################################################################

#
#--- read data needed
#
$hakama = `cat /data/mta/MTA/data/.hakama`;
$dare   = `cat /data/mta/MTA/data/.dare`;
chomp $hakama;
chomp $dare;
#
#--- find year interval
#
$start_year = $ARGV[0];
$end_year   = $ARGV[1];
if($start_year eq ''){
    $start_year = 0;
}
if($end_year eq ''){
    $end_year   = 15;
}
if($start_year >= $end_year){
    print "something is wrong. terminating!\n";
    print "Example: perl restore_rej_event.perl 0 15\n";
    print "         where 0 <--- 2000 / 15 <--- 2015\n";
    print "         the last year is exclusive\n";
    exit(1);
}

#for($year = 0; $year < 15; $year++){
for($year = $start_year; $year < $end_year; $year++){
    for($month = 1; $month < 13; $month++){
        $syr  = $year;
        $eyr  = $year;
        $smon = $month;
        $emon = $month + 1;
        if($emon > 12){
            $emon = 1;
            $eyr++;
        }
        if($syr < 10){
            $syr = '0'."$syr";
        }
        if($eyr < 10){
            $eyr = '0'."$eyr";
        }
        if($smon < 10){
            $smon = '0'."$smon";
        }
        if($emon < 10){
            $emon = '0'."$emon";
        }

        $start = "$smon".'/01/'."$syr".',00:00:00';
        $stop  = "$emon".'/01/'."$eyr".',00:00:00';

        open(OUT, "> ./dtext");
#
#--- call arc4gl to extract data
#
        print OUT "operation=retrieve\n";
        print OUT "dataset=flight   \n";
        print OUT "detector=acis    \n";
        print OUT "level=1          \n";
        print OUT "filetype=expstats\n";
        print OUT "tstart=$start\n";
        print OUT "tstop=$stop\n";
        print OUT "go\n";

        close(OUT);

        system("echo $hakama |arc4gl -U$dare  -Sarcocc -i dtext");
        system("rm ./dtext");

        $input = `ls *.fits.gz`;
        @list  = split(/\n+/, $input);
        foreach $fits (@list){
            system("gzip -d $fits");
            $fits =~ s/\.gz//;
#
#--- prep to call idl script
#
            open(OUT, ">./run_obs.pro");
            $line =  "rej_evts,'"."$fits"."'\n";
            $line = $line."exit\n";
            print OUT "$line";
            close(OUT);

            system("idl run_obs.pro");
#
#--- accumulate data
#
            $input = `ls CCD*_rej.dat`;
            @dlist = split(/\n+/, $input);

            foreach $rdat (@dlist){
                system("cat $rdat >> ./Save/$rdat");
                system("rm -rf $rdat");
            }
        }
    }
}

#
#---- now sort them and remove duplicated lines
#

for($i = 0; $i < 10; $i++){
    $file = 'CCD'."$i".'_rej.dat';
    $in   = './Save/'."$file";
    $out  = './Data/'."$file";

    @save = ();
    open(FH, $in);
    while(<FH>){
        chomp $_;
        push(@save, $_);
    }
    close(FH);

    @sorted = sort{$a<=>$b} @save;
    
    $prev    = '';
    @cleaned = ();
    foreach $ent (@sorted){
        if($ent ne $prev){
            $prev = $ent;
            push(@cleaned, $ent);
        }else{
            next;
        }
    }

    open(OUT, ">$out");
    foreach $ent (@cleaned){
        if($ent =~ /\*/){
            next;
        }

        print OUT "$ent\n";
    }
    close(OUT);
}

#system("rm -rf ./Save/*.dat");

