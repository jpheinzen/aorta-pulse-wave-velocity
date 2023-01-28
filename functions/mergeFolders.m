function mergeFolders(folderName,checkAllFilesCpd)
% Use this to merge all .tif files into one folder after taking a video

arguments
    folderName {mustBeTextScalar}
    checkAllFilesCpd {mustBeNumericOrLogical} = true
end

% Making sure input directory exists
if ~exist(folderName,'dir')
    error("mergeFolder:dirDoesNotExist",...
        'Directory ''%s'' does not exist',folderName)
end

% Getting names of all subfolders
subFolderNames = dir(folderName);

% making a new folder for all files found that aren't .tif's
extraFiles = strcat(folderName,'/extraFiles');
if exist(extraFiles,'dir')
    error("mergeFolder:dirAlreadyExists",...
        'Directory ''%s'' already exists. Delete and try again.',...
        extraFiles)
%     rmdir(extraFiles,'s')
end
[success,message,messageId] = mkdir(folderName,'extraFiles');
if ~success
    error(messageId,message)
end


for fi = 1:length(subFolderNames)
    % file path of subFolders
    subfolderFilepath = strcat(folderName,'/',subFolderNames(fi).name);
    if subFolderNames(fi).name(1) ~= '.' && ...
            subFolderNames(fi).name ~= "extraFiles"

        if ~subFolderNames(fi).isdir
            mvFiles(subfolderFilepath, extraFiles)

        else    % subfolder is a directory

            % Get filepath of all .tif files
            filepath = strcat(subfolderFilepath,'/*.tif');
            mvFiles(filepath, folderName)

            % move all extra files to extraFiles folder
            extraFilepath = strcat(subfolderFilepath,'/*');
            mvFiles(extraFilepath, extraFiles)

            % remove subfolder
            [success,message,messageId] = rmdir(subfolderFilepath);
            if ~success
                error(messageId,message)
            end
        end
    end

    printProgress(fi,length(subFolderNames),"Copying files in sub folders")
end

% check to make sure all the files are copied
if checkAllFilesCpd
    fprintf('Checking all files are there...\n')
    tifName = dir(strcat(folderName,"/*.tif"));

    % less strict on length, may not be in order though??
    tifName = string({tifName(:).name}');
    % strict that every name must have the same length
    % vidName = string(cell2mat({vidName(:).name}'));

    [~,~]= checkVidOrder(tifName,true,true);
end

fprintf('Done.\n')
end

%%
function mvFiles(sourceFile, destination)
% making sure there is at least one file in the folder 
%   (that isn't '.' or '..' becuase they can't be copied
files = dir(sourceFile);
fileNames = string({files.name}');
fileNames = fileNames(fileNames ~= "." & fileNames ~= "..");

if ~isempty(fileNames)
    % move all source files to destination
    [success,message,messageId] = movefile(sourceFile, destination);
    if ~success
        error(messageId,message)
    end
end
end





