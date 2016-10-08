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

    !===================================================
    !=================  READ VALUES  ===================
    !===================================================     

    !function to read current external axes with selected precision (abb function wrapper) 
    ! ret: extjoint = current readed (& rounded) external axes
    ! arg: extPrec - external axes read precision
    FUNC extjoint readExtAxes(num extPrec)
        VAR extjoint result;
        VAR jointtarget tempJointT;

        !waiting untill robot is standstill and read current position
        WaitTime\InPos,0;
        tempJointT:=CJointT();
        !rounding current jointtarget
        result:=roundExtAxes(tempJointT.extax\extDec:=extPrec);

        RETURN result;
    ENDFUNC

    !function to read current jointtarget with selected precision (abb function wrapper) 
    ! ret: jointtarget = current readed (& rounded) jointtarget 
    ! arg: robPrec - robot axes read precision
    ! arg: extPrec - external axes read precision
    FUNC jointtarget readJointT(num robPrec\num extPrec)
        VAR jointtarget result;
        VAR num additPrec;

        !checking if user wants to have different precisions
        additPrec:=robPrec;
        IF Present(extPrec) additPrec:=extPrec;
        !waiting untill robot is standstill and read current position
        WaitTime\InPos,0;
        result:=CJointT();
        !rounding current jointtarget
        result:=roundJointT(result\robDec:=robPrec\extDec:=additPrec);

        RETURN result;
    ENDFUNC

    !function to read current pos with selected precision (abb function wrapper) 
    ! ret: pos = current readed (& rounded) pos
    ! arg: tool - tooldata used to define current position
    ! arg: wobj - wobjdata used to define current position
    ! arg: robPrec - robot axes read precision
    FUNC pos readPos(PERS tooldata tool,PERS wobjdata wobj,num robPrec)
        VAR pos result;

        !waiting untill robot is standstill (to read good position)
        WaitTime\InPos,0;
        !reading current pos (selected tool in selected wobj)
        result:=CPos(\Tool:=tool\WObj:=wobj);
        !rounding current pos
        result:=roundPos(result\posDec:=robPrec);

        RETURN result;
    ENDFUNC

    !function to read current pose with selected precision (abb function wrapper) 
    ! ret: pose = current readed (& rounded) pose
    ! arg: tool - tooldata used to define current position
    ! arg: wobj - wobjdata used to define current position
    ! arg: robPrec - robot axes read precision (decimal numbers)
    ! arg: oriPrec - robot orient read precision (decimal numbers)
    FUNC pose readPose(PERS tooldata tool,PERS wobjdata wobj,num robPrec\num oriPrec)
        VAR pose result;
        VAR num additPrec;

        !checking if user wants to have different precisions
        additPrec:=robPrec;
        IF Present(oriPrec) additPrec:=oriPrec;
        !waiting untill robot is standstill (to read good position)
        WaitTime\InPos,0;
        !reading current pose (selected tool in selected wobj)
        result:=robtToPose(CRobT(\Tool:=tool\WObj:=wobj));
        !rounding readed pose
        result:=roundPose(result\posDec:=robPrec\oriDec:=additPrec);

        RETURN result;
    ENDFUNC

    !function to read current robtarget with selected precision (abb function wrapper) 
    ! ret: robtarget = current readed (& rounded) robtarget
    ! arg: tool - tooldata used to define current position
    ! arg: wobj - wobjdata used to define current position
    ! arg: robPrec - robot axes read precision
    ! arg: oriPrec - robot orient read precision
    ! arg: extPrec - external axes read precision
    FUNC robtarget readRobt(PERS tooldata tool,PERS wobjdata wobj,num robPrec\num oriPrec\num extPrec)
        VAR robtarget result;
        VAR num orientPrec;
        VAR num extaxPrec;

        !checking if user wants to have different precisions
        orientPrec:=robPrec;
        IF Present(oriPrec) orientPrec:=oriPrec;
        extaxPrec:=robPrec;
        IF Present(extaxPrec) extaxPrec:=extPrec;
        !waiting untill robot is standstill (to read good position)
        WaitTime\InPos,0;
        !reading current robtarget (selected tool in selected wobj)
        result:=CRobT(\Tool:=tool\WObj:=wobj);
        !rounding readed robtarget
        result:=roundRobt(result\posDec:=robPrec\oriDec:=orientPrec\extDec:=extaxPrec);

        RETURN result;
    ENDFUNC

    !===================================================
    !===============  ROUND VALUES  ====================
    !=================================================== 

    !function used to round all components of jointtarget
    ! ret: jointtarget = joints with rounded components
    ! arg: inJointT - joints to round up
    ! arg: robDec - decimal number of robot axes
    ! arg: extDec - decimal number of external axes
    FUNC jointtarget roundJointT(jointtarget inJointT\num robDec\num extDec)
        VAR jointtarget result;
        VAR num robDecimals:=3;
        VAR num extDecimals:=3;

        !check number of decimals
        IF Present(robDec) robDecimals:=robDec;
        IF Present(extDec) extDecimals:=extDec;
        IF numInsideSet(robDecimals,0,6) AND numInsideSet(extDecimals,0,6) THEN
            !round up trans and rot components
            result.robax:=roundRobAxes(inJointT.robax\robDec:=robDecimals);
            result.extax:=roundExtAxes(inJointT.extax\extDec:=extDecimals);
        ELSE
            !decimals NOK = no rounding applied + show error to user
            result:=inJointT;
            ErrWrite "ERROR::roundJointT","Wrong decimal number! Correct values: 0-6"
                                    \RL2:="robDec = "+NumToStr(robDecimals,0)+", extDec = "+NumToStr(extDecimals,0)+"."
                                    \RL3:="Program continues, but no rounding applied!!!";
        ENDIF

        RETURN result;
    ENDFUNC

    !function used to round all components of robot axes
    ! ret: robjoint = robot axes with rounded components
    ! arg: inRob - robot axes to round up
    ! arg: robDec - decimal number
    FUNC robjoint roundRobAxes(robjoint inRobAx\num robDec)
        VAR robjoint result;
        VAR num decimals:=3;

        !check number of decimals 
        IF Present(robDec) decimals:=robDec;
        IF numInsideSet(decimals,0,6) THEN
            !round up robjoint components
            result.rax_1:=Round(inRobAx.rax_1\Dec:=decimals);
            result.rax_2:=Round(inRobAx.rax_2\Dec:=decimals);
            result.rax_3:=Round(inRobAx.rax_3\Dec:=decimals);
            result.rax_4:=Round(inRobAx.rax_4\Dec:=decimals);
            result.rax_5:=Round(inRobAx.rax_5\Dec:=decimals);
            result.rax_6:=Round(inRobAx.rax_6\Dec:=decimals);
        ELSE
            !decimals NOK = no rounding applied + show error to user
            result:=inRobAx;
            ErrWrite "ERROR::roundRobAxes","Wrong decimal number! Correct values: 0-6"
                                     \RL2:="robDec = "+NumToStr(decimals,0)+"."
                                     \RL3:="Program continues, but no rounding applied!!!";
        ENDIF

        RETURN result;
    ENDFUNC

    !function used to round all components of external axes
    ! ret: extax = external axes with rounded components
    ! arg: inExt - external axes  to round up
    ! arg: extDec - decimal number (correct range 0 - 6)
    FUNC extjoint roundExtAxes(extjoint inExtAx\num extDec)
        VAR extjoint result;
        VAR num decimals:=3;

        !check number of decimals 
        IF Present(extDec) decimals:=extDec;
        IF numInsideSet(decimals,0,6) THEN
            !round up extax components
            result.eax_a:=Round(inExtAx.eax_a\Dec:=decimals);
            result.eax_b:=Round(inExtAx.eax_b\Dec:=decimals);
            result.eax_c:=Round(inExtAx.eax_c\Dec:=decimals);
            result.eax_d:=Round(inExtAx.eax_d\Dec:=decimals);
            result.eax_e:=Round(inExtAx.eax_e\Dec:=decimals);
            result.eax_f:=Round(inExtAx.eax_f\Dec:=decimals);
        ELSE
            !decimals NOK = no rounding applied + show error to user
            result:=inExtAx;
            ErrWrite "ERROR::roundExtAxes","Wrong decimal number! Correct values: 0-6"
                                     \RL2:="extDec="+NumToStr(decimals,0)+"."
                                     \RL3:="Program continues, but no rounding applied!!!";
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

        !check number of decimals 
        IF Present(oriDec) decimals:=oriDec;
        IF numInsideSet(decimals,0,6) THEN
            !round up orient components
            result.q1:=Round(inOri.q1\Dec:=decimals);
            result.q2:=Round(inOri.q2\Dec:=decimals);
            result.q3:=Round(inOri.q3\Dec:=decimals);
            result.q4:=Round(inOri.q4\Dec:=decimals);
            result:=NOrient(result);
        ELSE
            !decimals NOK = no rounding applied + show error to user
            result:=inOri;
            ErrWrite "ERROR::roundOri","Wrong decimal number! Correct values: 0-6"
                                 \RL2:="oriDec="+NumToStr(decimals,0)+"."
                                 \RL3:="Program continues, but no rounding applied!!!";
        ENDIF

        RETURN result;
    ENDFUNC

    !function used to round all components of pos
    ! ret: pos = pos with rounded components
    ! arg: inPos - pos to round up
    ! arg: posDec - decimal number
    FUNC pos roundPos(pos inPos\num posDec)
        VAR pos result;
        VAR num decimals:=3;

        !check number of decimals 
        IF Present(posDec) decimals:=posDec;
        IF numInsideSet(decimals,0,6) THEN
            !round up pos components
            result.x:=Round(inPos.x\Dec:=decimals);
            result.y:=Round(inPos.y\Dec:=decimals);
            result.z:=Round(inPos.z\Dec:=decimals);
        ELSE
            !decimals NOK = no rounding applied + show error to user
            result:=inPos;
            ErrWrite "ERROR::roundPos","Wrong decimal number! Correct values: 0-6"
                                 \RL2:="posDec="+NumToStr(decimals,0)+"."
                                 \RL3:="Program continues, but no rounding applied!!!";
        ENDIF

        RETURN result;
    ENDFUNC

    !function used to round all components of pose
    ! ret: pose = pose with rounded components
    ! arg: inPose - pose to round up
    ! arg: posDec - decimal number of pos component
    ! arg: oriDec - decimal number of orient component
    FUNC pose roundPose(pose inPose\num posDec\num oriDec)
        VAR pose result;
        VAR num posAcc:=3;
        VAR num oriAcc:=5;

        !check number of decimals
        IF Present(posDec) posAcc:=posDec;
        IF Present(oriDec) oriAcc:=oriDec;
        IF numInsideSet(posAcc,0,6) AND numInsideSet(oriAcc,0,6) THEN
            !round up trans and rot components
            result.trans:=roundPos(inPose.trans\posDec:=posAcc);
            result.rot:=roundOri(inPose.rot\oriDec:=oriAcc);
        ELSE
            !decimals NOK = no rounding applied + show error to user
            result:=inPose;
            ErrWrite "ERROR::roundPose","Wrong decimal number! Correct values: 0-6"
                                  \RL2:="posDec="+NumToStr(posAcc,0)+", oriDec="+NumToStr(oriAcc,0)+"."
                                  \RL3:="Program continues, but no rounding applied!!!";
        ENDIF

        RETURN result;
    ENDFUNC

    !function used to round all components of robtarget
    ! ret: robtarget = robtarget with rounded components
    ! arg: inRobt - robtarget to round up
    ! arg: posDec - decimal number of pos component
    ! arg: oriDec - decimal number of orient component
    ! arg: extDec - decimal number of external axes component
    FUNC robtarget roundRobt(robtarget inRobt\num posDec\num oriDec\num extDec)
        VAR robtarget result;
        VAR num posAcc:=3;
        VAR num oriAcc:=5;
        VAR num extAcc:=2;

        !check number of decimals
        IF Present(posDec) posAcc:=posDec;
        IF Present(oriDec) oriAcc:=oriDec;
        IF Present(extDec) extAcc:=extDec;
        IF numInsideSet(posAcc,0,6) AND numInsideSet(oriAcc,0,6) AND numInsideSet(extAcc,0,6) THEN
            !round up trans, rot, eax components (robconf - no change
            result.trans:=roundPos(inRobt.trans\posDec:=posAcc);
            result.rot:=roundOri(inRobt.rot\oriDec:=oriAcc);
            result.robconf:=inRobt.robconf;
            result.extax:=roundExtAxes(inRobt.extax\extDec:=extAcc);
        ELSE
            !decimals NOK = no rounding applied + show error to user
            result:=inRobt;
            ErrWrite "ERROR::roundRobt","Wrong decimal number! Correct values: 0-6"
                                  \RL2:="posDec="+NumToStr(posAcc,0)+", oriDec="+NumToStr(oriAcc,0)+", extDec="+NumToStr(extAcc,0)+"."
                                  \RL3:="Program continues, but no rounding applied!!!";
        ENDIF

        RETURN result;
    ENDFUNC

    !function used to round all components of wobjdata
    ! ret: wobjdata = workobject with rounded components
    ! arg: inWobj - workobject to round up
    ! arg: posDec - decimal number of pos component
    ! arg: oriDec - decimal number of orient component
    FUNC wobjdata roundWobj(wobjdata inWobj\num posDec\num oriDec)
        VAR wobjdata result;
        VAR num posAcc:=1;
        VAR num oriAcc:=4;

        !check number of decimals
        IF Present(posDec) posAcc:=posDec;
        IF Present(oriDec) oriAcc:=oriDec;
        IF numInsideSet(posAcc,0,6) AND numInsideSet(oriAcc,0,6) THEN
            !round up trans, rot, eax components (robconf - no change
            result.robhold:=inWobj.robhold;
            result.ufprog:=inWobj.ufprog;
            result.ufmec:=inWobj.ufmec;
            result.uframe:=roundPose(inWobj.uframe\posDec:=posAcc\oriDec:=oriAcc);
            result.oframe:=roundPose(inWobj.oframe\posDec:=posAcc\oriDec:=oriAcc);
        ELSE
            !decimals NOK = no rounding applied + show error to user
            result:=inWobj;
            ErrWrite "ERROR::roundWobj","Wrong decimal number! Correct values: 0-6"
                                  \RL2:="posDec="+NumToStr(posAcc,0)+", oriDec="+NumToStr(oriAcc,0)+"."
                                  \RL3:="Program continues, but no rounding applied!!!";
        ENDIF

        RETURN result;
    ENDFUNC
ENDMODULE
