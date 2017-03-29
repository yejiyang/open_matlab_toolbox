SeisLab 3.02

This folder contains a folder, S4M, with Matlab functions for seismic and 
well-log analysis, in the following collectively called SeisLab.

Folder "Other" contains support functions written by others and available
from the Matlab Central Program Exchange.

A manual in PDF format explains the philosophy behind the design of the
functions in SeisLab and the way they can be used. For good measure, I have 
also added a few sample scripts (verba docent, exempla trahunt).

To run SeisLab functions, copy folder S4M to your computer and add 
it and its subfolders to your Matlab path (please note that
folders that start with "@" are class directories and need not be included 
explicitly in the Matlab path; Matlab will find them anyway; the same 
is true for "private" folders). 

The folder "HelpFiles" need not be included in the Matlab path either 
as it contains only text files that provide instructions for the use of 
certain figures that expect user input.

I recommended that you run the sample scripts to ascertain that the 
installation was successful.

Please note that I do not promise any kind of support for these functions. 
However, should I happen to hear about a problem that illustrates an obvious 
bug (not a "feature") or that tickles my fancy I might do something about 
it and include the fix (or improvement) in the next release.

However, please note that some functions in this release of SeisLab may still 
not work with Matlab version R2015a or higher. I justhave not tested them in 
a thorough enough manner.

Also, function s_volume_browser, a viewer for 3-D data volumes, requires 
the volume browser package available on the Matlab file exchange 
http://www.mathworks.com/matlabcentral/fileexchange/13526

Eike Rietsch
