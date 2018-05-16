#!/usr/bin/perl 

$file = $ARGV[0];

open(FH, $file);
open(OUT, ">temp");

while(<FH>){
    chomp $_;
    if($_ =~ /\*/){
    }else{
        print OUT "$_\n";
    }
}
close(OUT);
close(FH);

system("mv -f temp $file");
