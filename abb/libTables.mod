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

    !function used to concate two tabs into one table (table1 elements are first)
    ! ret: num = number of elements in concated table
    ! arg: table1 - table 1 which elements will be first in concated table
    ! arg: table2 - table 2 which elements will be second in concated table
    ! arg: concatedTable - concated table with elements from table1 and table2
    ! arg: skipElementVal - value of element that is skipped in concating (considering as zero/empty element)
    FUNC num tableNumConcate(num table1{*},num table2{*},INOUT num concatedTable{*}\num skipElementVal)
        VAR num result:=0;
        VAR num concatedElements:=0;
        VAR num zeroElement:=-1;

        !check if result table is big enough
        IF Dim(concatedTable,1)>=Dim(table1,1)+Dim(table2,1) THEN
            !check user optional inputs
            IF Present(skipElementVal) zeroElement:=skipElementVal;
            !filling concated tablle with zero/empty elements
            tableNumFill\table1D:=concatedTable,zeroElement;
            !get all non-zero/non-empty elements from first table to concated table
            FOR i FROM 1 TO Dim(table1,1) DO
                IF table1{i}<>zeroElement THEN
                    Incr concatedElements;
                    concatedTable{concatedElements}:=table1{i};
                ENDIF
            ENDFOR
            !get all non-zero/non-empty elements from second table to concated table
            FOR i FROM 1 TO Dim(table2,1) DO
                IF table2{i}<>zeroElement THEN
                    Incr concatedElements;
                    concatedTable{concatedElements}:=table2{i};
                ENDIF
            ENDFOR
            !return number of concated elements
            result:=concatedElements;
        ELSE
            !result table is to small
            ErrWrite "ERROR::concateTabs","Dim of result table is to small to concate two tables"\RL2:="DIM(concated)>=DIM(table1)+DIM(table2)!";
            result:=-1;
        ENDIF

        RETURN result;
    ENDFUNC

    !function used to check if element of specified value exist in table
    ! ret: bool = element with specified value exists in table (TRUE) or not (FALSE)
    ! arg: val - element value to search
    ! arg: table - table in wich we want to search
    FUNC bool tableNumValExists(num val,num table{*})
        VAR bool result:=FALSE;

        !scan whole table untill we found searched value
        FOR i FROM 1 TO Dim(table,1) DO
            IF result=FALSE THEN
                IF table{i}=val result:=TRUE;
            ENDIF
        ENDFOR

        RETURN result;
    ENDFUNC

    !function calculating how many zero/empty elements is in table
    ! ret: num = number of zero/empty elmenets in table
    ! arg: table - table to check
    ! arg: zeroElementValue - value which will be considered as zero/empty value
    FUNC num tableNumCountNonEmpty(num table{*},num zeroElementVal)
        VAR num result;

        !scan whole table and count zero/empty elements
        FOR i FROM 1 TO Dim(table,1) DO
            IF table{i}<>zeroElementVal Incr result;
        ENDFOR

        RETURN result;
    ENDFUNC

    !procedure used to fill all elements of numeric table with specified value
    ! arg: table1D - one dimensional tab to fill with value
    ! arg: table2D - two dimensional tab to fill with value
    ! arg: table3D - three dimensional tab to fill with value
    ! arg: fillValue - value to fill all elements in selected table
    PROC tableNumFill(\INOUT num table1D{*}|INOUT num table2D{*,*}|INOUT num table3D{*,*,*},num fillValue)
        !sprawdzamy jaka tablice chcemy uzupelnic
        IF Present(table1D) THEN
            !filling one dimensional table 
            FOR i FROM 1 TO Dim(table1D,1) DO
                table1D{i}:=fillValue;
            ENDFOR
        ELSEIF Present(table2D) THEN
            !filling two dimensional table 
            FOR i FROM 1 TO Dim(table2D,1) DO
                FOR j FROM 1 TO Dim(table2D,2) DO
                    table2D{i,j}:=fillValue;
                ENDFOR
            ENDFOR
        ELSEIF Present(table3D) THEN
            !filling three dimensional table 
            FOR i FROM 1 TO Dim(table3D,1) DO
                FOR j FROM 1 TO Dim(table3D,2) DO
                    FOR k FROM 1 TO Dim(table3D,3) DO
                        table3D{i,j,k}:=fillValue;
                    ENDFOR
                ENDFOR
            ENDFOR
        ELSE
            !dont know what table to fill 
            ErrWrite "ERROR::fillTable","Specify table to fill!";
        ENDIF
    ENDPROC

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

    !procedure used to reverse table elements (number of elements from specified start element)
    ! arg: table - table to reverse elements 
    ! arg: startElementNo - number of element from which we want to start reversing elements
    ! arg: noOfElements - number of elements from startElementNo to reverse
    FUNC bool tableNumReverse(INOUT num table{*},num startElementNo,num noOfElements)
        VAR bool result:=FALSE;
        VAR num tableElements:=-1;
        VAR num endElementNo:=-1;
        VAR num swapsToDo:=-1;
        VAR num currElement:=-1;

        !check total number of elements in table
        tableElements:=Dim(table,1);
        !sprawdzamy wprowadzone dane
        IF startElementNo<1 OR startElementNo>tableElements THEN
            !start element is outside table - do nothing
            result:=FALSE;
        ELSE
            !start element is inside table - check end element
            endElementNo:=startElementNo+noOfElements-1;
            IF endElementNo>tableElements THEN
                endElementNo:=tableElements;
                noOfElements:=endElementNo-startElementNo+1;
            ENDIF
            !get number of swaps to do (defined number of elements)
            IF noOfElements MOD 2=0 THEN
                swapsToDo:=noOfElements/2;
            ELSE
                swapsToDo:=(noOfElements-1)/2;
            ENDIF
            !do all calculated swaps
            IF swapsToDo>0 THEN
                FOR i FROM 1 TO swapsToDo DO
                    currElement:=table{endElementNo-i+1};
                    table{endElementNo-i+1}:=table{startElementNo-1+i};
                    table{startElementNo-1+i}:=currElement;
                ENDFOR
            ENDIF
            !update result (all OK)
            result:=TRUE;
        ENDIF

        RETURN result;
    ENDFUNC

    !function used to sort numeric table (whole table or user defined part of table)
    ! ret: bool = if sorting process was successfull (TRUE) or not (FALSE)
    ! arg: table - table to sort elements
    ! arg: tableMap - map of sorting process (how elements were reorganized)
    ! arg: fromElementNo - sorting start element (default: first table element)
    ! arg: toElementNo - sorting end element (default: last table element)
    FUNC bool tableNumSort(INOUT num table{*}\INOUT num tableMap{*}\num fromElementNo\num toElementNo)
        VAR bool result:=FALSE;
        VAR num tableSize;
        VAR num currStartEl;
        VAR num currStopEl;

        !get inputted table size
        tableSize:=Dim(table,1);
        !============= check if user wants to have a map of sorting (new elements position)
        IF Present(tableMap) THEN
            !table for element map must be the same size as table to sort
            IF Dim(tableMap,1)=tableSize THEN
                FOR i FROM 1 TO tableSize DO
                    tableMap{i}:=i;
                ENDFOR
                result:=TRUE;
            ELSE
                result:=FALSE;
            ENDIF
        ELSE
            result:=TRUE;
        ENDIF
        !============= which elements has to be sorted
        IF result THEN
            !check first element number
            IF Present(fromElementNo) THEN
                !check if fist element of sorting is inside table 
                IF fromElementNo>0 THEN
                    IF fromElementNo<=tableSize-1 THEN
                        currStartEl:=fromElementNo;
                    ELSE
                        ErrWrite "ERROR::sortTable","!! fromElementNo <= tableSize-1 !!";
                        result:=FALSE;
                    ENDIF
                ELSE
                    ErrWrite "ERROR::sortTable","!! fromElementNo > 0 !!";
                    result:=FALSE;
                ENDIF
            ELSE
                !no specified start sort element no = lets start from beginning
                currStartEl:=1;
            ENDIF
            !check end element number
            IF Present(toElementNo) THEN
                !check if last element is inside table and is bigger then start element
                IF toElementNo>0 THEN
                    IF toElementNo>currStartEl THEN
                        IF toElementNo>tableSize THEN
                            currStopEl:=tableSize-1;
                        ELSE
                            currStopEl:=toElementNo-1;
                        ENDIF
                    ELSE
                        ErrWrite "ERROR::sortTable","!! toElementNo > fromElementNo !!";
                        result:=FALSE;
                    ENDIF
                ELSE
                    ErrWrite "ERROR::sortTable","!! toElementNo > 0 !!";
                    result:=FALSE;
                ENDIF
            ELSE
                !no specified last sort element no = lest end at table end
                currStopEl:=tableSize-1;
            ENDIF
        ENDIF
        !============= lets sort table
        IF result THEN
            !get number of sorting steps to do (and decrement it after every num swap)
            tableSize:=currStopEl-currStartEl+1;
            WHILE tableSize>0 DO
                FOR i FROM currStartEl TO currStopEl DO
                    IF table{i}>table{i+1} THEN
                        numSwap table{i},table{i+1};
                        IF Present(tableMap) numSwap tableMap{i},tableMap{i+1};
                    ENDIF
                ENDFOR
                Decr tableSize;
            ENDWHILE
        ENDIF

        RETURN result;
    ENDFUNC
ENDMODULE
