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
            result.x:=Round(result.x\Dec:=robPrecision);
            result.y:=Round(result.y\Dec:=robPrecision);
            result.z:=Round(result.z\Dec:=robPrecision);
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
    ! arg: robPrecision - robot axes read precision
    ! arg: oriPrecision - robot orient read precision
    FUNC pose readPose(PERS tooldata tool,PERS wobjdata wobj,num robPrecision\num oriPrecision)
        VAR pose result;
        VAR num currPrecision;

        !waiting untill robot is standstill (to read good position)
        WaitTime\InPos,0;
        !reading current robtarget (selected tool in selected wobj)
        result:=robtToPose(CRobT(\Tool:=tool\WObj:=wobj));
        !rounding readed robtarget
        currPrecision:=robPrecision;
        IF numInsideSet(currPrecision,0,6) THEN
            !pose trans (pos)
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
            ELSE
                !wrong inputted data - oriPrecision
                ErrWrite\W,"WARN::readPose","Wrong argument value: oriPrecision = "+NumToStr(currPrecision,0),\RL2:="Correct value must be between [0 ; 6]"\RL3:="Program resumes - no rounding applied!";
            ENDIF
        ELSE
            !wrong inputted data - robPrecision
            ErrWrite\W,"WARN::readPose","Wrong argument value: robPrecision = "+NumToStr(currPrecision,0),\RL2:="Correct value must be between [0 ; 6]"\RL3:="Program resumes - no rounding applied!";
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
ENDMODULE
