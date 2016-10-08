MODULE libTables
    !*******************************************************************!
    ! Copyright (C) 2016 Piotr Ponikowski <pipon.github@gmail.com>      !
    !*******************************************************************!
    ! Module Name:  libTables                                           !
    ! Description:  basic table operations (search, sort, etc.)         !
    ! Date:         2016-10-08                                          !
    ! Author:       Piotr Ponikowski <pipon.github@gmail.com>           !
    ! Contributors:                                                     !
    !*******************************************************************! 

    !function used to inspect one dimension bool table and check if specified conditions are met
    ! ret: bool = result of table inspection (check if elements met selected condition)
    ! arg: table - bool table to check
    ! arg: allTrue - condition: all elements ale set to TRUE
    ! arg: allFalse - condition: all elements ale set to FALSE
    ! arg: noOfTrue - condition: no of elements are set to TRUE
    ! arg: noOfFalse - condition: no of elements are set to FALSE
    FUNC bool tableBoolCondition(VAR bool table{*}\switch allTrue|switch allFalse|num noOfTrue|num noOfFalse)
        VAR bool result:=FALSE;
        VAR bool currentBoolVal:=FALSE;
        VAR num minValue:=0;
        VAR num valuesOK:=0;

        !check minimum arguments number to meet condition
        IF Present(allTrue) OR Present(allFalse) THEN
            minValue:=Dim(table,1);
        ELSEIF Present(noOfTrue) THEN
            minValue:=noOfTrue;
        ELSEIF Present(noOfFalse) THEN
            minValue:=noOfFalse;
        ELSE
            minValue:=Dim(table,1);
        ENDIF
        !scan whole table and check inputted condition for all elements
        FOR i FROM 1 TO Dim(table,1) DO
            currentBoolVal:=table{i};
            IF (Present(allTrue) OR Present(noOfTrue)) AND currentBoolVal=TRUE Incr valuesOK;
            IF (Present(allFalse) OR Present(noOfFalse)) AND currentBoolVal=FALSE Incr valuesOK;
        ENDFOR
        !check how many values are OK
        result:=valuesOK>=minValue;

        RETURN result;
    ENDFUNC

    !function used to find biggest/smallest value/element in num table
    ! arg: table - on dimension num table which is inspected for finding specified num
    ! arg: biggest - biggest value in table / element with biggest value in table
    ! arg: smallest - smallest value in table / element with smallest value in table
    ! arg: value - use this agrument if you want to find biggest/smallest VALUE
    ! arg: elementNo - use this argument if you want to find biggest/smallest value ELEMENT
    FUNC num tableNumFind(num table{*},\switch biggest|switch smallest,\switch value|switch elementNo)
        VAR num result:=0;
        VAR num lowElementVal:=9E9;
        VAR num highElementVal:=-9E9;

        !check if user specified correct optional agruments
        IF Present(biggest) XOR Present(smallest) THEN
            IF Present(value) XOR Present(elementNo) THEN
                !scan whole num table
                FOR i FROM 1 TO Dim(table,1) DO
                    !check what we want to find
                    IF Present(smallest) THEN
                        !remember smallest value
                        IF lowElementVal>table{i} THEN
                            lowElementVal:=table{i};
                            result:=i;
                        ENDIF
                    ELSEIF Present(biggest) THEN
                        !remember biggest value
                        IF highElementVal<table{i} THEN
                            highElementVal:=table{i};
                            result:=i;
                        ENDIF
                    ENDIF
                ENDFOR
                !result contains biggest/smallest element number
                !if we want value we have to get it
                IF Present(value) result:=table{result};
            ELSE
                ErrWrite "ERROR::tableNumFind","You must specify what to search: value OR element number!";
            ENDIF
        ELSE
            ErrWrite "ERROR::tableNumFind","You must specify what to search: biggest OR smallest!";
        ENDIF

        RETURN result;
    ENDFUNC
ENDMODULE
