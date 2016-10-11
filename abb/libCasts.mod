MODULE libCasts
    !*******************************************************************!
    ! Copyright (C) 2016 Piotr Ponikowski <pipon.github@gmail.com>      !
    !*******************************************************************!
    ! Module Name:  libCasts                                            !
    ! Description:  data type conversions (casts)                       !
    ! Date:         2016-10-02                                          !
    ! Author:       Piotr Ponikowski <pipon.github@gmail.com>           !
    ! Contributors:                                                     !
    !*******************************************************************!

    !===================================================
    !================  ABB TYPES  ======================
    !===================================================    

    !function converting bool to byte
    ! ret: byte = converted byte
    ! arg: boolean - bool to convert
    FUNC byte boolToByte(bool boolean)
        VAR byte result:=0;

        IF boolean result:=1;

        RETURN result;
    ENDFUNC

    !function converting bool to num
    ! ret: num = converted num
    ! arg: boolean - bool to convert
    FUNC num boolToNum(bool boolean)
        VAR num result:=0;

        IF boolean result:=1;

        RETURN result;
    ENDFUNC

    !function converting bool to string
    ! ret: string = converted string
    ! arg: boolean - bool to convert
    FUNC string boolToStr(bool boolean\switch fullName)
        VAR string result;

        IF Present(fullName) THEN
            result:="FALSE";
            IF boolean result:="TRUE";
        ELSE
            result:="0";
            IF boolean result:="1";
        ENDIF

        RETURN result;
    ENDFUNC

    !function  converting byte to num
    ! ret: num = converted num
    ! arg: uint8 - byte to convert
    FUNC num byteToNum(byte uint8)
        VAR num result:=-1;

        IF NOT StrToVal(ByteToStr(uint8),result) result:=-1;

        RETURN result;
    ENDFUNC
    
    !function converting external axes to string
    ! ret: string = converted string
    ! arg: extaxes - external axes to convert
    ! arg: extPrec - decimal points in extjoint element 
    FUNC string extaxToString(extjoint extaxes\num extPrec)
        VAR string result:="";
        VAR num extAcc:=2;

        !checking optional arguments (extPrec)
        IF Present(extPrec) extAcc:=extPrec;
        !rounding pose [trans (XYZ) and rot (Q)]
        extaxes:=roundExtax(extaxes\extDec:=extAcc);
        !converting rounded pose to string
        result:=ValToStr(extaxes);

        RETURN result;
    ENDFUNC 
    
    !function converting jointtarget to pos
    ! ret: pos = converted pos
    ! arg: jointtarget - jointtarget to convert
    FUNC pos jointtToPos(jointtarget joints,PERS tooldata tool,PERS wobjdata wobj)
        RETURN poseToPos(robtToPose(CalcRobT(joints,tool\WObj:=wobj)));
    ENDFUNC    
    
    !function converting jointtarget to pose
    ! ret: pose = converted pose
    ! arg: jointtarget - jointtarget to convert
    FUNC pose jointtToPose(jointtarget joints,PERS tooldata tool,PERS wobjdata wobj)
        RETURN robtToPose(CalcRobT(joints,tool\WObj:=wobj));
    ENDFUNC
    
    !function converting jointtarget to string
    ! ret: string = converted string
    ! arg: jointtarget - jointtarget to convert
    ! arg: robPrec - decimal points in robjoint element 
    ! arg: extPrec - decimal points in extjoint element 
    FUNC string jointtToString(jointtarget joints\num robPrec\num extPrec)
        VAR string result:="";
        VAR num robAcc:=3;
        VAR num extAcc:=4;

        !checking optional arguments (robPrec & extPrec)
        IF Present(robPrec) robAcc:=robPrec;
        IF Present(extPrec) extAcc:=extPrec;
        !rounding pose [trans (XYZ) and rot (Q)]
        joints:=roundJointT(joints\robDec:=robAcc\extDec:=extAcc);
        !converting rounded pose to string
        result:=ValToStr(joints);

        RETURN result;
    ENDFUNC    

    !function converting num to bool
    ! ret: bool = converted bool
    ! arg: numeric - num to convert
    FUNC bool numToBool(num numeric)
        RETURN numeric<>0;
    ENDFUNC

    !function converting num to byte
    ! ret: byte = converted byte
    ! arg: numeric - num to convert
    FUNC byte numToByte(num numeric)
        VAR byte result;

        !byte [uint8] = min: 0 - max: 255
        IF numeric>255 THEN
            result:=255;
        ELSEIF numeric<0 THEN
            result:=0;
        ELSE
            result:=numeric;
        ENDIF

        RETURN result;
    ENDFUNC
    
    !function converting pos to pose
    ! ret: pose = converted pose
    ! arg: position - pos to convert
    ! arg: rot - orient to apply (if omitted: [1,0,0,0])
    FUNC pose posToPose(pos position\orient rot)
        VAR pose result;
        VAR orient ori:=[1,0,0,0];

        !check is user provided optional arguments
        IF Present(rot) ori:=rot;
        !update pose trans and rot 
        result.trans:=position;
        result.rot:=ori;

        RETURN result;
    ENDFUNC  
    
    !function converting pos to robtarget
    ! ret: robtarget = converted robtarget
    ! arg: position - pos to convert
    ! arg: rot - orient to apply (if omitted: [1,0,0,0])
    ! arg: ext - external axes to apply (if omitted: [9E9,9E9,9E9,9E9,9E9,9E9])
    FUNC robtarget posToRobt(pos position\orient rot\extjoint ext)
        VAR robtarget result;
        VAR orient ori:=[1,0,0,0];
        VAR extjoint eax:=[9E9,9E9,9E9,9E9,9E9,9E9];

        !check is user provided optional arguments
        IF Present(rot) ori:=rot;
        IF Present(ext) eax:=ext;
        !update pose trans, rot, extjoint and robconf
        result.trans:=position;
        result.rot:=ori;
        result.robconf:=[0,0,0,0];
        result.extax:=eax;

        RETURN result;
    ENDFUNC    

    !function converting pose to pos
    ! ret: pos = converted pos
    ! arg: position - pose to convert
    FUNC pos poseToPos(pose position)
        RETURN position.trans;
    ENDFUNC
    
    !function converting pose to robtarget
    ! ret: robtarget = converted robtarget
    ! arg: position - pose to convert
    FUNC robtarget poseToRobt(pose position)
        VAR robtarget result;

        !update robtarget trans and rot from input
        result.trans:=position.trans;
        result.rot:=position.rot;
        !default values for configuration and external axes
        result.robconf:=[0,0,0,0];
        result.extax:=[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09];

        RETURN result;
    ENDFUNC

    !function converting pose to string
    ! ret: string = converted string
    ! arg: position - pose to convert
    ! arg: posPrec - decimal points in pos element (pose.trans)
    ! arg: rotPrec - decimal points in orient element (pose.rot)
    FUNC string poseToString(pose position\num posPrec\num rotPrec)
        VAR string result:="";
        VAR num posAcc:=3;
        VAR num rotAcc:=4;

        !checking optional arguments (posPrec & rotPrec)
        IF Present(posPrec) posAcc:=posPrec;
        IF Present(rotPrec) rotAcc:=rotPrec;
        !rounding pose [trans (XYZ) and rot (Q)]
        position:=roundPose(position\posDec:=posAcc\oriDec:=rotAcc);
        !converting rounded pose to string
        result:=ValToStr(position);

        RETURN result;
    ENDFUNC

    !function converting robtarget to pos
    ! ret: pos = converted pos
    ! arg: robt - robtarget to convert
    FUNC pos robtToPos(robtarget robt)
        RETURN robt.trans;
    ENDFUNC

    !function converting robtarget to pose
    ! ret: pose = converted pose
    ! arg: robt - robtarget to convert
    FUNC pose robtToPose(robtarget robt)
        VAR pose result;

        result.trans:=robt.trans;
        result.rot:=robt.rot;

        RETURN result;
    ENDFUNC

    !function converting robtarget to string
    ! ret: string = converted string
    ! arg: robt - robtarget to convert
    ! arg: onlyPose - output only robtarget pose (no need to cast)
    ! arg: posPrec - decimal points in pos element (robt.trans)
    ! arg: rotPrec - decimal points in orient element (robt.rot)
    ! arg: extPrec - decimal points in external axis element (robt.extax)
    FUNC string robtToString(robtarget robt\switch onlyPose,\num posPrec\num rotPrec\num extPrec)
        VAR string result:="";
        VAR num posAcc:=1;
        VAR num rotAcc:=3;
        VAR num extAcc:=1;

        !checking optional arguments (posPrec, rotPrec, extPrec)
        IF Present(posPrec) posAcc:=posPrec;
        IF Present(rotPrec) rotAcc:=rotPrec;
        IF Present(extPrec) extAcc:=extPrec;
        !rounding robtarget [trans (XYZ), rot (Q), robconf, extaxes (EAX)]
        robt:=roundRobt(robt\posDec:=posAcc\oriDec:=rotAcc\extDec:=extAcc);
        !rounding data
        IF Present(onlyPose) THEN
            !user wants only pose components - converting rounded pose
            result:=ValToStr(robtToPose(robt));
        ELSE
            !user want all data - converting rounded robt
            result:=ValToStr(robt);
        ENDIF

        RETURN result;
    ENDFUNC

    !function converting string to bool
    ! ret: bool = converted bool (ERROR = check castOK!)
    ! arg: input - string to convert
    ! arg: castOK - conversion result
    FUNC bool strToBool(string input\INOUT bool castOK)
        VAR bool result;
        VAR bool status:=FALSE;

        !convert inputted string to desired value
        status:=StrToVal(input,result);
        IF NOT status THEN
            !convert nok
            result:=FALSE;
        ENDIF
        !update optional argument (if present)
        IF Present(castOK) castOK:=status;

        RETURN result;
    ENDFUNC

    !function converting string to num
    ! ret: num = converted num (ERROR = -9E9 or check castOK!) 
    ! arg: input - string to convert
    ! arg: castOK - conversion result
    FUNC num strToNum(string input\INOUT bool castOK)
        VAR num result:=-9E9;
        VAR bool status:=FALSE;

        !convert inputted string to desired value
        status:=StrToVal(input,result);
        IF NOT status THEN
            !convert nok
            result:=-9E9;
        ENDIF
        !update optional argument (if present)
        IF Present(castOK) castOK:=status;

        RETURN result;
    ENDFUNC

    !function converting wobjdata to string
    ! ret: string = converted string
    ! arg: wobj - workobject to convert
    ! arg: posPrec - decimal points in pos element 
    ! arg: rotPrec - decimal points in pos element 
    FUNC string wobjToString(wobjdata wobj,\switch onlyUFrame|switch onlyOFrame,\num posPrec\num rotPrec)
        VAR string result:="";
        VAR num posAcc:=1;
        VAR num rotAcc:=3;
        VAR num extAcc:=1;

        !checking optional arguments (posPrec & rotPrec)
        IF Present(posPrec) posAcc:=posPrec;
        IF Present(rotPrec) rotAcc:=rotPrec;
        !rounding pose [trans (XYZ) and rot (Q)]
        wobj:=roundWobj(wobj\posDec:=posAcc\oriDec:=rotAcc);
        !rounding data
        IF Present(onlyUFrame) THEN
            !user wants only uframe components - converting pose
            result:=ValToStr(wobj.uframe);
        ELSEIF Present(onlyOFrame) THEN
            !user wants only pframe components - converting pose
            result:=ValToStr(wobj.oframe);
        ELSE
            !user wants all components - converting wobj
            result:=ValToStr(wobj);
        ENDIF

        RETURN result;
    ENDFUNC

    !===================================================
    !==============  NON ABB TYPES  ====================
    !===================================================

    !function converting axis to vector
    ! ret: pos = reference vector
    ! arg: axisNo - axis number to convert
    FUNC pos axisToVec(num axisNo)
        VAR pos result;

        IF axisNo=axisX THEN
            result:=[1,0,0];
        ELSEIF axisNo=axisY THEN
            result:=[0,1,0];
        ELSEIF axisNo=axisZ THEN
            result:=[0,0,1];
        ELSE
            ErrWrite "ERROR::axisToVec","Dont know what is axis no."+NumToStr(axisNo,0)+"!"\RL2:="Accecpted axes: axisX = 1, axisY = 2, axisZ = 3.";
        ENDIF

        RETURN result;
    ENDFUNC

    !function translating error number to string (may be needed in ERROR recovery)
    ! ret: string = error description
    ! arg: errorNo - error number
    FUNC string errorToString(ERRNUM errorNo)
        VAR string result;

        IF errorNo=ERR_ACC_TOO_LOW THEN
            result:="Too low acc/dec [instruction: PathAccLim/WorldAccLim]";
        ELSEIF errorNo=ERR_ALIASIO_DEF THEN
            result:="Signal is not declared [instruction: AliasIO]";
        ELSEIF errorNo=ERR_ALIASIO_TYPE THEN
            result:="Signal types are not the same [instruction: AliasIO]";
        ELSEIF errorNo=ERR_ALRDYCNT THEN
            result:="Interrupt is already connected [instruction: CONNECT]";
        ELSEIF errorNo=ERR_ALRDY_MOVING THEN
            result:="Robot is already moving [instruction: StartMove/StartMoveRetry]";
        ELSEIF errorNo=ERR_AO_LIM THEN
            result:="Analog signal value outside limit [instruction: AO...]";
        ELSEIF errorNo=ERR_ARGDUPCND THEN
            result:="More than one present conditional argument for the same parameter.";
        ELSEIF errorNo=ERR_ARGNAME THEN
            result:="Argument is an expression, non existent or type switch [instruction: ArgName]";
        ELSEIF errorNo=ERR_ARGNOTPER THEN
            result:="Argument is NOT a persistent reference";
        ELSEIF errorNo=ERR_ARGNOTVAR THEN
            result:="Argument is NOT a variable reference";
        ELSEIF errorNo=ERR_ACTIV_PROF THEN
            result:="Error in activate profile data";
        ELSE
            result:="Unknown error - add descr in library!";
        ENDIF

        RETURN result;
    ENDFUNC
    
    !function converting vector to line
    ! ret: line2D = line from vector
    ! arg: vec - vector to convert
    FUNC line2D vecToLine(pos vec)
        RETURN lineGet(vec,shiftPosByVector(vec,vec,10));
    ENDFUNC
    
    !function converting line to vector
    ! ret: pos = vector (start point at X=0) from line
    ! arg: line - line to convert
    FUNC pos lineToVec(line2D line\num vecLen)
        VAR num currLength:=1;
        
        !check if user wants different length than 1 (versor)
        IF Present(vecLen) currLength:=vecLen;
        RETURN vectorCalc([0,line.B,0],[Cos(line.A)*currLength,Sin(line.A)*currLength,0]);
    ENDFUNC 
    
    !function used to calulate vector from pose 
    ! ret: pos = vector from pose
    ! arg: inPose - input pose to convert
    FUNC pos poseToVec(pose inPose\switch X|switch Y|switch Z)
        VAR pos result;
        VAR robtarget tempRobt;

        !check which axis to represent vector direction
        IF Present(X) THEN
            tempRobt:=RelTool(poseToRobt(inPose),100,0,0);
        ELSEIF Present(Y) THEN
            tempRobt:=RelTool(poseToRobt(inPose),0,100,0);
        ELSEIF Present(Z) THEN
            tempRobt:=RelTool(poseToRobt(inPose),0,0,100);
        ELSE
            tempRobt:=RelTool(poseToRobt(inPose),0,0,100);
        ENDIF
        !caluclate result;
        result:=vectorCalc(inPose.trans,tempRobt.trans);

        RETURN result;
    ENDFUNC    
ENDMODULE
