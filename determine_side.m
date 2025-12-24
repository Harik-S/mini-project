function side=determine_side(x,y,xl,yl,s,r)
% this returns 4 if the ball is outside the square. note that because i'm
% lazy and it doesn't make any visual difference
% for checking what side, we use diagonals to divide the plane into 4
% regions, which also represents the side its closest to.
% input - the x and y position of the ball centre, the x and y of the
% bottom left corner of the box, the side length of the box, and the radius
% of the ball
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