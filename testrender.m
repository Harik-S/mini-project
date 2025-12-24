N = 100;

% 1) empty drawnow (baseline)
clf; figure(gcf); axis off;
t=tic;
for i=1:N, drawnow; end
fprintf('avg drawnow empty = %.6f s\n', toc(t)/N);

% 2) image blit test (texture blit)
clf;
ax = axes('Position',[0 0 1 1],'Units','normalized');
imagesc(ax, rand(400,800));
axis off; drawnow;
t=tic;
for i=1:N, drawnow; end
fprintf('avg drawnow image = %.6f s\n', toc(t)/N);

% 3) vector-heavy test (many patches)
clf;
ax = axes('Position',[0 0 1 1],'Units','normalized'); axis off; hold on;
n = 200;
for k=1:n
    x = rand*1000; y=rand*1000; s=20;
    p = [x,y; x+s,y; x+s,y+s; x,y+s];
    patch('XData',p(:,1),'YData',p(:,2),'FaceColor',[rand,rand,rand],'EdgeColor','none');
end
drawnow;
t=tic;
for i=1:N, drawnow; end
fprintf('avg drawnow many patches = %.6f s\n', toc(t)/N);
