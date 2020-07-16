function us = upsample_s(s, usfactor, dim)
ssize = size(s);
sdim = size(ssize);

usvec = ones(sdim);
usvec(dim) = usfactor;
ussize = usvec .* ssize;
us = zeros(ussize); % initialize s

Index_s = cell(1, ndims(s));
Index_s(:) = {':'};
Index_us = cell(1, ndims(us));
Index_us(:) = {':'};

T = ussize(dim);
tr_vec = ceil((1:T)/usfactor);
for t = 1:T
    Index_us{dim} = t;
    Index_s{dim} = tr_vec(t);
    us(Index_us{:}) = s(Index_s{:});
end
end
