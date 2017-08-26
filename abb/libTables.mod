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

    !function used to count bool table elements that are true or false
    ! ret: num = number of specified elements
    ! arg: table - table to count specified elements in
    ! arg: countTrue - input if you want to count all true elements
    ! arg: countFalse - input if you want to count all false elements
    FUNC num tableBoolCount(VAR bool table{*}\switch countTrue|switch countFalse)
        VAR num result;

        !scan whole table
        FOR i FROM 1 TO Dim(table,1) DO
            !check current element and check user input
            IF table{i}=TRUE AND Present(countTrue) THEN
                !element true and user wants to count true so increment result
                Incr result;
            ELSEIF table{i}=FALSE AND Present(countFalse) THEN
                !element false and user wants to count false so increment result
                Incr result;
            ENDIF
        ENDFOR

        RETURN result;
    ENDFUNC

    !function used to calc determinant of inputted matrix
    ! ret: num = calculated matrix determinant
    ! arg: m - inputted matrix to calc determinant
    ! arg: considerSize - size of matrix to calc determinant
    FUNC num tableNumDeterminant(num m{*,*},num considerSize)
        VAR num result:=0;
        VAR num minor{5,5};
        VAR num methodJ:=1;

        !check if matrix is rectangular
        IF Dim(m,1)=Dim(m,2) THEN
            !check if matrix size is big enough for inputted considerSize
            IF Dim(m,1)>=considerSize THEN
                !check what size user wants to consider for calculating determinant
                IF considerSize=1 THEN
                    !one dimension matrix has only one element
                    result:=m{1,1};
                ELSEIF considerSize=2 THEN
                    !calc two dimension matrix determinant (to speed up calculations - less recursive calls)
                    result:=m{1,1}*m{2,2}-m{1,2}*m{2,1};
                ELSEIF considerSize=3 THEN
                    !calc three dimension matrix determinant (to speed up calculations - less recursive calls)
                    result:=m{1,1}*m{2,2}*m{3,3}+m{1,2}*m{2,3}*m{3,1}+m{2,1}*m{3,2}*m{1,3}-
                            m{1,3}*m{2,2}*m{3,1}-m{1,2}*m{2,1}*m{3,3}-m{1,1}*m{2,3}*m{3,2};
                ELSE
                    !find determinant using recursive method (with minors)
                    FOR rowNo FROM 1 TO considerSize DO
                        !get minor from inputted matrix
                        tableNumMinor m,rowNo,1,minor;
                        !calculate determinant from minor
                        result:=result+Pow(-1,rowNo+methodJ)*m{rowNo,methodJ}*tableNumDeterminant(minor,considerSize-1);
                    ENDFOR
                ENDIF
            ELSE
                ErrWrite "ERROR::matrixDeterminant","Matrix size must be at least equal to considerSize!";
                result:=-9E9;
            ENDIF
        ELSE
            ErrWrite "ERROR::matrixDeterminant","Matrix must be rectangular (rows = cols)!";
            result:=-9E9;
        ENDIF

        RETURN result;
    ENDFUNC

    !procedure used to get minor from inputted matrix
    ! arg: matrix - inputted matrix to get minor from
    ! arg: delRow - which row we want to exclude from matrix
    ! arg: delCol - which column we want to exclude from matrix
    ! arg: minor - result minor 
    PROC tableNumMinor(num matrix{*,*},num delRow,num delCol,INOUT num minor{*,*})
        VAR num minorRow:=1;
        VAR num minorCol:=1;

        !check inputted data
        IF delRow<=Dim(matrix,1) AND delCol<=Dim(matrix,2) THEN
            !scan all matrix row
            FOR cRow FROM 1 TO Dim(matrix,1) DO
                !if current row isnt excluded scan all elements from it
                IF cRow<>delRow THEN
                    !scan all matrix columns
                    FOR cCol FROM 1 TO Dim(matrix,2) DO
                        !if current column isnt excluded get it element
                        IF cCol<>delCol THEN
                            minor{minorRow,minorCol}:=matrix{cRow,cCol};
                            !next minor column
                            Incr minorCol;
                        ENDIF
                    ENDFOR
                    !next minor row
                    Incr minorRow;
                    !reset minor column
                    minorCol:=1;
                ENDIF
            ENDFOR
        ELSE
            ErrWrite "ERROR::matrixGetMinor","extrudeRow AND/OR extrudeCol is outside matrix dimension.";
        ENDIF
    ENDPROC

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

    !function calculating how many user specified values are in table
    ! ret: num = number of specified values in table
    ! arg: table - table to check
    ! arg: countValue - values to count
    FUNC num tableNumCount(num table{*},num countVal)
        VAR num result;

        !scan whole table and count zero/empty elements
        FOR i FROM 1 TO Dim(table,1) DO
            IF table{i}=countVal Incr result;
        ENDFOR

        RETURN result;
    ENDFUNC

    !function calculating how many zero/empty elements is in table
    ! ret: num = number of zero/empty elmenets in table
    ! arg: table - table to check
    ! arg: zeroElementVal - value which will be considered as zero/empty value
    FUNC num tableNumCountNonZero(num table{*}\num zeroElementVal)
        VAR num result;
        VAR num defaultZeros:=0;

        IF Present(zeroElementVal) defaultZeros:=zeroElementVal;
        !scan whole table and count zero/empty elements
        FOR i FROM 1 TO Dim(table,1) DO
            IF table{i}<>defaultZeros Incr result;
        ENDFOR

        RETURN result;
    ENDFUNC

    !procedure used to fill all elements of numeric table with specified value
    ! arg: table1D - one dimensional tab to fill with value
    ! arg: table2D - two dimensional tab to fill with value
    ! arg: table3D - three dimensional tab to fill with value
    ! arg: fillValue - value to fill all elements in selected table
    PROC tableNumFill(\INOUT num table1D{*}|INOUT num table2D{*,*}|INOUT num table3D{*,*,*},num fillValue\switch increment)
        !sprawdzamy jaka tablice chcemy uzupelnic
        IF Present(table1D) THEN
            !filling one dimensional table 
            FOR i FROM 1 TO Dim(table1D,1) DO
                IF Present(increment) THEN
                    table1D{i}:=fillValue+(i-1);
                ELSE
                    table1D{i}:=fillValue;
                ENDIF
            ENDFOR
        ELSEIF Present(table2D) THEN
            !filling two dimensional table 
            FOR i FROM 1 TO Dim(table2D,1) DO
                FOR j FROM 1 TO Dim(table2D,2) DO
                    IF Present(increment) THEN
                        table2D{i,j}:=fillValue+(i-1+j-1);
                    ELSE
                        table2D{i,j}:=fillValue;
                    ENDIF
                ENDFOR
            ENDFOR
        ELSEIF Present(table3D) THEN
            !filling three dimensional table 
            FOR i FROM 1 TO Dim(table3D,1) DO
                FOR j FROM 1 TO Dim(table3D,2) DO
                    FOR k FROM 1 TO Dim(table3D,3) DO
                        IF Present(increment) THEN
                            table3D{i,j,k}:=fillValue+(i-1+j-1+k-1);
                        ELSE
                            table3D{i,j,k}:=fillValue;
                        ENDIF
                    ENDFOR
                ENDFOR
            ENDFOR
        ELSE
            !dont know what table to fill 
            ErrWrite "ERROR::fillTable","Specify table to fill!";
        ENDIF
    ENDPROC

    !function used to calc mean value from all table elements
    ! ret: num = table mean value
    ! arg: table - table to calc mean
    FUNC num tableNumMean(num table{*})
        !calc mean value
        RETURN tableNumSum(table)/Dim(table,1);
    ENDFUNC

    !function used to calc most often value (mode) in table 
    ! ret: num = table most often value
    ! arg: table - table to calc mode
    FUNC num tableNumMode(num table{*})
        VAR num result:=-9E9;
        VAR num cIndex;
        VAR num valIndex;
        VAR num mapValue{50};
        VAR num mapCounter{50};

        !fill value and index map with zero values
        tableNumFill\table1D:=mapValue,-9E9;
        tableNumFill\table1D:=mapCounter,0;
        !scan whole table
        FOR i FROM 1 TO Dim(table,1) DO
            !check if current element exists in map
            valIndex:=tableNumSearchLinear(mapValue,table{i});
            IF valIndex>0 THEN
                !element exists in map - increment its counter
                Incr mapCounter{valIndex};
            ELSE
                !element doesnt exist - add it to map index and increment index
                Incr cIndex;
                Incr mapCounter{cIndex};
                mapValue{cIndex}:=table{i};
            ENDIF
        ENDFOR
        !find biggest element in map counter
        result:=mapValue{tableNumSearchMargin(mapCounter\biggest\elementNo)};

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

    !function used to binary find element index in SORTED table
    ! ret: num = index of searched element (if -1: no element exists)
    ! arg: table - table in which we want search value
    ! arg: value - value to search
    FUNC num tableNumSearchBinary(INOUT num table{*},num value)
        VAR num result:=-1;
        VAR num min;
        VAR num max;
        VAR num guessIndex;

        !starting values
        min:=0;
        max:=Dim(table,1);
        guessIndex:=0;
        !search value untill search set is zero
        WHILE max>=min DO
            !get middle index of set
            guessIndex:=min+Round((max-min)/2);
            !check if we found our value
            IF (table{guessIndex}=value) THEN
                !we got it !
                RETURN guessIndex;
            ELSEIF (table{guessIndex}<value) THEN
                !found value is smaller than mid point
                min:=guessIndex+1;
            ELSE
                !found value is higher than mid point
                max:=guessIndex-1;
            ENDIF
        ENDWHILE

        !element doesnt exist if we are here 
        RETURN result;
    ENDFUNC

    !function used to check if element of specified value exist in table
    ! ret: num = index of element with specified value (-1 if non-existent)
    ! arg: val - element value to search
    ! arg: table - table in wich we want to search
    FUNC num tableNumSearchLinear(num table{*},num val)
        VAR num result:=-1;

        !scan whole table untill we found searched value (linear search)
        FOR i FROM 1 TO Dim(table,1) DO
            IF result=-1 THEN
                IF table{i}=val result:=i;
            ENDIF
        ENDFOR

        RETURN result;
    ENDFUNC

    !function used to find biggest/smallest value/element in num table
    ! ret: num = found outermost element index
    ! arg: table - on dimension num table which is inspected for finding specified num
    ! arg: biggest - biggest value in table / element with biggest value in table
    ! arg: smallest - smallest value in table / element with smallest value in table
    ! arg: value - use this agrument if you want to find biggest/smallest VALUE
    ! arg: elementNo - use this argument if you want to find biggest/smallest value ELEMENT
    FUNC num tableNumSearchMargin(num table{*},\switch biggest|switch smallest,\switch value|switch elementNo)
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
                ErrWrite "ERROR::tableNumSearchOutermost","You must specify what to search: value OR element number!";
            ENDIF
        ELSE
            ErrWrite "ERROR::tableNumSearchOutermost","You must specify what to search: biggest OR smallest!";
        ENDIF

        RETURN result;
    ENDFUNC

    !function used to adjust input data (start and stop index, map table size) before sorting table
    ! ret: bool = all data are adjusted and we can start sorting (TRUE) or not (FALSE)
    ! arg: tableSize - size of table we want to sort
    ! arg: mapSize - size of map table (to keep track how elements were sorted)
    ! arg: startIndex - first sorting element number
    ! arg: stopIndex - last sorting element number
    FUNC bool tableNumSortAdjust(num tableSize,num mapSize,INOUT num startIndex,INOUT num stopIndex)
        VAR bool result:=FALSE;

        !============= if user want map check it dimension
        result:=NOT (mapSize>0) OR mapSize=tableSize;
        !============= which elements has to be sorted
        IF result THEN
            !*******************************
            !check start element number
            IF startIndex<=0 THEN
                startIndex:=1;
                ErrWrite\W,"WARN::tableNumSortPrepare","Start element is to small!"
                     \RL2:="Setting start element to table begin...";
                !continue with sorting
                result:=TRUE;
            ENDIF
            IF startIndex>tableSize-1 THEN
                startIndex:=tableSize-1;
                ErrWrite\W,"WARN::tableNumSortPrepare","Start element is to big"
                     \RL2:="Setting start element to table end...";
                !continue with sorting
                result:=TRUE;
            ENDIF
            !*******************************
            !check end element number
            IF stopIndex<=startIndex THEN
                stopIndex:=startIndex;
                ErrWrite\W,"WARN::tableNumSortPrepare","Stop element is less or equal then start element!"
                     \RL2:="Setting stop element at start element = no need to sort!";
                !there will be only one element - no sorting is needed
                result:=FALSE;
            ENDIF
            IF stopIndex>tableSize THEN
                stopIndex:=tableSize;
                ErrWrite\W,"WARN::tableNumSortPrepare","Stop element is to big"
                     \RL2:="Setting stop element to table end...";
                !continue with sorting
                result:=TRUE;
            ENDIF
            !*******************************
        ENDIF
        !====================

        RETURN result;
    ENDFUNC

    !function used to bubble sort numeric table (whole table or user defined part of table)
    ! ret: bool = if sorting process was successfull (TRUE) or not (FALSE)
    ! arg: table - table to sort elements
    ! arg: tableMap - map of sorting process (how elements were reorganized)
    ! arg: fromElementNo - sorting start element (default: first table element)
    ! arg: toElementNo - sorting end element (default: last table element)
    FUNC bool tableNumSortBubble(INOUT num table{*}\INOUT num tableMap{*}\num fromElementNo\num toElementNo)
        VAR bool result:=FALSE;
        VAR num tabSize:=0;
        VAR num mapSize:=0;
        VAR num currStartEl:=1;
        VAR num currStopEl:=1;

        !insert startup values 
        IF Present(tableMap) mapSize:=Dim(tableMap,1);
        tabSize:=Dim(table,1);
        currStopEl:=tabSize;
        !prepare input data
        IF Present(tableMap) tableNumFill\table1D:=tableMap,1\increment;
        IF Present(fromElementNo) currStartEl:=fromElementNo;
        IF Present(toElementNo) currStopEl:=toElementNo;
        !if everything is ok then start sorting process
        IF tableNumSortAdjust(tabSize,mapSize,currStartEl,currStopEl) THEN
            !get number of sorting steps to do (and decrement it after every num swap)
            tabSize:=currStopEl-currStartEl+1;
            WHILE tabSize>0 DO
                FOR i FROM currStartEl TO currStopEl DO
                    IF table{i}>table{i+1} THEN
                        numSwap table{i},table{i+1};
                        IF Present(tableMap) numSwap tableMap{i},tableMap{i+1};
                    ENDIF
                ENDFOR
                Decr tabSize;
            ENDWHILE
        ENDIF

        RETURN result;
    ENDFUNC

    !function used to insertion sort numeric table (whole table or user defined part of table)
    ! ret: bool = if sorting process was successfull (TRUE) or not (FALSE)
    ! arg: table - table to sort elements
    ! arg: tableMap - map of sorting process (how elements were reorganized)
    ! arg: fromElementNo - sorting start element (default: first table element)
    ! arg: toElementNo - sorting end element (default: last table element)
    FUNC bool tableNumSortInsertion(INOUT num table{*}\INOUT num tableMap{*}\num fromElementNo\num toElementNo)
        VAR bool result:=FALSE;
        VAR num keyVal:=0;
        VAR num scanNo:=0;
        VAR num tabSize:=0;
        VAR num mapSize:=0;
        VAR num currStartEl:=1;
        VAR num currStopEl:=1;

        !insert startup values 
        IF Present(tableMap) mapSize:=Dim(tableMap,1);
        tabSize:=Dim(table,1);
        currStopEl:=tabSize;
        !prepare input data
        IF Present(tableMap) tableNumFill\table1D:=tableMap,1\increment;
        IF Present(fromElementNo) currStartEl:=fromElementNo;
        IF Present(toElementNo) currStopEl:=toElementNo;
        !if everything is ok then start sorting process
        IF tableNumSortAdjust(tabSize,mapSize,currStartEl,currStopEl) THEN
            FOR i FROM currStartEl+1 TO currStopEl DO
                keyVal:=table{i};
                scanNo:=i-1;
                WHILE scanNo>currStartEl AND table{scanNo}>keyVal DO
                    table{scanNo+1}:=table{scanNo};
                    table{scanNo}:=keyVal;
                    Decr scanNo;
                ENDWHILE
            ENDFOR
            !everything is ok when if we are here
            result:=TRUE;
        ENDIF

        RETURN result;
    ENDFUNC

    !function used to selection sort of numeric table (whole table or user defined part of table)
    ! ret: bool = if sorting process was successfull (TRUE) or not (FALSE)
    ! arg: table - table to sort elements
    ! arg: tableMap - map of sorting process (how elements were reorganized)
    ! arg: fromElementNo - sorting start element (default: first table element)
    ! arg: toElementNo - sorting end element (default: last table element)
    FUNC bool tableNumSortSelection(INOUT num table{*}\INOUT num tableMap{*}\num fromElementNo\num toElementNo)
        VAR bool result:=FALSE;
        VAR num minValue;
        VAR num minIndex;
        VAR num tabSize:=0;
        VAR num mapSize:=0;
        VAR num currStartEl:=1;
        VAR num currStopEl:=1;

        !insert startup values 
        IF Present(tableMap) mapSize:=Dim(tableMap,1);
        tabSize:=Dim(table,1);
        currStopEl:=tabSize;
        !prepare input data
        IF Present(tableMap) tableNumFill\table1D:=tableMap,1\increment;
        IF Present(fromElementNo) currStartEl:=fromElementNo;
        IF Present(toElementNo) currStopEl:=toElementNo;
        !if everything is ok then start sorting process
        IF tableNumSortAdjust(tabSize,mapSize,currStartEl,currStopEl) THEN
            FOR cIndex FROM currStartEl TO currStopEl DO
                minIndex:=cIndex;
                minValue:=table{cIndex};
                FOR sIndex FROM cIndex TO currStopEl DO
                    IF table{sIndex}<minValue THEN
                        minIndex:=sIndex;
                        minValue:=table{sIndex};
                    ENDIF
                ENDFOR
                numSwap table{cIndex},table{minIndex};
            ENDFOR
            !everything is ok when if we are here
            result:=TRUE;
        ENDIF

        RETURN result;
    ENDFUNC

    !function used to sum up all table elements
    ! ret: num = sum of all table elements
    ! arg: table - table to sum elements
    FUNC num tableNumSum(num table{*})
        VAR num result:=0;

        !sum all table elements
        FOR i FROM 1 TO Dim(table,1) DO
            result:=result+table{i};
        ENDFOR

        RETURN result;
    ENDFUNC
ENDMODULE
