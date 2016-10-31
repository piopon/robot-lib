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
    !==============  COMPARE POSITIONS  ================
    !=================================================== 

    !function used to compare two external axes with specified decimal precision
    ! ret: bool = external axes are equal (TRUE) or not (FALSE)
    ! arg: eax1 - first external joint to compare
    ! arg: eax2 - second external joint to compare
    ! arg: prec - number of decimal points used in comparison (default: 3)
    FUNC bool compareExtax(extjoint eax1,extjoint eax2\num prec)
        VAR bool result;
        VAR num dec:=3;

        !check user optional argument
        IF Present(prec) dec:=prec;
        !rounding external axes
        eax1:=roundExtax(eax1\extDec:=dec);
        eax2:=roundExtax(eax2\extDec:=dec);
        !comparing two rounded external axes
        result:=eax1=eax2;

        RETURN result;
    ENDFUNC

    !function used to compare two robot axes with specified decimal precision
    ! ret: bool = robot axes are equal (TRUE) or not (FALSE)
    ! arg: robax1 - first robot joint to compare
    ! arg: robax2 - second robot joint to compare
    ! arg: prec - number of decimal points used in comparison (default: 3)
    FUNC bool compareRobax(robjoint robax1,robjoint robax2\num prec)
        VAR bool result;
        VAR num dec:=3;

        !check user optional argument
        IF Present(prec) dec:=prec;
        !rounding robot axes
        robax1:=roundRobax(robax1\robDec:=dec);
        robax2:=roundRobax(robax2\robDec:=dec);
        !comparing two rounded robot axes
        result:=robax1=robax2;

        RETURN result;
    ENDFUNC

    !function used to compare two jointtargets with specified decimal precision
    ! ret: bool = jointtargets are equal (TRUE) or not (FALSE)
    ! arg: joint1 - first jointtarget to compare
    ! arg: joint2 - second jointtarget to compare
    ! arg: prec - number of decimal points used in comparison (default: 3)
    FUNC bool compareJointT(jointtarget joint1,jointtarget joint2\num prec)
        VAR bool result;
        VAR num dec:=3;

        !check user optional argument
        IF Present(prec) dec:=prec;
        !rounding jointtargets
        joint1:=roundJointT(joint1\robDec:=dec\extDec:=dec);
        joint2:=roundJointT(joint2\robDec:=dec\extDec:=dec);
        !comparing two rounded jointtargets
        result:=joint1=joint2;

        RETURN result;
    ENDFUNC

    !function used to compare two orients with specified decimal precision
    ! ret: bool = orients are equal (TRUE) or not (FALSE)
    ! arg: ori1 - first orient to compare
    ! arg: ori2 - second orient to compare
    ! arg: prec - number of decimal points used in comparison (default: 3)
    FUNC bool compareOri(orient ori1,orient ori2\num prec)
        VAR bool result;
        VAR num dec:=3;

        !check user optional argument
        IF Present(prec) dec:=prec;
        !rounding orients
        ori1:=roundOri(ori1\oriDec:=dec);
        ori2:=roundOri(ori2\oriDec:=dec);
        !comparing two rounded orients
        result:=ori1=ori2;

        RETURN result;
    ENDFUNC

    !function used to compare two poses with specified decimal precision
    ! ret: bool = poses are equal (TRUE) or not (FALSE)
    ! arg: pos1 - first pos to compare
    ! arg: pos2 - second pos to compare
    ! arg: prec - number of decimal points used in comparison (default: 3)
    FUNC bool comparePos(pos pos1,pos pos2\num prec)
        VAR bool result;
        VAR num dec:=3;

        !check user optional argument
        IF Present(prec) dec:=prec;
        !rounding poses
        pos1:=roundPos(pos1\posDec:=dec);
        pos2:=roundPos(pos2\posDec:=dec);
        !comparing two rounded poses
        result:=pos1=pos2;

        RETURN result;
    ENDFUNC

    !function used to compare two positions with specified decimal precision
    ! ret: bool = positions are equal (TRUE) or not (FALSE)
    ! arg: pose1 - first position to compare
    ! arg: pose2 - second position to compare
    ! arg: prec - number of decimal points used in comparison (default: 3)
    FUNC bool comparePose(pose pose1,pose pose2\num prec)
        VAR bool result;
        VAR num dec:=3;

        !check user optional argument
        IF Present(prec) dec:=prec;
        !rounding positions
        pose1:=roundPose(pose1\posDec:=dec\oriDec:=dec);
        pose2:=roundPose(pose2\posDec:=dec\oriDec:=dec);
        !comparing two rounded positions
        result:=pose1=pose2;

        RETURN result;
    ENDFUNC

    !function used to compare two robtargets with specified decimal precision
    ! ret: bool = robtargets are equal (TRUE) or not (FALSE)
    ! arg: robt1 - first robtarget to compare
    ! arg: robt2 - second robtarget to compare
    ! arg: prec - number of decimal points used in comparison (default: 3)
    FUNC bool compareRobT(robtarget robt1,robtarget robt2\num prec)
        VAR bool result;
        VAR num dec:=3;

        !check user optional argument
        IF Present(prec) dec:=prec;
        !rounding robtargets
        robt1:=roundRobT(robt1\posDec:=dec\oriDec:=dec\extDec:=dec);
        robt2:=roundRobT(robt2\posDec:=dec\oriDec:=dec\extDec:=dec);
        !comparing two rounded robtargets
        result:=robt1=robt2;

        RETURN result;
    ENDFUNC

    !function used to compare two workobjects with specified decimal precision
    ! ret: bool = workobjects are equal (TRUE) or not (FALSE)
    ! arg: wobj1 - first workobject to compare
    ! arg: wobj2 - second workobject to compare
    ! arg: prec - number of decimal points used in comparison (default: 3)
    FUNC bool compareWobj(wobjdata wobj1,wobjdata wobj2\num prec)
        VAR bool result;
        VAR num dec:=3;

        !check user optional argument
        IF Present(prec) dec:=prec;
        !rounding workobjects
        wobj1:=roundWobj(wobj1\posDec:=dec\oriDec:=dec);
        wobj2:=roundWobj(wobj2\posDec:=dec\oriDec:=dec);
        !comparing two rounded workobjects
        result:=wobj1=wobj2;

        RETURN result;
    ENDFUNC

    !===================================================
    !=================  READ VALUES  ===================
    !===================================================     

    !function to read current external axes with selected precision (abb function wrapper) 
    ! ret: extjoint = current readed (& rounded) external axes
    ! arg: extPrec - external axes read precision
    FUNC extjoint readExtax(num extPrec)
        VAR extjoint result;
        VAR jointtarget tempJointT;

        !waiting untill robot is standstill and read current position
        WaitTime\InPos,0;
        tempJointT:=CJointT();
        !rounding current jointtarget
        result:=roundExtax(tempJointT.extax\extDec:=extPrec);

        RETURN result;
    ENDFUNC

    !function to read current robot axes with selected precision (abb function wrapper) 
    ! ret: robjoint = current readed (& rounded) robot axes
    ! arg: robPrec - robot axes read precision
    FUNC robjoint readRobax(num robPrec)
        VAR robjoint result;
        VAR jointtarget tempJointT;

        !waiting untill robot is standstill and read current position
        WaitTime\InPos,0;
        tempJointT:=CJointT();
        !rounding current jointtarget
        result:=roundRobax(tempJointT.robax\robDec:=robPrec);

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

    !function to read current orient with selected precision (abb function wrapper) 
    ! ret: orient = current readed (& rounded) orient
    ! arg: tool - tooldata used to define current orient
    ! arg: wobj - wobjdata used to define current orient
    ! arg: oriPrec - robot orient read precision (decimal numbers)
    FUNC orient readOri(PERS tooldata tool,PERS wobjdata wobj,num oriPrec)
        VAR orient result;
        VAR robtarget tempRobt;

        !waiting untill robot is standstill (to read good position)
        WaitTime\InPos,0;
        !reading current pose (selected tool in selected wobj)
        tempRobt:=CRobT(\Tool:=tool\WObj:=wobj);
        !rounding readed pose
        result:=roundOri(tempRobt.rot\oriDec:=oriPrec);

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
    FUNC robtarget readRobT(PERS tooldata tool,PERS wobjdata wobj,num robPrec\num oriPrec\num extPrec)
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
        result:=roundRobT(result\posDec:=robPrec\oriDec:=orientPrec\extDec:=extaxPrec);

        RETURN result;
    ENDFUNC

    !function to read current workobject with selected precision (abb function wrapper) 
    ! ret: wobjdata = current readed (& rounded) workobject
    ! arg: tool - tooldata used to define current position
    ! arg: wobj - wobjdata used to define current position
    ! arg: robPrec - robot axes read precision
    ! arg: oriPrec - robot orient read precision
    ! arg: extPrec - external axes read precision
    FUNC wobjdata readWobj(num posPrec\num oriPrec)
        VAR wobjdata result;
        VAR num orientPrec;

        !checking if user wants to have different precisions
        orientPrec:=posPrec;
        IF Present(oriPrec) orientPrec:=oriPrec;
        !reading current workobject 
        result:=CWobj();
        !rounding readed workobject
        result:=roundWobj(result\posDec:=posPrec\oriDec:=orientPrec);

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
            result.robax:=roundRobax(inJointT.robax\robDec:=robDecimals);
            result.extax:=roundExtax(inJointT.extax\extDec:=extDecimals);
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
    FUNC robjoint roundRobax(robjoint inRobAx\num robDec)
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
    FUNC extjoint roundExtax(extjoint inExtAx\num extDec)
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
    FUNC robtarget roundRobT(robtarget inRobt\num posDec\num oriDec\num extDec)
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
            result.extax:=roundExtax(inRobt.extax\extDec:=extAcc);
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

    !===================================================
    !=================  SAFE ZONES  ====================
    !===================================================

    !function used to find zone number (from global table in libVars.mod) which contains selected point
    ! ret: num = number of zone which contains selected pos
    ! arg: checkPos - position XYZ for wich we want to find parent zone 
    FUNC num zoneGet(pos byPos)
        !scan all zones defined in table (libVars)
        FOR i FROM 1 TO Dim(zones,1) DO
            !check if point is inside current zone
            IF zoneCheck(byPos\inside,zones{i}) RETURN zones{i}.ID;
        ENDFOR
        !if we are here there is no matching zone
        RETURN -1;
    ENDFUNC

    !function used to check if pos is inside/outside selected zone
    ! ret: bool = point is inside/outside selected zone (TRUE) or not (FALSE)
    ! arg: point - pos to check
    ! arg: currZone - zone to check
    FUNC bool zoneCheck(pos point,\switch inside|switch outside,zone3D currZone)
        VAR bool result:=TRUE;
        CONST num cornersNo:=4;
        VAR num refPointNo;
        VAR num vecPointNo{2};
        VAR pos zoneCorners{cornersNo};

        !we have to inspect two zone rectangles (first at XY surface, second at YZ surface)
        !to determine if selected point is inside/outside our zone3D
        FOR rectNo FROM 1 TO 2 DO
            !define current rectangle corners 
            zoneCorners{1}:=currZone.start.trans;
            zoneCorners{2}:=poseToPos(relPose(currZone.start,(2-rectNo)*currZone.xLen,0,(rectNo-1)*currZone.zLen));
            zoneCorners{3}:=poseToPos(relPose(currZone.start,(2-rectNo)*currZone.xLen,currZone.yLen,(rectNo-1)*currZone.zLen));
            zoneCorners{4}:=poseToPos(relPose(currZone.start,0,currZone.yLen,0));
            !check if point is inside rectangle defined by corners above
            FOR i FROM 1 TO cornersNo DO
                !determine reference and vector points numbers
                refPointNo:=(i+2)-Trunc((i+2)-1/cornersNo)*cornersNo;
                vecPointNo{1}:=(i+0)-Trunc((i+0)-1/cornersNo)*cornersNo;
                vecPointNo{2}:=(i+1)-Trunc((i+1)-1/cornersNo)*cornersNo;
                result:=vectorSameRefSide(point,zoneCorners{refPointNo},zoneCorners{vecPointNo{1}},zoneCorners{vecPointNo{2}});
                !if point is nok then return from this function with false
                IF NOT result RETURN result;
            ENDFOR
        ENDFOR

        RETURN result;
    ENDFUNC
ENDMODULE
