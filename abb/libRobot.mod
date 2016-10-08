MODULE libRobot
    !*******************************************************************!
    ! Copyright (C) 2016 Piotr Ponikowski <pipon.github@gmail.com>      !
    !*******************************************************************!
    ! Module Name:  libRobot                                            !
    ! Description:  abb robot data operations                           !
    ! Date:         2016-10-03                                          !
    ! Author:       Piotr Ponikowski <pipon.github@gmail.com>           !
    ! Contributors:                                                     !
    !*******************************************************************!

    !function to read current jointtarget with selected precision (abb function wrapper) 
    ! ret: jointtarget = current readed (& rounded) jointtarget 
    ! arg: robPrecision - robot axes read precision
    ! arg: extPrecision - external axes read precision
    FUNC jointtarget readJoint(num robPrecision\num extPrecision)
        VAR jointtarget result;
        VAR num currPrecision;

        !waiting untill robot is standstill (to read good position)
        WaitTime\InPos,0;
        !reading current jointtarget
        result:=CJointT();
        !rounding readed jointtarget
        currPrecision:=robPrecision;
        IF numInsideSet(currPrecision,0,6) THEN
            !robot axes
            result.robax.rax_1:=Round(result.robax.rax_1\Dec:=currPrecision);
            result.robax.rax_2:=Round(result.robax.rax_2\Dec:=currPrecision);
            result.robax.rax_3:=Round(result.robax.rax_3\Dec:=currPrecision);
            result.robax.rax_4:=Round(result.robax.rax_4\Dec:=currPrecision);
            result.robax.rax_5:=Round(result.robax.rax_5\Dec:=currPrecision);
            result.robax.rax_6:=Round(result.robax.rax_6\Dec:=currPrecision);
            !external axes
            IF Present(extPrecision) currPrecision:=extPrecision;
            IF numInsideSet(currPrecision,0,6) THEN
                result.extax.eax_a:=Round(result.extax.eax_a\Dec:=currPrecision);
                result.extax.eax_b:=Round(result.extax.eax_b\Dec:=currPrecision);
                result.extax.eax_c:=Round(result.extax.eax_c\Dec:=currPrecision);
                result.extax.eax_d:=Round(result.extax.eax_d\Dec:=currPrecision);
                result.extax.eax_e:=Round(result.extax.eax_e\Dec:=currPrecision);
                result.extax.eax_f:=Round(result.extax.eax_f\Dec:=currPrecision);
            ELSE
                !wrong inputted data - extPrecision
                ErrWrite\W,"WARN::readJoint","Wrong argument value: extPrecision = "+NumToStr(currPrecision,0),\RL2:="Correct value must be between [0 ; 6]"\RL3:="Program resumes - no rounding applied!";
            ENDIF
        ELSE
            !wrong inputted data - currPrecision
            ErrWrite\W,"WARN::readJoint","Wrong argument value: robPrecision = "+NumToStr(currPrecision,0),\RL2:="Correct value must be between [0 ; 6]"\RL3:="Program resumes - no rounding applied!";
        ENDIF

        RETURN result;
    ENDFUNC
    
    !function to read current pos with selected precision (abb function wrapper) 
    ! ret: pos = current readed (& rounded) pos
    ! arg: tool - tooldata used to define current position
    ! arg: wobj - wobjdata used to define current position
    ! arg: robPrecision - robot axes read precision
    FUNC pos readPos(PERS tooldata tool,PERS wobjdata wobj,num robPrecision)
        VAR pos result;

        !waiting untill robot is standstill (to read good position)
        WaitTime\InPos,0;
        !reading current robtarget (selected tool in selected wobj)
        result:=CPos(\Tool:=tool\WObj:=wobj);
        !rounding readed pos
        IF numInsideSet(robPrecision,0,6) THEN
            result:=roundPos(result\posDec:=robPrecision);
        ELSE
            !wrong inputted data - robPrecision
            ErrWrite\W,"WARN::readPos","Wrong argument value: robPrecision = "+NumToStr(robPrecision,0),\RL2:="Correct value must be between [0 ; 6]"\RL3:="Program resumes - no rounding applied!";
        ENDIF

        RETURN result;
    ENDFUNC    

    !function to read current pose with selected precision (abb function wrapper) 
    ! ret: pose = current readed (& rounded) pose
    ! arg: tool - tooldata used to define current position
    ! arg: wobj - wobjdata used to define current position
    ! arg: robDec - robot axes read precision (decimal numbers)
    ! arg: oriDec - robot orient read precision (decimal numbers)
    FUNC pose readPose(PERS tooldata tool,PERS wobjdata wobj,\num robDec\num oriDec)
        VAR pose result;
        VAR num currDec:=4;

        !waiting untill robot is standstill (to read good position)
        WaitTime\InPos,0;
        !reading current pose (selected tool in selected wobj)
        result:=robtToPose(CRobT(\Tool:=tool\WObj:=wobj));
        !rounding readed pose
        IF Present(robDec) currDec:=robDec;
        IF numInsideSet(currDec,0,6) THEN
            !pose trans (pos)
            result.trans:=roundPos(result.trans\posDec:=currDec);
            !robtarget orient
            IF Present(oriDec) currDec:=oriDec;
            IF numInsideSet(currDec,0,6) THEN
                result.rot:=roundOri(result.rot\oriDec:=currDec);
            ELSE
                !wrong inputted data - oriDec
                ErrWrite\W,"WARN::readPose","Wrong argument value: oriPrecision = "+NumToStr(currDec,0),\RL2:="Correct value must be between [0 ; 6]"\RL3:="Program resumes - no rounding applied!";
            ENDIF
        ELSE
            !wrong inputted data - robDec
            ErrWrite\W,"WARN::readPose","Wrong argument value: robPrecision = "+NumToStr(currDec,0),\RL2:="Correct value must be between [0 ; 6]"\RL3:="Program resumes - no rounding applied!";
        ENDIF

        RETURN result;
    ENDFUNC

    !function to read current robtarget with selected precision (abb function wrapper) 
    ! ret: robtarget = current readed (& rounded) robtarget
    ! arg: tool - tooldata used to define current position
    ! arg: wobj - wobjdata used to define current position
    ! arg: robPrecision - robot axes read precision
    ! arg: oriPrecision - robot orient read precision
    ! arg: extPrecision - external axes read precision
    FUNC robtarget readRobt(PERS tooldata tool,PERS wobjdata wobj,num robPrecision\num oriPrecision\num extPrecision)
        VAR robtarget result;
        VAR num currPrecision;

        !waiting untill robot is standstill (to read good position)
        WaitTime\InPos,0;
        !reading current robtarget (selected tool in selected wobj)
        result:=CRobT(\Tool:=tool\WObj:=wobj);
        !rounding readed robtarget
        currPrecision:=robPrecision;
        IF numInsideSet(currPrecision,0,6) THEN
            !robtarget pos
            result.trans.x:=Round(result.trans.x\Dec:=currPrecision);
            result.trans.y:=Round(result.trans.y\Dec:=currPrecision);
            result.trans.z:=Round(result.trans.z\Dec:=currPrecision);
            !robtarget orient
            IF Present(oriPrecision) currPrecision:=oriPrecision;
            IF numInsideSet(currPrecision,0,6) THEN
                result.rot.q1:=Round(result.rot.q1\Dec:=currPrecision);
                result.rot.q2:=Round(result.rot.q2\Dec:=currPrecision);
                result.rot.q3:=Round(result.rot.q3\Dec:=currPrecision);
                result.rot.q4:=Round(result.rot.q4\Dec:=currPrecision);
                result.rot:=NOrient(result.rot);
                !robtarget configuration (NO CHANGE)
                !robtarget external axes
                IF Present(extPrecision) currPrecision:=extPrecision;
                IF numInsideSet(currPrecision,0,6) THEN
                    result.extax.eax_a:=Round(result.extax.eax_a\Dec:=currPrecision);
                    result.extax.eax_b:=Round(result.extax.eax_b\Dec:=currPrecision);
                    result.extax.eax_c:=Round(result.extax.eax_c\Dec:=currPrecision);
                    result.extax.eax_d:=Round(result.extax.eax_d\Dec:=currPrecision);
                    result.extax.eax_e:=Round(result.extax.eax_e\Dec:=currPrecision);
                    result.extax.eax_f:=Round(result.extax.eax_f\Dec:=currPrecision);
                ELSE
                    !wrong inputted data - extPrecision
                    ErrWrite\W,"WARN::readRobt","Wrong argument value: extPrecision = "+NumToStr(currPrecision,0),\RL2:="Correct value must be between [0 ; 6]"\RL3:="Program resumes - no rounding applied!";
                ENDIF
            ELSE
                !wrong inputted data - oriPrecision
                ErrWrite\W,"WARN::readRobt","Wrong argument value: oriPrecision = "+NumToStr(currPrecision,0),\RL2:="Correct value must be between [0 ; 6]"\RL3:="Program resumes - no rounding applied!";
            ENDIF
        ELSE
            !wrong inputted data - robPrecision
            ErrWrite\W,"WARN::readRobt","Wrong argument value: robPrecision = "+NumToStr(currPrecision,0),\RL2:="Correct value must be between [0 ; 6]"\RL3:="Program resumes - no rounding applied!";
        ENDIF

        RETURN result;
    ENDFUNC
    
    !function used to round all components of orient
    ! ret: orient = orient with rounded components
    ! arg: inOri - orient to round up
    ! arg: oriDec - decimal number
    FUNC orient roundOri(orient inOri\num oriDec)
        VAR orient result;
        VAR num decimals:=5;
        
        IF Present(oriDec) decimals:=oriDec;
        result.q1:=Round(inOri.q1\Dec:=decimals);
        result.q2:=Round(inOri.q2\Dec:=decimals);
        result.q3:=Round(inOri.q3\Dec:=decimals);
        result.q4:=Round(inOri.q4\Dec:=decimals);
        result:=NOrient(result);
        
        RETURN result;
    ENDFUNC
    
    !function used to round all components of pos
    ! ret: pos = pos with rounded components
    ! arg: inPos - pos to round up
    ! arg: posDec - decimal number
    FUNC pos roundPos(pos inPos\num posDec)
        VAR pos result;
        VAR num decimals:=4;
        
        IF Present(posDec) decimals:=posDec;
        result.x:=Round(inPos.x\Dec:=decimals);
        result.y:=Round(inPos.y\Dec:=decimals);
        result.z:=Round(inPos.z\Dec:=decimals);
        
        RETURN result;
    ENDFUNC
    
    !function used to round all components of pose
    ! ret: pose = pose with rounded components
    ! arg: inPose - pose to round up
    ! arg: posDec - decimal number of pos component
    ! arg: oriDec - decimal number of orient component
    FUNC pose roundPose(pose inPose\num posDec\num oriDec)
        VAR pose result;
        VAR num posAcc:=4;
        VAR num oriAcc:=5;
        
        !check number of decimals in trans and round it up
        IF Present(posDec) posAcc:=posDec;
        result.trans:=roundPos(inPose.trans\posDec:=posAcc);
        !check number of decimals in orient and round it up
        IF Present(oriDec) oriAcc:=oriDec;
        result.rot:=roundOri(inPose.rot\oriDec:=oriAcc);
        
        RETURN result;
    ENDFUNC    
ENDMODULE
