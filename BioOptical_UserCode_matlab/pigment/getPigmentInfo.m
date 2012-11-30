function [profileInfo,variableInfo,globalAttributes]=getPigmentInfo(ncFile)
%% getPigmentInfo
% This function reads the information of an absorption NetCDF file from the BioOptical Database
% sub-facility. For each NetCDF file, there could be many profile for many stations. All the 
% information concerning the profiles and variables measured are harvested
%
% Syntax: [profileInfo,variableInfo,globalAttributes]=getPigmentInfo(ncFile)
%
% Inputs:  ncFile - location of the NetCDF file to process
%
% Outputs: profileInfo - structure of all the profile, time and location associated to each profile
%          variableInfo- structure of different variables and their attributes
%          globalAttributes - structure of global attributes names and values
%
%
% Example:
%    [profileInfo,variableInfo,globalAttributes]=getPigmentInfo('/this/is/thepath/IMOS_test.nc')
%
% Other m-files
% required:
% Other files required:
% Subfunctions: mkpath
% MAT-files required: none
%
% See also:
% getPigmentData,plotPigment,getPigmentData
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  http://froggyscripts.blogspot.com
% Aug 2011; Last revision: 28-Nov-2012
%
% Copyright 2012 IMOS
% The script is distributed under the terms of the GNU General Public License 


if exist(ncFile,'file') ==2
    nc = netcdf.open(char(ncFile),'NC_NOWRITE');
    
    [allVarnames,~]=listVarNC(nc);
    
    % 8 known variables
    dimidTIME = netcdf.inqVarID(nc,'TIME');
    dimidLAT = netcdf.inqVarID(nc,'LATITUDE');
    dimidLON = netcdf.inqVarID(nc,'LONGITUDE');
    dimidDEPTH= netcdf.inqVarID(nc,'DEPTH');
    dimidstation_name= netcdf.inqVarID(nc,'station_name');
    dimidprofile= netcdf.inqVarID(nc,'profile');
    dimidstation_index= netcdf.inqVarID(nc,'station_index');
    dimidrowSize= netcdf.inqVarID(nc,'rowSize');
    
    
    [~, numvars, ~, ~] = netcdf.inq(nc);
    
    tttt=1:numvars;
    ttt=tttt(setdiff(1:length(tttt),[tttt(dimidTIME+1),tttt(dimidLAT+1),...
        tttt(dimidLON+1),tttt(dimidDEPTH+1),...
        tttt(dimidstation_name+1),tttt(dimidprofile+1),tttt(dimidstation_index+1),...
        tttt(dimidrowSize+1)]));
    for ii=1:length(ttt)
        dimidVAR{ii}= netcdf.inqVarID(nc,allVarnames{ttt(ii)});
        variableList{ii}=allVarnames{ttt(ii)};
        [~,varAtt{ii}]=getVarNetCDF(variableList{ii},nc);
        varAtt{ii}.varname=variableList{ii};
        variableInfo.(variableList{ii})=varAtt{ii};
    end
    
    
    [lat,~]=getVarNetCDF('LATITUDE',nc);
    [lon,~]=getVarNetCDF('LONGITUDE',nc);
    [time,~]=getVarNetCDF('TIME',nc);
    
    
    %% which profile do we plot ?
    profileData=getVarNetCDF('profile',nc);
    StationIndex=(netcdf.getVar(nc,dimidstation_index));
    StationNames=(netcdf.getVar(nc,dimidstation_name));
    strlen=size(StationNames,1);
    nStation=length(unique(StationIndex));    
    for iiStation=1:nStation
        stationName{iiStation}=regexprep(StationNames(1:strlen,iiStation)','[^\w'']','');
    end
    
    
    for ii=1:length(profileData)
        profileInfo(ii).index=ii;
        profileInfo(ii).stationName=stationName(StationIndex(ii));
        profileInfo(ii).stationLatitude=lat(StationIndex(ii));
        profileInfo(ii).stationLongitude=lon(StationIndex(ii));
        profileInfo(ii).profileTime=time(ii);
    end
    %
    %     profileInfo.stationName=stationName;
    %     profileInfo.stationLatitude=lat;
    %     profileInfo.stationLongitude=lon;
    %     profileInfo.stationTime=time;
    
    [globalAttributes.gattName,globalAttributes.gattVal] = getGlobAttNC(nc);
    
    netcdf.close(nc)
else
    return
end