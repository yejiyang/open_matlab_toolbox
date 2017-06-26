function p = kspaceLineRecon(p, dy, dt, c, varargin)
%KSPACELINERECON    2D linear FFT reconstruction.
%
% DESCRIPTION:
%       kspaceLineRecon takes an acoustic pressure time-series p_ty
%       recorded over an evenly spaced array of sensor points on a line,
%       and constructs an estimate of the initial acoustic pressure
%       distribution that gave rise to those measurements using an
%       algorithm based on the FFT. The input p_ty must be indexed
%       p_ty(time step, sensor y position), where the sensor spacing is given
%       by dy, the temporal spacing given by dt, and the sound speed in the
%       propagation medium (which is assumed to be acoustically
%       homogeneous) is given by c. The output p_xy is indexed as
%       p_xy(x position, y position).
%
%       The code uses a k-space algorithm which performs (1) a Fourier
%       transform on the data p_ty along both t and y dimensions (into
%       wavenumber-frequency space, where the wavenumber component is along
%       the detector line), (2) a mapping, based on the dispersion relation
%       for a plane wave in an acoustically homogeneous medium, from
%       wavenumber-frequency space to wavenumber-wavenumber space (where
%       the second component is orthogonal to the detector line), and
%       finally (3) an inverse Fourier transform back from the wavenumber
%       domain to the spatial domain. The result is an estimate of the
%       initial acoustic pressure distribution from which the acoustic
%       waves originated. 
%
%       Steps (1) and (3) can be performed efficiently using the fast
%       Fourier transform (FFT); they are therefore fastest when the number
%       of samples and number of detector points are both powers of 2. The
%       mapping in step (2) requires an interpolation of the data from an
%       evenly spaced grid of points in the wavenumber-frequency domain to
%       an evenly-spaced grid of points in the wavenumber-wavenumber
%       domain. The option 'Interp' may be used to choose the interpolation
%       method.
%
%       The physics of photoacoustics requires that the acoustic pressure
%       is initially non-negative everywhere. The estimate of the initial
%       pressure distribution generated by this code may have negative
%       regions due to artefacts arising from differences between the
%       assumed model and the real situation, e.g., homogeneous medium vs.
%       real, somewhat heterogeneous, medium; infinite measurement surface
%       vs. finite-sized region-of-detection, etc. A positivity (or
%       non-negativity) condition can be enforced by setting the optional
%       'PosCond' to true which simply sets any negative parts of the final
%       image to zero. 
%
% USAGE:
%       p_xy = kspaceLineRecon(p_ty, dy, dt, c)
%       p_xy = kspaceLineRecon(p_ty, dy, dt, c, ...)
%
% INPUTS:
%       p_ty        - pressure time-series recorded over an evenly spaced
%                     array of sensor points on a line (indexed as t, y)
%       dy          - spatial step [m]
%       dt          - time step [s]
%       c           - acoustically-homogeneous sound speed [m/s]
%
% OPTIONAL INPUTS:
%       Optional 'string', value pairs that may be used to modify the
%       default computational settings.
%
%       'DataOrder' - String input which sets the data order (default =
%                     'ty'). Valid inputs are 'ty' and 'yt'
%       'Interp'    - string input controlling the interpolation method
%                     used by interp2 in the reconstruction (default =
%                     '*nearest')
%       'Plot'      - Boolean controlling whether a plot of the
%                     reconstructed estimate of the initial acoustic
%                     pressure distribution is produced (default = false).
%       'PosCond'   - Boolean controlling whether a positivity condition is
%                     enforced on the reconstructed estimate of the initial
%                     acoustic pressure distribution (default = false).
%
% OUTPUTS:
%       p_xy        - estimate of the initial acoustic pressure
%                     distribution (indexed as x, y)
%
% ABOUT:
%       author      - Bradley Treeby and Ben Cox
%       date        - 11th January 2009
%       last update - 13th August 2014
%       
% This function is part of the k-Wave Toolbox (http://www.k-wave.org)
% Copyright (C) 2009-2014 Bradley Treeby and Ben Cox
%
% See also interp2, kspacePlaneRecon, makeGrid

% This file is part of k-Wave. k-Wave is free software: you can
% redistribute it and/or modify it under the terms of the GNU Lesser
% General Public License as published by the Free Software Foundation,
% either version 3 of the License, or (at your option) any later version.
% 
% k-Wave is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
% more details. 
% 
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave. If not, see <http://www.gnu.org/licenses/>.

% Error: interp2 error in Matlab R2012b
matlab_ver = ver('matlab'); 
if strcmp(matlab_ver.Release, '(R2012b)')
    error('This function will not run in Matlab R2012b because of a bug in Matlab''s function interp2. It does work in prior and subsequent versions of Matlab.')
end

% start timer
tic;

% define defaults
num_req_inputs = 4;
data_order = 'ty';
interp_method = '*nearest';
plot_recon = false;
positivity_cond = false;

% replace with user defined values if provided
if nargin < num_req_inputs
    error('Incorrect number of inputs');
elseif ~isempty(varargin)
    for input_index = 1:2:length(varargin)
        switch varargin{input_index}
            case 'DataOrder'
                data_order = varargin{input_index + 1};
                if ~strcmp(data_order, 'ty') && ~strcmp(data_order, 'yt')
                    error('Unknown setting for optional input DataOrder');
                end
            case 'Interp'
                interp_method = varargin{input_index + 1};
            case 'Plot'
                plot_recon = varargin{input_index + 1};                
            case 'PlotRecon'
                plot_recon = varargin{input_index + 1};
            case 'PosCond'
                positivity_cond = varargin{input_index + 1};                
            otherwise
                error('Unknown optional input');
        end
    end
end

% reorder the data if needed (p_ty)
if strcmp(data_order, 'yt')
    p = p.';
end

% mirror the time domain data about t = 0 to allow the cosine transform to
% be computed using an FFT (p_ty)
p = [flipdim(p, 1); p(2:end, :)];

% extract the size of mirrored input data
[Nt, Ny] = size(p);

% update command line status
disp('Running k-Wave line reconstruction...');
disp(['  grid size: ' num2str(Ny) ' by ' num2str((Nt+1)/2) ' grid points']);
disp(['  interpolation mode: ' interp_method]);

% create a computational grid that is evenly spaced in w and ky, where 
% Nx = Nt and dx = dt*c
kgrid = makeGrid(Nt, dt*c, Ny, dy);

% from the grid for kx, create a computational grid for w using the
% relation dx = dt*c; this represents the initial sampling of p(w, ky)
w = c*kgrid.kx;

% remap the computational grid for kx onto w using the dispersion
% relation w/c = (kx^2 + ky^2)^1/2. This gives an w grid that is
% evenly spaced in kx. This is used for the interpolation from p(w, ky)
% to p(kx, ky). Only real w is taken to force kx (and thus x) to be
% symmetrical about 0 after the interpolation. 
w_new = (c*kgrid.k);

% calculate the scaling factor using the value of kx, where
% kx = sqrt( (w/c).^2 - kgrid.ky.^2 ) and then manually
% replacing the DC value with its limit (otherwise NaN results) 
sf = c^2*sqrt( (w/c).^2 - kgrid.ky.^2)./(2*w);
sf(w == 0 & kgrid.ky == 0) = c/2;

% compute the FFT of the input data p(t, y) to yield p(w, ky) and scale
p = sf.*fftshift(fftn(fftshift(p)));

% remove unused variables
clear sf;

% exclude the inhomogeneous part of the wave
p(abs(w) < abs(c*kgrid.ky)) = 0;

% compute the interpolation from p(w, ky) to p(kx, ky)and then force to be
% symmetrical 
p = interp2(kgrid.ky, w, p, kgrid.ky, w_new, interp_method);

% remove unused variables
clear kgrid w;

% set values outside the interpolation range to zero
p(isnan(p)) = 0;

% compute the inverse FFT of p(kx, ky) to yield p(x, y)
p = real(ifftshift(ifftn(ifftshift(p))));

% remove the left part of the mirrored data which corresponds to the
% negative part of the mirrored time data
p = p( (Nt + 1)/2:Nt, :);

% correct the scaling - the forward FFT is computed with a spacing of dt
% and the reverse requires a spacing of dy = dt*c, the reconstruction
% assumes that p0 is symmetrical about y, and only half the plane collects
% data (first approximation to correcting the limited view problem)
p = 2*2*p./c;

% enfore positivity condition
if positivity_cond
    disp('  applying positivity condition...');
    p(p < 0) = 0;
end

% update command line status
disp(['  computation completed in ' scaleTime(toc)]);

% plot the reconstruction
if plot_recon
    
    % allocate axis dimensions
    x_axis = [0 (Nt/2)*dt*c]; 
    y_axis = [0 Ny*dy];
    
    % select suitable axis scaling factor
    [x_sc, scale, prefix] = scaleSI(max([Ny*dy, (Nt/2)*dt*c])); 
    
    % select suitable plot scaling factor
    plot_scale = max(p(:));
    
    % create the figure
    figure;
    imagesc(y_axis*scale, x_axis*scale, p, [-plot_scale, plot_scale]);
    axis image;
    colormap(getColorMap);
    xlabel(['Sensor Position [' prefix 'm]']);
    ylabel(['Depth [' prefix 'm]']);
    colorbar;
end