function mat2movie(mat, quality, fr)
if ndims(mat) ==  4
    % time, color, x, y
    [T, c, x, y] = size(mat);
    % generate video file
    v = VideoWriter('sample.mp4', 'MPEG-4');
    v.Quality = quality;
    v.FrameRate = fr;
    open(v)
    for t = 1:T
        fr = squeeze(mat(t, :, :, :));
        fr = permute(fr, [2, 3, 1]);
        writeVideo(v, fr);
    end
    close(v)
else
    % time, x, y
    [T, x, y] = size(mat);
    % generate video file
    v = VideoWriter('sample.mp4', 'MPEG-4');
    v.FrameRate = fr;
    v.Quality = quality;
    open(v)
    for t = 1:T
        fr = squeeze(mat(t, :, :));
        writeVideo(v, fr);
    end
    close(v)
end
end