# SuperStarTrek - Perl and LUA ports
These are "faithful" ports to Perl and LUA of the 1978 BASIC code of Super Star Trek by Bob Leedom. They are based on the code published in BASIC COMPUTER GAMES - Microcomputer Edition, edited by David H. Ahl.

## What is Super Star Trek
Super Star Trek is an old text-only game, an early example of a turn-based space strategy sim, written in BASIC.
In this game, you are the captain of the starship Enterprise, and your mission is to scout the federation space and eliminate all the invading Klingon ships.
You will have to manage the ship energy carefully, use phasers and torpedoes to destroy the Klingons, and find starbases to repair damages and replenish your energy.

## The story of the game
The first Star Trek game was written by Mike Mayfield in 1971 for the Sigma 7 mainframe. In 1974 Bob Leedom improved the code; he added some new features and called it Super Star Trek.
The program listing appeared in the famous 1978 book BASIC COMPUTER GAMES - Microcomputer Edition, edited by David Ahl.
The book's success and the birth of the home computers in 1977 made Super Star Trek one of the most popular games written in BASIC ever created.

For more info about the game, its story, and how to play it, have a look at this article I wrote: [Rediscovering the 1978 Super Star Trek game](https://gamesnostalgia.com/story/182/rediscovering-the-1978-text-only-super-star-trek-game)

For the ones that are interested in the original code, I added it in the folder "original-version". I downloaded it from [Vintage Basic](http://vintage-basic.net/games.html)


## About the ports
There are literally thousands of different versions of Super Star Trek. During the years, it has been rewritten, ported, and improved many times. But I could not find a version that was a faithful conversion of the 1978 code that appeared in the book, so I decided to write it.
The first version I wrote was the Perl one. I chose Perl because it's easy and because it has "goto"s. In fact, my first attempt was mostly a 1-to-1 conversion of the original code.
But I continued working on it for several days. In the last version, all "goto"s have disappeared, they became if-then-else blocks, loops, and functions. Once I got familiar with the code, I gave meaningful names to most of the variables. I also added a lot of comments to explain the code and highlight possible bugs or improvements.
I also converted most of the BASIC subroutines (GOSUB), based on global vars, into functions with local vars.
After the Perl version, I decided to convert it into LUA. Since LUA does not have a "continue" statement, only "break", I had to rewrite many blocks, but in the end the code is simpler and looks much better. I removed the "continue" (aka "next" in Perl) also from the Perl version.

The code now is very different, but I paid attention to not change the mechanics or the math behind the game algorithm. The game should play exactly like the BASIC version.

You will notice that I didn't use the normal `print`. The reason is a full speed version doesn't really offer a faithful experience. When I tried the Commodore 64 version, I noticed that the text was scrolling much slower, and there is also a small delay before the quadrant screen is rendered. So I tried to recreate this experience using a `smallDelay()` function and replacing `print` with a `telePrint()` function (telePrint prints the line and then wait a bit). If you don't like this, change `DisableTeleprint = false` into `DisableTeleprint = true` (or '1' for Perl version)

Versions included:

- **startrek-tos.lua** : an enhanced version of the LUA port, with the *voices* of the original Star Trek: The Original Series cast - [see here](https://github.com/emabolo/superstartrek/blob/master/tos-version.md) for more info;
- **superstartrek.lua** : 100% faithful port to LUA of the 1978 BASIC version;
- **superstartrek.pl** : this is the first version I wrote. Perl is already installed on Mac, so it might be easier to try this one if you just want to play it. Mostly aligned with the LUA version, the only difference is the Perl version uses `select` for the delay, which could be a bit more precise. Also, in Perl the main code is on top, while functions are below, I find it easier to read.

## What's next
startrek-tos is now my favourite version. More features are coming.
I'm also planning to port this to Pico-8. Let's see how it goes.


Happy startrekking!


