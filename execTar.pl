#!/usr/bin/perl

###########################
#use strict;
use threads; 
use Term::Cap;

sub tarexec {
      
    local($targetDir, $archiveName)=@_;
    $str=0;
    open (FILE, "tar zcvf $archiveName $targetDir |");
    while ($line = <FILE>) {
	$cstr=length $line;
#	chomp($line);
	#if ($cstr < $str) {
	#    $pstr=str+1;
	#    print sprintf("%-${pstr}s", $line);
	#} else {
	    print "$line";
	#}
	#print "\r";

	$str=$cstr;
    }

    close FILE;
    print "\n";
}

##
## get archive target list
##
$ArchListFile=$ARGV[0];
@ArchDirList;

$infp='IN';
open($infp, "$ArchListFile");

while($al = <$infp>){push(@ArchDirList,$al);}

close($infp);

##
## execute tar command
##

$aname; # tar file name
$lname; # archived list file name
$atype; # type of archive

# specify tar file
print "Please input archive name (default:/dev/st0) ";
$aname=<STDIN>;
chomp($aname);
if (length $aname > 0) {
    $lname=$aname;
    $atype="file";
} else {
    $aname="/dev/st0";
    $atype="tape";
     #specify archived list file ;
     print "Archive list file : ";
     while (<STDIN>) {
        chomp;
        if (length $_ > 0) {
	    $lname=$_;
	    last;
        }
        print "invalid file name. retry : ";
      }
}




# archive serial number
$anum=1;

foreach $archives (@ArchDirList) {

    # confirmation archive media
    print "tape is ready, type \'yes\': ";
    while (<STDIN>) {
	chomp;
	if ($_ eq "yes") {	    
	    last;
	}
	print "type \'yes\' :  ";
    }
    
    # tar file define
    $tarfile=$aname;
    if ($atype eq "file") {
	$tarfile=$aname.".".$anum.".tar";
    }
    print "DEBUG:tar $tarfile, arcihve list file = $lname.$anum.list\n";
    #$tarThread = threads->new(\&tarexec, $archives, $tarfile);
    #$tarThread->join;
    tarexec($archives, $tarfile);
    
    # make archived list file
    @alist=split / /,$archives;
    
    open (FILE, "> $lname.$anum.list");
    print FILE "archive \"$lname\" vol.$anum\n";
    foreach $dl (@alist) {
	print FILE "$dl\n";
    }
    close(FILE);
    $anum++;
    
}

 


