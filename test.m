targets = [0.001 0.002 0.005 0.01 0.02 0.05 0.1];
N = 50;
for k = 1:numel(targets)
    dt = targets(k);
    times = zeros(N,1);
    for i=1:N
        t = tic;
        pause(dt);
        times(i) = toc(t);
    end
    fprintf('target=%.4f mean=%.5f std=%.5f\n', dt, mean(times), std(times));
end