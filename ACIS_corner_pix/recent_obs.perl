#!/usr/bin/perl 

#########################################################################################################################
#															#
#	recent_obs.perl: creates a table for MTA ACIS Corner Pixels Recent Obsids Plots					#
#															#
#		author: t. isobe (tisobe@cfa.harvard.edu)								#
#															#
#		last update: Nov 23, 2015										#
#															#
#########################################################################################################################

#
#---  this is a supplemental script for ACIS Corner Pixel which is managed by B. Spitzbart.
#---  most scripts are written in idl, and kept in /data/mta_www/mta_acis_sci_run/Corner_pix.
#---  please see idl scripts in that directory for detail computation of ACIs Corner Pixels.
#


$web_dir = "/data/mta_www/mta_acis_sci_run/Corner_pix/Week/";

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);

$uyear += 1900;
$umon++;

$time_ago_month = $umon;
#$time_ago_date  = $umday - 15;
$time_ago_date  = $umday - 45;

$pchk = 0;
if($time_ago_date < 1){
	$time_ago_month--;
	if($time_ago_month < 1){
		$time_ago_month = 12;
		$time_ago_date = 31 + $time_ago_date;
		$pchk = 1;
	}else{
		if($time_ago_month == 2){
			$chk = 4.0 * int(0.25 * $uyear);
			if($chk == $uyear){
				$time_ago_date = 29 + $time_ago_date;
			}else{
				$time_ago_date = 28 + $time_ago_date;
			}
		}elsif($time_ago_month == 1 || $time_ago_month == 3 || $time_ago_month == 5 ||  $time_ago_month == 7
			|| $time_ago_month == 8 || $time_ago_month == 10){
				$time_ago_date = 31 + $time_ago_date;
		}else{
			$time_ago_date = 30 + $time_ago_date;
		}
	}
}

$input = `ls -lrt $web_dir/*.gif`;
@list  = split(/\n/, $input);

@this_week_list = ();
$count          = 0;
foreach $ent (@list){
	@atemp = split(/\s+/, $ent);
	$month = convert_to_digit($atemp[5]);
	$date  = $atemp[6];

	if($pchk == 1){
		if($month == 12){
			if($date >= $time_ago_date){
				push(@this_week_list, $atemp[8]);
				$count++;
			}else{
###				system("mv $web_dir/$atemp[8] $web_dir/Old");
			}
		}elsif($month == 1){
			push(@this_week_list, $atemp[8]);
			$count++;
		}else{
###			system("mv $web_dir/$atemp[8] $web_dir/Old");
		}
	}else{
		if($month >= $time_ago_month){
			if($date >= $time_ago_date){
				push(@this_week_list, $atemp[8]);
				$count++;
			}else{
###				system("mv $web_dir/$atemp[8] $web_dir/Old");
			}
		}
	}
}


@obsid_list = ();
@temp  = split(/acisf/, $this_week_list[0]);
@atemp = split(/_/, $temp[1]);
$obsid = $atemp[0];
push(@obsid_list, $obsid);
OUTER:
for($i = 1; $i < $count; $i++){
	if($this_week_list[$i] =~ /$obsid/){
		next;
	}
	@temp  = split(/acisf/, $this_week_list[$i]);
	@atemp = split(/_/, $temp[1]);
	$obsid = $atemp[0];
	push(@obsid_list, $obsid);
}
	

open(OUT, "> $web_dir/recent_data.html");


print OUT "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"> \n";
print OUT " \n";
print OUT "<html> \n";
print OUT "<head> \n";

print OUT "        <link rel=\"stylesheet\" type=\"text/css\" href=\"https://cxc.cfa.harvard.edu/mta/REPORTS/Template/mta.css\" /> \n";
print OUT "        <title> ACIS Corner Pixels -- Recent Observations </title> \n";
print OUT " \n";
print OUT "        <script language=\"JavaScript\"> \n";
print OUT "                function WindowOpener(imgname) { \n";
print OUT "                        msgWindow = open(\"\",\"displayname\",\"toolbar=no,directories=no,menubar=no,location=no,scrollbars=no,status=no,width=700,height=560,resize=no\"); \n";
print OUT "                        msgWindow.document.clear(); \n";
print OUT "                        msgWindow.document.write(\"<html><title>ACIS Corner Pixels:   \"+imgname+\"</title>\"); \n";
print OUT "                        msgWindow.document.write(\"<body bgcolor='black'>\"); \n";
print OUT "                        msgWindow.document.write(\"<img src='./\"+imgname+\"' border =0 ><p></p></body></html>\") \n";
print OUT "                        msgWindow.document.close(); \n";
print OUT "                        msgWindow.focus(); \n";
print OUT "                } \n";
print OUT "        </script> \n";
print OUT " \n";
print OUT "</head> \n";
print OUT "<body> \n";
print OUT "<h2>ACIS Corner Pixels: Recent Observations</h2> \n";
print OUT "<p>Click to see a plot. Note that not all plots are created for the given obsid.</p> \n";
print OUT "<table border=2 cellpadding=10, cellspacing=10> \n";

print OUT "<tr><th>Obsid</th><th>I2ahist</th><th>I3ahist</th><th>S2ahist</th><th>S2ahist</th><th>acp</th>\n";
print OUT "<th>I2hist</th><th>I3hist</th><th>S2hist</th><th>S3hist</th><th>cp</th></tr>\n";
foreach $obsid (@obsid_list){
	print OUT "<tr> \n";
	print OUT "<th>$obsid</th>\n";

	$name = 'acisf'."$obsid".'_I2ahist.gif';
	if($input =~ /$name/){
		print OUT "<td align=\"center\"><a href=\"javascript:WindowOpener('$name')\">I2ahist</a></td> \n";
	}else{
		print OUT "<td>No Plot</td>\n";
	}

	$name = 'acisf'."$obsid".'_I3ahist.gif';
	if($input =~ /$name/){
		print OUT "<td align=\"center\"><a href=\"javascript:WindowOpener('$name')\">I3ahist</a></td> \n";
	}else{
		print OUT "<td>No Plot</td>\n";
	}

	$name = 'acisf'."$obsid".'_S2ahist.gif';
	if($input =~ /$name/){
		print OUT "<td align=\"center\"><a href=\"javascript:WindowOpener('$name')\">S2ahist</a></td> \n";
	}else{
		print OUT "<td>No Plot</td>\n";
	}

	$name = 'acisf'."$obsid".'_S3ahist.gif';
	if($input =~ /$name/){
		print OUT "<td align=\"center\"><a href=\"javascript:WindowOpener('$name')\">S2ahist</a></td> \n";
	}else{
		print OUT "<td>No Plot</td>\n";
	}

	$name = 'acisf'."$obsid".'acp.gif';
	if($input =~ /$name/){
		print OUT "<td align=\"center\"><a href=\"javascript:WindowOpener('$name')\">acp</a></td> \n";
	}else{
		print OUT "<td>No Plot</td>\n";
	}

	$name = 'acisf'."$obsid".'_I2hist.gif';
	if($input =~ /$name/){
		print OUT "<td align=\"center\"><a href=\"javascript:WindowOpener('$name')\">I2hist</a></td> \n";
	}else{
		print OUT "<td>No Plot</td>\n";
	}

	$name = 'acisf'."$obsid".'_I3hist.gif';
	if($input =~ /$name/){
		print OUT "<td align=\"center\"><a href=\"javascript:WindowOpener('$name')\">I3hist</a></td> \n";
	}else{
		print OUT "<td>No Plot</td>\n";
	}

	$name = 'acisf'."$obsid".'_S2hist.gif';
	if($input =~ /$name/){
		print OUT "<td align=\"center\"><a href=\"javascript:WindowOpener('$name')\">S2hist</a></td> \n";
	}else{
		print OUT "<td>No Plot</td>\n";
	}

	$name = 'acisf'."$obsid".'_S3hist.gif';
	if($input =~ /$name/){
		print OUT "<td align=\"center\"><a href=\"javascript:WindowOpener('$name')\">s3hist</a></td> \n";
	}else{
		print OUT "<td>No Plot</td>\n";
	}

	$name = 'acisf'."$obsid".'cp.gif';
	if($input =~ /$name/){
		print OUT "<td align=\"center\"><a href=\"javascript:WindowOpener('$name')\">cp</a></td> \n";
	}else{
		print OUT "<td>No Plot</td>\n";
	}

	print OUT "</tr> \n";
}

print OUT "</table> \n";
print OUT "<hr /> \n";
print OUT "<p> \n";
print OUT "If you have any questions about this page, please contact \n";
print OUT "<a href=\"mailto:brad\@head.cfa.harvard.edu\">brad\@head.chfa.harvard.edu</a> \n";
print OUT "<br />\n";
$date =`date`;
print OUT "Last Update: $date\n";

print OUT "</p> \n";
print OUT "</body> \n";
print OUT "</html> \n";


close(OUT);




###################################################################################################
###################################################################################################
###################################################################################################

sub convert_to_digit{
	my ($lmon);
	($lmon) = @_;
	chomp $lmon;

	if($lmon =~ /Jan/i){
		$dmon = 1;
	}elsif($lmon =~ /Feb/i){
		$dmon = 2;
	}elsif($lmon =~ /Mar/i){
		$dmon = 3;
	}elsif($lmon =~ /Apr/i){
		$dmon = 4;
	}elsif($lmon =~ /May/i){
		$dmon = 5;
	}elsif($lmon =~ /Jun/i){
		$dmon = 6;
	}elsif($lmon =~ /Jul/i){
		$dmon = 7;
	}elsif($lmon =~ /Aug/i){
		$dmon = 8;
	}elsif($lmon =~ /Sep/i){
		$dmon = 9;
	}elsif($lmon =~ /Oct/i){
		$dmon = 10;
	}elsif($lmon =~ /Nov/i){
		$dmon = 11;
	}elsif($lmon =~ /Dec/i){
		$dmon = 12;
	}

	return($dmon);
}
	
