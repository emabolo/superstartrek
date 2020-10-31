# Star Trek LUA port - TOS version
Unlike the other LUA version, this is not a 100% faithful port of the original code. Main changes/improvements:
* All game messages replaced with lines taken from the episodes of Star Trek: The Original Series (hence the name "TOS")
* Course calculations and movement of the ship now implemented with trigonometric functions
* All the game objects (ships, stars, starbases) are now persistent
* Other minor changes, such as "Sectors" instead of "Quadrants".

## Game Messages
Spock, Scott, Chekov, and the others make a brief appearance in the original game with some occasional messages. I thought it would be fun if  **all** the game messages were not invented by taken from the Star Trek Episodes' original transcripts. So I downloaded all the episodes transcripts of the 3 seasons of Star Trek. Then I opened the game code, and for each message, I searched through the text to find something that the original characters have said, and that can be appropriate. In most of the cases, I was able to use the lines without changing anything. In some cases, I have to adapt a bit, trying to maintain the character style. So now, when you use the phasers, you will read:

`KIRK: Fire phasers, Mister Chekov.` (taken from the episode "Obsession")
`CHEKOV: Main phasers armed and ready, sir.` ("The Trouble With Tribbles")

If Phasers don't damage the Klingons, Checkov will say:
`CHEKOV: Phasers ineffectual, sir.` ("Obsession")

When you use the long-range sensors:
`KIRK: Long-range sensor scan, Mister Sulu.` (episode "The Omega Glory")
`SULU: Sectors surrounding 7,7 charted and examined` ("Who Mourns For Adonais?" adapted a bit)

When you find a Klingon, you will see:
`KIRK: All hands, battle stations. Red alert. I repeat, red alert.` ("Arena")

And so on. Now you can really "hear" the original voices. I find it pretty cool. Maybe I will add some variations, let's see.

## Trigonometric functions
The original game code didn't use any trigonometric functions, probably because `sin()` and `cos()` were not available in BASIC when the original Star Trek game was written. The code uses some clever math tricks to calculate the course between 2 points and the vector of the movement of the Enterprise.

The course calculation is not 100% accurate, but considering the screen is small (only 8x8 cells), the error is negligible. In fact, my torpedoes never missed a target because of this. In any case, I rewrote this part using `math.atan2`. Mostly because I want the code to be safe if I decide to increase the screen size in a new version. There is no impact in terms of gameplay.

Instead, the movement of the Enterprise is heavily impacted by the introduction of trigonometry. Let's see why.
The distance covered by the Enterprise is 8 cell x Warp Speed. For example, when the ship moves to the right at warp speed 1, it covers a distance of 8 cells. A warp speed of 0.5 is 4 cells, and so on. All good until it's a horizontal or vertical movement.
But in the original code, when the Enterprise moves at 45° - let's say north-east - at warp speed 1, it goes 8 cells up and 8 cells right, which is a distance of 11.3, not 8! If it moves north-north-east, something in the middle: 8 cells up and 4 cells right, which is a distance of 8.9. Basically, the Enterprise is faster if the direction is close to 45°.
Rewriting the code, I introduced `sin()` and `cos()` to calculate the movement, so the math is now correct: Warp Speed 1 is always a distance of 8, regardless of the angle.

The gameplay is impacted because, in the original version, when you move at warp speed 1, you always land in another sector. This is not true anymore when you are moving diagonally.

## Persistent Objects
To save memory, the author decided to split the game map into *sectors* (called *quadrants* in the original version - see later) and store only the number of stars, enemy ships, and starbases present in that specific sector. When the Enterprise enters a sector, the program places the required objects in random locations. If there are enemy ships, it also calculates their energy. This is a pretty smart trick; this way, the entire galaxy is stored in an 8x8 array.

The side effect is that when you go back to a sector you have already visited, you will notice that the stars and starbases are in different positions. Even worse, if you have already reduced a Klingon to 1 point of energy, but for some reason, you leave the sector without destroying it, when you go back, you will find a fresh new Klingon ship.

In my version, I introduced a 64x64 array to store every cell of the galaxy. There is also an array of all Klingon ships, with their coordinates, energy level, and even their name. If you leave a sector and later go back to it, you will find the same situation.
More than an improvement to the game, this is more to support future development and additional features (such as Klingons that move from one sector to another to hunt you).

## Other changes
The original game imagines that the Enterprise is patrolling the entire galaxy, divided into 64 *quadrants*. Each *quadrant* is a portion of space, with usually less than 10 stars, up to 3 Klingon ships, and if you are lucky, a starbase.
Clearly, this doesn't make any sense. The entire galaxy has 100 thousand millions stars. In reality, the game screen is more similar to the definition of "sectors" in the Star Trek lore. According to memory alpha, a sector is:

>a volume of space approximately twenty light-years across. A typical sector in Federation space will contain about 6 to 10 star systems.

So I changed the game's terminology using the word *sector* instead of *quadrant*. Obviously, the Enterprise is not patrolling the entire galaxy, but just a portion of space around 160x160 light-years wide—a bit more reasonable.

Unfortunately, despite this change of scale, the game time doesn't make any sense. The Enterprise can move from one sector to another at warp speed 1, in just 1 day. But Warp Speed 1 is light speed, so the Enterprise would take 20 years to go to the next sector, not 1 day. Simulating the *real* warp speed would change the game too much because warp speed is exponential.


This is now my favorite version, so I will continue developing the TOS one. If you want a more vintage experience, go for the default one.

