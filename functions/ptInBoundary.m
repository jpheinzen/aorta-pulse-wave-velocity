function inBoundary = ptInBoundary(pt, maxHeight, maxWidth)
x = pt(1); y = pt(2);
inBoundary = x <= maxWidth && x >= 1 && y <= maxHeight && y >= 1;
end