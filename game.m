% game.m - this is my version of space invaders/bubble burst/any game tbh.
% by harik <3
% enjoy
% for in game help, navigate to the help menu

% clear everything
close all
clear variables
clc

game_state=0; % this variables is 0: start up menu, 1: help menu, 2: game, 
% 3: game loss, 4: game win

mode = true; % this corresponds to the mode where you have 3 lives, there is 
% also a mode with 5 lives but i would argue this is boring
gifFilename = 'helpgif.gif';
x_max=2000;
y_max=4000;
fps=60;
playing=true;
moving=false;
num_lives=5;
f = figure(Color='#4c6898', Name= 'so close to square????', NumberTitle='off');
initMap = containers.Map('KeyType','char','ValueType','logical'); 
setappdata(f, 'keysDown', initMap);
w = 600;
h = w * y_max/x_max;
x_button = 13/20 * x_max;
v_button = x_max;
f.Position = [200 200 w h];
set(gcf, 'Position', get(0, 'Screensize'));
deltaT=1/fps;
mystery=false;
info = imfinfo(gifFilename);
N = numel(info);

mainFont='Unison Pro Bold Round';
fallbackFont='Arial';

if any(strcmpi(listfonts,mainFont))
    fontToUse=mainFont;
else
    fontToUse=fallbackFont;
end



for k = 1:N
    [A,map] = imread(gifFilename, k);
    if ~isempty(map)
        frames{k} = ind2rgb(A,map);
    else
        frames{k} = A;
    end
    delays(k) = info(k).DelayTime;
end
rawDelays = [info.DelayTime];
delays = rawDelays / 100;

cumDelay = [0 cumsum(delays)];
gifDuration = cumDelay(end);

fig = gcf;
set(fig, ... 
        'KeyPressFcn', @keyDown, ... 
        'KeyReleaseFcn',@keyUp);

blocks=[];
im_width=0.06*y_max*757/1113;
file="heart.png";
img=imread(file);
num_blocks=0;
r=0.005*x_max;
vm_plat=x_max/3 * 2.25 * 2/3;
first_time=true;
immune=true;
platform_pos=x_max/2;
platform_width=0.1*x_max;
platform_height=0.01*x_max;
platform_offset=0.05*x_max;
platform_vel=0;

v_0 = 2.25*x_max/2 * 2/3;
r_ball=0.0125*x_max;
pos=[x_max/2, platform_offset + r_ball];
initial_angle = (pi/2) * (rand()-0.5);
vel=[sin(initial_angle)*v_0, cos(initial_angle)*v_0];
just_lost=false;
restitution = 0.75;

lastDraw=tic;
while playing
    kd = getappdata(fig,'keysDown');
    if ~isempty(kd) && isKey(kd,'p') && kd('p')
        playing = false;
    end
    if (game_state==0)
        lp = tic;
        hold on
        grid off
        fix_axes(gca,x_max,y_max);
        set(gca,'XTick',[], 'YTick', [])
        
        if (first_time)
            nopt=true;
            nd=true;
            mystery=false;
            immune=true;
            pos=[x_max/2, platform_offset + r_ball];
            initial_angle = (pi/2) * (rand()-0.5);
            vel=[sin(initial_angle)*v_0, cos(initial_angle)*v_0];
            clf
            hold on
            fix_axes(gca,x_max,y_max);
            text_height(gca,x_max/2, 9*y_max/10, ["so close", "to square????"], 0.05*x_max*4/3, 'HorizontalAlignment', "center", 'Color','w', 'FontName',fontToUse);
            fix_axes(gca,x_max,y_max);
            text_height(gca,x_max/2, y_max*0.7, "MODE", 0.05*x_max, 'HorizontalAlignment', "center", 'Color','w', 'FontName',fontToUse);
            poly1=define_hex_shape(1/2 * x_max, 1/2 * x_max + 1*(1/10)*y_max, 1/10*y_max,x_max/2,0.6*y_max);
            fix_axes(gca,x_max,y_max);
            fill(poly1(:,1), poly1(:,2), [226/255, 227/255, 213/255], 'EdgeColor','none')
            poly2=define_hex_shape(1/5 * x_max, 1/5 * x_max + 1*(1/10)*y_max,1/10*y_max,x_button,0.6*y_max);
            slider=fill(poly2(:,1), poly2(:,2), [204/255, 64/255, 99/255], 'EdgeColor', 'none');
            fix_axes(gca,x_max,y_max);
            text_height(gca,7/20 * x_max, 0.6*y_max, "cool", 0.05*x_max*1/2, "HorizontalAlignment","center","VerticalAlignment","middle", 'FontName',fontToUse);
            fix_axes(gca,x_max,y_max);
            text_height(gca,13/20 * x_max, 0.6*y_max, "chaotic", 0.05*x_max*1/2, "HorizontalAlignment","center","VerticalAlignment","middle", 'FontName',fontToUse);
            poly3=define_hex_shape(1/2 * x_max, 1/2 * x_max + 1*(1/10)*y_max, 1/10*y_max,x_max/2,0.3*y_max);
            fill(poly3(:,1), poly3(:,2), [112/255, 126/255, 194/255], 'EdgeColor','none')
            fix_axes(gca,x_max,y_max);
            text_height(gca,0.5 * x_max, 0.3*y_max, "PLAY", 0.05*x_max, "HorizontalAlignment","center","VerticalAlignment","middle", 'FontName',fontToUse);
            poly4=define_hex_shape(1/2 * x_max, 1/2 * x_max + 1*(1/10)*y_max, 1/10*y_max,x_max/2,0.1*y_max);
            fill(poly4(:,1), poly4(:,2), [221/255, 80/255, 191/255], 'EdgeColor','none')
            fix_axes(gca,x_max,y_max);
            text_height(gca,0.5 * x_max, 0.1*y_max, "WHAT????", 0.05*x_max, "HorizontalAlignment","center","VerticalAlignment","middle", 'FontName',fontToUse);
            first_time=false;
        end
        fix_axes(gca,x_max,y_max);
        poly2=define_hex_shape(1/5 * x_max, 1/5 * x_max + 1*(1/10)*y_max,1/10*y_max,x_button,0.6*y_max);
        slider.XData=poly2(:,1);
        slider.YData=poly2(:,2);
        ClickLoc=get(gca,'CurrentPoint');
        ClickLoc=ClickLoc(1,1:2);
        [in1,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly1(:,1),poly1(:,2));
        [in2,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly2(:,1),poly2(:,2));
        [in3,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly3(:,1),poly3(:,2));
        [in4,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly4(:,1),poly4(:,2));
        if (moving==false && in1==1 && in2==0)
            mode = ~mode;
        end
        if (in3==1)
            game_state=2;
            pr=rand();
            if pr<0.01
                mystery=true;
            end
            if (~mode)
                num_lives=7;
            end
            if mystery
                blocks=[ones(5,1), (0:4)';2,2;2,4;ones(5,1)*3,(0:4)';ones(5,1)*5,(0:4)';6,4;ones(5,1)*7,(0:4)';ones(5,1)*9,(0:4)';10,2;10,4;ones(5,1)*11,(0:4)';0,10;
                    ones(5,1)*1,(6:10)';2,10;ones(5,1)*4,(6:10)';5,8;5,10;ones(5,1)*6,(6:10)';8,10;ones(5,1)*9,(6:10)';10,10;ones(5,1)*12,(6:10)'];
            else
                blocks=[zeros(5,1),(6:10)';ones(5,1)*1,(0:4)';1,10;2,0;ones(3,1)*2,(8:10)';3,0;3,10;ones(5,1)*4,(6:10)';ones(5,1)*5,(0:4)';6,2;6,4;ones(5,1)*6,(6:10)';
                    ones(5,1)*7,(0:4)';7,8;7,10;ones(5,1)*8,(6:10)';ones(5,1)*9,(0:4)';10,0;10,2;10,4;10,10;ones(5,1)*11,(0:4)';ones(5,1)*11,(6:10)';12,10];
            end
            [num_blocks,~]=size(blocks);
            clf
            hold on
            grid off
            fix_axes(gca,x_max,y_max);
            set(gca,'XTick',[], 'YTick', [])
            livesImages=gobjects(num_lives,1);
            for i = 0:(num_lives-1)
               xl=0.01*y_max*(i+1) + im_width*i;
               livesImages(i+1) = image([xl, xl+im_width], [0.98*y_max, 0.92*y_max], img);
            end
            % contains graphics objects, wayyyyyyyyyy faster so that high
            % pace gameplay is possible, otherwise fps rate drops to like 7
            % when redrawing every time
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
            progress = text_height(gca, x_max-0.01*y_max,0.95*y_max,num2str(num_blocks),0.05*y_max,'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'Color', 'w', 'FontName', fontToUse);
            blockAlive = true(num_blocks,1);
            tPlat=hgtransform('Parent',gca);
            platform = def_rt(platform_pos-(platform_width/2),platform_offset-platform_height,platform_height,platform_width);
            platform_fill = patch('XData',platform(:,1),'YData',platform(:,2),'FaceColor', 'w', 'Parent', tPlat, 'EdgeColor', 'none');
            tBall = hgtransform('Parent',gca);
            ball = def_circ(r_ball, pos(1), pos(2), 36);
            ball_fill = patch('XData',ball(:,1),'YData',ball(:,2),'FaceColor', 'w', 'Parent', tBall, 'EdgeColor', 'none');
            pause(0.5)
            num_blocks_left=num_blocks;
            start_lives=num_lives;
            % opengl info;
        end
        if (in4==1)
            game_state=1;
            tGifStart = tic;
        end
        tep = toc(lp);
        pause(max(deltaT - tep,0))
        if (mode)
            if(x_button<13/20 * x_max)
                moving=true;
                x_button = x_button + 1/fps * v_button;
            else
                moving=false;
                x_button=13/20 * x_max;
            end
        else
            if(x_button>7/20 * x_max)
                moving=true;
                x_button = x_button - 1/fps * v_button;
            else
                moving=false;
                x_button=7/20 * x_max;
            end
        end
    elseif (game_state==1)
        lp=tic;
        clf
        hold on
        grid off
        axis([0 x_max 0 y_max])
        set(gca,'XTick',[], 'YTick', [])
        poly1=define_hex_shape(2/3*0.3 * x_max, 2/3*(0.3 * x_max + 1*(1/10)*y_max), 1/10*y_max*2/3,x_max*0.25,0.9*y_max);
        fill(poly1(:,1), poly1(:,2), [202/255, 165/255, 102/255], 'EdgeColor','none')
        fix_axes(gca,x_max,y_max);
        text_height(gca,0.25 * x_max, 0.9*y_max, "(don't come) back",2/3*0.032*x_max, "HorizontalAlignment","center","VerticalAlignment","middle", "FontName", fontToUse)
        fix_axes(gca,x_max,y_max);
        text_height(gca,0.5*x_max, 0.8*y_max,["hey cute jeans", "i think you know what this is", "but if not, hiii, this is my", ...
            "winter vac matlab project.", "it's t8 mcrae themed Breakout", ...
            "[you're so] cool - 7 lives", "chaotic - 5 lives", "left/a - move your platform left", ...
            "right/d - move to the right", "*the platform accelerates*", ...
            "feel free to send feedback to", "harik.sodhi[at]chch.ox.ac.uk", ...
            "live now, think later,", "harik <3"], 0.032*x_max,HorizontalAlignment="center", VerticalAlignment="top", Color='w', FontName=fontToUse)
        gif_x1=0.1*x_max;
        gif_x2=0.9*x_max;
        gif_y2=0.1 * x_max;
        gif_y1=0.9*x_max;
        t = toc(tGifStart);
        t = mod(t, gifDuration);
        k = find(cumDelay(2:end) > t, 1);
        image([gif_x1 gif_x2], [gif_y1 gif_y2], frames{k});
        fix_axes(gca,x_max,y_max);
        ClickLoc=get(gca,'CurrentPoint');
        ClickLoc=ClickLoc(1,1:2);
        [in1,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly1(:,1),poly1(:,2));
        if (in1 == 1)
            game_state=0;
            first_time=true;
        end
        tep=toc(lp);
        pause(max(1/fps - tep,0))
    elseif (game_state==2)
        tStartt = tic;
        if (num_lives<0)
            game_state=3;
        end
        kd = getappdata(fig,'keysDown');
        if ~isempty(kd) && ((isKey(kd,'a') && kd('a')) || (isKey(kd,'leftarrow') && kd('leftarrow')))
            pmotion_multiplier=-1;
        elseif ~isempty(kd) && ((isKey(kd,'d') && kd('d')) || (isKey(kd,'rightarrow') && kd('rightarrow')))
            pmotion_multiplier=1;
        else
            pmotion_multiplier=0;
        end
        if (num_blocks_left<=0)
            game_state=4;
        end
        % platform = def_rt(platform_pos-(platform_width/2),platform_offset-platform_height,platform_height,platform_width);
        % platform_fill.XData = platform(:,1);
        % platform_fill.YData = platform(:,2);
        set(tPlat, 'Matrix',makehgtform('translate',[platform_pos-0.5*x_max,0,0]));
        % ball = def_circ(r_ball, pos(1), pos(2), 36);
        % ball_fill.XData=ball(:,1);
        % ball_fill.YData=ball(:,2);
        set(tBall, 'Matrix', makehgtform('translate',[pos(1)-0.5*x_max, pos(2) - platform_offset-r_ball, 0]));

        if (just_lost && game_state==2)
            if (num_lives<start_lives)
                livesImages(num_lives+1).Visible=false;
            end
            pos=[x_max/2, platform_offset + r_ball];
            pause(0.5)
            lastDraw=tic;
            tStartt=tic;
            just_lost=false;
            lp=tic;
            immune=true;
        end
        for i = 1:num_blocks
            if (blockAlive(i))
                p = blocks(i,1);
                q = blocks(i,2);
                xlr=1/105 * x_max + p*(8/105 * x_max);
                ylr=0.9 * y_max - 29/35 * x_max + q*(8/105 * x_max);
                s=1/15*x_max;
                x=determine_side(pos(1), pos(2), xlr, ylr, s, r_ball);
                if (x<4)
                    blockAlive(i)=false;
                    F(i,:) = NaN;
                    set(hBlocks,'Faces',F);
                    num_blocks_left=num_blocks_left-1;
                    progress.String=num2str(num_blocks_left);
                    drawnow
                    lastDraw=tic;
                    if (x==1 || x==2)
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
        if (pos(1)-r_ball<0)
            pos(1)=2*r_ball-pos(1);
            vel(1)=-vel(1);
        end
        if (pos(1)+r_ball>x_max)
            pos(1)=2*x_max - 2*r_ball - pos(1);
            vel(1)=-vel(1);
        end
        if (pos(2)>r_ball*2+0.9*y_max || pos(2)<platform_offset-platform_height-r_ball*2)
            if (~(immune && pos(2)>0.5*y_max))
                num_lives = num_lives - 1;
            end
            platform_pos=x_max/2;
            platform_vel=0;
            
            r_ball=0.0125*x_max;
            pos=[x_max/2, platform_offset + r_ball];
            initial_angle = (pi/2) * (rand()-0.5);
            vel=[sin(initial_angle)*v_0, cos(initial_angle)*v_0];
            just_lost=true;
        end
        if (platform_pos + platform_width/2)>x_max
            platform_pos = x_max - platform_width/2;
            platform_vel=min(platform_vel,0);
        elseif (platform_pos - platform_width/2)<0
            platform_pos = platform_width/2;
            platform_vel = max(platform_vel,0);
        end
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
        if (toc(lastDraw)>deltaT)
            drawnow
            lastDraw=tic;
        end
        counting = toc(tStartt);
        platform_vel = pmotion_multiplier * vm_plat;
        platform_pos = platform_pos + platform_vel * counting;
        pos = pos + vel * counting;
    end
    if (game_state==3)
        lp=tic;
        clf
        hold on
        grid off
        set(gca,'XTick',[], 'YTick', [])
        fix_axes(gca,x_max,y_max)
        poly1=define_hex_shape(0.3 * x_max * 2/3, 2/3*(0.3 * x_max + 1*(1/10)*y_max), 1/10*2/3*y_max,x_max*0.25,0.9*y_max);
        fill(poly1(:,1), poly1(:,2), [254/255, 185/255, 207/255], 'EdgeColor','none')
        fix_axes(gca,x_max,y_max);
        text_height(gca,0.25 * x_max, 0.9*y_max, "play again :)",2/3*0.032*x_max, "HorizontalAlignment","center","VerticalAlignment","middle", "FontName", fontToUse)
        poly2=define_hex_shape(0.2 * x_max, 2/3*(0.3 * x_max + 1*(1/10)*y_max), 2/3*1/10*y_max,x_max*0.75,0.9*y_max);
        fill(poly2(:,1), poly2(:,2), [46/255, 111/255, 64/255], 'EdgeColor','none')
        fix_axes(gca,x_max,y_max);
        text_height(gca,0.75 * x_max, 0.9*y_max, "listen here <3",0.032*x_max*2/3, "HorizontalAlignment","center","VerticalAlignment","middle", "FontName", fontToUse);
        fix_axes(gca,x_max,y_max);
        text_height(gca,0.5*x_max, 0.8*y_max,"UH OH", 2*0.032*x_max,HorizontalAlignment="center", VerticalAlignment="top", Color='w', FontName=fontToUse)
        fix_axes(gca,x_max,y_max)
        text_height(gca,0.5*x_max, 0.75*y_max,["i suppose i make you", "really really good at", "making bad decisions", "even 7 texts and 2 missed calls", "couldn't save you", "anyways, maybe you should like", "try to win next time?"], 0.032*x_max,HorizontalAlignment="center", VerticalAlignment="top", Color='w', FontName=fontToUse)
        gif_x1=0.1*x_max;
        gif_x2=0.9*x_max;
        gif_y2=0.1 * x_max;
        gif_y1=0.9*x_max;
        [X, map] = imread("uhoh.jpeg");
        if ~isempty(map)
            colormap(map);
            imgg = X;
        else
            imgg = X;
        end
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
            if (nopt)
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
        if (nd)
            if (mystery)
                if (mode)
                    load("su.mat")
                    l = size(su,1);
                    s = randi([1 l]);
                    song_name = su(s,1);
                    rating = su(s,2);
                    linky = su(s,3);
                    [X, map] = imread("su.png");
                    if ~isempty(map)
                        colormap(map);
                        imgg = X;
                    else
                        imgg = X;
                    end
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
clear variables
close all

function poly = define_hex_shape(top_width, total_width, height,cx,cy)
    v1= [cx-(total_width/2), cy];
    v2= [cx+(total_width/2), cy];
    v3= [cx+(top_width/2), cy+height/2];
    v4= [cx+(top_width/2), cy-height/2];
    v5= [cx-(top_width/2), cy+height/2];
    v6= [cx-(top_width/2), cy-height/2];
    poly = [v1;v5;v3;v2;v4;v6];
end

function circle = def_circ(r,xc,yc,N)
    t = transpose(linspace(0,2*pi,N+1));
    circle = [r*cos(t)+xc, yc+r*sin(t)];
end
function square = def_sq(xl,yl,s)
    square = [xl, yl; xl+s, yl; xl+s, yl+s; xl, yl+s];
end
function rectangle = def_rt(xl,yl,h,w)
    rectangle = [xl, yl; xl+w, yl; xl+w, yl+h; xl, yl+h];
end
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
function fix_axes(ax,x_max,y_max)
    ax.Color = '#0c0b13';
    daspect([1 1 1])
    ax.XLim = [0 x_max];
    ax.YLim = [0 y_max];
    ax.XLimMode = 'manual';
    ax.YLimMode = 'manual';
end
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

function spinWait(sec)
    t0 = tic;
    while toc(t0) < sec
        % play elevator noises idk
    end
end
