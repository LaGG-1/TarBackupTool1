#!/usr/bin/perl

sub setList { # *archDirList, *currentParam, $ArchSize
    local(*list,*stat,$maxsize)=@_;
    
    # make directory entry array
    local $crntdir=$stat{'dir'}; # get current work directory path
    local $lslist=`ls -a '$crntdir'`;
    local @dirs=split /\n/,$lslist; #ls result to array 
    
    print "setList() start in $crntdir\n";
    # get current directory list
    local $crntlist=$stat{'list'};

    # get current directory list size
    local $crntsize=$stat{'size'};
  
    foreach $element (@dirs) {
	 #remove '.' '..' from current directory entry 
	if ($element eq "." || $element eq "..") {
	   next;
	}
	local $target=$crntdir.'/'.$element; 
	print "target=$target\n\n";
	# GetDirectory Size check 
	local $quotgt='\''.$target.'\'';
	print "target = $target\n";
	local $targetSize=`du -sk --apparent-size $quotgt`;	
	$targetSize=~s/[^0-9].*//s; 

	# current list size reach max size
	print "before if ";
	if ($targetSize+$crntsize > $maxsize) {
	    print "$targetSize+$crntsize > $maxsize\n";
	    $tmpsize=$maxsize; 

	    if(-d $target) {
		print "target is Directory\n";
		$stat{'dir'}=$target;
		$stat{'size'}=$crntsize;
		$stat{'list'}=$crntlist;		
		setList(*list,*stat,$maxsize);
		$crntsize=$stat{'size'};
		$crntlist=$stat{'list'};
		next;
	    }elsif (-f $target) {
		print "target is File\n";
		if ($targetSize > $maxsize) {
		    die("$target is bigger than archive media!\n");
		}		
		
		push(@list,$crntlist); #add archive directory list array
		undef($crntlist); #reset current archive directory list
		$crntsize=0; #reset current archive size	
	    }
	}	    
	#add one element of list (quoted) 
	$crntlist=$crntlist.' '.'\''.$target.'\'';
	$crntsize=$crntsize+$targetSize;

	

    }
    # set current status 
    $stat{'dir'}=$crntdir;
    $stat{'size'}=$crntsize;
    $stat{'list'}=$crntlist;
    
}

$OwnName=$0;
$OwnName=~s/.*\///;
#number of argument check
if ($#ARGV < 2) 
{
    print "Usage:$OwnName Filename Target Size(kb)\n";
    print "      Filename : name of archive path list file\n";
    print "      Target   : taget path for archive.\n";
    print "      Size     : Size of one unit archive \n";

    exit;
}

$ListFilename=$ARGV[0];
$ArchSize=$ARGV[2];

#Archive Size Check
if ($ArchSize!~/[0-9]*$/) {
    print "Size must be numeric\n";
    exit;
}

#Target directory size check
$Target=$ARGV[1];
$currentSize=`du -sk --apparent-size $Target`;
$currentSize=~s/[^0-9].*//s; 

#Current work parameter array set
%currentStatus=("dir" => $Target,"size" => "0","list" => "");
@archDirList;

#If current directory size is bigger than archive size
if ($currentSize > $ArchSize) {
    &setList(*archDirList, *currentStatus, $ArchSize);
    if ($currentStatus{'size'} > 0) {
	push(@archDirList, $currentStatus{'list'});
    }
} else {
    push(@archDirList,$Target);
}


$fp='f';
open($fp,"> $ListFilename");
foreach $dl (@archDirList) {
    print $fp "$dl\n";
}
close($fp);





