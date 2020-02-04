function nm = loadmatfiles(s)
filedir = "/Users/dlee/visual-stimuli/matrix/naturalmovie/";
fileseed = num2str(s.seed);
fileformat = "*.mat";
filesearch = dir([filedir fileseed '/' fileformat]);
filename = filesearch(1).name;
nm = open([filedir fileseed '/' filename], "nm_intensity");
% should work here (dimension change********************************)
end