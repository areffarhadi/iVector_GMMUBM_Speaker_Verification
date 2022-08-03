function matrix = NormalizeNorm(matrix, dim)
if (nargin == 1)
    dim = 1;
end
if (dim == 1)
    m = size(matrix, 1);
    for i = 1 : m
        matrix(i, :) = matrix(i, :) / norm(matrix(i, :));
    end
else
    m = size(matrix, 2);
    for i = 1 : m
        matrix(:, i) = matrix(:, i) / norm(matrix(:, i));
    end
end