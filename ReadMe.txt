Formal Version:
The project is an adaptation of popular games such as Arkanoid and other similar games that have popped up. One undeniable thing is many references to *Tate Mcrae* (canadian pop artist) which is a completely non functional twist. To play, simply start up, click into the help (WHAT????) menu if you're looking for a slightly less formal version of this (also provided below), more in keeping with the overall theme. The difficulty selector allows you to choose between chaotic (3 lives) and [you're so] cool (5 lives). This is done by clicking on any part of the light grey while the toggle isn't moving (to stop the user from bouncing with the toggle - it's not a game object). Clicking play takes you into the game, which is relatively simple. If the ball leaves from the top, one life is lost. Otherwise, try to hit the blocks and knock them all out before all your lives are gone :)). The winning scene is a secret - and so is the losing scene. There are in fact 2 winning scenes based on your chosen difficulty. Good luck!!!
In terms of debugging, one issue was accidentally doing if (number of clicks inside hexagon == 0), switch to the next scene, which meant that it tried to load the scene before a button was clicked. This was very obvious. In another case, there was an issue with the fill function not taking in hex values - or RGB tuples that are in terms of 255 and not normalised to 1.
The most difficult part was making all the auxiliary variables for everything to mesh together smoothly because the physics itself is just reflection so its not very very hard.
As the project evolved, I had more and more different features and references that were a very nice touch to the final project.
If I had more time, potentially more levels or making it more difficult would be more interesting.

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
[gif of tate if possible]
