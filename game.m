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
fps=30;
playing=true;
moving=false;
num_lives=3;
f = figure(Color='#4c6898', Name= 'so close to square????', NumberTitle='off');
initMap = containers.Map('KeyType','char','ValueType','logical'); 
setappdata(f, 'keysDown', initMap);
w = 600;
h = w * y_max/x_max;
x_button = 13/20 * x_max;
v_button = x_max;
f.Position = [200 200 w h];
set(gcf, 'Position', get(0, 'Screensize'));
v_0 = x_max;
pos=[];
vel=[];
mystery=false;
info = imfinfo(gifFilename);
N = numel(info);
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
im_width=0.08*y_max*757/1113;
file="heart.png";
img=imread(file);
num_blocks=0;
r=0.005*x_max;
a=x_max;



while playing
    kd = getappdata(fig,'keysDown');
    if ~isempty(kd) && isKey(kd,'p') && kd('p')
        playing = false;
        close(f)
        return
    end
    if (game_state==0)
        lp = tic;
        hold off
        clf
        hold on
        grid off
        axis([0 x_max 0 y_max])
        axis equal
        axis tight
        set(gca,'XTick',[], 'YTick', [])
        text(x_max/2, 9*y_max/10, "so close to square????", FontSize=60, HorizontalAlignment="center", Color='w')
        text(x_max/2, y_max*0.7, "MODE", FontSize=36, HorizontalAlignment="center", Color='w')
        poly1=define_hex_shape(1/2 * x_max, 1/2 * x_max + 1*(1/10)*y_max, 1/10*y_max,x_max/2,0.6*y_max);
        fill(poly1(:,1), poly1(:,2), [226/255, 227/255, 213/255], 'EdgeColor','none')
        poly2=define_hex_shape(1/5 * x_max, 1/5 * x_max + 1*(1/10)*y_max,1/10*y_max,x_button,0.6*y_max);
        fill(poly2(:,1), poly2(:,2), [204/255, 64/255, 99/255], 'EdgeColor', 'none')
        text(7/20 * x_max, 0.6*y_max, "cool", "HorizontalAlignment","center","VerticalAlignment","middle", "FontSize", 24)
        text(13/20 * x_max, 0.6*y_max, "chaotic", "HorizontalAlignment","center","VerticalAlignment","middle", "FontSize", 24)
        poly3=define_hex_shape(1/2 * x_max, 1/2 * x_max + 1*(1/10)*y_max, 1/10*y_max,x_max/2,0.3*y_max);
        fill(poly3(:,1), poly3(:,2), [112/255, 126/255, 194/255], 'EdgeColor','none')
        text(0.5 * x_max, 0.3*y_max, "PLAY", "HorizontalAlignment","center","VerticalAlignment","middle", "FontSize", 36)
        poly4=define_hex_shape(1/2 * x_max, 1/2 * x_max + 1*(1/10)*y_max, 1/10*y_max,x_max/2,0.1*y_max);
        fill(poly4(:,1), poly4(:,2), [221/255, 80/255, 191/255], 'EdgeColor','none')
        text(0.5 * x_max, 0.1*y_max, "WHAT????", "HorizontalAlignment","center","VerticalAlignment","middle", "FontSize", 36)
        axis([0 x_max 0 y_max])
        ax = gca;
        ax.Color = '#0c0b13';
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
                num_lives=5;
            end
            if mystery
                blocks=[ones(5,1), (0:4)';2,2;2,4;ones(5,1)*3,(0:4)';ones(5,1)*5,(0:4)';6,4;ones(5,1)*7,(0:4)';ones(5,1)*9,(0:4)';10,2;10,4;ones(5,1)*11,(0:4)';0,10;
                    ones(5,1)*1,(6:10)';2,10;ones(5,1)*4,(6:10)';5,8;5,10;ones(5,1)*6,(6:10)';8,10;ones(5,1)*9,(6:10)';10,10;ones(5,1)*12,(6:10)'];
            else
                blocks=[zeros(5,1),(6:10)';ones(5,1)*1,(0:4)';1,10;2,0;ones(3,1)*2,(8:10)';3,0;3,10;ones(5,1)*4,(6:10)';ones(5,1)*5,(0:4)';6,2;6,4;ones(5,1)*6,(6:10)';
                    ones(5,1)*7,(0:4)';7,8;7,10;ones(5,1)*8,(6:10)';ones(5,1)*9,(0:4)';10,0;10,2;10,4;10,10;ones(5,1)*11,(0:4)';ones(5,1)*11,(6:10)';12,10];
            end
            [num_blocks,~]=size(blocks);
            hold off
            clf
            hold on
            grid off
            axis([0 x_max 0 y_max])
            set(gca,'XTick',[], 'YTick', [])
            livesImages=gobjects(num_lives,1);
            for i = 0:(num_lives-1)
                xl=0.01*y_max*(i+1) + im_width*i;
                livesImages(i+1) = image([xl, xl+im_width], [0.99*y_max, 0.91*y_max], img);
            end
            % contains graphics objects, wayyyyyyyyyy faster so that high
            % pace gameplay is possible, otherwise fps rate drops to like 7
            % when redrawing every time
            blockPatches = gobjects(num_blocks,1);
            for i = 1:num_blocks
                p = blocks(i,1);
                q = blocks(i,2);
                sq = def_sq(1/105 * x_max + p*(8/105 * x_max), 0.9 * y_max - 29/35 * x_max + q*(8/105 * x_max), 1/15*x_max);
                blockPatches(i) = patch(sq(:,1), sq(:,2), 'w', 'EdgeColor','none');
            end
            progress = text_height(x_max-0.01*y_max,0.95*y_max,[num2str(num_blocks) '/' num2str(num_blocks)],0.05*y_max,'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'Color', 'w');
            blockAlive = true(num_blocks,1);
        end
        if (in4==1)
            game_state=1;
            tGifStart = tic;
        end
        tep = toc(lp);
        pause(max(1/fps - tep,0))
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
        hold off
        clf
        hold on
        grid off
        axis([0 x_max 0 y_max])
        set(gca,'XTick',[], 'YTick', [])
        poly1=define_hex_shape(0.3 * x_max, 0.3 * x_max + 1*(1/10)*y_max, 1/10*y_max,x_max*0.3,0.9*y_max);
        fill(poly1(:,1), poly1(:,2), [202/255, 165/255, 102/255], 'EdgeColor','none')
        text(0.3 * x_max, 0.9*y_max, "(don't come) back", "HorizontalAlignment","center","VerticalAlignment","middle", "FontSize", 36)
        text(0.5*x_max, 0.8*y_max,["hey cute jeans", "i think you know what this is", "but if not, hiii, this is my", ...
            "winter vac matlab project.", "it's t8 mcrae themed Arkanoid", ...
            "[you're so] cool - 5 lives", "chaotic - 3 lives", "left/a - move your platform left", ...
            "right/d - move to the right", "*the platform accelerates so be careful*", ...
            "feel free to send feedback to", "harik.sodhi[at]chch.ox.ac.uk", ...
            "live now, think later,", "harik <3"], HorizontalAlignment="center", FontSize=24, VerticalAlignment="top", Color='w')
        gif_x1=0.1*x_max;
        gif_x2=0.9*x_max;
        gif_y2=0.05 * x_max;
        gif_y1=0.85*x_max;
        t = toc(tGifStart);
        t = mod(t, gifDuration);
        k = find(cumDelay(2:end) > t, 1);
        image([gif_x1 gif_x2], [gif_y1 gif_y2], frames{k});
        set(gca,'YDir','normal')
        ax = gca;
        ax.Color = '#0c0b13';
        daspect([1 1 1])
        ax.XLim = [0 x_max];
        ax.YLim = [0 y_max];
        ax.XLimMode = 'manual';
        ax.YLimMode = 'manual';
        ClickLoc=get(gca,'CurrentPoint');
        ClickLoc=ClickLoc(1,1:2);
        [in1,~]=inpolygon(ClickLoc(1),ClickLoc(2),poly1(:,1),poly1(:,2));
        if (in1 == 1)
            game_state=0;
        end
        tep=toc(lp);
        pause(max(1/fps - tep,0))
    elseif (game_state==2)

        if (num_lives<0)
            game_state=3;
        end
        lp=tic;
        
        [num_blocks_left,~]=size(blocks);
        set(gca,'YDir','normal')
        ax = gca;
        ax.Color = '#0c0b13';
        daspect([1 1 1])
        ax.XLim = [0 x_max];
        ax.YLim = [0 y_max];
        ax.XLimMode = 'manual';
        ax.YLimMode = 'manual';
        tep=toc(lp);
        pause(max(1/60 - tep,0))
        fps=floor(1/tep);
        counting = toc(lp);

    end
end

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
function h = text_height(x, y, str, h_data, varargin)
    ax = gca;
    oldUnits = ax.Units;
    ax.Units = 'points';
    axPos = ax.Position;
    ax.Units = oldUnits;

    yRange = diff(ax.YLim);
    pointsPerData = axPos(4) / yRange;

    fontSize = h_data * pointsPerData;

    h = text(x, y, str, 'FontSize', fontSize, varargin{:});
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
    if (y>(yl-r) && y<(yl+s+r) && x>(xl-r) && x<(xl+r+s))
        side=0;
        if ((y-yc)-(x-xc))>0
            side=side+2;
        end
        if ((y-yc)+(x+xc))>0
            side=side+1;
        end
    else
        side=4;
    end
end