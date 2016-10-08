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
    ! arg: posPrecision - decimal points in pos element (pose.trans)
    ! arg: rotPrecision - decimal points in orient element (pose.rot)
    FUNC string poseToString(pose position\num posPrecision\num rotPrecision)
        VAR string result:="";
        VAR num posAcc:=3;
        VAR num rotAcc:=4;

        !checking optional arguments (posPrecision & rotPrecision)
        IF Present(posPrecision) posAcc:=posPrecision;
        IF Present(rotPrecision) rotAcc:=rotPrecision;
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
    ! arg: posPrecision - decimal points in pos element (robt.trans)
    ! arg: rotPrecision - decimal points in orient element (robt.rot)
    ! arg: extPrecision - decimal points in external axis element (robt.extax)
    FUNC string robtToString(robtarget robt\switch onlyPose,\num posPrecision\num rotPrecision\num extPrecision)
        VAR string result:="";
        VAR num posAcc:=1;
        VAR num rotAcc:=3;
        VAR num extAcc:=1;

        !checking optional arguments (posPrecision, rotPrecision, extPrecision)
        IF Present(posPrecision) posAcc:=posPrecision;
        IF Present(rotPrecision) rotAcc:=rotPrecision;
        IF Present(extPrecision) extAcc:=extPrecision;
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
    ! arg: precision - z jaka dokladnoscia wypisac wynik
    FUNC string wobjToString(wobjdata wobj,\switch onlyUFrame|switch onlyOFrame,\num posPrecision\num rotPrecision)
        VAR string result:="";
        VAR num posAcc:=1;
        VAR num rotAcc:=3;
        VAR num extAcc:=1;

        !checking optional arguments (posPrecision & rotPrecision)
        IF Present(posPrecision) posAcc:=posPrecision;
        IF Present(rotPrecision) rotAcc:=rotPrecision;
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
ENDMODULE
