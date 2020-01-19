function mat2movie(mat)
% time, x, y
[T, x, y] = size(mat);
% generate video file
v = VideoWriter('sample.mp4', 'MPEG-4');
open(v)
for t = 1:T
    fr = squeeze(mat(t, :, :));
    writeVideo(v, fr);
end
close(v)
end