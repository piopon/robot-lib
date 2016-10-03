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
        !checking if inputs is ok
        IF numInsideSet(posAcc,0,6) THEN
            IF numInsideSet(rotAcc,0,6) THEN
                !robot position (XYZ)
                position.trans.x:=Round(position.trans.x\Dec:=posAcc);
                position.trans.y:=Round(position.trans.y\Dec:=posAcc);
                position.trans.z:=Round(position.trans.z\Dec:=posAcc);
                !robot orientation (Q)
                position.rot.q1:=Round(position.rot.q1\Dec:=rotAcc);
                position.rot.q2:=Round(position.rot.q2\Dec:=rotAcc);
                position.rot.q3:=Round(position.rot.q3\Dec:=rotAcc);
                position.rot.q4:=Round(position.rot.q4\Dec:=rotAcc);
                !converting rounded pose to string
                result:=ValToStr(position);
            ELSE
                !wrong optional argument rotPrecision
                ErrWrite "ERROR::poseToString","Wrong argument value: rotPrecision = "+NumToStr(rotAcc,0),\RL2:="Correct value must be between [0 ; 6]";
                result:=ValToStr(zeroPose);
            ENDIF
        ELSE
            !wrong optional argument posPrecision
            ErrWrite "ERROR::poseToString","Wrong argument value: posPrecision = "+NumToStr(posAcc,0),\RL2:="Correct value must be between [0 ; 6]";
            result:=ValToStr(zeroPose);
        ENDIF

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
    ! arg: onlyPose - output only robtarget pose (DEFAULT)
    ! arg: posPrecision - decimal points in pos element (robt.trans)
    ! arg: rotPrecision - decimal points in orient element (robt.rot)
    ! arg: extPrecision - decimal points in external axis element (robt.extax)
    FUNC string robtToString(robtarget robt\switch onlyPose,\num posPrecision\num rotPrecision\num extPrecision)
        VAR string result:="";
        VAR num posAcc:=1;
        VAR num rotAcc:=3;
        VAR num extAcc:=1;

        !checking optional arguments (posPrecision & rotPrecision)
        IF Present(posPrecision) posAcc:=posPrecision;
        IF Present(rotPrecision) rotAcc:=rotPrecision;
        !checking if inputs is ok
        IF numInsideSet(posAcc,0,6) THEN
            IF numInsideSet(rotAcc,0,6) THEN
                !robtarget pos (XYZ)
                robt.trans.x:=Round(robt.trans.x\Dec:=posAcc);
                robt.trans.y:=Round(robt.trans.y\Dec:=posAcc);
                robt.trans.z:=Round(robt.trans.z\Dec:=posAcc);
                !robtarget orient (Q)
                robt.rot.q1:=Round(robt.rot.q1\Dec:=rotAcc);
                robt.rot.q2:=Round(robt.rot.q2\Dec:=rotAcc);
                robt.rot.q3:=Round(robt.rot.q3\Dec:=rotAcc);
                robt.rot.q4:=Round(robt.rot.q4\Dec:=rotAcc);
                !check if user want all data
                IF Present(onlyPose) THEN
                    !user wants only pose components - converting rounded pose...
                    result:=ValToStr(robtToPose(robt));
                ELSE
                    !robtarget configuration - NO CHANGE
                    robt.robconf:=robt.robconf;
                    !checking optional argument (extPrecision)
                    IF Present(extPrecision) extAcc:=extPrecision;
                    IF numInsideSet(extAcc,0,6) THEN
                        !external axes (EXTAX)
                        robt.extax.eax_a:=Round(robt.extax.eax_a\Dec:=extAcc);
                        robt.extax.eax_b:=Round(robt.extax.eax_b\Dec:=extAcc);
                        robt.extax.eax_c:=Round(robt.extax.eax_c\Dec:=extAcc);
                        robt.extax.eax_d:=Round(robt.extax.eax_d\Dec:=extAcc);
                        robt.extax.eax_e:=Round(robt.extax.eax_e\Dec:=extAcc);
                        robt.extax.eax_f:=Round(robt.extax.eax_f\Dec:=extAcc);
                        !got full robt - converting rounded robtarget to string...
                        result:=ValToStr(robt);
                    ELSE
                        !wrong optional argument rotPrecision
                        ErrWrite "ERROR::robtToString","Wrong argument value: extPrecision = "+NumToStr(extAcc,0),\RL2:="Correct value must be between [0 ; 6]";
                        result:=ValToStr(zeroRobt);
                    ENDIF
                ENDIF
            ELSE
                !wrong optional argument rotPrecision
                ErrWrite "ERROR::robtToString","Wrong argument value: rotPrecision = "+NumToStr(rotAcc,0),\RL2:="Correct value must be between [0 ; 6]";
                result:=ValToStr(zeroRobt);
            ENDIF
        ELSE
            !wrong optional argument posPrecision
            ErrWrite "ERROR::robtToString","Wrong argument value: posPrecision = "+NumToStr(posAcc,0),\RL2:="Correct value must be between [0 ; 6]";
            result:=ValToStr(zeroRobt);
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
        !checking if inputs is ok
        IF numInsideSet(posAcc,0,6) THEN
            IF numInsideSet(rotAcc,0,6) THEN
                !wobjdata robhold - NO CHANGE
                wobj.robhold:=wobj.robhold;
                !wobjdata ufprog - NO CHANGE
                wobj.ufprog:=wobj.ufprog;
                !wobjdata ufmec - NO CHANGE
                wobj.ufmec:=wobj.ufmec;
                !wobjdata user frame - position (XYZ)
                wobj.uframe.trans.x:=Round(wobj.uframe.trans.x\Dec:=posAcc);
                wobj.uframe.trans.y:=Round(wobj.uframe.trans.y\Dec:=posAcc);
                wobj.uframe.trans.z:=Round(wobj.uframe.trans.z\Dec:=posAcc);
                !wobjdata user frame - orientation (Q)
                wobj.uframe.rot.q1:=Round(wobj.uframe.rot.q1\Dec:=rotAcc);
                wobj.uframe.rot.q2:=Round(wobj.uframe.rot.q2\Dec:=rotAcc);
                wobj.uframe.rot.q3:=Round(wobj.uframe.rot.q3\Dec:=rotAcc);
                wobj.uframe.rot.q4:=Round(wobj.uframe.rot.q4\Dec:=rotAcc);
                !wobjdata object frame - position (XYZ)
                wobj.oframe.trans.x:=Round(wobj.oframe.trans.x\Dec:=posAcc);
                wobj.oframe.trans.y:=Round(wobj.oframe.trans.y\Dec:=posAcc);
                wobj.oframe.trans.z:=Round(wobj.oframe.trans.z\Dec:=posAcc);
                !wobjdata object frame - orientation (Q)
                wobj.oframe.rot.q1:=Round(wobj.oframe.rot.q1\Dec:=rotAcc);
                wobj.oframe.rot.q2:=Round(wobj.oframe.rot.q2\Dec:=rotAcc);
                wobj.oframe.rot.q3:=Round(wobj.oframe.rot.q3\Dec:=rotAcc);
                wobj.oframe.rot.q4:=Round(wobj.oframe.rot.q4\Dec:=rotAcc);
                !checking desired output
                IF Present(onlyUFrame) THEN
                    result:=ValToStr(wobj.uframe);
                ELSEIF Present(onlyOFrame) THEN
                    result:=ValToStr(wobj.oframe);
                ELSE
                    result:=ValToStr(wobj);
                ENDIF
            ELSE
                !wrong optional argument rotPrecision
                ErrWrite "ERROR::robtToString","Wrong argument value: rotPrecision = "+NumToStr(rotAcc,0),\RL2:="Correct value must be between [0 ; 6]";
                result:=ValToStr(zeroRobt);
            ENDIF
        ELSE
            !wrong optional argument posPrecision
            ErrWrite "ERROR::robtToString","Wrong argument value: posPrecision = "+NumToStr(posAcc,0),\RL2:="Correct value must be between [0 ; 6]";
            result:=ValToStr(zeroRobt);
        ENDIF

        RETURN result;
    ENDFUNC
ENDMODULE
