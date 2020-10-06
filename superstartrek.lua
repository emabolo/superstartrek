--[[
SUPER STARTREK - MAY 16,1978 - REQUIRES 24K MEMORY

****        **** STAR TREK ****        ****
**** SIMULATION OF A MISSION OF THE STARSHIP ENTERPRISE,
**** AS SEEN ON THE STAR TREK TV SHOW.
**** ORIGIONAL PROGRAM BY MIKE MAYFIELD, MODIFIED VERSION
**** PUBLISHED IN DEC'S "101 BASIC GAMES", BY DAVE AHL.
**** MODIFICATIONS TO THE LATTER (PLUS DEBUGGING) BY BOB
*** LEEDOM - APRIL & DECEMBER 1974,
*** WITH A LITTLE HELP FROM HIS FRIENDS . . .
*** COMMENTS, EPITHETS, AND SUGGESTIONS SOLICITED --
*** SEND TO:  R. C. LEEDOM
***           WESTINGHOUSE DEFENSE & ELECTRONICS SYSTEMS CNTR.
***           BOX 746, M.S. 338
***           BALTIMORE, MD  21203
***
*** CONVERTED TO MICROSOFT 8 K BASIC 3/16/78 BY JOHN GORDERS
*** LINE NUMBERS FROM VERSION STREK7 OF 1/12/75 PRESERVED AS
*** MUCH AS POSSIBLE WHILE USING MULTIPLE STATEMENTS PER LINE
*** SOME LINES ARE LONGER THAN 72 CHARACTERS; THIS WAS DONE
*** BY USING "?" INSTEAD OF "PRINT" WHEN ENTERING LINES
***
*************************************************************
*** LUA Conversion by Emanuele Bolognesi - v0.3 Oct 2020
***
*** Comments in uppercase are the original comments, lowercase
*** are mine.
***
*** My blog: http://emabolo.com/
*** Github:  https://github.com/emabolo
***
*************************************************************
--]]


-- Instructions =============================================

function printInstructions()
	
text = [[
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
]]
	print (text)
	print ("-- HIT RETURN TO CONTINUE ")
	io.read()
end

function askForInstructions()
	io.write("DO YOU NEED INSTRUCTIONS (Y/N) ? ")
	yesno = string.upper(io.read())
	if yesno == 'Y' or yesno == 'YES' then
		printInstructions()
	end
end

-- Utilities =============================================

function FNR(r)
	-- original function is "math.floor(rand(R)*7.98+1.01)"
	return math.random(1,8)	-- replaced with this simple rand
end

function smallDelay(sec)
	sec = sec or 0.15
    --socket.select(nil, nil, sec)
	local t0 = os.clock()
	while os.clock() - t0 <= sec do end
end

function telePrint(str,delay)
	str = str or ''
	delay = delay or 0.10
	print(str)
	smallDelay(delay)
end

function die (msg)
	msg = msg or 'I died well'
 	io.stderr:write(msg,'\n')
 	os.exit(1)
end

function roundTo(value,precision)
	precision = 10^precision
	value = math.floor(value*precision)
	return value/precision
end

function formatWithSpaces(str,maxlength,centered)
	-- if not centered it's aligned to the right
	centered = centered or false
	local final = ""
	if centered then
		spaces = string.rep(" ",math.floor((maxlength-string.len(str))/2) )
		final = spaces .. str .. spaces
		if string.len(final) < maxlength then final = final..' ' end
	else
		spaces = string.rep(" ",maxlength-string.len(str))
		final = str .. spaces
	end
	return final
end


-- Names Utilities ===========================================================

function deviceName(sys)
	local names = {"WARP ENGINES","SHORT RANGE SENSORS","LONG RANGE SENSORS","PHASER CONTROL","PHOTON TUBES","DAMAGE CONTROL","SHIELD CONTROL","LIBRARY-COMPUTER"}
	return names[sys]
end

function GetQuadrantName(Z4,Z5,RegionNameOnly)

	RegionNameOnly = RegionNameOnly or false
	
	-- QUADRANT NAME IN G2 FROM Z4,Z5 (=Q1,Q2)
	-- CALL WITH G5=1 (RegionNameOnly) TO GET REGION NAME ONLY
	
	local starnames = {}
	if Z5<=4 then
		starnames ={'ANTARES','RIGEL','PROCYON','VEGA','CANOPUS','ALTAIR','SAGITTARIUS','POLLUX'}
	else
		starnames ={'SIRIUS','DENEB','CAPELLA','BETELGEUSE','ALDEBARAN','REGULUS','ARCTURUS','SPICA'}
	end
	
	QuadrantName = starnames[Z4] -- array in LUA start from 1
	
	if (not(RegionNameOnly)) then
		if Z5 ==1 or Z5 ==5 then
			QuadrantName = QuadrantName .. " I"
		elseif Z5 == 2 or Z5 == 6 then
			QuadrantName = QuadrantName .. " II"
		elseif Z5 == 3 or Z5 == 7 then
			QuadrantName = QuadrantName .. " III"
		elseif Z5 == 4 or Z5 == 8 then
			QuadrantName = QuadrantName .. " IV"
		end
	end
	
	return QuadrantName
end

-- Quadrant Management  =========================================

function AddElementInQuadrantString(elem,y,x)
	--# INSERT IN STRING ARRAY FOR QUADRANT line 8670

	y = math.floor(y-.5)
	x = math.floor(x-.5)
	position=x*3+y*24+1
	
	if string.len(elem) ~= 3 then
		die("wrong string passed to AddElementInQuadrantString")
	end
	
	if position == 1 then
		QuadString = elem .. QuadString:sub(4)
	elseif position == 190 then
		QuadString = QuadString:sub(1,189) .. elem
	else
		QuadString = QuadString:sub(1,position-1) .. elem .. QuadString:sub(position+3)
	end

	return position
end

function SearchStringinQuadrant(elem,y,x)
	-- STRING COMPARISON IN QUADRANT ARRAY - line 8830

	y = math.floor(y-.5)
	x = math.floor(x-.5)
	position=x*3+y*24+1
	
	if QuadString:sub(position,position+2) == elem then
		return true
	else
		return false
	end
end

function FindEmptyPlaceinQuadrant()
	-- FIND EMPTY PLACE IN QUADRANT (FOR THINGS)
	-- generate 2 random coordinates, and check if quadrant cell is empty.
	-- If empty space is found, returns the coordinates

	found = false
	while (not found) do
		y=FNR(1)
		x=FNR(1)
		found = SearchStringinQuadrant('   ',y,x)
	end
	return y,x
end


-- Ship Status Management  ================================

function CheckShipStatus()
	if ShipDocked then
		return 'DOCKED'
	elseif K3>0 then
		return "*RED*"
	elseif EnergyLevel < (MaxEnergyLevel/10) then
		return "YELLOW"
	else
		return "GREEN"
	end
end

function checkIfDocked()
	-- checking all the sectors around the Enterprise to see if it's docked
	ShipDocked=false

	for i=S1-1,S1+1 do
		for j=S2-1,S2+1 do

			ii = math.floor(i+0.5)
			jj = math.floor(j+0.5)
			if ii>=1 and ii<=8 and jj>=1 and jj<=8 then
				
				if SearchStringinQuadrant(">!<",i,j) then	-- found a starbase at coordinates I,J
					ShipDocked=true
					ShipCondition="DOCKED"
					EnergyLevel=MaxEnergyLevel
					PhotonTorpedoes=MaxTorpedoes
					telePrint("SHIELDS DROPPED FOR DOCKING PURPOSES")
					ShieldLevel=0
					break
				end
			end
		end
	end
	
	ShipCondition = CheckShipStatus()
	return ShipDocked
end

-- Math functions to calculate distance and direction ==================
-- ported from the original BASIC code

function CalcDistanceOfShip(x1,y1,x2,y2)
	local DX = x1-x2
	local DY = y1-y2
	return math.sqrt(DX^2 + DY^2)
end

function CalcAndPrintDirection(m,n,StartingCourse)
	local Direction = 0
	-- line 8290
	if math.abs(m) > math.abs(n) then  
		Direction = StartingCourse+(math.abs(n)/math.abs(m))
	else
		Direction = StartingCourse+( (math.abs(n)-math.abs(m)+math.abs(n)) / math.abs(n))
	end
	telePrint(" DIRECTION = " .. roundTo(Direction,2))
	return Direction
end

function PrintDistanceAndDirection(x1,y1,x2,y2)
	-- calc direction from x2,y2 to x1, y1
	HD=y1-y2
	VD=x2-x1
	
	if HD<0 then
		if VD>0 then							-- VD>0 and HD < 0
			CalcAndPrintDirection(VD,HD,3)
		elseif HD ~= 0 then						-- but HD cant be 0, so this is just else
			CalcAndPrintDirection(HD,VD,5)
		end
	else
		if VD<0 then							-- case HD>= 0 and VD < 0
			CalcAndPrintDirection(VD,HD,7)
		elseif HD>0 then						-- the only case where this is not true is HD = 0
			CalcAndPrintDirection(HD,VD,1)
		elseif VD==0 then					-- so HD = 0 and VD = 0
			CalcAndPrintDirection(HD,VD,5)
		elseif VD>0 then						-- so HD = 0 and VD > 0
			CalcAndPrintDirection(HD,VD,1)
		end
	end
	
	local Distance = CalcDistanceOfShip(x1,y1,x2,y2)
	telePrint(" DISTANCE = ".. roundTo(Distance,2))

	return Distance
end



-- Main Commands of the Game =======================================

function ShortRangeSensorScan()
	-- SHORT RANGE SENSOR SCAN & STARTUP SUBROUTINE
	-- line 6720 was here
	if DamageLevel[2]<0 then
		telePrint("\n*** SHORT RANGE SENSORS ARE OUT ***\n")
		return
	end
	
	Header ="---------------------------------"
	telePrint(Header)

	for i=1,8 do
		local line = i-1
		for j=line*24+1,line*24+22,3 do
			io.write(" "..string.sub(QuadString,j,j+2))
		end
		if i == 1 then telePrint("        STARDATE           "..roundTo(Stardate,1)) end
		if i == 2 then telePrint("        CONDITION          "..ShipCondition) end
		if i == 3 then telePrint("        QUADRANT           "..Q1.." , "..Q2) end
		if i == 4 then telePrint("        SECTOR             "..S1.." , "..S2) end
		if i == 5 then telePrint("        PHOTON TORPEDOES   "..math.floor(PhotonTorpedoes)) end
		if i == 6 then telePrint("        TOTAL ENERGY       "..math.floor(EnergyLevel+ShieldLevel)) end
		if i == 7 then telePrint("        SHIELDS            "..math.floor(ShieldLevel)) end
		if i == 8 then telePrint("        KLINGONS REMAINING "..math.floor(TotalKlingonShips)) end
	end
	telePrint(Header)
	return true
end

function LongRangeSensorScan()
	--# it was line 4000
	local N = {}
	if DamageLevel[3]<0 then
		telePrint("\n*** LONG RANGE SENSORS ARE INOPERABLE ***\n")
		return
	end
	
	telePrint("LONG RANGE SCAN FOR QUADRANT "..Q1..','..Q2)
	Header="-------------------"
	telePrint(Header)
	
	for i=Q1-1,Q1+1 do
		N[1]=-1	-- every time set a negative number
		N[2]=-2 -- if it's not filled later, it means the quadrant does not exist
		N[3]=-3
		for j=Q2-1,Q2+1 do
			if i>0 and i<9 and j>0 and j<9 then
				N[j-Q2+2]=Galaxy[i][j]
				ExploredSpace[i][j]=Galaxy[i][j];		--# Scan a new quadrant
			end
		end
		for idx=1,3 do
			io.write(": ")
			if N[idx]<0 then
				io.write("*** ")
			else
				local string = tostring(N[idx]+1000)   -- it's a way to fill the missing 0 at the beginning
				io.write(string:sub(2,4)..' ')
			end
		end
		telePrint(":")
		telePrint(Header)
	end
	return true
end


function ShieldControl()

	-- 5520 REM SHIELD CONTROL - 5530
	if DamageLevel[7]<0 then
		telePrint("SHIELD CONTROL INOPERABLE")
		return false
	end
	
	telePrint("ENERGY AVAILABLE = "..(EnergyLevel+ShieldLevel))
	io.write("NUMBER OF UNITS TO SHIELDS? ")
	local Units = tonumber(io.read())
	
	if Units == nil then
		telePrint("WRONG VALUE")
	elseif Units<0 or ShieldLevel == Units then
		telePrint("<SHIELDS UNCHANGED>")
	elseif Units > EnergyLevel+ShieldLevel then
		telePrint("SHIELD CONTROL REPORTS  'THIS IS NOT THE FEDERATION TREASURY.'")
		telePrint("<SHIELDS UNCHANGED>")
	else
		EnergyLevel=EnergyLevel+ShieldLevel-Units
		ShieldLevel=Units
		telePrint("DEFLECTOR CONTROL ROOM REPORT:")
		telePrint("  'SHIELDS NOW AT "..ShieldLevel.." UNITS PER YOUR COMMAND.'")
	end
	
	return ShieldLevel
end


function DamageControl()
	-- 5680 REM DAMAGE CONTROL - 5690
	
	if DamageLevel[6]>=0 then
		telePrint("\nDEVICE             STATE OF REPAIR")
		for index=1,8 do
			-- print with alignment of spaces
			local tabs = 27
			if DamageLevel[index]<0 then tabs=26 end  -- for formatting
			telePrint(formatWithSpaces(deviceName(index),tabs) .. roundTo(DamageLevel[index],2) )
		end
	else
		telePrint("DAMAGE CONTROL REPORT NOT AVAILABLE")
	end
	print("")
	-- By checking the status, you can also ask to repair, if docked
	if ShipDocked then
		-- line 5720
		local TimeToRepair=0
		for I=1,8 do
			if DamageLevel[I]<0 then
				TimeToRepair=TimeToRepair+.1;				-- Time increases for each damaged system
			end
		end
		if TimeToRepair==0 then
			return 0;					-- nothing to repair
		end
		print("")
		
		TimeToRepair=roundTo(TimeToRepair+math.random()*0.5,2)	-- add a random factor and round to 2 decimals
		
		if TimeToRepair >0.9 then TimeToRepair=0.9 end -- cannot be more than 1 day
		
		telePrint("TECHNICIANS STANDING BY TO EFFECT REPAIRS TO YOUR SHIP;")
		telePrint("ESTIMATED TIME TO REPAIR: "..TimeToRepair.." STARDATES")
		io.write("WILL YOU AUTHORIZE THE REPAIR ORDER (Y/N) ? ")
		local YesNo = io.read()
		if YesNo == "Y" then
			for i=1,8 do
				if DamageLevel[i]<0 then
					DamageLevel[i]=0
				end
			end
			Stardate=Stardate+TimeToRepair+0.1;		-- never trust engineers!
			telePrint("REPAIR COMPLETED.")
		end
	end
	return true
end

function PrintComputerRecord(GalaxyMapOn)
	telePrint("       1     2     3     4     5     6     7     8")
	telePrint("     ----- ----- ----- ----- ----- ----- ----- -----")

	for i=1,8 do
		io.write(i..'  ')
		if GalaxyMapOn then
			QuadrantName = GetQuadrantName(i,1,true)
			io.write('  '..formatWithSpaces(QuadrantName,23,true))	-- centered string
			
			QuadrantName = GetQuadrantName(i,5,true)
			io.write(' '..formatWithSpaces(QuadrantName,23,true))
			
		else
			for j=1,8 do
				io.write("   ")
				if ExploredSpace[i][j]==0 then
					io.write("***")
				else
					local str = tostring(ExploredSpace[i][j]+1000)
					io.write(str:sub(2,4))
				end
			end
		end
		
		print("")
		telePrint("     ----- ----- ----- ----- ----- ----- ----- -----")
	end
	print("")
	return false
end

function GalaxyMap()
	--#7390 REM SETUP TO CHANGE CUM GAL RECORD TO GALAXY MAP
	telePrint("                        THE GALAXY")	-- # GOTO7550
	PrintComputerRecord(true)
	return true
end

function ComulativeGalacticRecord()
	telePrint("       COMPUTER RECORD OF GALAXY FOR QUADRANT "..Q1..','..Q2.."\n")
	PrintComputerRecord(false)
	return true
end

function StatusReport()
	-- #7890 REM STATUS REPORT - 7900
	telePrint("   STATUS REPORT:")
	Ss=""
	if TotalKlingonShips>1 then Ss="S" end
	telePrint("KLINGON"..Ss.." LEFT: "..TotalKlingonShips)
	telePrint("MISSION MUST BE COMPLETED IN "..roundTo(T0+MaxNumOfDays-Stardate,1).." STARDATES")
	
	Ss=""
	if TotalStarbases>1 then Ss="S" end

	if TotalStarbases<1 then
		telePrint("YOUR STUPIDITY HAS LEFT YOU ON YOUR ON IN")
		telePrint("  THE GALAXY -- YOU HAVE NO STARBASES LEFT!")
	else
		telePrint("THE FEDERATION IS MAINTAINING "..TotalStarbases.." STARBASE"..Ss.." IN THE GALAXY")
	end
	DamageControl()
	return true
end


function PhotonTorpedoData()
	--#8060 REM TORPEDO, BASE NAV, D/D CALCULATOR
	if K3<=0 then
		telePrint("SCIENCE OFFICER SPOCK REPORTS  'SENSORS SHOW NO ENEMY SHIPS")
		telePrint("                                IN THIS QUADRANT'")
		return true
	end
	Ss=""
	if K3>1 then
		Ss="S"
	end
	telePrint("FROM ENTERPRISE TO KLINGON BATTLE CRUISER"..Ss..":")

	for i=1,3 do
		if K[i][3]>0 then
			PrintDistanceAndDirection(K[i][1],K[i][2],S1,S2)
		end
	end
	return true
end


function DistanceCalculator()
	telePrint("DIRECTION/DISTANCE CALCULATOR:")
	telePrint("YOU ARE AT QUADRANT "..Q1..","..Q2.." SECTOR "..S1..","..S2)
	io.write("PLEASE ENTER INITIAL COORDINATES (row,col): ")

	local Coord = io.read()
	local inp1, inp2 = Coord:match("(%d+),(%d+)")
	local y1, x1 = tonumber(inp1), tonumber(inp2)
	
	io.write("  FINAL COORDINATES (row,col): ")
	Coord = io.read()
	inp1, inp2 = Coord:match("(%d+),(%d+)")
	local y2, x2 = tonumber(inp1), tonumber(inp2)
	
	if y1 == nil or x1 == nil or x2 == nil or y2 == nil then
		telePrint("WRONG COORDINATES")
		return false
	end
	PrintDistanceAndDirection(y2,x2,y1,x1)
	return true
end

function StarbaseNavData()
	if B3 > 0 then
		telePrint("FROM ENTERPRISE TO STARBASE:")
		PrintDistanceAndDirection(B4,B5,S1,S2)
	else
		telePrint("MR. SPOCK REPORTS,  'SENSORS SHOW NO STARBASES IN THIS")
		telePrint(" QUADRANT.'")
	end
	return true
end

function LibraryComputer()
	--#7280 REM LIBRARY COMPUTER CODE - 7290
	if DamageLevel[8]<0 then
		telePrint("COMPUTER DISABLED")
		return false
	end
	local ComputerDone = false
	while not ComputerDone do
		io.write("COMPUTER ACTIVE AND AWAITING COMMAND? ")
		local Command = tonumber(io.read())
		print("")

		if Command == 0 then
			ComputerDone = ComulativeGalacticRecord()	--	#7540
		elseif Command == 1 then
			ComputerDone = StatusReport()				--	#7900
		elseif Command == 2 then
			ComputerDone = PhotonTorpedoData()			--	#8070
		elseif Command == 3 then
			ComputerDone = StarbaseNavData()			--	#8500
		elseif Command == 4 then
			ComputerDone = DistanceCalculator()			--	#8150
		elseif Command == 5 then
			ComputerDone = GalaxyMap()					--	#7400
		else
			print("FUNCTIONS AVAILABLE FROM LIBRARY-COMPUTER:")
			print("   0 = CUMULATIVE GALACTIC RECORD")
			print("   1 = STATUS REPORT")
			print("   2 = PHOTON TORPEDO DATA")
			print("   3 = STARBASE NAV DATA")
			print("   4 = DIRECTION/DISTANCE CALCULATOR")
			print("   5 = GALAXY 'REGION NAME' MAP\n")
		end
	end
	return false
end

-- End of Game functions ===============================================

function EnterpriseDestroyed()
	telePrint("\nTHE ENTERPRISE HAS BEEN DESTROYED.  THE FEDERATION WILL BE CONQUERED.")
	smallDelay(2)
	return
end

function KlingonsDefeated()
	telePrint("\nCONGRATULATIONS, CAPTAIN! THE LAST KLINGON BATTLE CRUISER")
	telePrint("MENACING THE FEDERATION HAS BEEN DESTROYED IN STARDATE "..roundTo(Stardate,1))
	telePrint("\nYOUR EFFICIENCY RATING IS " .. math.floor(1000*(InitialKlingonShips/(Stardate-T0))^2))
	return
end

function TimeExpired()
	telePrint("\nTOO LATE CAPTAIN!  THE FEDERATION HAS BEEN CONQUERED.")
end

-- Combat functions ===============================================

--# this was line-6000
function KlingonsAttack()
	if K3<=0 then
		return false
	end
	telePrint("KLINGON SHIPS ATTACK THE ENTERPRISE",1)

	if ShipDocked then
		telePrint("STARBASE SHIELDS PROTECT THE ENTERPRISE.")
		return false
	end

	for i=1,3 do
		KlingonEnergy = K[i][3]
		if KlingonEnergy>0 then
			local Distance = CalcDistanceOfShip(K[i][1],K[i][2],S1,S2)
			local Hits = math.floor((KlingonEnergy/Distance)*(2+math.random()))+1
			ShieldLevel = ShieldLevel-Hits

			-- this is a strange choice. Energy of the klingon decrease when they fire
			-- but it does not depend on the power used by the phasers
			-- also it decreases a lot, because it can become 1/3 or 1/4 of the previous energy
			-- would be better to use an algorithm similar to the one used for the Enterprise
			K[i][3] = KlingonEnergy/(3+math.random())
			telePrint(Hits.." UNIT HIT ON ENTERPRISE FROM SECTOR "..K[i][1]..","..K[i][2])
			if ShieldLevel<0 then
				EnterpriseDestroyed()
				GameOver = true
				return true
			end
			telePrint("      <SHIELDS DOWN TO "..ShieldLevel.." UNITS>",1)
			
			if Hits>19 and (ShieldLevel==0 or (math.random()<.6 and (Hits/ShieldLevel) > 0.02)) then
				SysDamaged=FNR(1)
				DamageLevel[SysDamaged]= DamageLevel[SysDamaged] - (Hits/ShieldLevel) - (0.5 * math.random())
				telePrint("DAMAGE CONTROL REPORTS '"..deviceName(SysDamaged).." DAMAGED BY THE HIT'")
			end
		end
	end

	return false
end

--#4690 REM PHOTON TORPEDO CODE BEGINS HERE
function FirePhotonTorpedoes()
	if PhotonTorpedoes<=0 then
		telePrint("ALL PHOTON TORPEDOES EXPENDED.",2)
		return false
	end
	if DamageLevel[5]<0 then
		telePrint("PHOTON TUBES ARE NOT OPERATIONAL.",2)
		return false
	end
	
	io.write("PHOTON TORPEDO COURSE (1-9)? ")
	local Course = tonumber(io.read())

	if Course == nil then return false end
	if Course == 9 then Course = 1 end

	if Course<0.1 or Course>9 then
		telePrint("ENSIGN CHEKOV REPORTS,  'INCORRECT COURSE DATA, SIR!'")
		return false
	end

	EnergyLevel=EnergyLevel-2
	PhotonTorpedoes=PhotonTorpedoes-1
	
	local cindex = math.floor(Course)

	local StepX1=C[cindex][1]+(C[cindex+1][1]-C[cindex][1])*(Course-cindex)
	local StepX2=C[cindex][2]+(C[cindex+1][2]-C[cindex][2])*(Course-cindex)
	
	local X=S1  -- torpedoes starting coordinates = Enterprise coordinates
	local Y=S2
	telePrint("TORPEDO TRACK:")
	--# this is line 4920

	local KlingonDestroyed = 0

	while (1) do
		X=X+StepX1
		Y=Y+StepX2
		X3=math.floor(X+.5)
		Y3=math.floor(Y+.5)
		
		if X3<1 or X3>8 or Y3<1 or Y3>8 then
			-- torpedo is out of borders
			telePrint("TORPEDO MISSED!")
			smallDelay(2)
			break
		end
		
		telePrint("               "..X3.." , "..Y3,0.5)
		if SearchStringinQuadrant("   ",X,Y) then
			--# found white space, continue and go to next iteration of loop
	
		elseif SearchStringinQuadrant("+K+",X,Y) then
			--# found a klingon at coordinates X, Y
			telePrint("*** KLINGON DESTROYED ***",1)
			K3=K3-1
			ShipCondition = CheckShipStatus()		-- could become GREEN if there are no more klingons
			
			TotalKlingonShips=TotalKlingonShips-1
			if TotalKlingonShips<=0 then
				KlingonsDefeated()
				GameOver = true
				return true
			end
			--# Check which Klingon has been destroyed
			for i=1,3 do
				if X3 == K[i][1] and Y3 == K[i][2] then
					K[i][3]=0
					KlingonDestroyed = i
				end
			end
			AddElementInQuadrantString('   ',X,Y)  		-- remove klingon
			Galaxy[Q1][Q2]=K3*100+B3*10+S3				-- update galaxy 
			ExploredSpace[Q1][Q2]=Galaxy[Q1][Q2]		-- update explored galaxy
			break										-- no need to continue loop
			
		--# check if I hit a star
		elseif SearchStringinQuadrant(" * ",X,Y) then
			telePrint("STAR AT "..X3..","..Y3.." ABSORBED TORPEDO ENERGY.",1)
			break

		--# Check if I hit a starbase
		elseif SearchStringinQuadrant(">!<",X,Y) then
			--# found a starbase
			telePrint("*** STARBASE DESTROYED ***",1)
			B3=B3-1
			TotalStarbases=TotalStarbases-1
			if TotalStarbases>0 or TotalKlingonShips>Stardate-T0-MaxNumOfDays then
				telePrint("STARFLEET COMMAND REVIEWING YOUR RECORD TO CONSIDER")
				telePrint("COURT MARTIAL!")
				smallDelay(2)
				ShipDocked=false	-- if docked, no more docked - but what if it was docked to another base?

				AddElementInQuadrantString('   ',X,Y)  		-- remove base
				Galaxy[Q1][Q2]=K3*100+B3*10+S3				-- update galaxy 
				ExploredSpace[Q1][Q2]=Galaxy[Q1][Q2]
				break
			else
				telePrint("THAT DOES IT, CAPTAIN!!  YOU ARE HEREBY RELIEVED OF COMMAND")
				telePrint("AND SENTENCED TO 99 STARDATES AT HARD LABOR ON CYGNUS 12!!")
				smallDelay(2)
				GameOver = true
				return true
			end
		else
			--# If the space was not empty, and I didnt hit a star, nor a base, or a klingon
			--# what else could have happened?
			--# in the original code, it asks again to enter the course
			--# here I just print a message to see if this can really happen
			telePrint("An unknown object has been hit")
			break
		end
	end
	
	KlingonsAttack()
	return true
end



function FirePhasers()
	-- formerly line 4260 REM PHASER CONTROL CODE BEGINS HERE
	if DamageLevel[4]<0 then
		telePrint("PHASERS INOPERATIVE")
		return false
	end
	if K3<1 then
		telePrint("SCIENCE OFFICER SPOCK REPORTS  'SENSORS SHOW NO ENEMY SHIPS")
		telePrint("                                IN THIS QUADRANT'")
		return false
	end
	if DamageLevel[8]<0 then
		telePrint("COMPUTER FAILURE HAMPERS ACCURACY")
	end
	telePrint("PHASERS LOCKED ON TARGET;  ")
	local Units = nil
	while Units == nil or Units>EnergyLevel do
		telePrint("ENERGY AVAILABLE = "..EnergyLevel.." UNITS")
		io.write("NUMBER OF UNITS TO FIRE? ")
		Units = tonumber(io.read())
		if Units == 0 then return false end 	-- entering 0 will cancel the command
	end
	
	EnergyLevel=EnergyLevel-Units
	if DamageLevel[8]<0 then 			-- when computer is broken, the risk is to waste energy
		Units = Units*math.random()		-- the original code has a bug, it checks shield damage not computer
	end
	H1=math.floor(Units/K3)				-- all the phasers energy is splitted among the enemy ships
	
	for i=1,3 do
		KlingonEnergy = K[i][3]
		if KlingonEnergy >0 then
			distance = CalcDistanceOfShip(K[i][1],K[i][2],S1,S2)
			distanceRatio = H1/distance 	-- damage is inversely proportional to distance
			randNumb = math.random()+2		-- but a random factor can increse damage up to x2
			HitPoints=math.floor(distanceRatio*randNumb)

			-- the next check is a sort of simulation of klingon ship shields
			if HitPoints <= (.15*KlingonEnergy) then
				telePrint("SENSORS SHOW NO DAMAGE TO ENEMY AT "..K[i][1]..","..K[i][2],0.5)
				HitPoints = 0
			else
				K[i][3]=K[i][3]-HitPoints
				telePrint(HitPoints.." UNITS HIT ON KLINGON AT SECTOR "..K[i][1]..","..K[i][2])
			end

			if K[i][3] > 0 then
				telePrint("   (SENSORS SHOW "..math.floor(K[i][3]).." UNITS REMAINING)",1)
			else
				telePrint("*** KLINGON DESTROYED ***",1)
				K3=K3-1
				ShipCondition = CheckShipStatus()
				
				TotalKlingonShips=TotalKlingonShips-1
				
				if TotalKlingonShips <= 0 then
					KlingonsDefeated()
					GameOver = true
					return true
				end

				AddElementInQuadrantString('   ',K[i][1],K[i][2]);  -- Delete klingon ship from screen
				K[i][3]=0											-- it is already 0 or less than 0
				Galaxy[Q1][Q2]=Galaxy[Q1][Q2]-100					-- Delete klingon ship from galaxy array
				ExploredSpace[Q1][Q2]=Galaxy[Q1][Q2]				-- clear also explored galaxy
			end
		end
	end
	KlingonsAttack()
	return false
end


-- Movement functions ===============================================

function ShowDirections()
	print [[

      4  3  2   
       \ | /    
        \|/     
    5 ---*--- 1 
        /|\     
       / | \    
      6  7  8
]]
end


function ConsumeEnergy()
	--MANEUVER ENERGY S/R **
	EnergyLevel=EnergyLevel-NoOfSteps-10  -- a warp speed of 8 consumes 8x8+10 =74 energy, speed 1 instead 1x8+10 =18
	if EnergyLevel>=0 then
		return EnergyLevel
	end
	telePrint("SHIELD CONTROL SUPPLIES ENERGY TO COMPLETE THE MANEUVER.")
	ShieldLevel=ShieldLevel+EnergyLevel  -- remove the energy required from the shields
	EnergyLevel=0
	if ShieldLevel<=0 then 				 -- this should not be possible
		ShieldLevel=0
	end
	return EnergyLevel
end


function EndOfMovementInQuadrant()
	--  this is line-3370
	--  These are the last operations done before end of the turn, if the Enterprise has not changed quadrant
	
	AddElementInQuadrantString('<*>',math.floor(S1),math.floor(S2))
	ConsumeEnergy()
	DayIncrement=1			-- time advances by 1, even if you traveled at warp speed 9

	if WarpFactor<1 then
		DayIncrement = roundTo(WarpFactor,1)
	end
	
	Stardate=Stardate+DayIncrement		
	if Stardate > T0+MaxNumOfDays then
		TimeExpired()
		GameOver = true
		return true
	end

	checkIfDocked()
	ShortRangeSensorScan()
	
	return false
end

function ExceededQuadrantLimits()
	-- EXCEEDED QUADRANT LIMITS
	-- checking if quadrant has been exceeded. If it's still in the same quadrant, returns true
	
	X=8*Q1+X+NoOfSteps*StepX1
	Y=8*Q2+Y+NoOfSteps*StepX2
	Q1=math.floor(X/8)
	Q2=math.floor(Y/8)
	S1=math.floor(X-Q1*8)	-- new pos of enterprise in quadrant
	S2=math.floor(Y-Q2*8)

	if S1 == 0 then
		Q1=Q1-1
		S1=8
	end
	if S2==0 then
		Q2=Q2-1
		S2=8
	end
	
	local CrossingPerimeter = false
	if Q1<1 then
		CrossingPerimeter=true
		Q1=1
		S1=1
	end
	if Q1>8 then
		CrossingPerimeter=true
		Q1=8
		S1=8
	end
	if Q2<1 then
		CrossingPerimeter=true
		Q2=1
		S2=1
	end
	if Q2>8 then
		CrossingPerimeter=true
		Q2=8
		S2=8
	end
	
	if CrossingPerimeter then
		telePrint("LT. UHURA REPORTS MESSAGE FROM STARFLEET COMMAND:")
		telePrint("  'PERMISSION TO ATTEMPT CROSSING OF GALACTIC PERIMETER")
		telePrint("  IS HEREBY *DENIED*.  SHUT DOWN YOUR ENGINES.'")
		telePrint("CHIEF ENGINEER SCOTT REPORTS  'WARP ENGINES SHUT DOWN")
		telePrint("  AT SECTOR "..S1.." , "..S2.." OF QUADRANT "..Q1.." , "..Q2.."'")
	end
	--# this is 3860

	if Q1*8+Q2 == Q4*8+Q5 then
		-- Quadrant not changed - this could have been (Q1 == Q4 and Q2 == Q5)
		-- this happens only when CrossingPerimeter is true, but not vice versa
		-- I could have Crossed the perimeter after changing 1 or more quadrant
		EndOfMovementInQuadrant()
		-- returning false means it does not restart the quadrant
		return false
	end
	
	-- If arrived here, it means we reached a new quadrant, so time advances by 1
	-- unlike EndOfMovementInQuadrant, this is true also when the warp speed is <1, if this has moved the Enterprise
	-- to another quadrant. I think it makes sense
	Stardate=Stardate+1
	
	if Stardate > T0+MaxNumOfDays then
		TimeExpired()
		GameOver = true
		return true
	end
		
	ConsumeEnergy()
	-- No more in the same quadrant, this will end the inner main loop
	return true
end



--# COURSE CONTROL BEGINS HERE - line 2290

function CourseControl()
	
	ShowDirections()	--# the original BASIC code does not show this, comment if you want

	-- 1) Ask for course and speed
	io.write("COURSE (0-9) :")
	local Course = tonumber(io.read())

	if Course == nil or Course<1 or Course>9 then
		telePrint("   LT. SULU REPORTS, 'INCORRECT COURSE DATA, SIR!'")
		return false
	end
	MaxWarp = '8'
	if DamageLevel[1]<0 then MaxWarp = '0.2' end
	
	WarpFactor = nil
	
	while WarpFactor == nil do
		io.write("WARP FACTOR (0-"..MaxWarp..")? ")
		WarpFactor = tonumber(io.read())
		
		if WarpFactor == 0 then		-- 0 warp will cancel the NAV command
			return false
		end
			
		if DamageLevel[1]<0 and WarpFactor > .2 then
			telePrint("WARP ENGINES ARE DAMAGED.  MAXIMUM SPEED = WARP 0.2")
			WarpFactor = nil
		elseif WarpFactor<0 or WarpFactor>8 then
			telePrint("   CHIEF ENGINEER SCOTT REPORTS 'THE ENGINES WON'T TAKE WARP "..WarpFactor.." !")
			WarpFactor = nil
		end
	end
	
	NoOfSteps = math.floor(WarpFactor*8+.5)	-- Energy consumed by warp (formerly N) = Number of steps of movement
	if EnergyLevel < NoOfSteps then
		telePrint("ENGINEERING REPORTS   'INSUFFICIENT ENERGY AVAILABLE")
		telePrint("                       FOR MANEUVERING AT WARP "..WarpFactor.." !'")
		
		-- it's possible to deviate energy from shields to warp
		if ShieldLevel >= (NoOfSteps - EnergyLevel) and DamageLevel[7]>=0 then
			telePrint("DEFLECTOR CONTROL ROOM ACKNOWLEDGES ShieldLevel UNITS OF ENERGY")
			telePrint("                         PRESENTLY DEPLOYED TO SHIELDS.")
		end
		return false
	end
	
	
	-- 2) Klingons move (before Enterprise moves)
	
	--2580 REM KLINGONS MOVE/FIRE ON MOVING STARSHIP . . .
	for i=1,K3 do
		if K[i][3] > 0 then
			AddElementInQuadrantString('   ',K[i][1],K[i][2])	-- delete Klingon ship in current position
			local R1,R2 = FindEmptyPlaceinQuadrant()			-- find a new random position for the ship 
			K[i][1]=R1
			K[i][2]=R2
			AddElementInQuadrantString('+K+',R1,R2)				-- put ship in the new position (would be better if it moves close to previous pos)
		end
	end
	
	-- 3) Klingons fire (before Enterprise moves)
	if KlingonsAttack() then
		-- if KlingonsAttack returns true, the Enterprise has been destroyed
		-- GameOver is set to true, so when CourseControl function returns, the game will end
		return false
	end
	
	-- 4) Now check if the movement will repair some Ship systems
	-- since this happens after Klingon attack, some device just broken by the klingon can get repaired, nonsense
	local RepairFactor = WarpFactor
	if WarpFactor>=1 then
		RepairFactor=1
	end
	
	devIndex = 0
	for i=1,8 do
		if DamageLevel[i]<0 then
			DamageLevel[i]=DamageLevel[i]+RepairFactor			-- moving by 1 quadrant repair by 1
			if DamageLevel[i]>-0.1 and DamageLevel[i] < 0 then	-- if it's almost 0, goes back to -0.1
				DamageLevel[i] =-.1
			elseif DamageLevel[i]>=0 then
				telePrint("DAMAGE CONTROL REPORT: '"..deviceName(i).." REPAIR COMPLETED.'")
			end
		end
	end
	
	-- 5) Now check if a random system is broken or repaired
	-- In 20% of the cases, select a random system and either repair it or break it
	-- wouldn't it be better to do it in the previous loop?
	if math.random()<=.2 then
		devIndex=FNR(1)
		if math.random()>=.6 then
			-- it does not make sense that a system can have damage > 0
			-- also what's the point of repairing something if it was not broken?
			DamageLevel[devIndex]=DamageLevel[devIndex]+math.random()*3+1
			telePrint("DAMAGE CONTROL REPORT: '"..deviceName(devIndex).." STATE OF REPAIR IMPROVED.'")
		else
			-- it' possible that something that just got repaired, it's broken here, nonsense
			DamageLevel[devIndex]=DamageLevel[devIndex]-(math.random()*5+1)
			telePrint("DAMAGE CONTROL REPORT: '"..deviceName(devIndex).." DAMAGED.'")
		end
	end

	-- 6) Finally the Enterprise can move
	AddElementInQuadrantString('   ',math.floor(S1),math.floor(S2))				-- delete Enterprise from screen
	
	local cindex = math.floor(Course)

	StepX1=C[cindex][1]+(C[cindex+1][1]-C[cindex][1])*(Course-cindex)
	StepX2=C[cindex][2]+(C[cindex+1][2]-C[cindex][2])*(Course-cindex)
	
	X=S1		-- save previous Enterprise position
	Y=S2
	Q4=Q1		-- save previous Enterprise quadrant
	Q5=Q2

	for i=1,NoOfSteps do
		S1=S1+StepX1
		S2=S2+StepX2
		
		-- While inside the quadrant, the Enterprise will move step by step, checking if
		-- it encounters an obstacle, or tries to cross the border of the quadrant
		-- once the border is crossed, all the rest of the movement will be performed by ExceededQuadrantLimits
		-- at that point, obstacles dont matter any more, all the movement will be done in one big step
		-- This makes sense if we consider inside quadrant Impulse Speed and once crossed, Warp speed
		
		if S1<1 or S1>8 or S2<1 or S2>8 then
			--# EXCEEDED QUADRANT LIMITS
			-- This will check if Enterprise has moved to another quadrant, and will make the rest of the movements
			-- It's possible that the ship tried to cross border of quadrant and it stopped
			-- so quadrant has not changed, in this case the next function will return false
			
			return ExceededQuadrantLimits()
		end
		
		-- still in the same quadrant, so it will continue moving
		if SearchStringinQuadrant('   ',S1,S2) then
			-- ok
		else 
			-- if space is NOT empty, go back to previous position and exit loop
			S1=math.floor(S1-StepX1)
			S2=math.floor(S2-StepX2)
			telePrint("WARP ENGINES SHUT DOWN AT")
			telePrint("SECTOR S1 , S2 DUE TO BAD NAVIGATION.")
			break
		end
	end
	
	-- not sure why math.floor it's necessary again
	S1=math.floor(S1)
	S2=math.floor(S2)
	
	EndOfMovementInQuadrant()
	return false   -- still in the same quadrant
end


-- ************************************************************
-- **    start of the program                                **
-- ************************************************************

math.randomseed(os.time())

-- COMMENT/UNCOMMENT this if you want
--askForInstructions()

-- the original 1978 BASIC code does not have instructions
-- there is another BASIC program. I copied it here. If you don't want it, you
-- can simply comment the line above
print [[



                                    ,------*------,
                    ,-------------   '---  ------'
                     '-------- --'      / /
                         ,---' '-------/ /--,
                          '----------------'
                    THE USS ENTERPRISE --- NCC-1701


]]


SomeSpaces ="                         "

-- Array G is the Galaxy, contains elements of 3 numbers like 215 -> 2 klingons 1 base 5 stars

Galaxy = {{},{},{},{},{},{},{},{}} -- DIM G(8,8) in the original code
K = {{},{},{}} -- DIM K(3,3) - Klingons

ExploredSpace = {{},{},{},{},{},{},{},{}} -- DIM Z(8,8)	# A copy of Galaxy, but only with quadrants explored/scanned
DamageLevel = {}

Stardate = 2000+math.random(0,1900) -- Stardate is a number between 2000 and 3900 (was T)
T0 = Stardate
MaxNumOfDays = 25+math.random(0,10)
ShipDocked = false

-- Next 3 values can change difficulty level
MaxEnergyLevel = 3000	-- Enterprise max energy
MaxTorpedoes=10
KlingonBaseEnergy=200	-- Klingon ship energy range from 0.5x to 2x this value

EnergyLevel = MaxEnergyLevel
PhotonTorpedoes=MaxTorpedoes
ShieldLevel=0			-- Shield level of the Enterprise (was S)
TotalStarbases=0		-- This was set to 2, but the code never adds the 2 additional bases so I changed to 0
TotalKlingonShips=0
ShipCondition = ''
Ss=""
Ss0=" IS"


-- REM INITIALIZE ENTERPRIZE'S POSITION

Q1=FNR(1)		-- There are 2 functions in the original BASIC code. I kept the original
Q2=FNR(1)		-- name for this one (FNR), that generates a random number between 1 and 8

S1=FNR(1)		-- Coordinates of Enterprise in current sector
S2=FNR(1)

-- array C (CourseDelta) is the delta to Y and X determined by the course - last element (9) should be useless
C = {{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1},{1,0},{1,1},{0,1}}

for i=1,8 do
	-- Set Damage level to 0 for all systems
	DamageLevel[i]=0
end

-- REM SETUP WHAT EXISTS IN GALAXY . . .
K3 = 0 -- KLINGONS in quadrant
B3 = 0 -- STARBASES in quadrant
S3 = 0 -- stars in quadrant

B4,B5 = 1,1 -- B4, B5 = coordinates of the starbase, if any

for i=1,8 do
	for j=1,8 do
		K3=0
		ExploredSpace[i][j]=0		-- Galaxy explored by the player, initially all quadrants are 0
		R1=math.random()
		if R1>.98 then
			K3=3
			TotalKlingonShips=TotalKlingonShips+3
		elseif R1>.95 then
			K3=2
			TotalKlingonShips=TotalKlingonShips+2
		elseif R1>.80 then
			K3=1
			TotalKlingonShips=TotalKlingonShips+1
		end

		B3=0
		if math.random()>.96 then
			B3=1
			TotalStarbases=TotalStarbases+1
		end
		Galaxy[i][j]=K3*100+B3*10+FNR(1)
	end
end

if TotalKlingonShips>MaxNumOfDays then
	MaxNumOfDays=TotalKlingonShips+1
end

-- Q1, Q2 are random coordinates
if TotalStarbases == 0 then
	-- if bases are 0, add a base in a random quadrant, this makes sense
	TotalStarbases=1
	Galaxy[Q1][Q2]=Galaxy[Q1][Q2]+10
	Q1=FNR(1)
	Q2=FNR(1)
end

InitialKlingonShips=TotalKlingonShips

if (TotalStarbases>1) then
	Ss="S"
	Ss0=" ARE"
end

-- The function telePrint is just a 'print' with a small delay to slow down text scrolling.

telePrint("YOUR ORDERS ARE AS FOLLOWS:")
telePrint(" DESTROY THE "..TotalKlingonShips.." KLINGON WARSHIPS WHICH HAVE INVADED")
telePrint(" THE GALAXY BEFORE THEY CAN ATTACK FEDERATION HEADQUARTERS")
telePrint(" ON STARDATE "..(T0+MaxNumOfDays)..". THIS GIVES YOU "..MaxNumOfDays.." DAYS.")
telePrint(" THERE"..Ss0.." "..TotalStarbases.." STARBASE"..Ss.." IN THE GALAXY FOR RESUPPLYING YOUR SHIP.")
telePrint(" \n\n\n")
smallDelay(1)


--#===============================================================
--# This was line 1320

GameOver = false

Q4 = 0 --	# this will contain the coordinate of previous quadrant
Q5 = 0 --	# useful to see if a movement produced a change of quadrant


-- main loop, it goes ahead until the enterprise is destroyed or the time is over or klingons are defeated
while (not GameOver) do
	
	K3=0
	B3=0
	S3=0
 
	ExploredSpace[Q1][Q2]=Galaxy[Q1][Q2]	-- this quadrant has been discovered

	-- Not sure when it can happen that Q1 and Q2 are outside borders
	if Q1<1 or Q1>8 or Q1<1 or Q2>8 then
		die("Should not happen that we are outside borders")
	end
 
	QuadrantName = GetQuadrantName(Q1,Q2)
	telePrint()
	
	if (T0 == Stardate) then
		telePrint("YOUR MISSION BEGINS WITH YOUR STARSHIP LOCATED")
		telePrint("IN THE GALACTIC QUADRANT "..QuadrantName)
	else
		telePrint("NOW ENTERING '"..QuadrantName.."' QUADRANT . . .")
	end

	telePrint()
	K3=math.floor(Galaxy[Q1][Q2]*.01)
	B3=math.floor(Galaxy[Q1][Q2]*.1)-10*K3
	S3=Galaxy[Q1][Q2]-100*K3-10*B3

	if K3>0 then
		telePrint("COMBAT AREA      CONDITION RED")
		if ShieldLevel<=200 then
			telePrint("   SHIELDS DANGEROUSLY LOW")
		end
		smallDelay(1)
	end
	
	--reset klingons power
	for i=1,3 do
		K[i][1]=0
		K[i][2]=0
		K[i][3]=0
	end
	
	QuadString = string.rep(" ",192)
	
	-- POSITION ENTERPRISE IN QUADRANT, THEN PLACE "K3" KLINGONS, &
	-- "B3" STARBASES, & "S3" STARS ELSEWHERE.

	AddElementInQuadrantString('<*>',S1,S2)

	-- IF Klingons are present
	if K3>0 then
		-- for each klingon ship, find a place in the quadrant
		for i=1,K3 do
			R1,R2 = FindEmptyPlaceinQuadrant()
			
			AddElementInQuadrantString('+K+',R1,R2)
			
			K[i][1]=R1	-- klingon ship coordinates
			K[i][2]=R2
			K[i][3]=KlingonBaseEnergy*(0.5+math.random())  -- energy of the klingon ship
		end
	end

	-- IF a base is present
	if B3>0 then
		R1,R2 = FindEmptyPlaceinQuadrant()
		B4=R1
		B5=R2
		AddElementInQuadrantString('>!<',R1,R2)
	end

	-- For each star
	for i=1,S3 do
		R1,R2 = FindEmptyPlaceinQuadrant()
		AddElementInQuadrantString(' * ',R1,R2)
	end
	
	-- this is line 1980
	checkIfDocked()
	ShortRangeSensorScan()

	-- This is line-1990 - MAIN LOOP for EXECUTING COMMANDS
	-- Exit when the ship enters a new quadrant
	
	local ReachedNewQuadrant = false

	while (not ReachedNewQuadrant and not GameOver) do
		
		--of there is very low total energy or shield are damaged, the game is over
		if EnergyLevel+ShieldLevel<=10 or (EnergyLevel<=10 and DamageLevel[7]<0) then
			telePrint("\n** FATAL ERROR **   YOU'VE JUST STRANDED YOUR SHIP IN SPACE")
			telePrint("YOU HAVE INSUFFICIENT MANEUVERING ENERGY, AND SHIELD CONTROL")
			telePrint("IS PRESENTLY INCAPABLE OF CROSS-CIRCUITING TO ENGINE ROOM!!")
			smallDelay(2)
			GameOver = true
			break
		end

		io.write("COMMAND? ")

		Command = string.upper(io.read())

		-- AllCommands="NAV SRS LRS PHA TOR SHE DAM COM XXX"
		-- Now it's a series of IF, before it was a ON I GOTO

		if Command == 'NAV' then ReachedNewQuadrant = CourseControl()	-- NAV is the only command that will consume time/turns
		elseif Command == 'SRS' then ShortRangeSensorScan()
		elseif Command == 'LRS' then LongRangeSensorScan()
		elseif Command == 'PHA' then FirePhasers()
		elseif Command == 'TOR' then FirePhotonTorpedoes()
		elseif Command == 'SHE' then ShieldControl()
		elseif Command == 'DAM' then DamageControl()
		elseif Command == 'COM' then LibraryComputer()
		elseif Command == 'XXX' or Command == 'EXIT' then GameOver = true
		else
			print("ENTER ONE OF THE FOLLOWING:")
			print("  NAV  (TO SET COURSE)")
			print("  SRS  (FOR SHORT RANGE SENSOR SCAN)")
			print("  LRS  (FOR LONG RANGE SENSOR SCAN)")
			print("  PHA  (TO FIRE PHASERS)")
			print("  TOR  (TO FIRE PHOTON TORPEDOES)")
			print("  SHE  (TO RAISE OR LOWER SHIELDS)")
			print("  DAM  (FOR DAMAGE CONTROL REPORTS)")
			print("  COM  (TO CALL ON LIBRARY-COMPUTER)")
			print("  XXX  (TO RESIGN YOUR COMMAND)\n")
		end
	end  -- keep asking new commands until the ship reaches a new quadrant
end
-- end of the main loop


-- 6210 REM END OF GAME
telePrint()

-- this was line 6270
if TotalKlingonShips>0 then
	telePrint("THERE WERE "..TotalKlingonShips.." KLINGON BATTLE CRUISERS LEFT AT")
	telePrint("THE END OF YOUR MISSION, IN STARDATE "..roundTo(Stardate,1))
end
	
-- The following block has been commented, if you want to play again, just
-- relaunch the game.

-- if TotalStarbases > 0 then
	-- telePrint("THE FEDERATION IS IN NEED OF A NEW STARSHIP COMMANDER")
	-- telePrint("FOR A SIMILAR MISSION -- IF THERE IS A VOLUNTEER,")
	-- telePrint("LET HIM STEP FORWARD AND ENTER 'AYE'? ")
	-- Command = io.read()
	-- if (Command == "AYE") then

	-- end
-- end

telePrint("\n\nThank you for playing this game!")
telePrint("\n\nLUA conversion by Emanuele Bolognesi - http://emabolo.com\n")

os.exit()
