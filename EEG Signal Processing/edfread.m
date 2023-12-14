function [data,annotations] = edfread(filename,varargin)
%edfread Read data from the EDF or EDF+ file
%   DATA = EDFREAD(FILENAME) reads signal data from each record in the
%   EDF or EDF+ file specified in FILENAME. DATA is returned as a
%   timetable. Each row of DATA is a record and each variable is a signal.
%   RowTimes of the timetable correspond to the start time of each data
%   record relative to the start time of the file recording.
%
%   DATA = EDFREAD(...,'SelectedSignals',SIGNAMES) reads from FILENAME
%   the signals whose names are specified in the string vector SIGNAMES.
%   DATA is a timetable with a variable for each of the names specified in
%   SIGNAMES. If SIGNAMES is not specified, EDFREAD reads the data of all
%   the signals in the EDF or EDF+ file.
%
%   DATA = EDFREAD(...,'SelectedDataRecords',RECORDINDICES) reads from
%   FILENAME the data records specified in the vector RECORDINDICES. The
%   integers in RECORDINDICES must be unique and strictly increasing.
%   DATA is a timetable with number of rows equal to the number of indices
%   specified in RECORDINDICES. If RECORDINDICES is not specified, EDFREAD
%   reads all the data records in the EDF or EDF+ file.
%
%   DATA = EDFREAD(...,'DataRecordOutputType',DTYPE) specifies the data
%   output type, DTYPE, as 'timetable' or 'vector'. If DTYPE is specified
%   as 'timetable', the signals in DATA are returned as timetables. The
%   row times of each signal timetable correspond to the signal sample
%   times. If DTYPE is specified as 'vector', the signals in DATA are
%   returned as vectors. If DTYPE is not specified, 'DataRecordOutputType'
%   defaults to 'vector'.
%
%   DATA = EDFREAD(...,'TimeOutputType',TTYPE) specifies time output type,
%   TTYPE, as 'duration' or 'datetime'. If TTYPE is specified as
%   'duration', the times in DATA are returned as durations. If TTYPE is
%   specified as 'datetime', the times in DATA are returned as datetimes.
%   If TTYPE is not specified, 'TimeOutputType' defaults to 'duration'.
%
%   [DATA ANNOTATIONS] = EDFREAD(...) also returns a timetable with any
%   annotations present in the data records. The ANNOTATIONS timetable
%   contains these variables:
%
%   Onset      - Time at which each annotation occurred, specified either
%                as a datetime array indicating absolute times or as a
%                duration array indicating relative times in seconds
%                measured from the start time of the file.
%   Annotation - A string containing the text of each annotation.
%   Duration   - A duration scalar indicating the duration of the event
%                described by each annotation. If the file does not specify
%                annotation durations, this variable is returned as
%                NaN.
%
%   If there are no annotations in the file, ANNOTATIONS is returned as
%   an empty timetable.
%
%   % EXAMPLE 1:
%      % Read all the signal data from the EDF file example.edf
%      data = edfread('example.edf')
%
%   % EXAMPLE 2:
%      % Read the data for the signal "ECG" in the EDF file example.edf
%      [data,annotations] = edfread('example.edf','SelectedSignals',"ECG")
%
%   % EXAMPLE 3:
%      % Read the first, third, and fifth data records of the EDF file
%      % example.edf
%      data = edfread('example.edf','SelectedDataRecords',[1 3 5])
%
%   See also EDFINFO, EDFHEADER, EDFWRITE

%   Copyright 2020 The MathWorks, Inc.

%   References:
% 	  [1] Bob Kemp, Alpo Värri, Agostinho C. Rosa, Kim D. Nielsen, and
%         John Gade. "A simple format for exchange of digitized polygraphic
%         recordings." Electroencephalography and Clinical
%         Neurophysiology 82 (1992): 391-393.
% 	  [2] Bob Kemp and Jesus Olivan. "European data format 'plus' (EDF+),
%         an EDF alike standard format for the exchange of physiological
%         data." Clinical Neurophysiology 114 (2003): 1755-1761.

% Check number of input arguments
narginchk(1,9);

% Convert string to characters
[filename, varargin{:}] = convertStringsToChars(filename, varargin{:});

% Parse Name-Value pairs
[sigFormat, timeFormat, signals,...
    tempRecords] = parseInputs(filename,varargin{:});

% Error out when the file extension is not .edf/.EDF
[~, ~, ext] = fileparts(filename);
if ~strcmpi(ext,'.edf')
    error(message('signal:edf:InvalidFileExt'));
end

% Get file ID based on the file name.
[fid, fileInfo] = signal.internal.edf.openFile(filename,'r');

% Close the opened file using onCleanup
cleanup = onCleanup(@() fclose(fid));

try
    % Read the Header details
    [version, ~, ~, startDate, startTime, headerBytes,...
        reserve, numDataRecords, dataRecordDuration, numSignals,...
        sigLabels, transducerType, physicalDimension, physicalMinimum,...
        physicalMaximum, digitalMinimum, digitalMaximum, prefilter,...
        numSamples, sigReserve] = signal.internal.edf.readHeader(fid);
catch
    error(message('signal:edf:EDFFileNotCompliant', filename));
end

% Validate EDF/EDF+ files
signal.internal.edf.validateEDF(filename, fileInfo, version, startDate, startTime,...
    headerBytes, reserve, numDataRecords, numSignals,...
    sigLabels, numSamples, transducerType, physicalDimension,...
    physicalMinimum, physicalMaximum, digitalMinimum, digitalMaximum, ...
    prefilter, sigReserve, dataRecordDuration, mfilename, false);

% Check for Annotations signal label
annotationExist = strcmpi(sigLabels, 'EDF Annotations');

% Get signal indices
signalsIdx = getSignalIndices(filename, signals, sigLabels);

if (~isempty(tempRecords))
    records = tempRecords;
elseif (numDataRecords ~= -1)
    records = 1:numDataRecords;
else
    records = [];
end

% Check whether the file has only annotations or not
tDataRecordDurationFlag = (dataRecordDuration == 0);

% Read annotations and data from EDF files
if tDataRecordDurationFlag
    % Read only annotations when dataRecordDuration is 0 which is supported
    % only in EDF+ files
    [annotations,tempData] = signal.internal.edf.readData(fid, filename,...
        sigLabels, numDataRecords, physicalMaximum, physicalMinimum, ...
        digitalMaximum, digitalMinimum, numSignals, numSamples,...
        [], [], dataRecordDuration, true, false);
else
    % Read annotations and data for non-zero dataRecordDuration
    [annotations,tempData] = signal.internal.edf.readData(fid, filename,...
        sigLabels, numDataRecords, physicalMaximum, physicalMinimum, ...
        digitalMaximum, digitalMinimum, numSignals, numSamples,...
        signalsIdx, records, dataRecordDuration, false, true);
end

if (isempty(records))
    records = 1:size(tempData,1);
end

% Time Table computations
if (any(annotationExist))
    [recordTimes, onset, annotations,...
        tempDuration] = signal.internal.edf.readAnnotations(annotations);
    recordTimes = recordTimes(records);
    annotations = timetable(onset,annotations,tempDuration,...
            'VariableNames',["Annotations","Duration"]);
else
    annotations = timetable(duration.empty(0,1),...
        [],duration.empty(0,1),'VariableNames',...
        ["Annotations","Duration"]);
    recordTimes = (records.'- 1).* seconds(dataRecordDuration);
end
annotations.Properties.DimensionNames{1} = 'Onset';

tTimeFormatFlag = strcmp(timeFormat,'datetime');
if tTimeFormatFlag
    startDate = datetime([startDate '.' startTime],'InputFormat',...
        'dd.MM.yy.HH.mm.ss');
    recordTimes = recordTimes + startDate;
    if isempty(annotations)
        tEmpty = zeros(0,1);
        annotations.Onset = datetime(tEmpty, tEmpty, tEmpty);
    else
        annotations.Onset = annotations.Onset + startDate;
    end
end

if tDataRecordDurationFlag
    if tTimeFormatFlag
        tEmpty = zeros(0,1);
        recordTimes =  datetime(tEmpty,tEmpty,tEmpty);
    else
        recordTimes = duration.empty(0,1);
    end
    tblData = timetable(recordTimes,...
        [],duration.empty(0,1));
else
    reqSigLabels = sigLabels(signalsIdx);
    if (strcmp(sigFormat,'timetable'))
        tempData = convert2timetable(tempData,...
            recordTimes,seconds(dataRecordDuration ./ numSamples(signalsIdx)),...
            reqSigLabels);
    end
    
    % Check if all the signal names are different or not
    if length(unique(reqSigLabels)) < length(reqSigLabels)
        warning(message('signal:edf:UniqueLabels',filename));
        % Create variable names
        tempNo = strings(length(reqSigLabels),1);
        tempSignstr = "Signal Label ";
        for idx = 1:length(reqSigLabels)
            tempNo(idx) =  num2str(idx);
        end
        reqSigLabels = strcat(tempSignstr,tempNo,":",reqSigLabels);
    end
    
    tblData = table2timetable(cell2table(tempData,'VariableNames',...
        matlab.lang.makeValidName(reqSigLabels)),'RowTimes',recordTimes);
end
tblData.Properties.DimensionNames{1} = 'Record Time';
data = tblData;

if ~issortedrows(annotations)
    annotations = sortrows(annotations);
end

%Parse and validate given inputs
function [sigFormat, timeFormat, signals, records] = parseInputs(filename,...
    varargin)
ip = inputParser;
ip.addRequired('filename', ...
    @(x) validateattributes(x,{'char','string'},{'scalartext','nonempty'},...
    'EDFREAD','filename'));
ip.addParameter('SelectedSignals',[],...
    @(x) ((ischar(x)&&isrow(x)) || iscellstr(x)));%#ok<*ISCLSTR>
ip.addParameter('SelectedDataRecords',[],...
    @(x) validateattributes(x,{'numeric'},{'positive','integer','vector',...
    'increasing'}, 'EDFREAD','SelectedDataRecords'));
ip.addParameter('DataRecordOutputType','vector');
ip.addParameter('TimeOutputType','duration');
ip.parse(filename,varargin{:});

% Validate DataRecordOutputType
sigFormat = validatestring(ip.Results.DataRecordOutputType,...
    {'vector','timetable'},mfilename,"DataRecordOutputType");

% Validate TimeOutputType
timeFormat = validatestring(ip.Results.TimeOutputType,...
    {'datetime','duration'},mfilename,"TimeOutputType");

signals = ip.Results.SelectedSignals;

records = ip.Results.SelectedDataRecords;

% Calculate indices of given signals
function indices = getSignalIndices(filename,signals,labels)

annotationExist = strcmpi(labels,"EDF Annotations");
tempIndices = 1:numel(labels);

% Populate signals if not present, else find their indices.
if (isempty(signals))
    indices = tempIndices;
    indices(annotationExist) = [];
elseif ischar(signals) || iscellstr(signals)
    if iscolumn(signals)
        signals = signals.';
    end
    
    % Using ismember check whether all the signals
    [sigExists, indices] = ismember(signals,labels);
    
    % Check whether all the signals are specified using SelectedSignals
    % are valid or not
    if ~all(sigExists)
        error(message('signal:edf:InvalidSignalLabel', filename));
    end
end

% Change data to timetable
function data = convert2timetable(tdata,rtimes,timeValue,labels)
[nr,ns] = size(tdata);
data = cell(nr,ns);
for ii = 1:nr
    for jj = 1:ns
        data{ii,jj} = array2timetable(tdata{ii,jj},'TimeStep',timeValue(jj),...
            'StartTime',rtimes(ii),'VariableNames',labels(jj));
    end
end
