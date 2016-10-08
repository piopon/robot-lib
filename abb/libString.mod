MODULE libString
    !*******************************************************************!
    ! Copyright (C) 2016 Piotr Ponikowski <pipon.github@gmail.com>      !
    !*******************************************************************!
    ! Module Name:  libString                                           !
    ! Description:  basic string operations                             !
    ! Date:         2016-10-07                                          !
    ! Author:       Piotr Ponikowski <pipon.github@gmail.com>           !
    ! Contributors:                                                     !
    !*******************************************************************!    

    !function counting no of sub-strings (and remembering their positions) in inputted string 
    ! ret: num = number of sub-strings
    ! arg: fullStr - string in which we count sub-strnigs
    ! arg: subStr - sub-string to be found
    ! arg: subStrPos - positions of found sub-strings
    FUNC num strCount(string fullStr,string subStr\INOUT num subStrPos{*})
        VAR num result:=0;
        VAR num currPos:=-1;

        !find sub-string in whole text
        currPos:=StrMatch(fullStr,1,subStr);
        WHILE currPos<>StrLen(fullStr)+1 DO
            Incr result;
            !check if we want to get sub-strings positions
            IF Present(substrPos) THEN
                IF result<=Dim(subStrPos,1) THEN
                    subStrPos{result}:=currPos;
                ELSE
                    ErrWrite "ERROR::strCount","subStrPos table overflow! Increase table size."\RL2:="Program continues, but not all data is included...";
                    currPos:=StrLen(fullStr);
                ENDIF
            ENDIF
            !find next sub-string position
            currPos:=StrMatch(fullStr,currPos+1,subStr);
        ENDWHILE

        RETURN result;
    ENDFUNC

    !function used to fill input string with sub-string (original substring will be overwritten
    ! ret: string = string filled with inputted sub-string
    ! arg: fullStr - original string
    ! arg: fillStr - filling string
    ! arg: startPos - position to start filling
    FUNC string strFill(string fullStr,string fillStr,num startPos)
        VAR string result;
        VAR num fullLen;
        VAR num currLen;

        !check if startPos is inside string
        fullLen:=StrLen(fullStr);
        IF startPos<=fullLen THEN
            result:=strSubstring(fullStr,1,startPos);
            result:=result+fillStr;
            !if new string is smaller than original then add its remain part
            currLen:=StrLen(result);
            IF currLen<fullLen THEN
                result:=result+strSubstring(fullStr,fullLen-currLen,fullLen);
            ENDIF
        ELSE
            !startPos outside string - return original string
            ErrWrite "ERROR::strFill","startPos is outside fullStr"\RL2:="Program continues, but no fill not effected...";
            result:=fullStr;
        ENDIF

        RETURN result;
    ENDFUNC

    !function used to get sub-string from string (by defining start and stop pos)
    ! ret: string = sub-string from string
    ! arg: fullString - original string containing interesting sub-string
    ! arg: startPos - sub-string start position in original position
    ! arg: stopPos - sub-string end position in original position
    FUNC string strSubstring(string fullStr,num startPos,num stopPos)
        VAR string result;
        VAR num fullLen;

        !check if startPos is in string
        fullLen:=StrLen(fullStr);
        IF startPos<=fullLen THEN
            !check if stopPos is in string
            IF stopPos>fullLen THEN
                stopPos:=fullLen;
            ENDIF
            !get part of string
            result:=StrPart(fullStr,startPos,stopPos-startPos);
        ELSE
            !startPos outside string - return original string
            ErrWrite "ERROR::strFill","startPos is outside fullStr"\RL2:="Program continues, but no fill not effected...";
            result:=fullStr;
        ENDIF

        RETURN result;
    ENDFUNC

    !function to replace selected sub-string with another
    ! ret: string = string after replaced sub-string
    ! arg: fullString - original string before sub-string replacing
    ! arg: replaceWhat - what sub-string we want to replace
    ! arg: replaceWhit - new sub-string to replace selected old one
    FUNC string strReplace(string fullString,string replaceWhat,string replaceWith)
        VAR string result;
        VAR string prePart:="";
        VAR string postPart:="";
        VAR num cutStringPos;
        VAR num cutStringLen;
        VAR num fullStringLen;

        !get original string length and check if there is inputted sub-string
        fullStringLen:=StrLen(fullString);
        cutStringPos:=StrMatch(fullString,1,replaceWhat);
        IF cutStringPos<fullStringLen+1 THEN
            !sub-string exists
            cutStringLen:=StrLen(replaceWhat);
            !remeber string before and after sub-string
            prePart:=StrPart(fullString,1,cutStringPos-1);
            postPart:=StrPart(fullString,cutStringPos+cutStringLen,fullStringLen-(cutStringPos+cutStringLen-1));
            !check if new string will fit in 80 chars
            IF StrLen(prePart+replaceWith+postPart)<80 THEN
                !new string is ok (return it)
                result:=prePart+replaceWith+postPart;
            ELSE
                !new string is too long (trim it to 80 chars)
                ErrWrite "ERROR::strReplace","New string after replace is longer than 80 chars!"\RL2:="Returning original string...";
                result:=fullString;
            ENDIF
        ELSE
            !sub-string doesnt exist (return original string)
            ErrWrite "ERROR::strReplace","Original sub-string not existent!"\RL2:="Returning original string...";
            result:=fullString;
        ENDIF

        RETURN result;
    ENDFUNC
ENDMODULE
