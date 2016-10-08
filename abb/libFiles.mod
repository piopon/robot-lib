MODULE libFiles
    !*******************************************************************!
    ! Copyright (C) 2016 Piotr Ponikowski <pipon.github@gmail.com>      !
    !*******************************************************************!
    ! Module Name:  libFiles                                            !
    ! Description:  file operations                                     !
    ! Date:         2016-10-08                                          !
    ! Author:       Piotr Ponikowski <pipon.github@gmail.com>           !
    ! Contributors:                                                     !
    !*******************************************************************!    

    !procedure to create FULL file path
    ! arg: path - full file path to create
    PROC fileCreatePath(string path)
        CONST num maxNestLvl:=10;
        VAR num pathLength;
        VAR num lastSlashPos:=0;
        VAR num currSlashPos:=0;
        VAR num currLevel:=0;
        VAR string newParentFolder;
        VAR string folderStuct{maxNestLvl};

        !check if path is valid
        pathLength:=StrLen(path);
        IF pathLength>1 THEN
            !first find how many nest levels there are (from number of slashes)
            WHILE currSlashPos<>pathLength+1 DO
                Incr currLevel;
                currSlashPos:=StrFind(path,lastSlashPos+1,"/");
                folderStuct{currLevel}:=StrPart(path,lastSlashPos+1,currSlashPos-(lastSlashPos+1));
                lastSlashPos:=currSlashPos;
            ENDWHILE
            !make all level path
            FOR i FROM 1 TO currLevel DO
                newParentFolder:=newParentFolder+folderStuct{i}+"/";
                IF NOT fileDirExists(newParentFolder,folderStuct{i+1}) THEN
                    MakeDir newParentFolder+folderStuct{i+1};
                ENDIF
            ENDFOR
        ENDIF
    ENDPROC

    !function used to find if folder (searchDir) exists in parent (parentDir)
    ! ret: bool = folder exists (TRUE) or not (FALSE)
    ! arg: parentDir - parent folder to search in
    ! arg: searchDir - search folder we want to find
    FUNC bool fileDirExists(string parentDir,string searchDir)
        VAR bool result:=FALSE;
        VAR dir mainDir;
        VAR string currentFile;

        !check if parent folder exists 
        IF IsFile(parentDir\Directory) THEN
            !parent exists - lets try to find search folder
            OpenDir mainDir,parentDir;
            WHILE ReadDir(mainDir,currentFile) AND result=FALSE DO
                IF currentFile=searchDir result:=TRUE;
            ENDWHILE
            CloseDir mainDir;
        ENDIF

        RETURN result;
    ENDFUNC

    !procedure to resolve full file path to: directories, file and extension
    ! arg: fullPath - full file path
    ! arg: dirs - directories in inputted path
    ! arg: file - file name in inputted path
    ! arg: ext - file extension in inputted path
    PROC fileResolvePath(string fullPath,\INOUT string dirs,\INOUT string file,\INOUT string ext)
        VAR num pathLength;
        VAR num nextLevel;
        VAR num searchedLvl;
        VAR num extensionStart;
        VAR string output{3};

        !check if input is correct
        pathLength:=StrLen(fullPath);
        IF pathLength>0 THEN
            !lets extrude folders and file
            WHILE nextLevel<pathLength+1 DO
                nextLevel:=StrFind(fullPath,nextLevel+1,"/");
                IF nextLevel<pathLength+1 searchedLvl:=nextLevel;
            ENDWHILE
            !rozdzielamy odpowiednie elementy ze sciezki dostepu
            IF searchedLvl>0 THEN
                output{1}:=StrPart(fullPath,1,searchedLvl);
                output{2}:=StrPart(fullPath,searchedLvl+1,pathLength-searchedLvl);
            ELSE
                !there was no folders - it has to be only file inputted
                output{1}:="";
                output{2}:=fullPath;
            ENDIF
            !check if there is a dot (to extrude extension)
            extensionStart:=StrFind(output{2},1,".");
            IF extensionStart>StrLen(output{2}) THEN
                !no extension type - only file
                output{2}:=fullPath;
                output{3}:="";
            ELSE
                !there is extension in path - lets extrude it
                output{3}:=StrPart(output{2},extensionStart,StrLen(output{2})-extensionStart+1);
                output{2}:=StrPart(output{2},1,extensionStart-1);
            ENDIF
        ENDIF
        !check what user wants to receive
        IF Present(dirs) dirs:=output{1};
        IF Present(file) file:=output{2};
        IF Present(ext) ext:=output{3};
    ENDPROC

    !procedure to save variable of any type
    ! arg: filePath - full file path to save selected variable
    ! arg: varID - variable ID to name saved value
    ! arg: varVal - variable value to save
    FUNC bool fileSave(string filePath,string varID,string varVal)
        VAR bool result:=TRUE;
        VAR bool continue:=TRUE;
        VAR bool dirExists:=FALSE;
        VAR string message:="";
        VAR string fileDirs:="";
        VAR string fileName:="";
        VAR string fileExt:="";
        !ABB file operations variables
        VAR dir directory;
        VAR iodev saveFile;

        !lest separate full path to directiories, fileName and extension
        fileResolvePath filePath\dirs:=fileDirs\file:=fileName\ext:=fileExt;
        !write data to file
        WHILE continue DO
            !==========================================================
            !open inputted directory (if user placed them in filePath)
            IF continue THEN
                IF StrLen(fileDirs)>0 THEN
                    fileDirs:=fileDirs+"/";
                    IF IsFile(fileDirs\Directory) THEN
                        dirExists:=TRUE;
                        OpenDir directory,fileDirs;
                    ENDIF
                ENDIF
            ENDIF
            !==========================================================
            !open selected file
            IF continue THEN
                IF NOT IsFile(fileDirs+fileName+fileExt) THEN
                    !file doesnt exist - create and write to it
                    Open fileDirs+fileName+fileExt,saveFile\Write;
                ELSE
                    !file exists - append text to it
                    Open fileDirs+fileName+fileExt,saveFile\Append;
                ENDIF
            ENDIF
            !==========================================================
            !write variable id and value to file
            IF continue THEN
                Write saveFile,"<"+varID+">";
                Write saveFile,varVal;
            ENDIF
            !==========================================================
            !close directory and file (even if not opened)
            Close saveFile;
            CloseDir directory;
            !to exit while loop
            continue:=FALSE;
        ENDWHILE
        !return result
        RETURN result;
    ERROR
        !error recovery
        IF ERRNO=ERR_FILEACC THEN
            IF NOT dirExists THEN
                !folder structure doesnt exist
                fileCreatePath fileDirs;
                continue:=TRUE;
                RETRY;
            ENDIF
            message:="File/directory accessed incorectly!";
        ELSEIF ERRNO=ERR_FILEOPEN THEN
            message:="File/directory cannot be opened!";
        ELSEIF ERRNO=ERR_FILNOTFND THEN
            message:="File/directory not found!";
        ELSEIF ERRNO=ERR_FILEEXIST THEN
            message:="File/directory already exists";
        ENDIF
        ErrWrite "ERROR::fileSave",message\RL2:="File not saved!";
        result:=FALSE;
        continue:=FALSE;
    ENDFUNC
ENDMODULE
