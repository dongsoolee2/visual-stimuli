function g = fitGamma(filename, n, table)
% FUNCTION g = fitGamma(filename, [n = 20], [table = false])
%
% Fit either a simple gamma correction factor or a full gamma table 
% from luminance data in the given HDF5 file.
%
% Parameters
% ----------
% filename : string
% 	The filename from which to load data.
%
% n : int
% 	The number of intensity values used in the stimulus. Defaults to 20.
%
% table : boolean
% 	If true, compute a full gamma-correction table, by fitting a sigmoid
% 	to the raw data. If false, the default, compute only a single gamma
%	correction factor, by fitting the function:
%
%		Vout = Vin ^ gamma
%
% Returns
% -------
%
% g : double or array
% 	Either the gamma-correction factor, or the full gamma table.
%
% (C) 2016 Benjamin Naecker bnaecker@stanford.edu

if nargin == 1
	n = 20;
	table = false;
elseif nargin == 2
	table = false;
end

luminance = compute_luminance(filename, n);
vout = luminance - min(luminance);
vout = vout / max(vout);
vout = vout(:);
vin = linspace(0, 1, n);
vin = vin(:);

if table == true
	fo = fittype(@(g,m,x) 1./(1+exp(-g.*(x-m))));
	fopts = fitoptions(fo);
	fopts.StartPoint = [1 1];
	fopts.Lower = [1e-3, 1e-3];
	fopts.Upper = [1e3, 1e3];
else
	fo = fittype(@(g,x) x.^g);
	fopts = fitoptions(fo);
	fopts.StartPoint = [1];
	fopts.Lower = [1e-3];
	fopts.Upper = [1e3];
end
cf = fit(vin, vout, fo, fopts);

plot(vin, vout);
hold on;
plot(vin, cf(vin), 'r*');
legend('Measured luminance', 'Fit')
if table
	g = cf(vin) * ones(1, 3);
	title(sprintf('Fit sigmoid midpoint = %0.2f, slope = %0.2f', ...
		cf.m, cf.g));
else
	g = cf.g;
	title(sprintf('Fit gamma = %0.2f', cf.g));
end

end % end function


function luminance = compute_luminance(filename, n)
% Return the luminance values from an HDF5 file

IFI = 0.013328; 	% Inter-flip interval, assuming 75Hz
WAIT_FRAMES = 2;	% Number of frames between each frame in the stimulus
NUM_FRAMES = 20;	% Number of frames at each luminance value

pd = h5read(filename, '/data', [1 1], [Inf 1]); % read just photodiode
finfo = h5info(filename);
sample_rate = double(finfo.Datasets.Attributes(...
	strcmp({finfo.Datasets.Attributes.Name}, 'sample-rate')).Value);

samples_per_intensity = round(NUM_FRAMES * IFI * sample_rate);
start_idx = round(IFI * WAIT_FRAMES * sample_rate);
end_idx = round(IFI * WAIT_FRAMES * sample_rate * n * NUM_FRAMES);
raw_data = pd(start_idx : end_idx);

luminance = zeros(n, 1);
for li = 1:n
	luminance(li) = mean(raw_data((li - 1) * samples_per_intensity + 1 : ...
		li * samples_per_intensity));
end

end % end function

