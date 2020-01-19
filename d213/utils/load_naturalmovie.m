function nm = load_naturalmovie(filename)
filedir = "/Users/dlee/visual-stimuli/d213/movie/";
filename = "mov_Birds_moving objects in whold field_f1811_intensity.mat";
nm = load(filedir + filename, 'mm_intensity');
end