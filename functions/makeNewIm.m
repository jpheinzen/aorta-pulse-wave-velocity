function im = makeNewIm(means, assignments)
% Makes a new image from the assignments into the corresponding means
% values
im = reshape(means(1,assignments,:),[size(assignments),3]);
end