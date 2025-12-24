function outputShape = reflecty(shape)
% this function reflects a shape about the y axis
% the input is the shape
% the output is the reflected shape
% harik
    % this uses matrix multiplication for reflection
    outputShape = [-1 0; 0 1] * shape;
end