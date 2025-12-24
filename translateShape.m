function editedShape = translateShape(shape,xShift,yShift)
% translateShape = this function translates a shape using matrix logic
% input: the matrix which contains the original shape and the x and y
% shifts
% output: the final shape
% harik
    dim = size(shape);
    % this creates a matrix which represents the translation. dim is stored
    % as a variable because executing it twice would be less
    % computationally efficient.
    shiftm = [xShift * ones(1,dim(2)); yShift * ones(1,dim(2))];
    editedShape = shape + shiftm;
end