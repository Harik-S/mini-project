Formal Version:
The project is an adaptation of popular games such as Arkanoid and other similar games that have popped up. One undeniable thing is many references to *Tate Mcrae* (canadian pop artist) which is a completely non functional twist. To play, simply start up, click into the help (WHAT????) menu if you're looking for a slightly less formal version of this (also provided below), more in keeping with the overall theme. The difficulty selector allows you to choose between chaotic (3 lives) and [you're so] cool (5 lives). This is done by clicking on any part of the light grey while the toggle isn't moving (to stop the user from bouncing with the toggle - it's not a game object). Clicking play takes you into the game, which is relatively simple. If the ball leaves from the top or bottom, one life is lost. Otherwise, try to hit the blocks and knock them all out before all your lives are gone :)). The caveat is that if the ball leaves from the top before you even get a chance to hit, you don't lose a life. And if this happens when there are 5 or fewer blocks. Unfortunately, there was no way to pre calculate stuff because that would be very complicated. This is the only reasonable solution that makes the game alright to play.
The winning scene is a secret - and so is the losing scene. There are in fact 41 different winning scenes based on your chosen difficulty, with some having rarities of up to 1/4000. Good luck!!!
In terms of debugging, one issue was accidentally doing if (number of clicks inside hexagon == 0), switch to the next scene, which meant that it tried to load the scene before a button was clicked. This was very obvious. In another case, there was an issue with the fill function not taking in hex values - or RGB tuples that are in terms of 255 and not normalised to 1.
The most difficult part was when linux decided to not use cpu acceleration and I discovered that pause(dt) first finished re rendering then checked if dt had elapsed. So, in theory, the command pause(0) would re render. This is alright for data analysis, but horrible for games/animations where you have to run at more than ~20fps. First, re writing all the code to optimise (changing the properties of graphics objects instead of clf and then remaking them, also using one patch with lots of faces rather than a vector containing many patches). Also getting Ubuntu to use my GPU was very annoying.
As the project evolved, I had more and more different features and references that were a very nice touch to the final project.
If I had more time, potentially more levels or making it more difficult would be more interesting. Also making the physics less buggy would be nice.

INFORMAL HELP MENU (WHAT????)
hey cute jeans [sports car]
i think you know what this is [sports car]
but if not, hiii, this is my 
winter vac matlab project.
it's t8 themed Arkanoid
[you're so] cool - 5 lives
chaotic - 3 lives
left/a - move your platform left
right/d - move to the right
*the platform accelerates so be careful*
feel free to send feedback to 
harik.sodhi[at]chch.ox.ac.uk
live now, think later,
harik <3
[gif of t8]
