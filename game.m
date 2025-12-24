% game.m - this is my version of blockbuster
% by harik <3
% enjoy
% for in game help, navigate to the help menu

% clear everything
close all
clear variables
clc

game_state=0; % this variables is 0: start up menu, 1: help menu, 2: game, 
% 3: game loss, 4: game win

mode = true; % this corresponds to the mode where you have 5 lives, there is 
% also a mode with 7 lives but i would argue this is boring

% the filename for the gif that plays in the help menu
gifFilename = 'helpgif.gif';
% the x and y dimensions of the axes. everything is defined in terms of
% these so you can vary them if you want (changing the ratio is possibly
% bad though)
x_max=2000;
y_max=4000;

ge = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment();
gd = ge.getDefaultScreenDevice();
dm = gd.getDisplayMode();

refreshRate = dm.getRefreshRate();
disp(refreshRate)

% number of frames per second, it's best to sync this to monitor refresh
% rate or there may be tearing. this is done through java code ^. a null
% value is given by 0 or -1 so this checks if the value is accurate. if
% not, a baseline of 60Hz is reasonable.
if (refreshRate > 0)
    fps=refreshRate;
else
    fps=60;
end
% this variable controls the whole loop and provides an easy exit method
playing=true;
% this is for checking if the toggle in the main menu is moving (and
% essentially stopping it from being bounced back and forth
moving=false;
% number of lives remaining
num_lives=5;
% setting the background colour (chosen to be the blue from the sctw????
% album cover) and the title
f = figure(Color='#4c6898', Name= 'so close to square????', NumberTitle='off');
% containers.Map is the equivalent of a python dict, it uses keys to store
% different values
initMap = containers.Map('KeyType','char','ValueType','logical'); 
% stores the initMap inside the figure
setappdata(f, 'keysDown', initMap);
% the starting x position of the centre of the button
x_button = 13/20 * x_max;
% the speed of the button moving left/right
v_button = x_max;
% setting the position of the figure inside the window, and ensures that
% the aspect ratio is fixed and that it's full screen. get(0) retrieves the
% monitor information and screen size is a 1x4 matrix with co ordinate
% information
set(gcf, 'Position', get(0, 'Screensize'));
% pre dividing to save a tiny bit of time
deltaT=1/fps;
% mystery mode (0.01 chance of coming up)
mystery=false;

% an array containing information about every frame in the gif
info = imfinfo(gifFilename);
% the number of frames in the gif
N = numel(info);

% the preferred and fallback fonts
mainFont='Unison Pro Bold Round';
fallbackFont='Arial';

% checks to see if the main font is installed. if so, use it. otherwise,
% use fallback font (which is pre installed so no problem)
if any(strcmpi(listfonts,mainFont))
    fontToUse=mainFont;
else
    fontToUse=fallbackFont;
end


% when reading the file, there may be a colour map, and if this colourmap
% exists, then using that. the delays array contains the raw delays scaled
% by 100. the raw delays come from the info variable (it was defined before
% the tangent on fonts). scaling by 100 was chosen by trial and error (the
% times are defined in centiseconds which was weird) but the gif runs as
% expected with this value
frames = cell(1,N);
for k = 1:N
    [A,map] = imread(gifFilename, k);
    if ~isempty(map)
        frames{k} = ind2rgb(A,map);
    else
        frames{k} = A;
    end
end
rawDelays = [info.DelayTime];
delays = rawDelays / 100;

% cumsum(delays) gives the running sum as a horizontal vector
cumDelay = [0 cumsum(delays)];
% takes the final element, which gives the total duration
gifDuration = cumDelay(end);

% creates a handle to these 2 functions
fig = gcf;
set(fig, ... 
        'KeyPressFcn', @keyDown, ... 
        'KeyReleaseFcn',@keyUp);
% the blocks in the main level
blocks=[];
% the width of the image, given the height of 0.06*y_max, and provided
% aspect ratio.
im_width=0.06*y_max*757/1113;
% the image for the heart at the top
file="heart.png";
% reads the file in advance, speeding up processing later. it works without
% the colour map, because it's an RGB image
img=imread(file);
% number of blocks
num_blocks=0;
% speed of platform
vm_plat=x_max/3 * 2.25 * 2/3;
% make sure the menu only sets the static components once (no necessary
% regeneration)
first_time=true;
% if the ball goes directly out the top, then you don't lose a life,
% because that's out of your control
immune=true;
% position of the platform (as a function of time)
platform_pos=x_max/2;
% width of the platform
platform_width=0.1*x_max;
% vertical height of the platform
platform_height=0.01*x_max;
% distance between the bottom of the display and the top of the platform
platform_offset=0.05*x_max;
% speed of the platform, initially at rest
platform_vel=0;

% speed of the ball
v_0 = 2.25*x_max/2 * 2/3;
% radius of the ball
r_ball=0.0125*x_max;
% starting position of ball centre (just above centre of platform)
pos=[x_max/2, platform_offset + r_ball];
% randomly generate an angle from -pi/4 to pi/4
initial_angle = (pi/2) * (rand()-0.5);
% velocity vector
vel=[sin(initial_angle)*v_0, cos(initial_angle)*v_0];
% to manage the changes that happen when you lose a life
just_lost=false;
% hitting the ball with a moving platform transfers some of the speed from
% the platform to the ball. the fraction is given be "restitution". as a
% note, it is possibly more practical to consider the spin and the magnus
% effect. however, the messy cross products etc. are possibly too annoying
% and difficult to tune for this simple game- and also less loyal to the
% original game. alas, there will be no swerving balls this time.
restitution = 0.75;
% this timer is to stick to frame rate - 
lastDraw=tic;
while playing
    % runs the function to check if p is pressed - which is the automatic
    % exit key
    kd = getappdata(fig,'keysDown');
    if ~isempty(kd) && isKey(kd,'p') && kd('p')
        playing = false;
    end
    if (game_state==0)
        % start a timer
        lp = tic;
        % hold on so that everything is plotted
        hold on
        % remove the grid
        grid off
        % run the command to fix the axes
        fix_axes(gca,x_max,y_max);
        % remove the axes ticks on the side to make it cleaner
        set(gca,'XTick',[], 'YTick', [])
        
        if (first_time)
            % commands for the win/loss screen (checking if a random song
            % has been generated + checking if the link has already been
            % clicked). it's rather funny to see the program flick through
            % songs, or for it to open 20 browser tabs. however, this is
            % not happening
            % they're here because if you press play again, it won't
            % execute the bit before the while playing loop
            nopt=true;
            nd=true;
            mystery=false;
            immune=true;
            pos=[x_max/2, platform_offset + r_ball];
            initial_angle = (pi/2) * (rand()-0.5);
            vel=[sin(initial_angle)*v_0, cos(initial_angle)*v_0];
            platform_pos=x_max/2;
            % clear whatever was on the axes before
            clf
            hold on
            % title text
            fix_axes(gca,x_max,y_max);
            text_height(gca,x_max/2, 9*y_max/10, ["so close", "to square????"], 0.05*x_max*4/3, 'HorizontalAlignment', "center", 'Color','w', 'FontName',fontToUse);
            fix_axes(gca,x_max,y_max);
            % mode subheading for difficulty
            text_height(gca,x_max/2, y_max*0.7, "MODE", 0.05*x_max, 'HorizontalAlignment', "center", 'Color','w', 'FontName',fontToUse);
            % background box for slider
            poly1=define_hex_shape(1/2 * x_max, 1/2 * x_max + 1*(1/10)*y_max, 1/10*y_max,x_max/2,0.6*y_max);
            fix_axes(gca,x_max,y_max);
            % we need to call fix axes before every test prompt because the
            % height of text is a function of the current axes, so we do
            % need to rescale
            fill(poly1(:,1), poly1(:,2), [226/255, 227/255, 213/255], 'EdgeColor','none')
            % the smaller slider inside the box
            poly2=define_hex_shape(1/5 * x_max, 1/5 * x_max + 1*(1/10)*y_max,1/10*y_max,x_button,0.6*y_max);
            slider=fill(poly2(:,1), poly2(:,2), [204/255, 64/255, 99/255], 'EdgeColor', 'none');
            fix_axes(gca,x_max,y_max);
            % slider text
            text_height(gca,7/20 * x_max, 0.6*y_max, "cool", 0.05*x_max*1/2, "HorizontalAlignment","center","VerticalAlignment","middle", 'FontName',fontToUse);
            fix_axes(gca,x_max,y_max);
            text_height(gca,13/20 * x_max, 0.6*y_max, "chaotic", 0.05*x_max*1/2, "HorizontalAlignment","center","VerticalAlignment","middle", 'FontName',fontToUse);
            % box for play game button
            poly3=define_hex_shape(1/2 * x_max, 1/2 * x_max + 1*(1/10)*y_max, 1/10*y_max,x_max/2,0.3*y_max);
            fill(poly3(:,1), poly3(:,2), [112/255, 126/255, 194/255], 'EdgeColor','none')
            fix_axes(gca,x_max,y_max);
            % text for play game button
            text_height(gca,0.5 * x_max, 0.3*y_max, "PLAY", 0.05*x_max, "HorizontalAlignment","center","VerticalAlignment","middle", 'FontName',fontToUse);
            % box for help button
            poly4=define_hex_shape(1/2 * x_max, 1/2 * x_max + 1*(1/10)*y_max, 1/10*y_max,x_max/2,0.1*y_max);
            fill(poly4(:,1), poly4(:,2), [221/255, 80/255, 191/255], 'EdgeColor','none')
            fix_axes(gca,x_max,y_max);
            % text for help button
            text_height(gca,0.5 * x_max, 0.1*y_max, "WHAT????", 0.05*x_max, "HorizontalAlignment","center","VerticalAlignment","middle", 'FontName',fontToUse);
            first_time=false;
        end
        % re adjust the axes
        fix_axes(gca,x_max,y_max);
        poly2=define_hex_shape(1/5 * x_max, 1/5 * x_max + 1*(1/10)*y_max,1/10*y_max,x_button,0.6*y_max);
        slider.XData=poly2(:,1);
        slider.YData=poly2(:,2);
        % re define the slider based on where it is. this is more efficient
        % than redefining and redrawing everything. instead, we can adjust
        % existing graphics objects

        % gets the position of the current click
        ClickLoc=get(gca,'CurrentPoint');
        ClickLoc=ClickLoc(1,1:2);
        % checks if the click is in all of the polygonts
        [in1,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly1(:,1),poly1(:,2));
        [in2,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly2(:,1),poly2(:,2));
        [in3,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly3(:,1),poly3(:,2));
        [in4,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly4(:,1),poly4(:,2));
        if (moving==false && in1==1 && in2==0)
            % if the click is in the white area, and the slider isnt
            % already moving, we adjust the mode
            mode = ~mode;
        end
        if (in3==1)
            % if we play the game, get in the game state
            game_state=2;
            pr=rand();
            if pr<0.01
                % 0.01 chance of getting into the mystery mode
                mystery=true;
            end
            % on easy mode, the number of lives is 7
            if (~mode)
                num_lives=7;
            end
            if mystery
                % mystery block set up
                blocks=[ones(5,1), (0:4)';2,2;2,4;ones(5,1)*3,(0:4)';ones(5,1)*5,(0:4)';6,4;ones(5,1)*7,(0:4)';ones(5,1)*9,(0:4)';10,2;10,4;ones(5,1)*11,(0:4)';0,10;
                    ones(5,1)*1,(6:10)';2,10;ones(5,1)*4,(6:10)';5,8;5,10;ones(5,1)*6,(6:10)';8,10;ones(5,1)*9,(6:10)';10,10;ones(5,1)*12,(6:10)'];
            else
                % normal block set up
                blocks=[zeros(5,1),(6:10)';ones(5,1)*1,(0:4)';1,10;2,0;ones(3,1)*2,(8:10)';3,0;3,10;ones(5,1)*4,(6:10)';ones(5,1)*5,(0:4)';6,2;6,4;ones(5,1)*6,(6:10)';
                    ones(5,1)*7,(0:4)';7,8;7,10;ones(5,1)*8,(6:10)';ones(5,1)*9,(0:4)';10,0;10,2;10,4;10,10;ones(5,1)*11,(0:4)';ones(5,1)*11,(6:10)';12,10];
            end
            % number of blocks to begin with (need a variable as mystery
            % can be different to non mystery)
            [num_blocks,~]=size(blocks);
            % clear and set up axes again
            clf
            hold on
            grid off
            fix_axes(gca,x_max,y_max);
            set(gca,'XTick',[], 'YTick', [])
            % storing the images for hearts as a vector of geometric
            % objects
            livesImages=gobjects(num_lives,1);
            for i = 0:(num_lives-1)
               xl=0.01*y_max*(i+1) + im_width*i;
               livesImages(i+1) = image([xl, xl+im_width], [0.98*y_max, 0.92*y_max], img);
            end
            % contains graphics objects, wayyyyyyyyyy faster so that high
            % pace gameplay is possible, otherwise fps rate drops to like 7
            % when redrawing every time

            % for slight optimisations, instead of having each block be a
            % different patch, have one big patch with lots of faces

            % blockPatches = gobjects(num_blocks,1);
            V = zeros(4*num_blocks,2);
            F = zeros(num_blocks,4);
            idx=1;
            for i = 1:num_blocks
                p = blocks(i,1);
                q = blocks(i,2);
                xl=1/105 * x_max + p*(8/105 * x_max);
                yl=0.9 * y_max - 29/35 * x_max + q*(8/105 * x_max);
                s=1/15*x_max;
                V(idx,:)   = [xl, yl];
                V(idx+1,:) = [xl+s, yl];
                V(idx+2,:) = [xl+s, yl+s];
                V(idx+3,:) = [xl, yl+s];
                F(i,:) = idx:idx+3;
                idx = idx + 4;
            end
            hBlocks = patch('Vertices',V,'Faces',F,'FaceColor',[153/255 0 0],'CData',ones(num_blocks,1),'EdgeColor','none');
            fix_axes(gca,x_max,y_max);
            % the text in the top right with the number of blocks remaining
            progress = text_height(gca, x_max-0.01*y_max,0.95*y_max,num2str(num_blocks),0.05*y_max,'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'Color', 'w', 'FontName', fontToUse);
            % this contains a vector of booleans that records which blocks
            % are alive
            blockAlive = true(num_blocks,1);
            % a different set of axes essentially. this is because re
            % computing the polygon data for the platform and ball is quite
            % expensive, so instead we link it to a different pair of axes
            % we cant traslate.
            tPlat=hgtransform('Parent',gca);
            platform = def_rt(platform_pos-(platform_width/2),platform_offset-platform_height,platform_height,platform_width);
            platform_fill = patch('XData',platform(:,1),'YData',platform(:,2),'FaceColor', 'w', 'Parent', tPlat, 'EdgeColor', 'none');
            tBall = hgtransform('Parent',gca);
            ball = def_circ(r_ball, pos(1), pos(2), 36);
            ball_fill = patch('XData',ball(:,1),'YData',ball(:,2),'FaceColor', 'w', 'Parent', tBall, 'EdgeColor', 'none');
            pause(0.5)
            % pause to render and give the user time to contemplate their
            % life decisions
            num_blocks_left=num_blocks;
            start_lives=num_lives;
            % opengl info;
        end
        if (in4==1)
            % go to help screen and start playing gif
            game_state=1;
            tGifStart = tic;
        end
        tep = toc(lp);
        % handles frame rate
        pause(max(deltaT - tep,0))
        % physics to move slider and make it stops when it hits one end.
        % also handles moving logic.
        if (mode)
            if(x_button<13/20 * x_max)
                moving=true;
                x_button = x_button + tep * v_button;
            else
                moving=false;
                x_button=13/20 * x_max;
            end
        else
            if(x_button>7/20 * x_max)
                moving=true;
                x_button = x_button - tep* v_button;
            else
                moving=false;
                x_button=7/20 * x_max;
            end
        end
    elseif (game_state==1)
        lp=tic;
        % fix the axes as usual
        clf
        hold on
        grid off
        axis([0 x_max 0 y_max])
        set(gca,'XTick',[], 'YTick', [])
        % drawing button and text for going back to the main screen
        poly1=define_hex_shape(2/3*0.3 * x_max, 2/3*(0.3 * x_max + 1*(1/10)*y_max), 1/10*y_max*2/3,x_max*0.25,0.9*y_max);
        fill(poly1(:,1), poly1(:,2), [202/255, 165/255, 102/255], 'EdgeColor','none')
        fix_axes(gca,x_max,y_max);
        text_height(gca,0.25 * x_max, 0.9*y_max, "(don't come) back",2/3*0.032*x_max, "HorizontalAlignment","center","VerticalAlignment","middle", "FontName", fontToUse)
        fix_axes(gca,x_max,y_max);
        % main text
        text_height(gca,0.5*x_max, 0.8*y_max,["hey cute jeans", "i think you know what this is", "but if not, hiii, this is my", ...
            "winter vac matlab project.", "it's t8 mcrae themed breakout", ...
            "[you're so] cool - 7 lives", "chaotic - 5 lives", "left/a - move your platform left", ...
            "right/d - move to the right", ...
            "feel free to send feedback to", "harik.sodhi[at]chch.ox.ac.uk", ...
            "live now, think later,", "harik <3"], 0.032*x_max,HorizontalAlignment="center", VerticalAlignment="top", Color='w', FontName=fontToUse)
        % defining corner placement of the gif
        gif_x1=0.1*x_max;
        gif_x2=0.9*x_max;
        gif_y2=0.1 * x_max;
        gif_y1=0.9*x_max;
        % calculating time since the gif started. then do the modulus to
        % calculate looping behaviour
        t = toc(tGifStart);
        t = mod(t, gifDuration);
        % finding the relevant frame (the frames aren't equal durations (it
        % does this weird alternating thing) so this is the best option)
        k = find(cumDelay(2:end) > t, 1);
        image([gif_x1 gif_x2], [gif_y1 gif_y2], frames{k});
        fix_axes(gca,x_max,y_max);
        % goes back to the main screen if you click the back button
        ClickLoc=get(gca,'CurrentPoint');
        ClickLoc=ClickLoc(1,1:2);
        [in1,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly1(:,1),poly1(:,2));
        if (in1 == 1)
            game_state=0;
            first_time=true;
        end
        tep=toc(lp);
        % pause and render
        pause(max(1/fps - tep,0))
    elseif (game_state==2)
        % start the timer for frame rate
        tStartt = tic;
        % if you don't have any lives left, you lose
        if (num_lives<0)
            game_state=3;
            % pause to let them contemplate their loss (also to make the
            % scene transition a bit calmer)
            pause(0.2)
        end
        % checks to see if the keys are being pressed. then records this
        % for later (doesn't update straight away
        kd = getappdata(fig,'keysDown');
        if ~isempty(kd) && ((isKey(kd,'a') && kd('a')) || (isKey(kd,'leftarrow') && kd('leftarrow')))
            pmotion_multiplier=-1;
        elseif ~isempty(kd) && ((isKey(kd,'d') && kd('d')) || (isKey(kd,'rightarrow') && kd('rightarrow')))
            pmotion_multiplier=1;
        else
            pmotion_multiplier=0;
        end
        % if they don't have any blocks left, they win!
        if (num_blocks_left<=0)
            game_state=4;
            % pauses to let them think about winning or something
            pause(0.2)
        end
        % this is old code from when each time, the rectangle was re drawn.
        % now, it just translates the axes, noting that the zero point was
        % the original position, not (0,0)
        
        % platform = def_rt(platform_pos-(platform_width/2),platform_offset-platform_height,platform_height,platform_width);
        % platform_fill.XData = platform(:,1);
        % platform_fill.YData = platform(:,2);
        set(tPlat, 'Matrix',makehgtform('translate',[platform_pos-0.5*x_max,0,0]));
        % ball = def_circ(r_ball, pos(1), pos(2), 36);
        % ball_fill.XData=ball(:,1);
        % ball_fill.YData=ball(:,2);
        set(tBall, 'Matrix', makehgtform('translate',[pos(1)-0.5*x_max, pos(2) - platform_offset-r_ball, 0]));

        if (just_lost && game_state==2)
            % make sure they havent already lost or it will throw an error
            if (num_lives<start_lives)
                % to deal with immunity issues, we always run this, even if
                % they were immune, because then it will hide an already
                % hidden image which is FINE. if we have immunity problems
                % on the first go, then it will try use an index which
                % doesnt exist so that's why we have the if statement
                livesImages(num_lives+1).Visible=false;
            end
            % reset the ball position
            pos=[x_max/2, platform_offset + r_ball];
            % pause to give time to think
            pause(0.2)
            % restart all the timers because otherwise this 0.2 seconds
            % will throw them off
            lastDraw=tic;
            tStartt=tic;
            just_lost=false;
            lp=tic;
            % they are now immune
            immune=true;
        end
        for i = 1:num_blocks
            if (blockAlive(i))
                % checks for collisions and at the same time also which
                % side was collided with.
                p = blocks(i,1);
                q = blocks(i,2);
                xlr=1/105 * x_max + p*(8/105 * x_max);
                ylr=0.9 * y_max - 29/35 * x_max + q*(8/105 * x_max);
                s=1/15*x_max;
                x=determine_side(pos(1), pos(2), xlr, ylr, s, r_ball);
                if (x<4)
                    % hides block and updates text showing number of
                    % blocks. then forces a render
                    blockAlive(i)=false;
                    F(i,:) = NaN;
                    set(hBlocks,'Faces',F);
                    num_blocks_left=num_blocks_left-1;
                    progress.String=num2str(num_blocks_left);
                    drawnow
                    lastDraw=tic;
                    if (x==1 || x==2)
                        % reflects the ball. since we are running physics
                        % at 12 thousand hertz, we don't need to shift the
                        % position
                        vel(1)=-vel(1);
                        % if (x==2)
                        %     pos(1)=2*xlr-pos(1);
                        % else
                        %     pos(1)=2*(xlr+s)-pos(1);
                        % end
                    else
                        vel(2)=-vel(2);
                        % if ~(x==0)
                        %     pos(2)=2*ylr-pos(2);
                        % else
                        %     pos(2)=2*(ylr+s)-pos(2);
                        % end
                    end
                    break
                end 
            end
        end
        % wall reflection
        if (pos(1)-r_ball<0)
            pos(1)=2*r_ball-pos(1);
            vel(1)=-vel(1);
        end
        if (pos(1)+r_ball>x_max)
            pos(1)=2*x_max - 2*r_ball - pos(1);
            vel(1)=-vel(1);
        end
        % checks if the ball is too far up the top or too far down the
        % bottom of the page
        if (pos(2)>r_ball*2+0.9*y_max || pos(2)<platform_offset-platform_height-r_ball*2)
            if (~(immune && pos(2)>0.5*y_max))
                % if we are immune and the ball goes up the top, no lives
                % are lost
                num_lives = num_lives - 1;
            else
                if (num_blocks_left<=5)
                    game_state=4;
                    % pauses to let them think about winning or something
                    pause(0.2)
                    % provides an alternative win condition to avoid a
                    % drawn out end game
                end
            end
            % reset everything to initial values
            platform_pos=x_max/2;
            platform_vel=0;
            
            r_ball=0.0125*x_max;
            pos=[x_max/2, platform_offset + r_ball];
            initial_angle = (pi/2) * (rand()-0.5);
            vel=[sin(initial_angle)*v_0, cos(initial_angle)*v_0];
            just_lost=true;
        end
        % if platform hits wall, stop
        if (platform_pos + platform_width/2)>x_max
            platform_pos = x_max - platform_width/2;
            platform_vel=min(platform_vel,0);
        elseif (platform_pos - platform_width/2)<0
            platform_pos = platform_width/2;
            platform_vel = max(platform_vel,0);
        end
        % collision with the platform. we ignore collisions with the bottom
        % of the platform and if it collides with the side, we treat it
        % differently
        if (pos(2)<r_ball+platform_offset && pos(1)>=(platform_pos-platform_width/2 - r_ball) && pos(1)<=(platform_pos+platform_width/2 +r_ball) && ~just_lost)
            if pos(2)>platform_offset - platform_height
                pos(2)= 2*(r_ball+platform_offset) - pos(2);
                vel(1)= vel(1) + restitution*platform_vel;
                vel(2)=-vel(2);
                immune=false;
            else
                vel(1)=-vel(1);
            end
        end
        % this makes the fps stuff work. this is because the cap on frame
        % rate is monitor refresh rate so doing it any quicker is
        % unnecessary and places extra strain on the GPU for no reason
        if (toc(lastDraw)>deltaT)
            drawnow
            lastDraw=tic;
        end
        % update positions, simple kinematics
        counting = toc(tStartt);
        platform_vel = pmotion_multiplier * vm_plat;
        platform_pos = platform_pos + platform_vel * counting;
        pos = pos + vel * counting;
    end
    if (game_state==3)
        % standard set up
        lp=tic;
        clf
        hold on
        grid off
        set(gca,'XTick',[], 'YTick', [])
        fix_axes(gca,x_max,y_max)
        % play again button
        poly1=define_hex_shape(0.3 * x_max * 2/3, 2/3*(0.3 * x_max + 1*(1/10)*y_max), 1/10*2/3*y_max,x_max*0.25,0.9*y_max);
        fill(poly1(:,1), poly1(:,2), [254/255, 185/255, 207/255], 'EdgeColor','none')
        fix_axes(gca,x_max,y_max);
        text_height(gca,0.25 * x_max, 0.9*y_max, "play again :)",2/3*0.032*x_max, "HorizontalAlignment","center","VerticalAlignment","middle", "FontName", fontToUse)
        % listen button
        poly2=define_hex_shape(0.2 * x_max, 2/3*(0.3 * x_max + 1*(1/10)*y_max), 2/3*1/10*y_max,x_max*0.75,0.9*y_max);
        fill(poly2(:,1), poly2(:,2), [46/255, 111/255, 64/255], 'EdgeColor','none')
        fix_axes(gca,x_max,y_max);
        text_height(gca,0.75 * x_max, 0.9*y_max, "listen here <3",0.032*x_max*2/3, "HorizontalAlignment","center","VerticalAlignment","middle", "FontName", fontToUse);
        fix_axes(gca,x_max,y_max);
        % title
        text_height(gca,0.5*x_max, 0.8*y_max,"UH OH", 2*0.032*x_max,HorizontalAlignment="center", VerticalAlignment="top", Color='w', FontName=fontToUse)
        fix_axes(gca,x_max,y_max)
        % main text
        text_height(gca,0.5*x_max, 0.75*y_max,["i suppose i make you", "really really good at", "making bad decisions", "even 7 texts and 2 missed calls", "couldn't save you", "anyways, maybe you should like", "try to win next time?"], 0.032*x_max,HorizontalAlignment="center", VerticalAlignment="top", Color='w', FontName=fontToUse)
        % position of the image (gif is left over from copied code and not
        % much point fixing it
        gif_x1=0.1*x_max;
        gif_x2=0.9*x_max;
        gif_y2=0.1 * x_max;
        gif_y1=0.9*x_max;
        % uses colourmap as remarked on before
        [X, map] = imread("uhoh.jpeg");
        if ~isempty(map)
            colormap(map);
            imgg = X;
        else
            imgg = X;
        end
        image([gif_x1 gif_x2], [gif_y1 gif_y2], imgg);
        % finds where the user clicked
        ClickLoc=get(gca,'CurrentPoint');
        ClickLoc=ClickLoc(1,1:2);
        [in1,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly1(:,1),poly1(:,2));
        [in2,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly2(:,1),poly2(:,2));        
        if (in1 == 1)
            % back to main screen
            game_state=0;
            first_time=true;
        end
        if (in2 == 1)
            % opens spotify link to the song (uh oh)
            if (nopt)
                % the nopt stops it from opening a lot of tabs
                web("https://open.spotify.com/track/6qmvAJSUfVGMubvI2awW7p?si=9b745e5334584d57",'-browser')
                nopt=false;
            end
        end
        fix_axes(gca,x_max,y_max);
        tep=toc(lp);
        pause(max(1/fps - tep,0))

    end
    if (game_state==4)
        lp=tic;
        % similar to losing screen but slight differences will be commented
        if (nd)
            if (mystery)
                if (mode)
                    load("su.mat")
                    l = size(su,1);
                    s = randi([1 l]);
                    song_name = su(s,1);
                    rating = su(s,2);
                    linky = su(s,3);
                    % picks a random song from the chosen database
                    % (different based on difficulty and whether mystery
                    % mode was used)
                    [X, map] = imread("su.png");
                    if ~isempty(map)
                        colormap(map);
                        imgg = X;
                    else
                        imgg = X;
                    end
                    % has an image at the bottom
                else
                    load("sctwd.mat")
                    l = size(sctwd,1);
                    s = randi([1 l]);
                    song_name = sctwd(s,1);
                    rating = sctwd(s,2);
                    linky = sctwd(s,3);
                    [X, map] = imread("sctwd.jpeg");
                    if ~isempty(map)
                        colormap(map);
                        imgg = X;
                    else
                        imgg = X;
                    end
                end
            else
                if (mode)
                    load("tl.mat")
                    l = size(tl,1);
                    s = randi([1 l]);
                    song_name = tl(s,1);
                    rating = tl(s,2);
                    linky = tl(s,3);
                    [X, map] = imread("tl.jpg");
                    if ~isempty(map)
                        colormap(map);
                        imgg = X;
                    else
                        imgg = X;
                    end
                else
                    load("iutticf.mat")
                    l = size(iutticf,1);
                    s = randi([1 l]);
                    song_name = iutticf(s,1);
                    rating = iutticf(s,2);
                    linky = iutticf(s,3);
                    [X, map] = imread("iutticf.png");
                    if ~isempty(map)
                        colormap(map);
                        imgg = X;
                    else
                        imgg = X;
                    end
                end
            end
            nd=false;
        end
        clf
        hold on
        grid off
        set(gca,'XTick',[], 'YTick', [])
        fix_axes(gca,x_max,y_max)
        poly1=define_hex_shape(0.2 * x_max, 2/3*(0.3 * x_max + 1*(1/10)*y_max), 2/3*1/10*y_max,x_max*0.25,0.9*y_max);
        fill(poly1(:,1), poly1(:,2), [254/255, 185/255, 207/255], 'EdgeColor','none')
        fix_axes(gca,x_max,y_max);
        text_height(gca,0.25 * x_max, 0.9*y_max, "play again :)",0.032*x_max*2/3, "HorizontalAlignment","center","VerticalAlignment","middle", "FontName", fontToUse);
        poly2=define_hex_shape(0.2 * x_max, 2/3*(0.3 * x_max + 1*(1/10)*y_max), 2/3*1/10*y_max,x_max*0.75,0.9*y_max);
        fill(poly2(:,1), poly2(:,2), [46/255, 111/255, 64/255], 'EdgeColor','none')
        fix_axes(gca,x_max,y_max);
        text_height(gca,0.75 * x_max, 0.9*y_max, "listen here <3",0.032*x_max*2/3, "HorizontalAlignment","center","VerticalAlignment","middle", "FontName", fontToUse);
        fix_axes(gca,x_max,y_max);
        text_height(gca,0.5*x_max, 0.8*y_max,"YOU WON", 2*0.032*x_max,HorizontalAlignment="center", VerticalAlignment="top", Color='w', FontName=fontToUse);
        fix_axes(gca,x_max,y_max)
        if (~mystery)
            text_height(gca,0.5*x_max, 0.75*y_max,["omg you did it", "that's so cool", "love that for you", "anyways, here's my rating of", song_name{1,1}, join(["i think its ", num2str(rating{1,1}), "/10"]), "i had soooo much fun with this", "hope u liked it too <3"], 0.032*x_max,HorizontalAlignment="center", VerticalAlignment="top", Color='w', FontName=fontToUse);
        elseif (~mode)
            text_height(gca,0.5*x_max, 0.75*y_max,["omg? you beat the", "mystery level????", "that's so cool", "love that for you", "(an extra amount)", "anyways, here's my rating of", song_name{1,1}, join(["i think its ", num2str(rating{1,1}), "/10"]), "i had soooo much fun with this", "hope u liked it too <3"], 0.032*x_max,HorizontalAlignment="center", VerticalAlignment="top", Color='w', FontName=fontToUse);
        else
            text_height(gca,0.5*x_max, 0.75*y_max,["omg? you beat the", "mystery level????", "on hard mode????", "that's so cool", "love that for you", "(an extra extra amount)", "these songs are unreleased", "or singles, these songs", "are the loml", "anyways, here's my rating of", song_name{1,1}, join(["i think its ", num2str(rating{1,1}), "/10"]), "i had soooo much fun with this", "hope u liked it too <3"], 0.029*x_max,HorizontalAlignment="center", VerticalAlignment="top", Color='w', FontName=fontToUse);
        end
        % different win text based on mystery and difficulty
        gif_x1=0.1*x_max;
        gif_x2=0.9*x_max;
        gif_y2=0.1 * x_max;
        gif_y1=0.9*x_max;
        image([gif_x1 gif_x2], [gif_y1 gif_y2], imgg);
        ClickLoc=get(gca,'CurrentPoint');
        ClickLoc=ClickLoc(1,1:2);
        [in1,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly1(:,1),poly1(:,2));
        [in2,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly2(:,1),poly2(:,2));        
        if (in1 == 1)
            game_state=0;
            first_time=true;
        end
        if (in2 == 1)
            if nopt
                web(linky{1,1},'-browser')
                nopt=false;
            end
        end
        fix_axes(gca,x_max,y_max);
        tep=toc(lp);
        pause(max(1/fps - tep,0))
    end
end
% don't take up too much memory :)
clear variables
close all

% defines the weird hexagon ish shape for all the buttons
function poly = define_hex_shape(top_width, total_width, height,cx,cy)
    v1= [cx-(total_width/2), cy];
    v2= [cx+(total_width/2), cy];
    v3= [cx+(top_width/2), cy+height/2];
    v4= [cx+(top_width/2), cy-height/2];
    v5= [cx-(top_width/2), cy+height/2];
    v6= [cx-(top_width/2), cy-height/2];
    poly = [v1;v5;v3;v2;v4;v6];
end

% defines a circle, with N being the number of points, allowing varied
% levels of performance/fidelity for balance
function circle = def_circ(r,xc,yc,N)
    t = transpose(linspace(0,2*pi,N+1));
    circle = [r*cos(t)+xc, yc+r*sin(t)];
end
% square (now we use lots of faces in a patch this isn't necessary)
function square = def_sq(xl,yl,s)
    square = [xl, yl; xl+s, yl; xl+s, yl+s; xl, yl+s];
end
% defines a rectangle based on bottom left corner co ordinates and height
% and width
function rectangle = def_rt(xl,yl,h,w)
    rectangle = [xl, yl; xl+w, yl; xl+w, yl+h; xl, yl+h];
end
% text but it's scaled based on the axes so HOPEFULLY provides more cross
% compatibility than outright defining font size
function h = text_height(ax, x, y, str, h_data, varargin)
    oldUnits = ax.Units;
    ax.Units = 'points';
    axPos = ax.Position;
    ax.Units = oldUnits;

    yRange = diff(ax.YLim);
    pointsPerData = axPos(4) / yRange;

    fontSize = h_data * pointsPerData;

    h = text(x, y, str, 'FontSize', fontSize, varargin{:});
end
% does all the necessary axes adjusting, slightly tidying up the file. side
% note, calling functions is surprisingly expensive in matlab so if i
% really wanted to optimise for time, i would copy and paste this every
% time but then we'd be even further over 1000 lines.
function fix_axes(ax,x_max,y_max)
    ax.Color = '#0c0b13';
    daspect([1 1 1])
    ax.XLim = [0 x_max];
    ax.YLim = [0 y_max];
    ax.XLimMode = 'manual';
    ax.YLimMode = 'manual';
end

% key up/down information, these functions work with pressing keys
function keyDown(src, event)
    kd = getappdata(src, 'keysDown');
    if isempty(kd) || ~isa(kd,'containers.Map')
        kd = containers.Map('KeyType','char','ValueType','logical');
    end
    kd(event.Key) = true;
    setappdata(src, 'keysDown', kd);
end

function keyUp(src, event)
    kd = getappdata(src, 'keysDown');
    if isempty(kd) || ~isa(kd,'containers.Map')
        return
    end
    if isKey(kd, event.Key)
        remove(kd, event.Key);
        setappdata(src, 'keysDown', kd);
    end
end
% this returns 4 if the ball is outside the square. note that because i'm
% lazy and it doesn't make any visual difference
% for checking what side, we use diagonals to divide the plane into 4
% regions, which also represents the side its closest to.
function side=determine_side(x,y,xl,yl,s,r)
    xc = xl + s/2;
    yc = yl + s/2;
    if (y>(yl-r) && y<(yl+s+r) && x>(xl-r) && x<(xl+r+s))
        side=0;
        if ((y-yc)-(x-xc))>0
            side=side+2;
        end
        if ((y-yc)+(x-xc))>0
            side=side+1;
        end
    else
        side=4;
    end
end
% a wait command that was considered. see readme.md.
function spinWait(sec)
    t0 = tic;
    while toc(t0) < sec
        % play elevator noises idk
    end
end
