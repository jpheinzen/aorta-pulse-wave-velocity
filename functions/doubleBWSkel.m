function [out, skeleim, endpts] = doubleBWSkel(Lim, minBL)
out = bwskel(Lim,'MinBranchLength',minBL);
skeleim = bwskel(out,'MinBranchLength',minBL);
endpts = bwmorph(skeleim,'endpoints');
end