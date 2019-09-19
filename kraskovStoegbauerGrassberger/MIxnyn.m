% Copyright 2009 Alexander Kraskov, Harald Stoegbauer, Peter Grassberger
%-----------------------------------------------------------------------------------------
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should receive a copy of the GNU General Public License
% along with this program.  See also <http://www.gnu.org/licenses/>.
%----------------------------------------------------------------------------------------- 
% Contacts:
%
% Harald Stoegbauer <h.stoegbauer@gmail.com>
% Alexander Kraskov <alexander.kraskov@gmail.com>
%-----------------------------------------------------------------------------------------
% Please reference
% 
% A. Kraskov, H. Stogbauer, and P. Grassberger,
% Estimating mutual information.
% Phys. Rev. E 69 (6) 066138, 2004
%
% in your published research.
% 
% Minor modification to $PATH variables by 
%
% Holmes, C.M. & Nemenman, I.  Estimation of mutual information for
% real-valued data with error bars and controlled bias. 
% Submitted, 2018.
%


function miout=MIxnyn(x,y,kneig);

% Calculate MI value between 2 vector of any dimension (rectangular
% version)
% x....input data mxn   m...channelnummer  n...sampling points  m<<n
% kneig... k nearest neigbor for MI algorithm


%default-values
if ~exist('kneig'), kneig=6; end


% check input data if format is correct
[Ndx,Nx]=size(x);
if Ndx>Nx
    x=x';
    [Ndx,Nx]=size(x);
end
[Ndy,Ny]=size(y);
if Ndy>Ny
    y=y';
    [Ndy,Ny]=size(y);
end

if Nx~=Ny
    if Nx>Ny
        N=Ny;
    else
        N=Nx;
    end
    fprintf('The two input vectors must have the same length !!!!');
    fprintf('Caluculation using the %d datapoints',N);
    
else
    N=Nx;    
end


% save data for C-Programm
% generate random file name to allow multiple instances of MIxnyn.exe to
% run simultaneously
savestr = ['zwspMIxnyn-' num2str(dec2hex(round(rand(1)*100000))) '.txt'];
while isfile(savestr)
    savestr = ['zwspMIxnyn-' num2str(dec2hex(round(rand(1)*100000))) '.txt'];
end

zwsp=[x;y]';
save(savestr, 'zwsp', '-ASCII');


% BRYCE'S C PROGRAM CODE:
% % execute C Program
% check OS to determine how to call UNIX command
if ispc
    unix_str = ['MIxnyn ',savestr,' ',num2str(Ndx),' ',num2str(Ndy),' ',num2str(N),' ',num2str(kneig)];
elseif ismac
    unix_str = ['./MIxnyn ',savestr,' ',num2str(Ndx),' ',num2str(Ndy),' ',num2str(N),' ',num2str(kneig)];
else
    error('MIxnyn >> Unable to recognize operating system...');
end

[a unout]=unix(unix_str);

% % RACHEL'S C PROGRAM CODE: 
% % % execute C Programm MAC
% % [a unout]=unix(['MIxnyn ',savestr,' ',num2str(Ndx),' ',num2str(Ndy),' ',num2str(N),' ',num2str(kneig)]);
% % miout=str2num(unout);
% % 
% savepath = strcat('C:\Users\RBARKE2\Projects\MI_2_Neurons\ContinuousMIEstimation/',savestr);
% 
% % % 
% % % execute C Programm WINDOWS
% mcmd = ['C:\Cygwin\bin\bash.exe --login -c "''/cygdrive/c/Users/RBARKE2/Projects/MI-Breath-Muscles/ContinuousMIEstimation/kraskovStoegbauerGrassberger/a.exe'' ''savepath'' ' num2str(Ndx) ' ' num2str(Ndy) ' ' num2str(N) ' ' num2str(kneig) ];
% [a unout]=system(mcmd);

 miout=str2num(unout);
 %delete(savestr);



