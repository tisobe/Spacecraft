#!/usr/bin/perl 

#########################################################################################
#                                                                                       #
#   cleanup.perl: sort them numerically (means by date)  and remove duplicated lines    #
#                                                                                       #
#       author: t. isobe (tisobe@cfa.harvard.edu)                                       #
#                                                                                       #
#       last update: Apr. 16, 2015                                                      #
#                                                                                       #
#########################################################################################

for($i = 0; $i < 10; $i++){
    $file = './CCD'."$i".'_rej.dat';
    $in   = $file;
    $out  = $file;
    
    @save = ();
    open(FH, $in);
    while(<FH>){
        chomp $_;
#
#--- remove the header
#
        if($_ =~ /TIME/){
            next;
        }
        push(@save, $_);
    }
    close(FH);
    
    @sorted = sort{$a<=>$b} @save;
    
    $prev= '';
    @cleaned = ();
    foreach $ent (@sorted){
        if($ent ne $prev){
            $prev = $ent;
            push(@cleaned, $ent);
        }else{
            next;
        }
    }
#
#--- put back the header
#
    open(OUT, ">$out");
    print OUT "TIME EVTSENT SD DROP_POS SD DROP_GRD SD THR_PIX SD BERR_SUM SD Navg OBS_ID CCD\n";

    foreach $ent (@cleaned){
#
#--- occasionally idl output put *** instead of normal numerical values;
#--- so just remove the line contains *** 
#
        if($ent =~ /\*/){
    next;
    }
    
    print OUT "$ent\n";
    }
    close(OUT);
}

