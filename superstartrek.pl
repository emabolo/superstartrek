#!/usr/bin/perl
use strict;
use warnings;

# SUPER STARTREK - MAY 16,1978 - REQUIRES 24K MEMORY
#
# ****        **** STAR TREK ****        ****
# **** SIMULATION OF A MISSION OF THE STARSHIP ENTERPRISE,
# **** AS SEEN ON THE STAR TREK TV SHOW.
# **** ORIGIONAL PROGRAM BY MIKE MAYFIELD, MODIFIED VERSION
# **** PUBLISHED IN DEC'S "101 BASIC GAMES", BY DAVE AHL.
# **** MODIFICATIONS TO THE LATTER (PLUS DEBUGGING) BY BOB
# *** LEEDOM - APRIL & DECEMBER 1974,
# *** WITH A LITTLE HELP FROM HIS FRIENDS . . .
# *** COMMENTS, EPITHETS, AND SUGGESTIONS SOLICITED --
# *** SEND TO:  R. C. LEEDOM
# ***           WESTINGHOUSE DEFENSE & ELECTRONICS SYSTEMS CNTR.
# ***           BOX 746, M.S. 338
# ***           BALTIMORE, MD  21203
# ***
# *** CONVERTED TO MICROSOFT 8 K BASIC 3/16/78 BY JOHN GORDERS
# *** LINE NUMBERS FROM VERSION STREK7 OF 1/12/75 PRESERVED AS
# *** MUCH AS POSSIBLE WHILE USING MULTIPLE STATEMENTS PER LINE
# *** SOME LINES ARE LONGER THAN 72 CHARACTERS; THIS WAS DONE
# *** BY USING "?" INSTEAD OF "PRINT" WHEN ENTERING LINES
# ***
# *************************************************************
# *** Perl Conversion By Emanuele Bolognesi - v1.0 Oct 2020
# ***
# *** The main bug fixes are the number of starbases listed
# *** at the beginning of the game, and the phaser accuracy
# *** correctly affected by computer damage, not shields
# *** I also added instructions and indication of the course.
# *** A lot of comments regarding programming choices and
# *** and possible future improvements/bug fixes
# *** The "look & feel" should be exactly the same, apart from 
# *** a few additional messages that I added
# *** I will continue updating and improving this code, without
# *** changing the original game mechanics.
# *** 
# *** Comments in uppercase are the original comments, lowercase
# *** are mine.
# ***
# *** My blog: http://emabolo.com/
# *** Github:  https://github.com/emabolo
# ***
# *************************************************************

AskForInstructions();

my $DisableTeleprint = 0;

# the original 1978 BASIC code does not have instructions
# there is another BASIC program. I copied it here. If you don't want it, you
# can simply comment the line above

BeginningOfGame:
print "\n\n\n\n\n\n";
print "                                    ,------*------,\n";
print "                    ,-------------   '---  ------'\n";
print "                     '-------- --'      / /\n";
print "                         ,---' '-------/ /--,\n";
print "                          '----------------'\n\n";
print "                    THE USS ENTERPRISE --- NCC-1701\n";
print "\n\n\n\n\n\n";

# here is line-260
my $SomeSpaces ="                         ";

# Array G is the Galaxy, contains elements of 3 numbers like 215 -> 2 klingons 1 base 5 stars
my @Galaxy = (); # DIM G(8,8) in the original code

# Array "C" contains the delta X and Y depending on the course
# I know it's ugly, but since in BASIC the array starts from 1, I'm filling with zeros the useless elements
my @C = ([0,0,0],[0,0,1],[0,-1,1],[0,-1,0],[0,-1,-1],[0,0,-1],[0,1,-1],[0,1,0],[0,1,1],[0,0,1]);
my $i;
my $j;

my @K = (); # DIM K(3,3) - Klingons

my @ExploredSpace = (); # DIM Z(8,8)	# A copy of Galaxy, but only with quadrants explored/scanned

my @DamageLevel = ();
# here is line-370
my $Stardate=int(rand(1)*20+20)*100;  # Stardate, numero tra 2000 e 3900 (was $T)
my $T0 = $Stardate;
my $MaxNumOfDays=25+int(rand(1)*10);
my $ShipDocked=0; # Was D0
my $MaxEnergyLevel=3000;
my $EnergyLevel = $MaxEnergyLevel;
my $PhotonTorpedoes=10; # (was $P)
my $MaxTorpedoes=$PhotonTorpedoes;
my $KlingonBaseEnergy=200;	# Klingon ship energy range from 0.5x to 2x this value
my $ShieldLevel=0;	# Shield level of the Enterprise (was $S)
my $TotalStarbases=0;  # This was set to 2, but the code never adds the 2 additional bases so I changed to 0
my $TotalKlingonShips=0; # was K9
my $ShipCondition = '';
my $Ss="";
my $Ss0=" IS ";
my ($I,$J);

# REM INITIALIZE ENTERPRIZE'S POSITION

my $Q1=FNR(1);		# There are 2 functions in the original BASIC code. I kept the original
my $Q2=FNR(1);		# name for this one, that generates a random number between 1 and 8

my $S1=FNR(1);		# Coordinates of Enterprise
my $S2=FNR(1);

for ($I=1;$I<=8;$I++) {
	# Set Damage level to 0 for all systems
	$DamageLevel[$I]=0;
}

# All possible commands are here. The algorithm will search
# the string entered by the user in this string and then there was a "ON I GOTO"
# Much shorter than a series of IF

my $AllCommands="NAVSRSLRSPHATORSHEDAMCOMXXX";

# REM SETUP WHAT EXISTS IN GALAXY . . .
my $K3; # KLINGONS in sector
my $B3; # STARBASES in sector
my $S3; # stars in sector

my ($B4,$B5);  # B4, B5 = coordinates of the starbase, if any

for ($I=1;$I<=8;$I++) {
	for (my $J=1;$J<=8;$J++) {
		$K3=0;
		$ExploredSpace[$I][$J]=0;		# Galaxy explored by the player, initially all quadrants are 0
		my $R1=rand(1);
		if ($R1>.98) {
			$K3=3;
			$TotalKlingonShips=$TotalKlingonShips+3;
		}
		elsif($R1>.95) {
			$K3=2;
			$TotalKlingonShips=$TotalKlingonShips+2;
		}
		elsif($R1>.80) {
			$K3=1;
			$TotalKlingonShips=$TotalKlingonShips+1;
		}
		# that is line 980
		$B3=0;
		if(rand(1)>.96) {
			$B3=1;
			$TotalStarbases=$TotalStarbases+1;
		}
		$Galaxy[$I][$J]=$K3*100+$B3*10+FNR(1);
	}
}
if ($TotalKlingonShips>$MaxNumOfDays) {$MaxNumOfDays=$TotalKlingonShips+1;}

# Q1, Q2 are random coordinates
if ($TotalStarbases == 0) {
	
	# If sector has less than 2 klingon ship, it adds 1 ship and 2 bases, why?
	# also the total number of bases is not increased -  BUG ?
	# Doesnt make sense so I'm commenting the next 3 lines
	#if ($Galaxy[$Q1][$Q2]<200) {
	#	$Galaxy[$Q1][$Q2]=$Galaxy[$Q1][$Q2]+120;
	#	$TotalKlingonShips=$TotalKlingonShips+1;
	#}
	
	#if bases are 0, add a base in a random quadrant, this makes sense
	$TotalStarbases=1;
	$Galaxy[$Q1][$Q2]=$Galaxy[$Q1][$Q2]+10;
	$Q1=FNR(1);
	$Q2=FNR(1);
}

my $InitialKlingonShips=$TotalKlingonShips;

if ($TotalStarbases>1) {
	$Ss="S";
	$Ss0=" ARE ";
}

# The function telePrint is just a 'print' with a small delay to slow down text scrolling.

telePrint("YOUR ORDERS ARE AS FOLLOWS:");
telePrint(" DESTROY THE $TotalKlingonShips KLINGON WARSHIPS WHICH HAVE INVADED");
telePrint(" THE GALAXY BEFORE THEY CAN ATTACK FEDERATION HEADQUARTERS");
telePrint(" ON STARDATE ".($T0+$MaxNumOfDays).". THIS GIVES YOU $MaxNumOfDays DAYS.");
telePrint(" THERE".$Ss0." $TotalStarbases STARBASE".$Ss." IN THE GALAXY FOR RESUPPLYING YOUR SHIP.");
telePrint(" \n\n\n");
smallDelay(1);

$I=rand(1);
# IF INP(1)=13 THEN 1300 - this was already commented - function INP does not exist

#===============================================================
# This was line 1320

my ($X,$Y,$StepX1,$StepX2,$WarpFactor,$NoOfSteps);	# global vars used by several functions related to movement of ship
my $QuadString;
my $QuadrantName; # Name of the quadrant (was G2)
my $GameOver = 0;

my $Q4 = 0;	# this will contain the coordinate of previous quadrant
my $Q5 = 0;	# useful to see if a movement produced a change of quadrant


# main loop, it goes ahead until the enterprise is destroyed or the time is over or klingons are defeated
while (!$GameOver) {

	$K3=0;
	$B3=0;
	$S3=0;
 
	$ExploredSpace[$Q1][$Q2]=$Galaxy[$Q1][$Q2];	# this quadrant has been discovered

	# The original codes check if the Enterprise is inside the borders, not sure why
	if ($Q1<1 || $Q1>8 || $Q2<1 || $Q2>8) {
		die "The Enterprise went outside the border of the galaxy";
	}
	
	$QuadrantName = GetQuadrantName($Q1,$Q2);
	print "\n";
	if ($T0 == $Stardate) {
		telePrint("YOUR MISSION BEGINS WITH YOUR STARSHIP LOCATED");
		telePrint("IN THE GALACTIC QUADRANT '$QuadrantName'");
	}
	else {
		telePrint("NOW ENTERING '$QuadrantName' QUADRANT . . .");
	}

	print "\n";
	$K3=int($Galaxy[$Q1][$Q2]*.01);
	$B3=int($Galaxy[$Q1][$Q2]*.1)-10*$K3;
	$S3=$Galaxy[$Q1][$Q2]-100*$K3-10*$B3;

	if ($K3>0) {
		telePrint("COMBAT AREA      CONDITION RED");
		if($ShieldLevel<=200) {
			telePrint("   SHIELDS DANGEROUSLY LOW");
		}
		smallDelay(1);
	}
	for ($I=1;$I<=3;$I++) {
		$K[$I][1]=0;
		$K[$I][2]=0;
		$K[$I][3]=0;
	}

	# Clean Quadrant String
	$QuadString = ' ' x 192;

	#  POSITION ENTERPRISE IN QUADRANT, THEN PLACE "K3" KLINGONS, &
	#  "B3" STARBASES, & "S3" STARS ELSEWHERE.

	AddElementInQuadrantString('<*>',$S1,$S2);

	# IF Klingons are present, for each klingon ship, find a place in the quadrant
	if ($K3>0) {
		for ($I=1;$I<=$K3;$I++) {
			my ($R1,$R2) = FindEmptyPlaceinQuadrant();
			
			AddElementInQuadrantString('+K+',$R1,$R2);
			$K[$I][1]=$R1;  # coordinates of Klingon ship
			$K[$I][2]=$R2;
			$K[$I][3]=$KlingonBaseEnergy*(0.5+rand(1));  # energy of the klingon
		}
	}

	# If a base is present, place the base
	if ($B3>0) {
		my ($R1,$R2) = FindEmptyPlaceinQuadrant();
		$B4=$R1;
		$B5=$R2;
		AddElementInQuadrantString('>!<',$R1,$R2);
	}

	# For each star, find a place
	for ($I=1;$I<=$S3;$I++) {
		my ($R1,$R2) = FindEmptyPlaceinQuadrant();
		AddElementInQuadrantString(' * ',$R1,$R2);
	}

	# this is line 1980 in the original BASIC code
	checkIfDocked();
	ShortRangeSensorScan();
	
	my $ReachedNewQuadrant = 0;

	# This is line-1990 - MAIN LOOP for EXECUTING COMMANDS

	while (!$ReachedNewQuadrant && !$GameOver) {
	
		# of there is very low total energy or shield are damaged, the game is over
		if ($EnergyLevel+$ShieldLevel<=10 || ($EnergyLevel<=10 && $DamageLevel[7]<0)) {
			telePrint("\n** FATAL ERROR **   YOU'VE JUST STRANDED YOUR SHIP IN SPACE");
			telePrint("YOU HAVE INSUFFICIENT MANEUVERING ENERGY, AND SHIELD CONTROL");
			telePrint("IS PRESENTLY INCAPABLE OF CROSS-CIRCUITING TO ENGINE ROOM!!");
			smallDelay(2);
			$GameOver = 1;
			last;
		}

		print "COMMAND? ";
		chomp(my $Command = <STDIN>);
		$Command = uc($Command);
		
		if($Command eq "NAV"){
			$ReachedNewQuadrant = CourseControl();
		}
		elsif($Command eq "SRS"){
			ShortRangeSensorScan();
		}
		elsif($Command eq "LRS"){
			LongRangeSensorScan();
		}
		elsif($Command eq "PHA"){
			FirePhasers();
		}
		elsif($Command eq "TOR"){
			FirePhotonTorpedoes();
		}
		elsif($Command eq "SHE"){
			ShieldControl();
		}
		elsif($Command eq "DAM"){
			DamageControl();
		}
		elsif($Command eq "COM"){
			LibraryComputer();
		}
		elsif($Command eq "XXX"){
			$GameOver = 1;
		}
		else {
			print "ENTER ONE OF THE FOLLOWING:\n";
			print "  NAV  (TO SET COURSE)\n";
			print "  SRS  (FOR SHORT RANGE SENSOR SCAN)\n";
			print "  LRS  (FOR LONG RANGE SENSOR SCAN)\n";
			print "  PHA  (TO FIRE PHASERS)\n";
			print "  TOR  (TO FIRE PHOTON TORPEDOES)\n";
			print "  SHE  (TO RAISE OR LOWER SHIELDS)\n";
			print "  DAM  (FOR DAMAGE CONTROL REPORTS)\n";
			print "  COM  (TO CALL ON LIBRARY-COMPUTER)\n";
			print "  XXX  (TO RESIGN YOUR COMMAND)\n\n";
		}
	}  # keep asking new commands until the ship reaches a new quadrant

} # end of the main loop


#6210 REM END OF GAME
print "\n";
telePrint("IT IS STARDATE ".roundTo($Stardate,1));

# this was line 6270
if ($TotalKlingonShips>0) {			# IF was not in the original code, added to be more generic
	telePrint("THERE WERE $TotalKlingonShips KLINGON BATTLE CRUISERS LEFT AT");
	telePrint("THE END OF YOUR MISSION.");
	print "\n";
}
	
# This condition does not make sense. You can restart the game only if
# there are some starbases. But not in the same universe. You restart from scratch
# While if there are no starbases it doesn't ask you if you want to play again

if ($TotalStarbases > 0) {
	print "THE FEDERATION IS IN NEED OF A NEW STARSHIP COMMANDER\n";
	print "FOR A SIMILAR MISSION -- IF THERE IS A VOLUNTEER,\n";
	print "LET HIM STEP FORWARD AND ENTER 'AYE'? ";
	chomp(my $Command=<>);
	if ($Command eq "AYE") {
		goto BeginningOfGame;
	}
}

print "\n\nThank you for playing this game!\n\nPerl conversion by Emanuele Bolognesi - http://emabolo.com\n\n";

exit;

# ============================================

sub FNR {
	# the original code is int(rand()*7.98+1.01)
	return int(rand(8)+1);
}

sub AddElementInQuadrantString {
	# INSERT IN STRING ARRAY FOR QUADRANT line 8670

	my $elem = shift;
	my $y = shift;
	my $x = shift;
	
	die if (!$elem || !$y || !$x || length($elem) != 3);
	
	$y = int($y-.5);
	$x = int($x-.5);
	my $position=$x*3+$y*24+1;
	
	# Insert the element in the right position in the quadrant string
	if ($position == 1) {
		$QuadString = $elem . substr($QuadString,3);
	}
	elsif ($position == 190) {
		$QuadString = substr($QuadString,0,189) . $elem;
	}
	else {
		$QuadString = substr($QuadString,0,$position-1) . $elem . substr($QuadString,$position+2);
	}
	return;
}


sub SearchStringinQuadrant {
	# STRING COMPARISON IN QUADRANT ARRAY - line 8830

	my $elem = shift;
	my $y = shift;
	my $x = shift;
	die if (!$elem || !$y || !$x);

	$y = int($y-.5);
	$x = int($x-.5);
	my $position=$x*3+$y*24+1;

	if (substr($QuadString,$position-1,3) eq $elem) {
		return 1;
	}
	return 0;
}

sub FindEmptyPlaceinQuadrant {
	# FIND EMPTY PLACE IN QUADRANT (FOR THINGS)
	# generate 2 random coordinates, and check if quadrant cell is empty.
	# If empty space is found, returns the coordinates
	my ($y,$x);
	my $found = 0;
	while (!$found) {
		$y=FNR(1);
		$x=FNR(1);
		$found = SearchStringinQuadrant("   ",$y,$x);
	}
	return ($y,$x);
}


sub GetQuadrantName {
	my $Z4 = shift;
	my $Z5 = shift;
	my $RegionNameOnly = shift;
	
	die if (!$Z4 || !$Z5);
	
	# QUADRANT NAME IN G2$ FROM Z4,Z5 (=Q1,Q2)
	# CALL WITH G5=1 (RegionNameOnly) TO GET REGION NAME ONLY
	my @starnames = ();
	if($Z5<=4) {
		@starnames =('ANTARES','RIGEL','PROCYON','VEGA','CANOPUS','ALTAIR','SAGITTARIUS','POLLUX');
	}
	else {
		@starnames =('SIRIUS','DENEB','CAPELLA','BETELGEUSE','ALDEBARAN','REGULUS','ARCTURUS','SPICA');
		
	}
	$QuadrantName = $starnames[$Z4-1];
	if (!$RegionNameOnly) {
		if ($Z5 ==1 || $Z5 ==5) {
			$QuadrantName.=" I";
		}
		elsif($Z5 == 2 || $Z5 == 6) {
			$QuadrantName.=" II";
		}
		elsif($Z5 ==3 || $Z5 == 7) {
			$QuadrantName.=" III";
		}
		elsif($Z5 ==4 || $Z5 == 8) {
			$QuadrantName.=" IV";
		}
	}
	return $QuadrantName;
}

sub CheckShipStatus {
	if ($ShipDocked) {
		return 'DOCKED';
	}
	elsif ($K3>0) {
		return "*RED*";
	}
	elsif ($EnergyLevel < ($MaxEnergyLevel/10) ) {
		return "YELLOW";
	}
	else {
		return "GREEN";
	}
}

sub checkIfDocked {
	$ShipDocked = 0;
	for (my $i=$S1-1;$i<=$S1+1;$i++) {
		for (my $j=$S2-1;$j<=$S2+1;$j++) {
			my $ii = int($i+.5);
			my $jj = int($j+.5);
			if ($ii>=1 and $ii<=8 and $jj>=1 and $jj<=8) {
				if (SearchStringinQuadrant(">!<",$i,$j)) {	# found a starbase at coordinates I,J
					$ShipDocked=1;
					$ShipCondition="DOCKED";
					$EnergyLevel=$MaxEnergyLevel;
					$PhotonTorpedoes=$MaxTorpedoes;
					telePrint("SHIELDS DROPPED FOR DOCKING PURPOSES");
					$ShieldLevel=0;
					last;
				}
			}
		}
	}

	$ShipCondition= CheckShipStatus();
	return $ShipDocked;
}


sub ShortRangeSensorScan {
	# SHORT RANGE SENSOR SCAN & STARTUP SUBROUTINE
	
	# it was line 6720
	if ($DamageLevel[2]<0) {
		telePrint("\n*** SHORT RANGE SENSORS ARE OUT ***\n");
		return;
	}
	
	my $Header ="---------------------------------";
	telePrint($Header);
	for ($I=1;$I<=8;$I++) {
		for (my $J=($I-1)*24+1;$J<=($I-1)*24+22;$J+=3) {
			print " ".substr($QuadString,$J-1,3);
		}
		telePrint("        STARDATE           ".int($Stardate*10)*.1) if($I == 1);
		telePrint("        CONDITION          ".$ShipCondition) if($I == 2);
		telePrint("        QUADRANT           ".$Q1." , ".$Q2) if($I == 3);
		telePrint("        SECTOR             ".$S1." , ".$S2) if($I == 4);
		telePrint("        PHOTON TORPEDOES   ".int($PhotonTorpedoes)) if($I == 5);
		telePrint("        TOTAL ENERGY       ".int($EnergyLevel+$ShieldLevel)) if($I == 6);
		telePrint("        SHIELDS            ".int($ShieldLevel)) if($I == 7);
		telePrint("        KLINGONS REMAINING ".int($TotalKlingonShips)) if($I == 8);
	}
	telePrint($Header);
	return;
}


sub LongRangeSensorScan {
	# LONG RANGE SENSOR SCAN CODE
	# it was line 4000
	my @N = ();
	if ($DamageLevel[3]<0) {
		telePrint("LONG RANGE SENSORS ARE INOPERABLE.");
		return 0;
	}
	print "LONG RANGE SCAN FOR QUADRANT $Q1,$Q2\n";
	my $Header="-------------------";
	telePrint($Header);
	for ($I=$Q1-1;$I<=$Q1+1;$I++) {
		$N[1]=-1;	# if it's not a positive number later, it means the quadrant does not exist
		$N[2]=-2;
		$N[3]=-3;
		for ($J=$Q2-1;$J<=$Q2+1;$J++) {
			if ($I>0 && $I<9 && $J>0 && $J<9) {
				$N[$J-$Q2+2]=$Galaxy[$I][$J];
				$ExploredSpace[$I][$J]=$Galaxy[$I][$J];		# Scan a new quadrant
			}
		}
		for(my $idx=1;$idx<=3;$idx++) {
			print ": ";
			if ($N[$idx]<0) {
				print "*** ";
			}
			else {
				my $strdollar = $N[$idx]+1000;
				print substr($strdollar,-3)." ";
			}
		}
		telePrint(":");
		telePrint($Header);
	}
	return 0; # goto 1990
}


sub ShieldControl {
	#5520 REM SHIELD CONTROL - 5530
	if ($DamageLevel[7]<0) {
		telePrint("SHIELD CONTROL INOPERABLE");
		return 0;
	}
	telePrint("ENERGY AVAILABLE = ".($EnergyLevel+$ShieldLevel));
	print "NUMBER OF UNITS TO SHIELDS? ";
	my $Units;
	chomp($Units = <>);
	
	if ($Units !~ /^\d+$/) {
		telePrint("INCORRECT VALUE");
	}
	elsif ($ShieldLevel == $Units) {
		telePrint("<SHIELDS UNCHANGED>");
	}
	elsif ($Units > $EnergyLevel+$ShieldLevel) {
		telePrint("SHIELD CONTROL REPORTS  'THIS IS NOT THE FEDERATION TREASURY.'");
		telePrint("<SHIELDS UNCHANGED>");
	}
	else {
		$EnergyLevel=$EnergyLevel+$ShieldLevel-$Units;
		$ShieldLevel=$Units;
		telePrint("DEFLECTOR CONTROL ROOM REPORT:");
		telePrint("  'SHIELDS NOW AT ".$ShieldLevel." UNITS PER YOUR COMMAND.'");
	}
	return $Units;
}

# REM PRINTS DEVICE NAME - 8790
sub deviceName {
	# This was placing the device name in variable G2
	my $sys = shift;
	my @names = ("WARP ENGINES","SHORT RANGE SENSORS","LONG RANGE SENSORS","PHASER CONTROL","PHOTON TUBES",
	"DAMAGE CONTROL","SHIELD CONTROL","LIBRARY-COMPUTER");
	
	return $names[$sys-1];
}

sub roundTo {
	my $value = shift;
	my $precision = shift;
	
	return int($value) if (!$precision);
	
	$precision = (10 ** $precision);
	$value = int($value*$precision);
	return $value/$precision;
}

sub formatWithSpaces {
	my $str = shift;
	my $maxlength = shift;
	my $centered = shift;
	
	my $final = "";
	if($centered) {
		my $numsp = int(($maxlength-length($str))/2);
		my $spaces = ' ' x $numsp;
		$final = $spaces.$str.$spaces;
		if (length($final) < $maxlength) {
			$final = $final.' ';
		}
	}
	else {
		my $spaces = " " x ($maxlength-length($str));
		$final = $str . $spaces;
	}
	return $final;
}


sub DamageControl {
	#5680 REM DAMAGE CONTROL - 5690
	if ($DamageLevel[6]>=0) {
		telePrint("\nDEVICE             STATE OF REPAIR");
		for (my $index=1;$index<=8;$index++) {
			my $tabs = 27;
			if ($DamageLevel[$index]<0) {
				$tabs=26;
			}
			telePrint(formatWithSpaces(deviceName($index),$tabs) . roundTo($DamageLevel[$index],2));
		}
	}
	else {
		telePrint("DAMAGE CONTROL REPORT NOT AVAILABLE");
	}
	print "\n";
	
	# By checking the status, you can also ask to repair, if docked
	if ($ShipDocked) {
		# 5720
		my $TimeToRepair=0;
		for ($I=1;$I<=8;$I++) {
			if ($DamageLevel[$I]<0) {
				$TimeToRepair=$TimeToRepair+.1;				# Time increases for each damaged system
			}
		}
		if ($TimeToRepair==0) {
			return 0;					# nothing to repair
		}
		print "\n";
		
		$TimeToRepair=roundTo($TimeToRepair+rand(0.5),2);
		
		if ($TimeToRepair>0.9) {$TimeToRepair=0.9;}	# never more than 1 day
		
		telePrint("TECHNICIANS STANDING BY TO EFFECT REPAIRS TO YOUR SHIP;");
		telePrint("ESTIMATED TIME TO REPAIR: $TimeToRepair STARDATES");
		print "WILL YOU AUTHORIZE THE REPAIR ORDER (Y/N) ? ";
		chomp(my $YesNo = <>);
		if ($YesNo eq "Y") {
			for ($I=1;$I<=8;$I++) {
				if ($DamageLevel[$I]<0) {
					$DamageLevel[$I]=0;
				}
			}
			$Stardate=$Stardate+$TimeToRepair+0.1;		# never trust engineers!
			telePrint("REPAIR COMPLETED.");
		}
	}
	return 0;
}


sub CalcAndPrintDirection {
	my $m = shift;  # X
	my $n = shift;  # A
	my $StartingCourse = shift;  # c1
	
	my $Direction;
#8290
	if (abs($m) > abs($n)) {  
		$Direction =$StartingCourse+(abs($n)/abs($m));
	}
	else {
		$Direction =$StartingCourse+( ( abs($n)-abs($m)+abs($n) ) /abs($n));
	}
	telePrint(" DIRECTION = ".roundTo($Direction,2));
	return 0;
}


sub PrintDistanceAndDirection {
	my $W1 = shift;
	my $X = shift;
	my $C1 = shift;
	my $A = shift;

	$X=$X-$A;
	$A=$C1-$W1;
	if ($X<0) {
		if($A>0) {
			CalcAndPrintDirection($A,$X,3);	# A>0 and X < 0
		}
		elsif($X != 0) {   					# else would be enough here (X<0 and A <=0)
			CalcAndPrintDirection($X,$A,5);
		}
	}
	else {
		if ($A<0) {							# case X>= 0 and A < 0
			CalcAndPrintDirection($A,$X,7);
		}
		elsif($X>0) {						# the only case where this is not true is X = 0
			CalcAndPrintDirection($X,$A,1);
		}
		elsif ($A==0) {						# so X = 0 and A = 0
			CalcAndPrintDirection($X,$A,5);
		}
		elsif ($A > 0) {					# so X = 0 and A > 0
			CalcAndPrintDirection($X,$A,1);
		}
	}
	my $Distance = sqrt($X**2 + $A**2);
	telePrint(" DISTANCE = ".roundTo($Distance,2));

	return 1;
}


sub PrintComputerRecord {
	my $GalaxyMapOn = shift;

	telePrint("       1     2     3     4     5     6     7     8");
	telePrint("     ----- ----- ----- ----- ----- ----- ----- -----");

	for ($I=1;$I<=8;$I++) {
		print $I.'  ';
		if ($GalaxyMapOn) {
			$QuadrantName = GetQuadrantName($I,1,'RegionOnly');
			print '  '.formatWithSpaces($QuadrantName,23,1);
			$QuadrantName = GetQuadrantName($I,5,'RegionOnly');
			print ' '.formatWithSpaces($QuadrantName,23,1);
		}
		else {
			for ($J=1;$J<=8;$J++) {
				print "   ";
				if ($ExploredSpace[$I][$J]==0) { 
					print "***";
				}
				else {
					my $string = $ExploredSpace[$I][$J]+1000;
					print substr($string,-3);
				}
			}
		}
		
		print "\n";
		telePrint("     ----- ----- ----- ----- ----- ----- ----- -----");
	}
	print "\n";
	return 0;
}


sub GalaxyMap {
	#7390 REM SETUP TO CHANGE CUM GAL RECORD TO GALAXY MAP
	telePrint("                        THE GALAXY"); # GOTO7550
	PrintComputerRecord(1);
	return 1;
}

sub ComulativeGalacticRecord {
	telePrint("       COMPUTER RECORD OF GALAXY FOR QUADRANT $Q1,$Q2\n");
	PrintComputerRecord(0);
	return 1;
}

sub StatusReport {
	#7890 REM STATUS REPORT - 7900
	telePrint("   STATUS REPORT:");
	my $Ss="";
	if ($TotalKlingonShips>1) {$Ss="S";}
	telePrint("KLINGON".$Ss." LEFT: ".$TotalKlingonShips);
	telePrint("MISSION MUST BE COMPLETED IN ".roundTo($T0+$MaxNumOfDays-$Stardate,1)." STARDATES");
	$Ss="S";
	if($TotalStarbases<2) {$Ss='';}

	if($TotalStarbases<1) {
		telePrint("YOUR STUPIDITY HAS LEFT YOU ON YOUR ON IN");
		telePrint("  THE GALAXY -- YOU HAVE NO STARBASES LEFT!");
	}
	else {
		telePrint("THE FEDERATION IS MAINTAINING ".$TotalStarbases." STARBASE".$Ss." IN THE GALAXY");
	}
	DamageControl();
	return 1;
}


sub PhotonTorpedoData{
	#8060 REM TORPEDO, BASE NAV, D/D CALCULATOR
	if($K3<=0) {
		telePrint("SCIENCE OFFICER SPOCK REPORTS  'SENSORS SHOW NO ENEMY SHIPS");
		telePrint("                                IN THIS QUADRANT'");
		return 1;
	}
	$Ss="";
	if ($K3>1) {
		$Ss="S";
	}
	telePrint("FROM ENTERPRISE TO KLINGON BATTLE CRUISER".$Ss.":");

	for ($I=1;$I<=3;$I++) {
		if ($K[$I][3]>0) {
			PrintDistanceAndDirection($K[$I][1],$K[$I][2],$S1,$S2);
		}
	}
	return 1;
}

sub validCoord{
	my $n = shift;
	if ($n>=1 && $n<=8) {
		return 1;
	}
	return 0;
}

sub DistanceCalculator {
	telePrint("DIRECTION/DISTANCE CALCULATOR:");
	print "YOU ARE AT QUADRANT $Q1,$Q2 SECTOR $S1,$S2\n";
	print "PLEASE ENTER INITIAL COORDINATES (X,Y): ";
	chomp(my $Coord = <>);
	my ($y1,$x1) = split(/,/,$Coord,2);
	
	print "  FINAL COORDINATES (X,Y): ";
	chomp($Coord = <>);
	my ($y2,$x2) = split(/,/,$Coord,2);
	
	if (validCoord($x1) && validCoord($y1) && validCoord($x2) && validCoord($y2)) {
		PrintDistanceAndDirection($y2,$x2,$y1,$x1);
		return 1;
	}
	else {
		telePrint("WRONG COORDINATES");
		return 0;
	}
}

sub StarbaseNavData {
	if ($B3 > 0) {
		telePrint("FROM ENTERPRISE TO STARBASE:");
		PrintDistanceAndDirection($B4,$B5,$S1,$S2);   # dest, origin
	}
	else {
		telePrint("MR. SPOCK REPORTS,  'SENSORS SHOW NO STARBASES IN THIS");
		telePrint(" QUADRANT.'");
	}
	return 1;
}


sub LibraryComputer {
	#7280 REM LIBRARY COMPUTER CODE - 7290
	if($DamageLevel[8]<0) {
		telePrint("COMPUTER DISABLED");
		return 0;
	}
	my $ComputerDone = 0;
	while(!$ComputerDone) {
		print "COMPUTER ACTIVE AND AWAITING COMMAND? ";
		chomp(my $Command=<>);
		$Command = 0 if (!$Command);
		$Command = 6 if ($Command !~ /^\d+$/);
		
		print "\n";

		if($Command == 0) {
			$ComputerDone = ComulativeGalacticRecord(); #7540
		}
		elsif($Command == 1) {
			$ComputerDone = StatusReport();  #7900
		}
		elsif($Command == 2) {
			$ComputerDone = PhotonTorpedoData(); #8070
		}
		elsif($Command == 3) {
			$ComputerDone = StarbaseNavData(); #8500
		}
		elsif($Command == 4) {
			$ComputerDone = DistanceCalculator(); #8150
		}
		elsif($Command == 5) {
			$ComputerDone = GalaxyMap(); #7400
		}
		else {
			print "FUNCTIONS AVAILABLE FROM LIBRARY-COMPUTER:\n";
			print "   0 = CUMULATIVE GALACTIC RECORD\n";
			print "   1 = STATUS REPORT\n";
			print "   2 = PHOTON TORPEDO DATA\n";
			print "   3 = STARBASE NAV DATA\n";
			print "   4 = DIRECTION/DISTANCE CALCULATOR\n";
			print "   5 = GALAXY 'REGION NAME' MAP\n\n";
		}
	}
	return 0;
}

sub EnterpriseDestroyed {
	telePrint("\nTHE ENTERPRISE HAS BEEN DESTROYED.  THEN FEDERATION WILL BE CONQUERED.");
	smallDelay(2);
	return;
}

sub KlingonsDefeated {
	telePrint("\nCONGRATULATIONS, CAPTAIN!  THEN LAST KLINGON BATTLE CRUISER");
	telePrint("MENACING THE FEDERATION HAS BEEN DESTROYED.");
	telePrint("\nYOUR EFFICIENCY RATING IS " . int(1000*($InitialKlingonShips/($Stardate-$T0))**2));
	return;
}


sub DistanceOfShip {
	# Distance between enterprise and Klingon ship
	my $Index =shift;
	my $DX = $K[$Index][1]-$S1;
	my $DY = $K[$Index][2]-$S2;
	return sqrt($DX**2 + $DY**2);   # IN PERL DONT DO THIS: N^2 !!!
}


sub KlingonsAttack {
	# this was line-6000
	if ($K3<=0) {
		return 0;
	}
	telePrint("KLINGON SHIPS ATTACK THE ENTERPRISE",1);	 # This message is not in the original game

	if ($ShipDocked) {
		telePrint("STARBASE SHIELDS PROTECT THE ENTERPRISE.");
		return 0;
	}
	
	for ($I=1;$I<=3;$I++) {
		my $KlingonEnergy = $K[$I][3];
		if ($KlingonEnergy>0) {
			my $Hits = int(($KlingonEnergy/DistanceOfShip($I))*(2+rand(1))+1);
			$ShieldLevel = $ShieldLevel-$Hits;
			
			# The choice below is strange. Energy of the klingon decrease when they fire
			# but it does not depend on the power used by the phasers
			# also it decreases a lot, because it can become 1/3 or 1/4 of the previous energy
			# would be better to use an algorithm similar to the one used for the Enterprise
			# Basically they are committing suicide
			
			$K[$I][3] = $KlingonEnergy/(3+rand(1));
			
			telePrint("$Hits UNIT HIT ON ENTERPRISE FROM SECTOR ".$K[$I][1].",".$K[$I][2]);
			if($ShieldLevel<0) {
				EnterpriseDestroyed();
				$GameOver = 1;
				return 1;
			}
			telePrint("      <SHIELDS DOWN TO $ShieldLevel UNITS>",1);
			
			if ($Hits>19 && ($ShieldLevel==0 || (rand(1)<.6 && ($Hits/$ShieldLevel) > 0.02)) ) {
				my $SysDamaged=FNR(1);
				$DamageLevel[$SysDamaged] = $DamageLevel[$SysDamaged] - ($Hits/$ShieldLevel) - (0.5 * rand(1));
				telePrint("DAMAGE CONTROL REPORTS '".deviceName($SysDamaged)." DAMAGED BY THE HIT'");	
			}
		}
	}
	return 0;
}


#4690 REM PHOTON TORPEDO CODE BEGINS HERE
sub FirePhotonTorpedoes {
	if ($PhotonTorpedoes<=0) {
		telePrint("ALL PHOTON TORPEDOES EXPENDED.",2);
		return 0;
	}
	if ($DamageLevel[5]<0) {
		telePrint("PHOTON TUBES ARE NOT OPERATIONAL.",2);
		return 0;
	}
	
	print "PHOTON TORPEDO COURSE (1-9)? ";
	my $Course = <>;
	chomp($Course);
	return 0 if ($Course !~ /^\d$/ && $Course !~ /^\d\.\d+$/); #check that the course is correct
	$Course = 1 if ($Course==9);
	if ($Course<0.1 || $Course>9) {
		telePrint("ENSIGN CHEKOV REPORTS,  'INCORRECT COURSE DATA, SIR!'");
		return 0;
	}

	$EnergyLevel=$EnergyLevel-2;
	$PhotonTorpedoes=$PhotonTorpedoes-1;
	
	my $cindex = int($Course);	# this is not present in BASIC. Also in Perl is not necessary
	
	$StepX1=$C[$cindex][1]+($C[$cindex+1][1]-$C[$cindex][1])*($Course-$cindex);
	$StepX2=$C[$cindex][2]+($C[$cindex+1][2]-$C[$cindex][2])*($Course-$cindex);
	
	my $X=$S1;  # torpedoes starting coordinates = Enterprise coordinates
	my $Y=$S2;
	telePrint("TORPEDO TRACK:");
	
	# this is line 4920
	
	my $KlingonDestroyed = 0;
	
	while (1) {
		$X=$X+$StepX1;
		$Y=$Y+$StepX2;
		my $X3=int($X+.5);
		my $Y3=int($Y+.5);
		
		if ($X3<1 || $X3>8 || $Y3<1 || $Y3>8) {
			# torpedo is out of borders
			telePrint("TORPEDO MISSED!",2);
			last;
		}
		
		telePrint("               ".$X3." , ".$Y3,0.5);
		if (SearchStringinQuadrant("   ",$X,$Y)) {
			# found white space, continue and go to next iteration of loop
		}
		elsif (SearchStringinQuadrant("+K+",$X,$Y)) {
			# found a klingon at coordinates X, Y
			telePrint("*** KLINGON DESTROYED ***",1);
			$K3=$K3-1;
			$ShipCondition = CheckShipStatus();		# could become GREEN if there are no more klingons
			
			$TotalKlingonShips=$TotalKlingonShips-1;			
			if ($TotalKlingonShips<=0) {
				KlingonsDefeated();
				$GameOver = 1;
				return 1;
			}
			# Check which Klingon has been destroyed
			for ($I=1;$I<=3;$I++) {
				if ($X3 == $K[$I][1] && $Y3 == $K[$I][2]) {
					$K[$I][3]=0;
					$KlingonDestroyed = $I;
				}
			}
			AddElementInQuadrantString('   ',$X,$Y);  			# remove klingon
			$Galaxy[$Q1][$Q2]=$K3*100+$B3*10+$S3;				# update galaxy 
			$ExploredSpace[$Q1][$Q2]=$Galaxy[$Q1][$Q2];			# update explored galaxy
			last;
		}
		elsif (SearchStringinQuadrant(" * ",$X,$Y)) {
			# It was not a Klingon, checking if I hit a star
			telePrint("STAR AT ".$X3.",".$Y3." ABSORBED TORPEDO ENERGY.",1);
			last;
		}
		# Check if I hit a starbase
		elsif (SearchStringinQuadrant(">!<",$X,$Y)) {
			# found a starbase
			telePrint("*** STARBASE DESTROYED ***");
			$B3=$B3-1;
			$TotalStarbases=$TotalStarbases-1;
			if ($TotalStarbases>0 || $TotalKlingonShips>$Stardate-$T0-$MaxNumOfDays)	{
				telePrint("STARFLEET COMMAND REVIEWING YOUR RECORD TO CONSIDER");
				telePrint("COURT MARTIAL!");
				smallDelay(2);
				$ShipDocked=0;	# if docked, no more docked - but what if I was docked to another base?

				AddElementInQuadrantString('   ',$X,$Y);  	# remove base
				$Galaxy[$Q1][$Q2]=$K3*100+$B3*10+$S3;		# update galaxy 
				$ExploredSpace[$Q1][$Q2]=$Galaxy[$Q1][$Q2];
				last;
			}
			else {
				telePrint("THAT DOES IT, CAPTAIN!!  YOU ARE HEREBY RELIEVED OF COMMAND");
				telePrint("AND SENTENCED TO 99 STARDATES AT HARD LABOR ON CYGNUS 12!!");
				smallDelay(2);
				$GameOver = 1;
				return 1;
			}
		}
		else {
			# If the space was not empty, and I didnt hit a star, nor a base, or a klingon
			# what else could have happened?
			# in the original code, it asks again to enter the course
			# here I just print a message to see if this can really happen
			telePrint("An unknown object has been hit");
			last;
		}
	}
	
	KlingonsAttack();
	return 1;
}


sub FirePhasers {
	# formerly line 4260 REM PHASER CONTROL CODE BEGINS HERE
	if ($DamageLevel[4]<0) {
		telePrint("PHASERS INOPERATIVE");
		return 0;
	}
	if ($K3<1) {
		telePrint("SCIENCE OFFICER SPOCK REPORTS  'SENSORS SHOW NO ENEMY SHIPS");
		telePrint("                                IN THIS QUADRANT'");
		return 0;
	}
	if($DamageLevel[8]<0) {
		telePrint("COMPUTER FAILURE HAMPERS ACCURACY");
	}
	print "PHASERS LOCKED ON TARGET;  ";
	my $Units;
	do {
		print "ENERGY AVAILABLE = $EnergyLevel UNITS\n";
		print "NUMBER OF UNITS TO FIRE? ";
		chomp($Units = <>);
		return 0 if ($Units !~ /^\d+$/ || $Units == 0);
	} until ($Units <= $EnergyLevel);
	
	$EnergyLevel=$EnergyLevel-$Units;
	
	if($DamageLevel[8]<0) {			# when computer is broken, the risk is to waste energy
		$Units = $Units*rand(1);	# the original code has a bug, it checks shield damage not computer damage
	}
	my $H1=int($Units/$K3);   # all the phasers energy is splitted among the enemy ships
	
	for ($I=1;$I<=3;$I++) {
		my $KlingonEnergy = $K[$I][3];
		if ($KlingonEnergy >0) {
			my $distance = DistanceOfShip($I);
			my $distanceRatio = $H1/$distance;		# damage is inversely proportional to distance
			my $randNumb = rand(1)+2;				# but a random factor can increse damage up to x2
			my $HitPoints=int($distanceRatio*$randNumb);
			
			if ($HitPoints <= (.15*$KlingonEnergy)) {
				telePrint("SENSORS SHOW NO DAMAGE TO ENEMY $I AT ".$K[$I][1].",".$K[$I][2],0.5);
				$HitPoints = 0;
			}
			else {
				$K[$I][3]=$K[$I][3]-$HitPoints;
				telePrint("$HitPoints UNIT HIT ON KLINGON $I AT SECTOR ".$K[$I][1].",".$K[$I][2]);
			}
			
			if ($K[$I][3] > 0) {
				telePrint("   (SENSORS SHOW ".int($K[$I][3])." UNITS REMAINING)",1);
			}
			else {
				telePrint("*** KLINGON DESTROYED ***",1);
				$K3=$K3-1;
				$ShipCondition = CheckShipStatus();
				$TotalKlingonShips=$TotalKlingonShips-1;
				
				if($TotalKlingonShips <= 0) {
					KlingonsDefeated();
					$GameOver = 1;
					return 1;
				}
			
				AddElementInQuadrantString('   ',$K[$I][1],$K[$I][2]);  # Delete klingon ship from screen
				$K[$I][3]=0;   # isnt it already 0 ?
				$Galaxy[$Q1][$Q2]=$Galaxy[$Q1][$Q2]-100;			# Delete klingon ship from galaxy array
				$ExploredSpace[$Q1][$Q2]=$Galaxy[$Q1][$Q2];			# clear also explored galaxy
			}

		}
	}
	KlingonsAttack();
	return 0;
}

sub ShowDirections {
	print "\n";
	print '      4  3  2   '."\n";
	print '       \ | /    '."\n";
	print '        \|/     '."\n";
	print '    5 ---*--- 1 '."\n";
	print '        /|\     '."\n";
	print '       / | \    '."\n";
	print '      6  7  8   '."\n";
	print "\n";
}

sub ConsumeEnergy {
	#MANEUVER ENERGY S/R **
	$EnergyLevel=$EnergyLevel-$NoOfSteps-10;  # a warp speed of 8 consumes 8x8+10 =74 energy, speed 1 instead 1x8+10 =18
	if($EnergyLevel>=0) {
		return $EnergyLevel;
	}
	telePrint("SHIELD CONTROL SUPPLIES ENERGY TO COMPLETE THE MANEUVER.");
	$ShieldLevel=$ShieldLevel+$EnergyLevel;
	$EnergyLevel=0;
	if($ShieldLevel<=0) {
		$ShieldLevel=0;
	}
	return $EnergyLevel;
}


sub EndOfMovementInQuadrant {
	#  this is line-3370
	#  These are the last operations done before end of the turn, if the Enterprise has not changed quadrant
	AddElementInQuadrantString('<*>',int($S1),int($S2));
	ConsumeEnergy();
	my $DayIncrement=1;		# time advances by 1, even if you traveled at warp speed 9

	if ($WarpFactor<1) {
		$DayIncrement = roundTo($WarpFactor,1);
	}
	$Stardate=$Stardate+$DayIncrement;
	if ($Stardate > $T0+$MaxNumOfDays) {
		$GameOver = 1;
		return 1;
	}

	checkIfDocked();
	ShortRangeSensorScan();
	
	return 0;
}


sub ExceededQuadrantLimits{
	# checking if quadrant has been exceeded. If it's still in the same quadrant, returns 0

	$X=8*$Q1+$X+$NoOfSteps*$StepX1;
	$Y=8*$Q2+$Y+$NoOfSteps*$StepX2;
	$Q1=int($X/8);
	$Q2=int($Y/8);
	$S1=int($X-$Q1*8);
	$S2=int($Y-$Q2*8);

	if ($S1 == 0) {
		$Q1=$Q1-1;
		$S1=8;
	}
	if ($S2==0) {
		$Q2=$Q2-1;
		$S2=8;
	}
	my $CrossingPerimeter = 0;
	if($Q1<1) {
		$CrossingPerimeter=1;
		$Q1=1;
		$S1=1;
	}
	if ($Q1>8) {
		$CrossingPerimeter=1;
		$Q1=8;
		$S1=8;
	}
	if($Q2<1) {
		$CrossingPerimeter=1;
		$Q2=1;
		$S2=1;
	}
	if($Q2>8) {
		$CrossingPerimeter=1;
		$Q2=8;
		$S2=8;
	}
	if($CrossingPerimeter>0) {
		telePrint("LT. UHURA REPORTS MESSAGE FROM STARFLEET COMMAND:");
		telePrint("  'PERMISSION TO ATTEMPT CROSSING OF GALACTIC PERIMETER");
		telePrint("  IS HEREBY *DENIED*.  SHUT DOWN YOUR ENGINES.'");
		telePrint("CHIEF ENGINEER SCOTT REPORTS  'WARP ENGINES SHUT DOWN");
		telePrint("  AT SECTOR $S1 , $S2 OF QUADRANT $Q1 , $Q2'");
	}
	# this is 3860

	if($Q1*8+$Q2 == $Q4*8+$Q5) {
		#-- Quadrant not changed - this could have been (Q1 == Q4 and Q2 == Q5)
		#-- this happens only when CrossingPerimeter is true, but not vice versa
		#-- I could have Crossed the perimeter after changing 1 or more quadrant
		return 0;
	}
	
	# If arrived here, it means we reached a new quadrant, so time advances by 1
	# unlike EndOfMovementInQuadrant, this is true also when the warp speed is <1, if this has moved the Enterprise
	# to another quadrant. I think it makes sense
	$Stardate=$Stardate+1;
	
	if ($Stardate > $T0+$MaxNumOfDays) {
		$GameOver = 1;
		return 1;
	}
		
	ConsumeEnergy();
	# No more in the same quadrant, this will end the inner main loop
	return 1;
}


# COURSE CONTROL BEGINS HERE - line 2290

sub CourseControl {
	
	ShowDirections();	# the original BASIC code does not show this, comment if you want
	
#	1) Ask for course and speed

	print "COURSE (0-9) :";
	my $Course = <>;
	chomp($Course);
	return 1 if ($Course !~ /^\d$/ && $Course !~ /^\d\.\d+$/);
	
	$Course = 1 if ($Course==9);
	if ($Course<1 or $Course>9) {
		telePrint("   LT. SULU REPORTS, 'INCORRECT COURSE DATA, SIR!'");
		return 0;
	}
	
	my $MaxWarp = "8";
	$MaxWarp = "0.2" if ($DamageLevel[1]<0);
	
	$WarpFactor = -1;
	
	while($WarpFactor<0) {
		print "WARP FACTOR (0-$MaxWarp)? ";
		chomp($WarpFactor = <>);
		$WarpFactor =-1 if ($WarpFactor !~ /^\d$/ && $WarpFactor !~ /^\d\.\d+$/);
		
		if ($WarpFactor == 0) {
			#0 warp will cancel the NAV command
			return 0;
		}
		if ($DamageLevel[1]<0 && $WarpFactor > .2) {
			telePrint("WARP ENGINES ARE DAMAGED.  MAXIMUM SPEED = WARP 0.2");
			$WarpFactor =-1;
		}
		elsif($WarpFactor>8) {
			telePrint("   CHIEF ENGINEER SCOTT REPORTS 'THE ENGINES WON'T TAKE WARP $WarpFactor !");
			$WarpFactor =-1;
		}
	}
	
	$NoOfSteps =int($WarpFactor*8+.5);	# Energy consumed by warp (formerly $N) Number of steps of movement
	if ($EnergyLevel < $NoOfSteps) {
		telePrint("ENGINEERING REPORTS   'INSUFFICIENT ENERGY AVAILABLE");
		telePrint("                       FOR MANEUVERING AT WARP $WarpFactor !'");
		
		# it's possible to deviate energy from shields to warp
		if ($ShieldLevel >= ($NoOfSteps - $EnergyLevel) && $DamageLevel[7]>=0) {
			telePrint("DEFLECTOR CONTROL ROOM ACKNOWLEDGES $ShieldLevel UNITS OF ENERGY");
			telePrint("                         PRESENTLY DEPLOYED TO SHIELDS.");
		}
		return 0;
	}
	# If Energy is enough, go ahead
	
#	2) Klingons move (before Enterprise moves)
	for ($I=1;$I<=$K3;$I++) {
		if ($K[$I][3]>0) {
			AddElementInQuadrantString('   ',$K[$I][1],$K[$I][2]);  # delete ship in current position
			my ($R1,$R2) = FindEmptyPlaceinQuadrant();  			# returns a new position in R1,R2
			$K[$I][1]=$R1;
			$K[$I][2]=$R2;
			AddElementInQuadrantString('+K+',$R1,$R2);  # put ship in the new position
		}
	}

# 3) Klingons fire (before Enterprise moves)
	if (KlingonsAttack()) {
		# if KlingonsAttack returns true, the Enterprise has been destroyed
		# GameOver is set to true, so when CourseControl function returns, the game will end
		return 0;
	}
	
#	4) Now check if the movement will repair some Ship systems
#	since this happens after Klingon attack, some device just broken by the klingon can get repaired, nonsense

	my $RepairFactor = $WarpFactor;
	if ($WarpFactor>=1) {
		$RepairFactor=1;
	}

	my $devIndex = 0;
	for ($I=1;$I<=8;$I++) {
		if ($DamageLevel[$I]<0) {
			$DamageLevel[$I]=$DamageLevel[$I]+$RepairFactor;	#	-- moving by 1 quadrant repair by 1
			if ($DamageLevel[$I]>-0.1 && $DamageLevel[$I] < 0) {	#	-- if it's almost 0, goes back to -0.1
				$DamageLevel[$I] =-.1;
			}
			elsif ($DamageLevel[$I]>=0) {
				telePrint("DAMAGE CONTROL REPORT: '".deviceName($I)." REPAIR COMPLETED.'");
			}
		}
	}

#	5) Now check if a random system is broken or repaired
#	In 20% of the cases, select a random system and either repair it or break it
#	wouldn't it be better to do it in the previous loop?
	
	if (rand(1)<=.2) {
		$devIndex=FNR(1);
		if (rand(1)>=.6) {
			# it does not make sense that a system can have damage > 0
			# also what's the point of repairing something if it was not broken?
			$DamageLevel[$devIndex]=$DamageLevel[$devIndex]+rand(1)*3+1;
			telePrint("DAMAGE CONTROL REPORT: '".deviceName($devIndex)." STATE OF REPAIR IMPROVED.'");
		}
		else {
			# it' possible that something that just got repaired, it's broken here, nonsense
			$DamageLevel[$devIndex]=$DamageLevel[$devIndex]-(rand(1)*5+1);
			telePrint("DAMAGE CONTROL REPORT: '".deviceName($devIndex)." DAMAGED.'");
		}
	}

#	6) Finally the Enterprise can move
	AddElementInQuadrantString('   ',int($S1),int($S2));  # delete ship
	
	my $cindex = int($Course);
	
	$StepX1= $C[$cindex][1] + ($C[$cindex+1][1]-$C[$cindex][1])*($Course-$cindex);
	$StepX2= $C[$cindex][2] + ($C[$cindex+1][2]-$C[$cindex][2])*($Course-$cindex);
	
	$X=$S1;		# save previous Enterprise position
	$Y=$S2;
	
	$Q4=$Q1;	# save previous Enterprise quadrant
	$Q5=$Q2;
	
	for ($I=1;$I<$NoOfSteps;$I++) {
		$S1=$S1+$StepX1;
		$S2=$S2+$StepX2;

		#-- While inside the quadrant, the Enterprise will move step by step, checking if
		#-- it encounters an obstacle, or tries to cross the border of the quadrant
		#-- once the border is crossed, all the rest of the movement will be performed by ExceededQuadrantLimits
		#-- at that point, obstacles dont matter any more, all the movement will be done in one big step
		#-- This makes sense if we consider inside quadrant Impulse Speed and once crossed, Warp speed
		
		if ($S1<1 || $S1>8 || $S2<1 || $S2>8) {
			#-- This will check if Enterprise has moved to another quadrant, and will make the rest of the movements
			#-- It's possible that the ship tried to cross border of quadrant and it stopped
			#-- so quadrant has not changed, in this case the function will return false and loop will break
			if (ExceededQuadrantLimits()) {
				# movement has finished
				return 1;
			}
			else {
				# exit the "for" loop and then do EndOfMovementInQuadrant
				last;
			}
		}
		
		# still in the same quadrant, so it will continue moving
		
		if (SearchStringinQuadrant('   ',$S1,$S2)) {
			# ok then
		}
		else {
			# if space is NOT empty
			# Go back to previous position and exit loop
			$S1=int($S1-$StepX1);
			$S2=int($S2-$StepX2);
			telePrint("WARP ENGINES SHUT DOWN AT");
			telePrint("SECTOR $S1 , $S2 DUE TO BAD NAVIGATION.");
			last;
		}
	}
	# not sure why INT it's necessary
	$S1=int($S1);
	$S2=int($S2);
	
	EndOfMovementInQuadrant();
	
	return 0;   # still in the same quadrant
}

sub telePrint {
	my $string = shift;
	my $delay = shift;
	
	$delay = 0.10 if (!$delay);
	print $string."\n";
	smallDelay($delay);
}

sub smallDelay {
	my $delay = shift;
	return 0 if ($DisableTeleprint);
	$delay = 0.15 if (!$delay);
	select(undef, undef, undef, $delay);
}

sub PrintInstructions {
	
	my $text = <<'EOT';
	
          *************************************
          *                                   *
          *                                   *
          *      * * SUPER STAR TREK * *      *
          *                                   *
          *                                   *
          *************************************

      INSTRUCTIONS FOR 'SUPER STAR TREK'

1. WHEN YOU SEE \COMMAND ?\ PRINTED, ENTER ONE OF THE LEGAL
     COMMANDS (NAV,SRS,LRS,PHA,TOR,SHE,DAM,COM, OR XXX).
2. IF YOU SHOULD TYPE IN AN ILLEGAL COMMAND, YOU'LL GET A SHORT
     LIST OF THE LEGAL COMMANDS PRINTED OUT.
3. SOME COMMANDS REQUIRE YOU TO ENTER DATA (FOR EXAMPLE, THE
     'NAV' COMMAND COMES BACK WITH 'COURSE (1-9) ?'.)  IF YOU
     TYPE IN ILLEGAL DATA (LIKE NEGATIVE NUMBERS), THAN COMMAND
     WILL BE ABORTED

     THE GALAXY IS DIVIDED INTO AN 8 X 8 QUADRANT GRID,
AND EACH QUADRANT IS FURTHER DIVIDED INTO AN 8 X 8 SECTOR GRID.

     YOU WILL BE ASSIGNED A STARTING POINT SOMEWHERE IN THE
GALAXY TO BEGIN A TOUR OF DUTY AS COMANDER OF THE STARSHIP
\ENTERPRISE\; YOUR MISSION: TO SEEK AND DESTROY THE FLEET OF
KLINGON WARWHIPS WHICH ARE MENACING THE UNITED FEDERATION OF
PLANETS.

     YOU HAVE THE FOLLOWING COMMANDS AVAILABLE TO YOU AS CAPTAIN
OF THE STARSHIP ENTERPRISE:

\NAV\ COMMAND = WARP ENGINE CONTROL --
     COURSE IS IN A CIRCULAR NUMERICAL      4  3  2
     VECTOR ARRANGEMENT AS SHOWN             . . .
     INTEGER AND REAL VALUES MAY BE           ...
     USED.  (THUS COURSE 1.5 IS HALF-     5 ---*--- 1
     WAY BETWEEN 1 AND 2                      ...
                                             . . .
     VALUES MAY APPROACH 9.0, WHICH         6  7  8
     ITSELF IS EQUIVALENT TO 1.0
                                            COURSE
     ONE WARP FACTOR IS THE SIZE OF
     ONE QUADTANT.  THEREFORE, TO GET
     FROM QUADRANT 6,5 TO 5,5, YOU WOULD
     USE COURSE 3, WARP FACTOR 1.

\SRS\ COMMAND = SHORT RANGE SENSOR SCAN
     SHOWS YOU A SCAN OF YOUR PRESENT QUADRANT.

     SYMBOLOGY ON YOUR SENSOR SCREEN IS AS FOLLOWS:
        <*> = YOUR STARSHIP'S POSITION
        +K+ = KLINGON BATTLE CRUISER
        >!< = FEDERATION STARBASE (REFUEL/REPAIR/RE-ARM HERE!)
         *  = STAR

     A CONDENSED 'STATUS REPORT' WILL ALSO BE PRESENTED.

\LRS\ COMMAND = LONG RANGE SENSOR SCAN
     SHOWS CONDITIONS IN SPACE FOR ONE QUADRANT ON EACH SIDE
     OF THE ENTERPRISE (WHICH IS IN THE MIDDLE OF THE SCAN)
     THE SCAN IS CODED IN THE FORM \###\, WHERE TH UNITS DIGIT
     IS THE NUMBER OF STARS, THE TENS DIGIT IS THE NUMBER OF
     STARBASES, AND THE HUNDRESDS DIGIT IS THE NUMBER OF
     KLINGONS.

     EXAMPLE - 207 = 2 KLINGONS, NO STARBASES, & 7 STARS.

\PHA\ COMMAND = PHASER CONTROL.
     ALLOWS YOU TO DESTROY THE KLINGON BATTLE CRUISERS BY
     ZAPPING THEM WITH SUITABLY LARGE UNITS OF ENERGY TO
     DEPLETE THEIR SHIELD POWER.  (REMBER, KLINGONS HAVE
     PHASERS TOO!)

\TOR\ COMMAND = PHOTON TORPEDO CONTROL
     TORPEDO COURSE IS THE SAME AS USED IN WARP ENGINE CONTROL
     IF YOU HIT THE KLINGON VESSEL, HE IS DESTROYED AND
     CANNOT FIRE BACK AT YOU.  IF YOU MISS, YOU ARE SUBJECT TO
     HIS PHASER FIRE.  IN EITHER CASE, YOU ARE ALSO SUBJECT TO
     THE PHASER FIRE OF ALL OTHER KLINGONS IN THE QUADRANT.

     THE LIBRARY-COMPUTER (\COM\ COMMAND) HAS AN OPTION TO
     COMPUTE TORPEDO TRAJECTORY FOR YOU (OPTION 2)

\SHE\ COMMAND = SHIELD CONTROL
     DEFINES THE NUMBER OF ENERGY UNITS TO BE ASSIGNED TO THE
     SHIELDS.  ENERGY IS TAKEN FROM TOTAL SHIP'S ENERGY.  NOTE
     THAN THE STATUS DISPLAY TOTAL ENERGY INCLUDES SHIELD ENERGY

\DAM\ COMMAND = DAMMAGE CONTROL REPORT
     GIVES THE STATE OF REPAIR OF ALL DEVICES.  WHERE A NEGATIVE
     'STATE OF REPAIR' SHOWS THAT THE DEVICE IS TEMPORARILY
     DAMAGED.

\COM\ COMMAND = LIBRARY-COMPUTER
     THE LIBRARY-COMPUTER CONTAINS SIX OPTIONS:
     OPTION 0 = CUMULATIVE GALACTIC RECORD
        THIS OPTION SHOWES COMPUTER MEMORY OF THE RESULTS OF ALL
        PREVIOUS SHORT AND LONG RANGE SENSOR SCANS
     OPTION 1 = STATUS REPORT
        THIS OPTION SHOWS THE NUMBER OF KLINGONS, STARDATES,
        AND STARBASES REMAINING IN THE GAME.
     OPTION 2 = PHOTON TORPEDO DATA
        WHICH GIVES DIRECTIONS AND DISTANCE FROM THE ENTERPRISE
        TO ALL KLINGONS IN YOUR QUADRANT
     OPTION 3 = STARBASE NAV DATA
        THIS OPTION GIVES DIRECTION AND DISTANCE TO ANY
        STARBASE WITHIN YOUR QUADRANT
     OPTION 4 = DIRECTION/DISTANCE CALCULATOR
        THIS OPTION ALLOWS YOU TO ENTER COORDINATES FOR
        DIRECTION/DISTANCE CALCULATIONS
     OPTION 5 = GALACTIC /REGION NAME/ MAP
        THIS OPTION PRINTS THE NAMES OF THE SIXTEEN MAJOR
        GALACTIC REGIONS REFERRED TO IN THE GAME.
EOT
	print $text."\n\n";
	print "-- HIT RETURN TO CONTINUE ";
	<>;
}

sub AskForInstructions {
	print "\nDO YOU NEED INSTRUCTIONS (Y/N) ? ";
	chomp(my $ans =<>);
	if ($ans =~ /^(Y|YES)$/i) {
		PrintInstructions();
	}
	return 0;
}