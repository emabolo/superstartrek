--[[
***        **** STAR TREK ****        
*** SIMULATION OF A MISSION OF THE STARSHIP ENTERPRISE,
*** AS SEEN ON THE STAR TREK TV SHOW.
***
*** ORIGINAL PROGRAM BY MIKE MAYFIELD, MODIFIED VERSION
*** PUBLISHED IN DEC'S "101 BASIC GAMES", BY DAVE AHL.
*** MODIFICATIONS TO THE LATTER (PLUS DEBUGGING) BY BOB
*** LEEDOM - APRIL & DECEMBER 1974,
***
*************************************************************
*** LUA Conversion by Emanuele Bolognesi - v1.0 Oct 2020
***
***
*** My blog: http://emabolo.com/
*** Github:  https://github.com/emabolo
***
*************************************************************
--]]

-- this version uses a global map 64x64 to store all the objects
-- present in the game. This the position and attributes of ships,
-- starbases and stars don't reset every time you exit the sector
-- the following functions are useful to manage the global map
-- and the difference between local and global coordinates

function localToGlobalCoord(sx,sy,x,y)
	-- only integer numbers should arrive here
	local gx = (sx-1) * 8 +x
	local gy = (sy-1) * 8 +y
	return gx,gy
end

function roundTo(val,precision)
	precision = 10^precision
	val = math.floor(val*precision)
	return val/precision
end

function sectorFromGlobalCx(gx,gy)
	if gx<0.5 or gx>64.5 or gy<0.5 or gy>64.5 then return 0,0 end	-- invalid coordinates
	local sx = math.floor((gx-0.5)/8+1)
	local sy = math.floor((gy-0.5)/8+1)
	return sx,sy
end

function sectorNumberFromGlobalCx(gx,gy)
	local sx,sy = sectorFromGlobalCx(gx,gy)
	if sx == 0 or sy == 0 then return 0 end
	return (sx-1)*8+sy
end

function globalToLocalCoord(gx,gy)
	local sx,sy = sectorFromGlobalCx(gx,gy)
	local lx = math.floor(gx+0.5) % 8
	local ly = math.floor(gy+0.5) % 8
	if lx == 0 then lx = 8 end
	if ly == 0 then ly = 8 end
	return lx,ly,sx,sy
end

function MapCell(gx,gy)
	local x =  math.floor(gx+0.5)
	local y =  math.floor(gy+0.5)
	return GlobalMap[x][y]
end

function UpdateMapCell(gx,gy,element)
	local x =  math.floor(gx+0.5)
	local y =  math.floor(gy+0.5)
	GlobalMap[x][y] = element
end

function foundStarbaseInCell(x,y)
	if MapCell(x,y)>9 and MapCell(x,y)<100 then return true
	else return false end
end

function foundKlingonInCell(x,y)
	if MapCell(x,y)>99 and MapCell(x,y)<1000 then return true
	else return false end
end

function foundStarInCell(x,y)
	if MapCell(x,y)>999 then return true
	else return false end
end

function foundEnterpriseInCell(x,y)
	if MapCell(x,y) == 1 then return true
	else return false end
end

function mapCellIsNotEmpty(x,y)
	if MapCell(x,y) > 0 then return true
	else return false end
end

function mapCellIsEmpty(x,y)
	if MapCell(x,y) == 0 then return true
	else return false end
end

-- place the object in a random free location of the sector specified
function PlaceElementInSector(sectorx,sectory,element)
	local x,y
	repeat 
		local rx = math.random(1,8)
		local ry = math.random(1,8)
		x,y = localToGlobalCoord(sectorx,sectory,rx,ry)
	until GlobalMap[x][y] == 0
	GlobalMap[x][y] = element
	return x,y
end

-- trasform the value into an element on the screen
function PrintElementOfMap(x,y)
	local elem = '   '
	if foundEnterpriseInCell(x,y) then elem = '<e>'
	elseif foundStarbaseInCell(x,y) then elem = '>!<'
	elseif foundKlingonInCell(x,y) then elem = '+K+'
	elseif foundStarInCell(x,y) then elem=' * '
	end
	return elem
end

-- print full map and save it to file for debug
function PrintFullMap()
	mapfile = io.open("startrek.map", "w")
	print(' '..string.rep(' -',72))
	for i=1,64 do
		io.write('|')
		for j=1,64 do
			mapfile:write(GlobalMap[i][j]..',')
			local elem = PrintElementOfMap(i,j)
			io.write(' '..elem:sub(2,2))
			if j % 8 == 0 then io.write(' |') end
		end
		print()
		mapfile:write("\n")
		if i % 8 == 0 then print(' '..string.rep(' -',72)) end
	end
	EnergyLevel = 3000
	for i=1,8 do
		if DamageLevel[i]<0 then DamageLevel[i]=0 end
	end
	mapfile:close()
	return true
end

-- Perform a scan of current sector and pupulates B3,K3,S3
function CurrentSectorScan(sx,sy)
	local k3,b3,s3 = 0,0,0
	for i=(sx-1)*8+1,sx*8 do
		for j=(sy-1)*8+1,sy*8 do
			local elem = GlobalMap[i][j]
			if foundStarbaseInCell(i,j) then
				b3=b3+1
				B4,B5,sxx,syy = globalToLocalCoord(i,j)
				CurrentStarbase = elem-10
			elseif foundKlingonInCell(i,j) then
				k3=k3+1
				table.insert(EnemyShips,elem-100)	-- add the ship data to the current sector enemies array
			elseif foundStarInCell(i,j) then
				s3=s3+1
			end
		end
	end
	return k3,b3,s3
end

-- returns the string KBS (Klingons+Stabases+Stars) for selected sector
function SectorRecord(sx,sy)
	local k3,b3,s3 = 0,0,0
	for i=(sx-1)*8+1,sx*8 do
		for j=(sy-1)*8+1,sy*8 do
			local elem = GlobalMap[i][j]
			if foundStarbaseInCell(i,j) then
				b3=b3+1
			elseif foundKlingonInCell(i,j) then
				k3=k3+1
			elseif foundStarInCell(i,j) then
				s3=s3+1
			end
		end
	end
	return k3*100+b3*10+s3
end

-- generates the screen of the current sector
function GenerateSectorScreen(sx,sy)
	local screen = ''
	for i=1,8 do
		for j=1,8 do
			local x,y = localToGlobalCoord(sx,sy,i,j)
			elem = PrintElementOfMap(x,y)
			screen = screen .. elem
		end
	end
	return screen
end

-- Other Utilities =============================================

function FNR(r)
	return math.random(1,8)	-- replaced with this simple rand, parameter r is useless
end

function smallDelay(sec)
	sec = sec or 0.15
	if DisableTeleprint then return 0 end
	local t0 = os.clock()
	while os.clock() - t0 <= sec do end
end

function telePrint(str,delay)
	str = str or ''
	delay = delay or 0.10
	print(str)
	smallDelay(delay)
end

function die (msg)	-- for debug
	msg = msg or 'I died well'
	
 	io.stderr:write(msg,'\n')
 	os.exit(1)
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

\DAM\ COMMAND = DAMAGE CONTROL REPORT
     GIVES THE STATE OF REPAIR OF ALL DEVICES.  WHERE A NEGATIVE
     'STATE OF REPAIR' SHOWS THAT THE DEVICE IS TEMPORARILY
     DAMAGED.

\COM\ COMMAND = LIBRARY-COMPUTER
     THE LIBRARY-COMPUTER CONTAINS SIX OPTIONS:
     OPTION 0 = CUMULATIVE GALACTIC RECORD ** SHORTCUT: \MAP\
        THIS OPTION SHOWES COMPUTER MEMORY OF THE RESULTS OF ALL
        PREVIOUS SHORT AND LONG RANGE SENSOR SCANS
     OPTION 1 = STATUS REPORT ** SHORTCUT: \STA\
        THIS OPTION SHOWS THE NUMBER OF KLINGONS, STARDATES,
        AND STARBASES REMAINING IN THE GAME.
     OPTION 2 = PHOTON TORPEDO DATA ** SHORTCUT: \POS\
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

function PressEnterToContinue()
	print ("<Hit Return to continue>")
	io.read()
end

-- Names Utilities ===========================================================

function StarTrekSectorNames()
	local names = {'Algira','Almatha','Antares','Archanis','Argelius','Argosian','Argus','Bajor',
	'Beloti','Bolian','Cabral','Cygnus','Dalmine','Delta Vega','Dorvan','Epsilon IX',
	'Ficus','Galloway','Gamma 7','Gamma Hydra','Gamma Trianguli','Gand','Gariman','Genesis',
	'Glessene','Glintara','Grewler','Hekaras','Hyralan','Igo','Ipai','Jaradan',
	"K'Rebeca",'Kalandra','Kaleb','Kandari','Kavis Alpha',
	'Kepla','Lagana',"Lan'Tuana",'Lantaru','Marrab','Maxia','Mekorda','Mempa',
	'Moab','Mutara','Omega','Oneamisu','Onias','Orion','Podaris','Qiris',
	'Rakhari','Rhomboid Dronegar','Rukani','Rutharian','Selcundi Drema','Shepard','Sigma Antares',
	'Silarian','Takara','Tandar','Tholian','Typhon','Vaskan','Vay','Vega-Omicron','Woden','Zaphod','Zed Lapis'}

	for i = #names, 2, -1 do
		local j = math.random(i)
		names[i], names[j] = names[j], names[i]
	end
end

function GetQuadrantName(Z4,Z5,RegionNameOnly)

	RegionNameOnly = RegionNameOnly or false
	
	-- Real sector names are number in TOS
	
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
	local enterpriseSector = sectorNumberFromGlobalCx(EntX,EntY)
	
	for i=EntX-1,EntX+1 do
		for j=EntY-1,EntY+1 do
			local checkingSector = sectorNumberFromGlobalCx(i,j)	-- 0 if outside borders

			if enterpriseSector == checkingSector and foundStarbaseInCell(i,j) then
				ShipDocked=true
				ShipCondition="DOCKED"
				EnergyLevel=MaxEnergyLevel
				PhotonTorpedoes=MaxTorpedoes
				
				if K3 > 0 then
					telePrint("SULU: Sir, we are approaching "..AllStarbases[CurrentStarbase].name..". We are still under attack.")
				else
					telePrint("\nUHURA: "..AllStarbases[CurrentStarbase].name.." clears us for normal approach, sir.")
					telePrint("KIRK: Normal approach procedures, Mister Sulu.")
					telePrint("SULU: Approaching Stabase, sir. Shields dropped.")			
				end
				print()
				ShieldLevel=0
				break
			end
		end
	end
	
	ShipCondition = CheckShipStatus()
	return ShipDocked
end

-- Math functions to calculate distance and direction ==================
-- The original code was not using trigonometry

function getAngle(x,y,mCentreX,mCentreY)
    local dx = x - mCentreX
	local dy = -(y - mCentreY)

    local inRads = math.atan2(dy, dx)

    if inRads < 0 then
        inRads = math.abs(inRads)
    else
        inRads = 2 * math.pi - inRads
	end
	
	inRads = inRads - (math.pi/2)
	if inRads<0 then inRads=(math.pi*2+inRads) end	-- rotate
	return (4*inRads)/math.pi +1	-- convert in course
end

function CalcDistanceOfShip(x1,y1,x2,y2)
	local DX = x1-x2
	local DY = y1-y2
	return math.sqrt(DX^2 + DY^2)
end


function PrintDistanceAndDirection(x1,y1,x2,y2)
	
	local Direction = getAngle(x1,y1,x2,y2)
	telePrint(" Direction = "..roundTo(Direction,2))
	
	local Distance = CalcDistanceOfShip(x1,y1,x2,y2)
	telePrint(" Distance = ".. roundTo(Distance,2))
	
	return Distance
end


-- Main Commands of the Game =======================================

function ShortRangeSensorScan()
	-- SHORT RANGE SENSOR SCAN & STARTUP SUBROUTINE
	-- line 6720 was here
	if DamageLevel[2]<0 then
		telePrint("\n** SPOCK: Sensors are inoperative. Without them, we are blind. **\n")
		return
	end
	
	QuadString = GenerateSectorScreen(Q1,Q2)
	
	telePrint("  --- --- --- --- --- --- --- --- ")

	for i=1,8 do
		local line = i-1
		io.write('| ')
		for j=line*24+1,line*24+22,3 do
			io.write(string.sub(QuadString,j,j+2)..' ')
		end
		io.write('|')
		if i == 1 then telePrint("        STARDATE           "..roundTo(Stardate,1)) end
		if i == 2 then telePrint("        CONDITION          "..ShipCondition) end
		if i == 3 then telePrint("        SECTOR             "..Q1.." , "..Q2) end
		if i == 4 then telePrint("        COORDINATES        "..S1.." , "..S2) end
		if i == 5 then telePrint("        PHOTON TORPEDOES   "..math.floor(PhotonTorpedoes)) end
		if i == 6 then telePrint("        TOTAL ENERGY       "..math.floor(EnergyLevel+ShieldLevel)) end
		if i == 7 then telePrint("        SHIELDS            "..math.floor(ShieldLevel)) end
		if i == 8 then telePrint("        KLINGONS REMAINING "..math.floor(TotalKlingonShips)) end
	end
	telePrint("  --- --- --- --- --- --- --- --- ")
	return true
end

function LongRangeSensorScan()
	--# it was line 4000
	telePrint("KIRK: Long range sensor scan, Mister Sulu.")
	local N = {}
	if DamageLevel[3]<0 then
		telePrint("\n** SPOCK: Captain, some equipment is out of order. Long range sensors are inoperative. **\n")
		return
	end
	
	telePrint("SULU: Sectors surrounding "..Q1..','..Q2.." charted and examined:")
	-- Sectors one through twenty five charted and examined
	Header="-------------------"
	telePrint(Header)
	
	for i=Q1-1,Q1+1 do
		io.write(": ")
		for j=Q2-1,Q2+1 do
			if i>0 and i<9 and j>0 and j<9 then
				if ExploredSpace[i][j] == 0 then
					ExploredSpace[i][j]=SectorRecord(i,j)
				end
				local str = tostring(ExploredSpace[i][j]+1000)
				io.write(string.sub(str,2,4))
			else
				io.write("***")
			end
			io.write(' : ')
		end
		telePrint()
		telePrint(Header)
	end
	return true
end


function ShieldControl()
	telePrint("KIRK: Deflectors control.")
	-- 5520 REM SHIELD CONTROL - 5530
	if DamageLevel[7]<0 then
		telePrint("SULU: Sir, I have readings that deflectors are inoperative. The controls are frozen.") -- S03E11 Wink Of An Eye
		return false
	end
	
	telePrint("CHEKOV: Sir, total power at "..(EnergyLevel+ShieldLevel).." units.")
	io.write("CHEKOV: How many shall I use? ")
	local Units = tonumber(io.read())
	
	if Units == nil then
		telePrint("CHEKOV: Sorry, Captain. I can't understand it.")
	elseif Units<0 or ShieldLevel == Units then
		telePrint("<SHIELDS UNCHANGED>")
	elseif Units > EnergyLevel+ShieldLevel then
		telePrint("SCOTT: Ach! You're joking. We can't do it.")
		-- SCOTT: Giving them all we got.
		--SCOTT: Captain, if we try, we'll overload our own engines
		telePrint("<SHIELDS UNCHANGED>")
	else
		EnergyLevel=EnergyLevel+ShieldLevel-Units
		ShieldLevel=Units
		
		if Units == 0 then
			telePrint("CHEKOV: Deflector shields down, sir.")
		else
			telePrint("CHEKOV: Deflectors up, sir.  Shields at "..ShieldLevel.." units.")
		end
	end
	
	return ShieldLevel
end


function DamageControl()
	-- 5680 REM DAMAGE CONTROL - 5690
	telePrint("KIRK: Damage Control, report.")
	-- SCOTT: We need some repairs, sir, but the ship is intact.

	local TimeToRepair=0
	for I=1,8 do
		if DamageLevel[I]<0 then
			TimeToRepair=TimeToRepair+.1	-- 1/10 day for each damaged system - regardless of the Damage level
		end
	end
	if TimeToRepair==0 then
		telePrint("SPOCK: All systems report normal, Captain. No ascertainable damage.")
		return false
	end

	telePrint("UHURA: Damage report coming in, Captain. Situation under control. Minor damage, stations three, seven, and nineteen.")
	telePrint("MCCOY: Sickbay reports five minor injuries, all being treated.")

	if DamageLevel[6]<0 then
		telePrint("SPOCK: Detailed Damage control report not available, Captain")
	else
		telePrint("\nDEVICE             STATE OF REPAIR")
		for index=1,8 do
			local tabs = 27
			if DamageLevel[index]<0 then tabs=26 end  -- for formatting
			telePrint(formatWithSpaces(DeviceNames[index],tabs) .. roundTo(DamageLevel[index],2) )
		end
	end

	if ShipDocked then
		TimeToRepair=roundTo(TimeToRepair+math.random()*0.5,2)	-- add a random factor and round to 2 decimals
		
		if TimeToRepair >0.9 then TimeToRepair=0.9 end -- time to repair cannot be more than 1 day
		
		telePrint("\nSCOTT: Sir, the damage control party just beamed to the Enterprise.")
		telePrint("SCOTT: Estimate time to repair: "..TimeToRepair.." stardates.")
		io.write("SCOTT: Permission to proceed with repairs, sir (Y/N) ? ")
		local YesNo = io.read()
		if YesNo == "Y" then
			telePrint("KIRK: Permission granted.")
			for i=1,8 do
				if DamageLevel[i]<0 then DamageLevel[i]=0 end
			end
			Stardate=Stardate+TimeToRepair+0.1;		-- never trust engineers!
			telePrint("SPOCK: All systems operational, Captain.")
		else
			telePrint("KIRK: Request denied.")
			--telePrint("SCOTT: Several systems out, sir. Operating on emergency backup.") 
		end

	end
	return true
end

function Communication()
	telePrint("KIRK: This is Captain James T. Kirk, commanding the USS Enterprise. Please identify yourself.")
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
	if DamageLevel[8]<0 then
		telePrint("SPOCK: Library computer is inoperative, sir.")
		return false
	end
	telePrint("       COMPUTER RECORD OF GALAXY FOR SECTOR "..Q1..','..Q2.."\n")
	PrintComputerRecord(false)
	return true
end

function StatusReport()
	telePrint("KIRK: Mister Spock. Status.")
	if TotalKlingonShips>1 then
		telePrint("SPOCK: Captain, there are "..TotalKlingonShips.." Klingon ships left.")
	else
		telePrint("SPOCK: Captain, there is only one Klingon ship left.")
	end
	telePrint("Our mission must be completed in "..roundTo(T0+MaxNumOfDays-Stardate,1).." stardates.")
	
	if B3>0 then
		telePrint("UHURA: Captain, "..AllStarbases[CurrentStarbase].name.." is within range.")
	elseif TotalStarbases == 1 then
		telePrint("SPOCK: Captain, there is only one starbase left. We must protect it.")
	elseif TotalStarbases>1 then
		telePrint("SPOCK: Captain, "..TotalStarbases.." Federation starbases can assist us.")
	else
		telePrint("SPOCK: There are no starbases left. ")
	end
	
	telePrint("CHEKOV: Shields level is "..ShieldLevel..", with "..EnergyLevel.." units of energy left." )
	
	if K3>0 then
		if B3>0 then
			telePrint("UHURA: I'm picking up a subspace distress call. It's from "..AllStarbases[CurrentStarbase].name..".")
		else
			telePrint("SULU: Captain, we are under attack!")
		end
	end
	--DamageControl()
	return true
end


function PhotonTorpedoData()
	if DamageLevel[8]<0 then
		telePrint("SPOCK: Computer is inoperative, sir.")
		return false
	end

	local shiporships = 'ships'
	if K3 == 1 then shiporships = 'ship' end
	telePrint("KIRK: What is the position of the Klingon "..shiporships.."?")
	if K3<=0 then
		telePrint("SULU: No signs of hostile activities in this area.")
		return true
	end

--SPOCK: Impossible to calculate. We lack data to analyse. Our instruments appear to be functioning
--normally, but what they tell us makes no sense. Our records are clear up to the point at which we left our galaxy.

	telePrint("SPOCK: Captain, I have the calculations.")
	telePrint("From Enterprise to Klingon "..shiporships..":")

	for i,k in ipairs(EnemyShips) do
		if AllKlingons[k].energy > 0 then
			PrintDistanceAndDirection(AllKlingons[k].x,AllKlingons[k].y,EntX,EntY)
		end
	end
	
	return true
end


function DistanceCalculator()
	telePrint("KIRK: Computer, compute course and distance.")
	--telePrint("COMPUTER: Current Sector "..Q1..","..Q2..". Coordinates: "..S1..","..S2)
	io.write("COMPUTER: Starting co-ordinates (row,col)? ")

	local Coord = io.read()
	local inp1, inp2 = Coord:match("(%d+),(%d+)")
	local y1, x1 = tonumber(inp1), tonumber(inp2)
	
	io.write("COMPUTER: Final co-ordinates (row,col)? ")
	Coord = io.read()
	inp1, inp2 = Coord:match("(%d+),(%d+)")
	local y2, x2 = tonumber(inp1), tonumber(inp2)
	
	if y1 == nil or x1 == nil or x2 == nil or y2 == nil then
		telePrint("COMPUTER: Unable to comply.")
		return false
	end
	PrintDistanceAndDirection(y2,x2,y1,x1)
	return true
end

function StarbaseNavData()
	telePrint("KIRK: Lay in a course for the starbase, Mister Sulu.")
	if B3 > 0 then
		telePrint("SULU: Aye, aye, sir.")
		PrintDistanceAndDirection(B4,B5,S1,S2)
	else
		telePrint("SULU: Captain, no signs of starbases in this area.")
	end
	return true
end

function LibraryComputer()
	if DamageLevel[8]<0 then
		telePrint("SPOCK: Library computer is inoperative, sir.")
		return false
	end
	local ComputerDone = false
	while not ComputerDone do
		io.write("COMPUTER: Library computer ready. Command? ")
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
	telePrint("\n** The Enterprise has been destroyed. The Federation is lost. **")
	smallDelay(2)
	return
end

function KlingonsDefeated()
	telePrint("\nSPOCK: Congratulations, Captain! The last Klingon warship has been defeated.")
	telePrint("UHURA: Captain, Starfleet Control is calling the Enterprise.")
	telePrint("KIRK: Open a channel, Uhura.",2)
	telePrint("UHURA: Frequency open, sir.",2)
	telePrint("KIRK: Starfleet Control, this is the Enterprise. Captain Kirk speaking.",2)
	telePrint("FEDERATION: Thank you, Captain! You saved the Federation!",2)
	telePrint("FEDERATION: You and your crew will receive a Medal of Honour. Come back here to celebrate!")
	PressEnterToContinue()
	telePrint("\nSPOCK: Captain, our efficiency rating is " .. math.floor(1000*(InitialKlingonShips/(Stardate-T0))^2))
	telePrint("We can do better next time.")
	return
end

function TimeExpired()
	telePrint("\nSPOCK: It's too late, Captain. We failed our mission",2)
	--telePrint("Captain's Log, stardate "..roundTo(Stardate,1)..". Entry made by Second Officer Spock.")
	telePrint("It is stardate "..roundTo(Stardate,1).." and there are "..TotalKlingonShips.." Klingons ships left.",2)
	telePrint("The Federation has been conquered.")
end

-- Combat functions ===============================================

--# this was line-6000
function KlingonsAttack()
	if K3<=0 then
		return false
	end
	
	-- "KLINGON [on viewscreen]: Enterprise, prepare to be boarded or destroyed."

	if ShipDocked then
		telePrint("SPOCK: Klingons are firing, but the Enterprise is protected by the Starbase shields.")
		return false
	end
	print()
	telePrint("<Klingons turn>")
	for i,k in ipairs(EnemyShips) do
		local KlingonEnergy = AllKlingons[k].energy
		local KlingonName = AllKlingons[k].name
		
		if KlingonEnergy> 0 then
			print()
			local kx,ky,ksx,ksy = globalToLocalCoord(AllKlingons[k].x,AllKlingons[k].y)
			
			telePrint("SULU: Klingon ship at " ..kx..","..ky.." is firing, sir.")
			local Distance = CalcDistanceOfShip(AllKlingons[k].x,AllKlingons[k].y,EntX,EntY)
			local Hits = math.floor((KlingonEnergy/Distance)*(2+math.random()))+1
			local SysDamaged = 0
			ShieldLevel = ShieldLevel-Hits

			-- this is a strange choice. Energy of the klingon decrease when they fire
			-- but it does not depend on the power used by the phasers
			-- also it decreases a lot, because it can become 1/3 or 1/4 of the previous energy
			-- would be better to use an algorithm similar to the one used for the Enterprise
			AllKlingons[k].energy = KlingonEnergy/(3+math.random())
				
			if ShieldLevel<0 then
				telePrint("** SPOCK: Phaser penetrated the shields, Captain. All decks report damage. **")
				EnterpriseDestroyed()
				GameOver = true
				return true
			end
			telePrint("SPOCK: Phaser hit on port deflector four, Captain. "..Hits.." units of power lost.")

			if Hits>19 and (ShieldLevel==0 or (math.random()<.6 and (Hits/ShieldLevel) > 0.02)) then
				SysDamaged=FNR(1)
				DamageLevel[SysDamaged]= DamageLevel[SysDamaged] - (Hits/ShieldLevel) - (0.5 * math.random())
				telePrint("SCOTT: Sir, "..DeviceNames[SysDamaged].." was damaged by the hit.")
			end
				
			if ShieldLevel>(ShieldLevel+Hits)/2 and SysDamaged == 0 then
				telePrint("SCOTT: Shields still holding, sir.")
			elseif ShieldLevel<20 then
				telePrint("SPOCK: Captain, shields are down. We cannot survive another hit.")
			else
				telePrint("SPOCK: Shields are down to "..ShieldLevel.." units.")
			end
		end
	end

	return false
end

--#4690 REM PHOTON TORPEDO CODE BEGINS HERE
function FirePhotonTorpedoes()
	telePrint("KIRK: Chekov, arm photon torpedoes.")
	
	if PhotonTorpedoes<=0 then
		telePrint("CHEKOV: Captain, we already fired all of them.")
		return false
	end
	if DamageLevel[5]<0 then
		telePrint("SPOCK: Captain, photon torpedoes are inoperative.")
		return false
	end
	
	io.write("CHEKOV: Photon torpedoes ready. Course (1-9)? ")
	local Course = tonumber(io.read())

	if Course == nil then return false end
	if Course == 9 then Course = 1 end

	if Course<0.1 or Course>9 then
		telePrint("CHEKOV: I don't understand, sir.")
		return false
	end

	EnergyLevel=EnergyLevel-2
	PhotonTorpedoes=PhotonTorpedoes-1
	
	local CourseInRadiant = (math.pi/4)*(Course-1)
	
	StepX = math.sin(CourseInRadiant)*(-1)
	StepY = math.cos(CourseInRadiant)
	
	local X,Y = EntX,EntY  -- torpedoes starting coordinates = Enterprise coordinates
	local TorStartingSector = sectorNumberFromGlobalCx(EntX,EntY)

	telePrint("TORPEDO TRACK:")
	--# this is line 4920

	local KlingonDestroyed = 0
	
	while (1) do
		X=X+StepX
		Y=Y+StepY
		local X3,Y3,ssx,ssy = globalToLocalCoord(X,Y)
		
		if sectorNumberFromGlobalCx(X,Y) ~= TorStartingSector then
			-- torpedo is out of borders
			telePrint("CHEKOV: Torpedo missed, sir.")
			smallDelay(2)
			break
		end
		
		telePrint("               "..X3.." , "..Y3,0.5)
		
		if mapCellIsEmpty(X,Y) then
			--# found white space, continue and go to next iteration of loop
	
		elseif foundKlingonInCell(X,Y) then
			--# found a klingon at coordinates X, Y
			telePrint("\n*** SULU: Direct hit amidships. Klingon destroyed. ***",1)
			
			TotalKlingonShips=TotalKlingonShips-1
				
			if TotalKlingonShips <= 0 then
				KlingonsDefeated()
				GameOver = true
				return true
			end
			
			K3=K3-1
				
			ExploredSpace[Q1][Q2]=ExploredSpace[Q1][Q2]-100	-- update visited sectors
			
			shipDestroyed = MapCell(X,Y)-100
			AllKlingons[shipDestroyed].energy = 0
			
			UpdateMapCell(X,Y,0)	-- remove ship from map
			
			ShipCondition = CheckShipStatus()	-- status might be green now
			
			if K3 == 0 then
				print()
				ShortRangeSensorScan()
			end
			
			break								-- no need to continue loop
			
		--# check if I hit a star
		elseif foundStarInCell(X,Y) then
			telePrint("SPOCK: No effect. Star at "..X3..","..Y3.." absorbed full energy of our torpedo.",1)
			break

		--# Check if I hit a starbase
		elseif foundStarbaseInCell(X,Y) then
			--# found a starbase
			print()
			telePrint("** CHEKOV: Captain, we have destroyed the Starbase. **",1)
			print()
			B3=B3-1
			baseDestroyed = MapCell(X,Y)-10
			UpdateMapCell(X,Y,0)
			ExploredSpace[Q1][Q2]=ExploredSpace[Q1][Q2]-10
			TotalStarbases=TotalStarbases-1
			AllStarbases[baseDestroyed].energy = 0
			ShipDocked = false
			ShipCondition = CheckShipStatus()
			
			telePrint("UHURA: Captain, Starfleet Control is calling the Enterprise.",1)
			telePrint("KIRK: Open a channel, Uhura.",1)
			telePrint("UHURA: Frequency open, sir.",2)
			telePrint("KIRK: Starfleet Control, this is the Enterprise. Captain Kirk speaking.",1)
			telePrint("STARFLEET: Captain Kirk, consider yourself confined to your quarters.")
			telePrint("Official inquiry will determine whether a general court martial is in order.\n")
			PressEnterToContinue()
			telePrint("SPOCK: Attention, all personnel. Captain Kirk has been placed under arrest. Our mission ends here.\n")
			smallDelay(2)
			GameOver = true
			return true
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
	telePrint("KIRK: Fire phasers, Mister Chekov.")

	if DamageLevel[4]<0 then
		telePrint("CHEKOV: Phasers inoperative, sir.")
		return false
	end
	if K3<1 then
		telePrint("SPOCK: Sensors Show No Enemy Ships In This Quadrant, Captain.")
		return false
	end
	if DamageLevel[8]<0 then
		telePrint("SPOCK: Captain, computer failure will cause phasers inaccuracy.")
	end
	telePrint("CHEKOV: Main phasers armed and ready, sir.")
	local Units = nil
	while Units == nil or Units>EnergyLevel or Units<0 do
		telePrint("SULU: Power levels at "..EnergyLevel.." units.")
		io.write("CHEKOV: How much power shall I divert to phasers, sir? ")
		Units = tonumber(io.read())
		if Units == 0 then return false end 	-- entering 0 will cancel the command
	end
	
	EnergyLevel=EnergyLevel-Units
	if DamageLevel[8]<0 then 			-- when computer is broken, the risk is to waste energy
		Units = Units*math.random()		-- the original code has a bug, it checks shield damage not computer
	end
	local UnitsPerShip=math.floor(Units/K3)				-- all the phasers energy is splitted among the enemy ships
	
	for i,k in ipairs(EnemyShips) do
		local KlingonEnergy = AllKlingons[k].energy
		local KlingonName = AllKlingons[k].name
		
		if KlingonEnergy> 0 then
			print()
			local distance = CalcDistanceOfShip(AllKlingons[k].x,AllKlingons[k].y,EntX,EntY)

			local distanceRatio = UnitsPerShip/distance 	-- damage is inversely proportional to distance
			local randNumb = math.random()+2		-- but a random factor can increse damage up to x2
			
			local HitPoints=math.floor(distanceRatio*randNumb)
			local kx,ky,ksx,ksy = globalToLocalCoord(AllKlingons[k].x,AllKlingons[k].y)
			
			telePrint("CHEKOV: Fire to enemy "..i.." at "..kx..","..ky)
			-- the next check is a sort of simulation of klingon ship shields
			if HitPoints <= (.15*KlingonEnergy) then
				telePrint("CHEKOV: Phasers ineffectual, sir.")
				HitPoints = 0
			else
				KlingonEnergy=KlingonEnergy-HitPoints
				telePrint("SULU: Direct hit. "..HitPoints.." units hit on Klingon at "..kx..","..ky)
			end
		
			if KlingonEnergy > 0 then
				telePrint("SPOCK: Sensors show Klingon ship has "..math.floor(KlingonEnergy).." units of energy remaining.",1)
				AllKlingons[k].energy = KlingonEnergy
			else
				telePrint("*** CHEKOV: The Klingon ship is destroyed, sir. ***",1)
				AllKlingons[k].energy = 0	-- i dont delete the element of the array

				UpdateMapCell(AllKlingons[k].x,AllKlingons[k].y,0)	-- remove ship from map
				
				TotalKlingonShips=TotalKlingonShips-1
					
				if TotalKlingonShips <= 0 then
					KlingonsDefeated()
					GameOver = true
					return true
				end
				
				K3=K3-1
				
				ExploredSpace[Q1][Q2]=ExploredSpace[Q1][Q2]-100	-- update visited sectors
				ShipCondition = CheckShipStatus()	-- status might be green now
			end
		end
	end
	if K3 == 0 then
		print()
		ShortRangeSensorScan()
	else KlingonsAttack()
	end
	
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
	telePrint("SCOTT: Captain, I had to divert power from the shields to the engines.")
	ShieldLevel=ShieldLevel+EnergyLevel  -- remove the energy required from the shields
	EnergyLevel=0
	if ShieldLevel<=0 then 				 -- this should not be possible
		ShieldLevel=0
	end
	return EnergyLevel
end


function WarpSpeedMovement()
	-- If Enterprise is entering a new sector, at this point it checks what the final position will be
	local EntFinalX = EntStartingX+StepX*NoOfSteps
	local EntFinalY = EntStartingY+StepY*NoOfSteps
	local FinalSector = sectorNumberFromGlobalCx(EntFinalX,EntFinalY)
	
	if FinalSector == 0 then		-- final position is outside the map
		telePrint("UHURA: Captain, Starfleet acknowledges report on our situation and confirms")
		telePrint("no authorised Federation vessel outside the galatic perimeter.")
		
		if EntFinalX<1 then EntFinalX=1 end
		if EntFinalX>64 then EntFinalX=64 end
		if EntFinalY<1 then EntFinalY=1 end
		if EntFinalY>64 then EntFinalY=64 end
		FinalSector = sectorNumberFromGlobalCx(EntFinalX,EntFinalY)
		
		telePrint("SULU: All engines full stop in sector "..FinalSector..".")
		
	end

	EntX = math.floor(EntFinalX+0.5)
	EntY = math.floor(EntFinalY+0.5)

	if FinalSector == EntStartingSector then
		-- Sector not changed - warp failed
		-- this happens only when CrossingPerimeter is true, but not vice versa
		-- I could have crossed the perimeter after changing one or more sector
		return false
	end
	
	-- Here the Enterprise has always reached a new sector
	-- Regardless of the speed used to reach this point, time advances by 1, which is correct
	Stardate=Stardate+1

	if Stardate > T0+MaxNumOfDays then
		TimeExpired()
		GameOver = true
		return true
	end

	-- Place the Enterprise in the new position
	-- if there is a star or enemy, moves the enterprise to next free cell
	
	S1,S2,Q1,Q2 = globalToLocalCoord(EntX,EntY)
	
	if mapCellIsNotEmpty(EntX,EntY) then
		-- if cell is occupied, select a random position in the same sector
		EntX,EntY = PlaceElementInSector(Q1,Q2,1)
		S1,S2,Q1,Q2 = globalToLocalCoord(EntX,EntY)
	else
		UpdateMapCell(EntX,EntY,1)
	end
	
	ConsumeEnergy()
	-- No more in the same quadrant, this will end the inner main loop
	return true
end

--# COURSE CONTROL BEGINS HERE - line 2290

function CourseControl()
	telePrint("KIRK: Set a course, Mister Sulu.")

	ShowDirections()	--# the original BASIC code does not show this, comment if you want

	-- 1) Ask for course and speed
	io.write("SULU: Direction, sir (0-9)? ")
	local Course = tonumber(io.read())

	if Course == nil or Course<1 or Course>9 then
		telePrint("SULU: I can't feed these coordinates into the panel, sir. It rejects the course change.")
		return false
	end
	MaxWarp = '8'
	if DamageLevel[1]<0 then MaxWarp = '0.2' end
	
	WarpFactor = nil
	telePrint("SULU: Course laid in, sir.")
	
	while WarpFactor == nil do
		io.write("SULU: Warp Speed (0-"..MaxWarp..")? ")
		WarpFactor = tonumber(io.read())
		
		if WarpFactor == 0 then		-- 0 warp will cancel the NAV command
			return false
		end
		
		if WarpFactor == nil then
			telePrint("SULU: You mean "..MaxWarp..", Captain? ")
		elseif (DamageLevel[1]<0 and WarpFactor >.2) then
			telePrint("SCOTT: Sorry Captain, our star drive is completely burned out. The only thing we have left is impulse power. Max speed = 0.2")
			WarpFactor = nil
		elseif WarpFactor<0 or WarpFactor>8 then
			telePrint("SCOTT: I can't give you warp "..WarpFactor..", Captain. These engines are beginning to show signs of stress!")
			-- SCOTT: Impossible. It can't go that fast.
			WarpFactor = nil
		end
	end
		
	-- moving at warp speed 1 means the ship advances by 8 cells, at 0.2 -> 1.6 cells -> rounded to 2
	-- additionally, a warp 1 will consume 8 units of Energy. A bit low?
	NoOfSteps = math.floor(WarpFactor*8+.5)
		
	if EnergyLevel < NoOfSteps then
		telePrint("SCOTT: I can't give you warp "..WarpFactor..", Captain. We don't have enough power.")
		
		-- it's possible to deviate energy from shields to warp
		if ShieldLevel >= (NoOfSteps - EnergyLevel) and DamageLevel[7]>=0 then
			telePrint("SPOCK: We can divert the shields power into the warp engine, sir, if you want the speed.")
		end
		return false
	elseif NoOfSteps == 0 then
		telePrint("SULU: Captain, this speed won't be enough to move the ship.")
		return false
	end
	
	-- 2) Klingons move (before Enterprise moves)
	-- Now they move randomly but they should be smarter than this
	
	for i,k in ipairs(EnemyShips) do
		if AllKlingons[k].energy > 0 then
			UpdateMapCell(AllKlingons[k].x,AllKlingons[k].y,0)
			local kx,ky = PlaceElementInSector(Q1,Q2,100+k)	
			AllKlingons[k].x = kx
			AllKlingons[k].y = ky
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
				telePrint("SCOTT: Captain, "..DeviceNames[i].." has been repaired.")
			end
		end
	end
	
	-- 5) Now check if a random system is broken or repaired
	-- In 20% of the cases, select a random system and either repair it or break it
	-- wouldn't it be better to do it in the previous loop?
	if (math.random()<=.2) then
		devIndex=FNR(1)
		if (math.random()>=.6) then
			if DamageLevel[devIndex]<0 then
				DamageLevel[devIndex]=DamageLevel[devIndex]+math.random()*3+1
				telePrint("SCOTT: Captain, "..DeviceNames[devIndex].." is being repaired.")
			end
		else
			-- it' possible that something that just got repaired, it's broken here, nonsense
			DamageLevel[devIndex]=DamageLevel[devIndex]-(math.random()*5+1)
			telePrint("SPOCK: Damage in "..DeviceNames[devIndex]..", Captain.")
		end
	end

	-- 6) Finally the Enterprise can move
		
	local CourseInRadiant = (math.pi/4)*(Course-1)
	
	StepX = math.sin(CourseInRadiant)*(-1)
	StepY = math.cos(CourseInRadiant)
	
	EntStartingX = EntX
	EntStartingY = EntY
	EntStartingSector = sectorNumberFromGlobalCx(EntX,EntY)
	
	UpdateMapCell(EntX,EntY,0)

	-- steps are floating point numbers, so the enterprise will move in a continuous map
	-- however, at any step, we will check if there is a collision in a discreet map
	for i=1,NoOfSteps do
		EntX=EntX+StepX
		EntY=EntY+StepY
		
		-- While traveling inside the quadrant, the Enterprise will move step by step, checking if
		-- it encounters an obstacle, or crosses the border of the quadrant. Once the border is crossed,
		-- all the rest of the movement will be performed by WarpSpeedMovement.
		-- At that point, obstacles don't matter any more, all the movement will be done in one big step
		
		-- if Enterprise is going to enter a different sector - can be also a wrong sector (outside map)
		if sectorNumberFromGlobalCx(EntX,EntY) ~= EntStartingSector then

			-- WarpSpeedMovement can fail immediately if the Enterprise is trying to go outside map
			if WarpSpeedMovement() then
				-- movement has finished
				return true
			else
				-- Warp has failed, we didnt reach a new sector
				break
			end
		end
		
		-- checking collisions
		if mapCellIsNotEmpty(EntX,EntY) then
			-- goes back canceling the last step
			EntX=EntX-StepX
			EntY=EntY-StepY
			telePrint("SULU: We are on a collision course, Captain. Engines have been shut down.")
			break
		end
	end
	
	-- Place the Enterprise in the new position
	EntX = math.floor(EntX+0.5)
	EntY = math.floor(EntY+0.5)
	

	UpdateMapCell(EntX,EntY,1)
	S1,S2,Q1,Q2 = globalToLocalCoord(EntX,EntY)

	ConsumeEnergy()
	DayIncrement=1

	if WarpFactor<1 then
		DayIncrement = roundTo(WarpFactor,1)	-- time advances slower at impulse speed (?)
	end
	
	Stardate=Stardate+DayIncrement		
	if Stardate > T0+MaxNumOfDays then
		TimeExpired()
		GameOver = true
		return true
	end

	checkIfDocked()
	ShortRangeSensorScan()
	return false   -- still in the same quadrant
end




-- ************************************************************
-- **    start of the program                                **
-- ************************************************************

math.randomseed(os.time())

DisableTeleprint = false

-- COMMENT/UNCOMMENT this if you want
--askForInstructions()


print [[



                                    ,------*------,
                    ,-------------   '---  ------'
                     '-------- --'      / /
                         ,---' '-------/ /--,
                          '----------------'
                    THE USS ENTERPRISE --- NCC-1701


]]

KlingonShipsNames = {"IKS Amar","IKS B'Moth","IKS Bortas","IKS Buruk","IKS Ch'Tang","IKS Devisor","IKS Drovana","IKS Fek'lhr","IKS Gr'oth","IKS Hegh'ta","IKS Hor'Cha","K'Temang's","K'Vada's","IKS Ki'tang","Klaa's","IKS Klothos","IKS K'mpec","IKS Koraga","IKS Korinar","Kronos One","IKS M'Char","IKS Maht-H'a","IKS Malpara","IKS Negh'Var","IKS Ning'tao","IKS Orantho","IKS Pagh","IKS Par'tok","IKS P'Rang","IKS Qu'Vat","IKS Rotarran","IKS Somraw","IKS Slivin","IKS T'Acog","IKS T'Ong","IKS Toh'Kaht","IKS Vor'nak","IKS Vorn","IKS Y'tem","IKS Ya'Vang"}

DeviceNames = {"WARP ENGINES","SHORT RANGE SENSORS","LONG RANGE SENSORS","PHASER CONTROL","PHOTON TUBES","DAMAGE CONTROL","SHIELD CONTROL","LIBRARY-COMPUTER"}

AllKlingons = {}
AllStarbases = {}

ExploredSpace = {{},{},{},{},{},{},{},{}} -- A copy of Galaxy, but only with sectors explored/scanned
DamageLevel = {}

Stardate = 5943+math.random(1,1000) -- Stardate 5943 is the date of the last episode, the game starts after TOS
T0 = Stardate

ShipDocked = false

-- Game Settings based on Difficulty level ---------------------------------
DifficultyLevel = 2 -- number between 1 (easy) and 4 (very hard)

MaxEnergyLevel = 3000	-- Enterprise max energy
MaxTorpedoes=10
KlingonBaseEnergy=200	-- Klingon ship energy range from 0.5x to 2x this value
TotalStarbases=math.random(5,6)-DifficultyLevel
MaxStarsPerSector = 7

-- tot klingons = [14..17]  [18..24]  [22..31]  [26..38]
TotalKlingonShips=DifficultyLevel+10+math.random(DifficultyLevel*3,DifficultyLevel*6)

-- default is [TotShips+5..TotShips+10]
MaxNumOfDays = TotalKlingonShips + math.random(7-DifficultyLevel,14-DifficultyLevel*2)

------------------------------------------------------------------------------

-- array C (CourseDelta) is the delta to Y and X determined by the course - last element (9) should be useless
C = {{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1},{1,0},{1,1},{0,1}}

-- Set Damage level to 0 for all systems
for i=1,8 do
	DamageLevel[i]=0
end

EnergyLevel = MaxEnergyLevel
PhotonTorpedoes=MaxTorpedoes
ShieldLevel=0
ShipCondition = 'GREEN'
EntX,EntY = 1,1 -- position of the Enterprise in the global map

-- Initialize Global Map (coordinates of all the 64 sectors)
GlobalMap = {}
for i=1,64 do
	GlobalMap[i] = {}
	for j=1,64 do
		GlobalMap[i][j] =0
	end
end

-- Generate Stars
local Galaxy = {{},{},{},{},{},{},{},{}} -- used only during generation of map

for i=1,8 do
	for j=1,8 do
		local numOfStars = math.random(1,MaxStarsPerSector)
		ExploredSpace[i][j]=0  -- hidden
		Galaxy[i][j]=0  -- hidden
		for s=1,numOfStars do
			PlaceElementInSector(i,j,1001)	-- place a star in random coordinates of sector
		end
	end
end

-- Place and create Starbases
local addedBases =0
while addedBases<TotalStarbases do
	local x,y=math.random(1,8),math.random(1,8)
	if Galaxy[x][y] < 10 then					-- only if there are no starbases
		addedBases = addedBases+1
		Galaxy[x][y]= Galaxy[x][y] + 10
		local bx,by = PlaceElementInSector(x,y,10+addedBases)	-- place a starbase in random coordinates of sector

		local BaseName = "Starbase "..addedBases
		local BaseEnergy = math.random(9000,15000)
		AllStarbases[addedBases] = {x=bx,y=by,name=BaseName,energy=BaseEnergy}
	end
end

-- Place Klingons
local addedKlingons =0
while addedKlingons<TotalKlingonShips do
	local x,y=math.random(1,8),math.random(1,8)
	if Galaxy[x][y] < 100 then					-- only if there are no klingons in this sector
		R1=math.random(1,20)
		local FleetSize = 1
		if R1>18 then
			FleetSize = 3
		elseif R1>15 then
			FleetSize = 2
		end
		if addedKlingons + FleetSize > TotalKlingonShips then
			FleetSize = TotalKlingonShips - addedKlingons
		end
		Galaxy[x][y]= Galaxy[x][y] + FleetSize*100
		
		for k=1,FleetSize do
			addedKlingons = addedKlingons+1
			local kx,ky = PlaceElementInSector(x,y,100+addedKlingons)	-- place a klingon in random coordinates of sector
			local KEnergy = KlingonBaseEnergy*(0.5+math.random())
			table.insert(AllKlingons,{x=kx,y=ky,energy=KEnergy,name=table.remove(KlingonShipsNames)})
		end
	end	
end

-- no more used
Galaxy = {}

-- REM INITIALIZE ENTERPRIZE'S POSITION
Q1,Q2 = FNR(1),FNR(1)	-- initial sector of the Enterprise

-- Place Enterprise in the Global Array, in a random free location of sector Q1,Q2
EntX,EntY = PlaceElementInSector(Q1,Q2,1)

S1,S2,Q1b,Q2b = globalToLocalCoord(EntX,EntY)

if Q1b ~= Q1 or Q2b ~= Q2 then
	die("Impossible - error calculating local from global")
end

-- Star the game with a mission recap
InitialKlingonShips=TotalKlingonShips

--Captain's Log, stardate 4523.3. Deep Space Station K7 has issued a priority one call. More than an
--emergency, it signals near or total disaster. We can only assume the Klingons have attacked the
--station. We're going in armed for battle.

telePrint("Captain's Log, stardate "..Stardate..'.')
telePrint("Klingons have invaded the Federation space, destroying our outposts and")
telePrint("starbases. We know Klingons are a military dictatorship and war is their way")
telePrint("of life, but we don't know why they suddenly decided to wipe us out.")
telePrint("All attempts to stop them, or communicate with them, have failed.\n")
telePrint("The Enterprise is now the only hope for the Federation. We need to intercept")
telePrint("the "..TotalKlingonShips.." Klingon ships before they reach Federation's headquarters.")
telePrint("Mr Spock estimates we have "..MaxNumOfDays.." days. After that, all will be lost.")
telePrint("The "..TotalStarbases.." Starbases in this area will assist us, but we need to defend them.\n")
telePrint("We are now approaching the last reported position of two Klingon vessels.\n",1)

PressEnterToContinue()

--#===============================================================

GameOver = false

-- main loop, it goes ahead until the enterprise is destroyed or the time is over or klingons are defeated
while (not GameOver) do
	-- reset current base data
	B4,B5 = 0,0

	EnemyShips = {}		-- indexes of the enemy ships present in this sector
 
	QuadrantName = GetQuadrantName(Q1,Q2)
	
	print()
	telePrint("SULU: Sir, we're entering the "..QuadrantName.." SECTOR.")
	
	-- A real scan of GlobalMap instead of the string "KBS"  -- this also sets B4,B5
	K3,B3,S3 = CurrentSectorScan(Q1,Q2)
	
	if ExploredSpace[Q1][Q2] == 0 then
		ExploredSpace[Q1][Q2] = K3*100+B3*10+S3
	end
	
	-- IF Klingons are present
	if K3>0 then
		telePrint("KIRK: All hands, battle stations. Red alert. I repeat, red alert.")
		if ShieldLevel == 0 then
			telePrint("SPOCK: Captain, shields are down. We cannot survive an attack.")
		elseif ShieldLevel<=200 then
			telePrint("SPOCK: Sir, deflector shields on minimum.")
		end
		smallDelay(1)
	end	

	checkIfDocked()
	ShortRangeSensorScan()
	
	-- Inner loop - continue cycling until Enterprise goes to a new sector
	
	local ReachedNewSector = false

	while (not ReachedNewSector and not GameOver) do
			
	--if there is very low total energy or shield are damaged, the game is over
		if EnergyLevel+ShieldLevel<=10 or (EnergyLevel<=10 and DamageLevel[7]<0) then
			print()
			telePrint("SULU: Sir, energy depleted. We're stuck, Captain.")
			telePrint("KIRK: Mister Scott, report.")
			telePrint("SCOTT: We're dead, Captain. Locked up. Frozen tight. All propulsion systems read zero.") -- Arena
			smallDelay(2)
			GameOver = true
			break
		end
		telePrint()
		io.write("? ")

		Command = string.upper(string.sub(io.read(),1,3))

		-- Aliases
		if Command == 'SCR' then Command = 'SRS' end -- Screen
		if Command == 'SEN' then Command = 'LRS' end -- Sensor Scan
		if Command == 'EXI' then Command = 'XXX' end -- Exit
		if Command == 'CON' or Command == 'CAL' then Command = 'HAI' end -- Contact or Call

		if Command == 'NAV' then ReachedNewSector = CourseControl()	-- the only way to reach a new sector is with NAV
		elseif Command == 'SRS' then ShortRangeSensorScan()
		elseif Command == 'LRS' then LongRangeSensorScan()
		elseif Command == 'PHA' then FirePhasers()
		elseif Command == 'TOR' then FirePhotonTorpedoes()
		elseif Command == 'SHE' then ShieldControl()
		elseif Command == 'DAM' then DamageControl()
		elseif Command == 'STA' then StatusReport()
		elseif Command == 'POS' then PhotonTorpedoData()
		elseif Command == 'COM' then LibraryComputer()
		elseif Command == 'MAP' then ComulativeGalacticRecord()
		elseif Command == 'DEB' then PrintFullMap()
		--elseif Command == 'HAI' then Communication()
		elseif Command == 'XXX' then GameOver = true
		else
			print("ENTER ONE OF THE FOLLOWING:")
			print("  NAV or Navigation (TO SET COURSE)")
			print("  SRS or Screen     (FOR SHORT RANGE SENSOR SCAN)")
			print("  LRS or Sensors    (FOR LONG RANGE SENSOR SCAN)")
			print("  PHA or Phasers    (TO FIRE PHASERS)")
			print("  TOR or Torpedo    (TO FIRE PHOTON TORPEDOES)")
			print("  SHE or Shields    (TO RAISE OR LOWER SHIELDS)")
			print("  DAM or Damage     (FOR DAMAGE CONTROL REPORTS)")
			print("  STA or Status     (FOR STATUS REPORT)")
			--print("  HAI or Hail       (TO OPEN A COMMUNICATION CHANNEL)")
			print("  POS or Position   (FOR POSITION/DISTANCE OF ENEMIES)")
			print("  COM or Computer   (TO CALL ON LIBRARY-COMPUTER)")
			print("  MAP or Map        (TO SEE THE SECTORS MAP)")
			print("  XXX or Exit       (TO RESIGN YOUR COMMAND)\n")
		end
	end  -- keep asking new commands until the ship reaches a new quadrant
end
-- end of the main loop


-- 6210 REM END OF GAME
telePrint()

-- this was line 6270
if TotalKlingonShips>0 then
	telePrint("** MISSION FAILED **")
end
	

telePrint("\n\nThank you for playing this game!")
telePrint("\n\nLUA conversion by Emanuele Bolognesi - http://emabolo.com\n")

os.exit()
