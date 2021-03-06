MODULE libGeometry
    !*******************************************************************!
    ! Copyright (C) 2016 Piotr Ponikowski <pipon.github@gmail.com>      !
    !*******************************************************************!
    ! Module Name:  libGeometry                                         !
    ! Description:  math 3D (align, rotations, vecor shifting, etc.)    !
    ! Date:         2016-10-06                                          !
    ! Author:       Piotr Ponikowski <pipon.github@gmail.com>           !
    ! Contributors:                                                     !
    !*******************************************************************!    

    !function used to move selected pos by selected length in direction specified by vector
    ! ret: pos = point moved by length in selected direction
    ! arg: currentPos - starting point to be shifted
    ! arg: vector - direction of shift
    ! arg: length - value of shift [mm] 
    FUNC pos shiftPosByVector(pos currentPos,pos vector,num length)
        VAR pos result;

        !move selected pos
        result.x:=currentPos.x+vector.x*length;
        result.y:=currentPos.y+vector.y*length;
        result.z:=currentPos.z+vector.z*length;

        RETURN result;
    ENDFUNC

    !function used to move selected pose by selected length in direction specified by vector
    ! ret: pose = pose moved by length in selected direction
    ! arg: currentPos - starting pose to be shifted
    ! arg: vector - direction of shift
    ! arg: length - value of shift [mm] 
    FUNC pose shiftPoseByVector(pose currentPose,pos vector,num length)
        VAR pose result;

        !remeber orient (pos will be changed below)
        result:=currentPose;
        !shift pos by vector
        result.trans:=shiftPosByVector(currentPose.trans,vector,length);

        RETURN result;
    ENDFUNC

    !function used to move robt by selected length in direction specified by vector
    ! ret: robtarget = robt moved by length in selected direction
    ! arg: currentPos - starting robt to be shifted
    ! arg: vector - direction of shift
    ! arg: length - value of shift [mm] 
    FUNC robtarget shiftRobtByVector(robtarget currentRobt,pos vector,num length)
        VAR robtarget result;

        !remeber orient,extax and config (pos will be changed below)
        result:=currentRobt;
        !shift pos by vector
        result.trans:=shiftPosByVector(currentRobt.trans,vector,length);

        RETURN result;
    ENDFUNC
    
    !function used to local correction of pose variable (analogy to RelTool) 
    ! ret: pose = locally corrected pose
    ! arg: input - input pose
    ! arg: x,y,z - trans correction (displacement in mm in X, Y and Z direction)
    ! arg: Rx,Ry,Rz - orient correction (rotation in deg around X, Y and Z axis)
    FUNC pose relPose(VAR pose input,num x,num y,num z,\num Rx,\num Ry,\num Rz)
        VAR pose result;
        VAR pose correction;
        VAR num finalRx:=0;
        VAR num finalRy:=0;
        VAR num finalRz:=0;

        !check optional data provided by user
        IF Present(Rx) finalRx:=Rx;
        IF Present(Ry) finalRy:=Ry;
        IF Present(Rz) finalRz:=Rz;
        !compose correction
        correction:=[[x,y,z],OrientZYX(finalRz,finalRy,finalRx)];
        !locally modify input pose
        result:=PoseMult(input,correction);

        RETURN result;
    ENDFUNC   
    
    !function used to local correction of robtarget variable (lib-wrapper of RelTool) 
    ! ret: robtarget = locally corrected robtarget
    ! arg: input - input robtarget
    ! arg: x,y,z - trans correction (displacement in mm in X, Y and Z direction)
    ! arg: Rx,Ry,Rz - orient correction (rotation in deg around X, Y and Z axis)
    FUNC robtarget relRobt(VAR robtarget input,num x,num y,num z,\num Rx,\num Ry,\num Rz)
        VAR robtarget result;
        VAR num finalRx:=0;
        VAR num finalRy:=0;
        VAR num finalRz:=0;

        !check optional data provided by user
        IF Present(Rx) finalRx:=Rx;
        IF Present(Ry) finalRy:=Ry;
        IF Present(Rz) finalRz:=Rz;
        !locally modify input robtarget
        result:=relTool(input,x,y,z\Rx:=finalRx\Ry:=finalRy\Rz:=finalRz);

        RETURN result;
    ENDFUNC    

    !function used to calc local reorientation of pose (in tool coordinate system) [order: Z->Y->X]
    ! ret: pose = locally rotated pose
    ! arg: originalPose - input pose to rotate
    ! arg: xRotDeg - rotation angle (in deg) around axis X
    ! arg: yRotDeg - rotation angle (in deg) around axis Y
    ! arg: zRotDeg - rotation angle (in deg) around axis Z
    FUNC pose rotLocalPoseZYX(pose originalPose,\num xRotDeg\num yRotDeg\num zRotDeg)
        VAR pose result;
        VAR pose tempPose:=[[0,0,0],[1,0,0,0]];
        VAR num xRot:=0;
        VAR num yRot:=0;
        VAR num zRot:=0;

        !update rotations angles (user selection)
        IF Present(xRotDeg) xRot:=xRotDeg;
        IF Present(yRotDeg) yRot:=yRotDeg;
        IF Present(zRotDeg) zRot:=zRotDeg;
        !rotate position (multiply)
        tempPose.rot:=OrientZYX(zRot,yRot,xRot);
        tempPose.rot:=Norient(tempPose.rot);
        result:=PoseMult(originalPose,tempPose);

        RETURN result;
    ENDFUNC
    
    !function used to calc local reorientation of robtarget (in tool coordinate system) [order: Z->Y->X]
    ! ret: robtarget = locally rotated robt
    ! arg: originalRobt - input robtarget to rotate
    ! arg: xRotDeg - rotation angle (in deg) around axis X
    ! arg: yRotDeg - rotation angle (in deg) around axis Y
    ! arg: zRotDeg - rotation angle (in deg) around axis Z
    FUNC robtarget rotLocalRobtZYX(robtarget originalRobt,\num xRotDeg\num yRotDeg\num zRotDeg)
        VAR robtarget result;
        VAR num xRot:=0;
        VAR num yRot:=0;
        VAR num zRot:=0;

        !update rotations angles (user selection)
        IF Present(xRotDeg) xRot:=xRotDeg;
        IF Present(yRotDeg) yRot:=yRotDeg;
        IF Present(zRotDeg) zRot:=zRotDeg;
        !rotate robtarget
        result:=relTool(originalRobt,0,0,0\Rx:=xRot\Ry:=yRot\Rz:=zRot);

        RETURN result;
    ENDFUNC    
    
    !function used to calc global reorientation of pose (in wobj coordinate system) [order: Z->Y->X]
    ! ret: pose = globally rotated pose
    ! arg: originalPose - input pose to rotate
    ! arg: xRotDeg - rotation angle (in deg) around axis X
    ! arg: yRotDeg - rotation angle (in deg) around axis Y
    ! arg: zRotDeg - rotation angle (in deg) around axis Z
    FUNC pose rotGlobalPoseZYX(pose originalPose,\num xRotDeg\num yRotDeg\num zRotDeg)
        VAR pose result;
        VAR pose tempPose:=[[0,0,0],[1,0,0,0]];
        VAR num xRot:=0;
        VAR num yRot:=0;
        VAR num zRot:=0;

        !update rotations angles (user selection)
        IF Present(xRotDeg) xRot:=xRotDeg;
        IF Present(yRotDeg) yRot:=yRotDeg;
        IF Present(zRotDeg) zRot:=zRotDeg;
        !rotate position (multiply)
        tempPose.rot:=OrientZYX(zRot,yRot,xRot);
        tempPose.rot:=Norient(tempPose.rot);
        result:=PoseMult(tempPose,originalPose);

        RETURN result;
    ENDFUNC 
    
    !function used to calc global reorientation of robtarget (in wobj coordinate system) [order: Z->Y->X]
    ! ret: robtarget = globally rotated robtarget
    ! arg: originalRobt - input robtarget to rotate
    ! arg: xRotDeg - rotation angle (in deg) around axis X
    ! arg: yRotDeg - rotation angle (in deg) around axis Y
    ! arg: zRotDeg - rotation angle (in deg) around axis Z
    FUNC robtarget rotGlobalRobtZYX(robtarget originalRobt,\num xRotDeg\num yRotDeg\num zRotDeg)
        VAR robtarget result;
        VAR pose tempPose;
        VAR num xRot:=0;
        VAR num yRot:=0;
        VAR num zRot:=0;

        !update rotations angles (user selection)
        IF Present(xRotDeg) xRot:=xRotDeg;
        IF Present(yRotDeg) yRot:=yRotDeg;
        IF Present(zRotDeg) zRot:=zRotDeg;
        !rotate position (multiply)
        tempPose:=rotGlobalPoseZYX(robtToPose(originalRobt)\xRotDeg:=xRot\yRotDeg:=yRot\zRotDeg:=zRot);
        !convert back to robtarget and recover external axes and configuration
        result:=poseToRobt(tempPose);
        result.robconf:=originalRobt.robconf;
        result.extax:=originalRobt.extax;

        RETURN result;
    ENDFUNC    

    !function to find line crossing two points (described by linear equation) 
    ! ret: line2D = calculated line (described by params A and B of linear equation [y=Ax+B])
    ! arg: pos1 - first point
    ! arg: pos2 - second point
    FUNC line2D lineGet(pos pos1,pos pos2)
        VAR line2D result;

        result.A:=(pos2.y-pos1.y)/(pos2.x-pos1.x);
        result.B:=pos1.y-pos1.x*result.A;

        RETURN result;
    ENDFUNC

    !function to find orthogonal line (described by linear equation)
    ! ret: line2D = ortho line (described by params A and B of linear equation [y=Ax+B])
    ! arg: pos1 - first point
    ! arg: pos2 - second point
    FUNC line2D lineOrthoGet(pos pos1,pos pos2)
        VAR line2D result;
        VAR pos midPos;

        !calc pos in the middle of pos1 and pos2
        midPos.x:=(pos1.x+pos2.x)/2;
        midPos.y:=(pos1.y+pos2.y)/2;
        !calc ortho line
        result:=lineGet(pos1,pos2);
        result.A:=-1/result.A;
        result.B:=midPos.y-midPos.x*result.A;

        RETURN result;
    ENDFUNC

    !function used to calc intersection point of two lines
    ! ret: pos = intersection point
    ! arg: line1 - line 1
    ! arg: line2 - line 2
    FUNC pos lineIntersectLine(line2D line1,line2D line2)
        VAR pos result;

        result.y:=(line2.A*line1.B-line1.A*line2.B)/(line2.A-line1.A);
        result.x:=(result.y-line2.B)/line2.A;

        RETURN result;
    ENDFUNC
    
    !function used to count distance between line2D and point
    ! ret: num = distance line2D <-> vector
    ! arg: line - reference line2D to count distance
    ! arg: point - point to count distance    
    FUNC num lineDistToPoint(line2D line, pos point)
        !line 2D include only X and Y (Z=0)
        point.z:=0;
        RETURN vectorDistToPoint(lineToVec(line),point);
    ENDFUNC    

    !function calculating circle params (center and radius) from min 3 points
    ! ret: circle2D = calculated circle center and radius
    ! arg: points{*} - points to calculate circle (first 3 points are used even if there is more in table)
    !                  [if you want to use 4 or more points - use circleFit function]
    FUNC circle2D circleGet(pos points{*})
        VAR circle2D result;
        VAR pos intersect{3};
        VAR line2D lines{3};

        !check if there is at least 3 points [we always take first three = they already determine a unique circle]
        IF Dim(points,1)>=3 THEN
            !define three lines between three points
            lines{1}:=lineOrthoGet(points{1},points{2});
            lines{2}:=lineOrthoGet(points{2},points{3});
            lines{3}:=lineOrthoGet(points{3},points{1});
            !calc intersection points between those lines
            intersect{1}:=lineIntersectLine(lines{1},lines{2});
            intersect{2}:=lineIntersectLine(lines{2},lines{3});
            intersect{3}:=lineIntersectLine(lines{3},lines{1});
            !calc middle (center) point
            result.center.x:=(intersect{1}.x+intersect{2}.x+intersect{3}.x)/3;
            result.center.y:=(intersect{1}.y+intersect{2}.y+intersect{3}.y)/3;
            result.center.z:=(points{1}.z+points{2}.z+points{3}.z)/3;
            !calc circle radius
            result.radius:=Distance(result.center,points{1});
        ELSE
            !not enough points to calc center
            ErrWrite "ERROR::circleCenterPos","Not enough points to calc circle center!"\RL2:="Min: 3 points!"\RL3:="Curr: "+NumToStr(Dim(points,1),0)+"...";
        ENDIF

        RETURN result;
    ENDFUNC
    
    !function used to calc robtarget lying at the same circle as inputted position
    ! ret: robtarget = position at the same circle (at radius and degree) as startPoint
    ! arg: startPoint - start position from which we want to calculate output
    ! arg: startPointAngle - at what angle of circle start point is lying (default 0)
    ! arg: radius - radius of circe
    ! arg: diffAngle - angle output from startPoint (can be positive and negative)
    FUNC robtarget circlePerimPos(robtarget startPoint\num atAngle,num radius,num diffAngle)
        VAR robtarget result;
        VAR num startPointAngle:=0;
        VAR robtarget center;

        !check data provided by user
        IF Present(atAngle) startPointAngle:=atAngle;
        !calc center of circle
        center:=startPoint;
        center.trans.x:=startPoint.trans.x-radius*Cos(startPointAngle);
        center.trans.y:=startPoint.trans.y-radius*Sin(startPointAngle);
        !calc output pose
        result:=center;
        result.trans.x:=center.trans.x+radius*Cos(startPointAngle+diffAngle);
        result.trans.y:=center.trans.y+radius*Sin(startPointAngle+diffAngle);

        RETURN result;
    ENDFUNC    

    !procedure to reorient selected axis of TCP so it will point to zero of wobj0 (robot base)
    ! arg: axis - which axis has to point to wobj0 (no argument = closest axis)
    ! arg: tool - which tool to reorient
    PROC axisToRobot(\num axis,PERS tooldata tool)
        !first we have to do align (Z tool = Z wobj0)
        axisPosAlign axisZ,tool,wobj0;
        !next rotate axis to wobj0 
        IF Present(axis) THEN
            !user inputted which axis of TCP has to point to wobj0
            axisToWobjZ\whichAxis:=axis,tool,wobj0;
        ELSE
            !the closest axis of TCP has to point to wobj0
            axisToWobjZ tool,wobj0;
        ENDIF
    ENDPROC

    !procedure to reorient selected axis of TCP so it will point to zero of selected wobj
    ! arg: whichAxis - which axis has to point to wobj0 (no argument = closest axis)
    ! arg: tool - which tool to reorient
    ! arg: wobj - which wobj to point to
    PROC axisToWobjZ(\num whichAxis,PERS tooldata tool,PERS wobjdata wobj)
        VAR robtarget currentPos;
        VAR num whichAxisToBase;
        VAR num backupZ;
        VAR pos vecReference;

        !get current TCP pose in selected wobj
        currentPos:=CRobT(\Tool:=tool\WObj:=wobj);
        !calc vector from current TCP to zero point of selected wobj
        backupZ:=currentPos.trans.z;
        currentPos.trans.z:=wobj.uframe.trans.z;
        vecReference:=vectorCalc(currentPos.trans,wobj.uframe.trans);
        currentPos.trans.z:=backupZ;
        !check if user selected axis
        IF Present(whichAxis) THEN
            !remeber selected axis
            whichAxisToBase:=whichAxis;
        ELSE
            !find closest axis
            whichAxisToBase:=axisClosestToVec(currentPos,vecReference);
        ENDIF
        !screw selected axis to vector (calculate only)
        currentPos:=axisScrew(currentPos,whichAxisToBase,vecReference);
        !update robot position
        MoveL currentPos,v100,fine,tool\WObj:=wobj;
    ENDPROC

    !procedure used to align current pose to match selected axis of wobj
    ! arg: toWhichAxis - to which wobj axis we want to align (1 = X, 2 = Y, 3 = Z)
    ! arg: tool - which TCP we want to align
    ! arg: wobj - which WOBJ we want to align to
    PROC axisPosAlign(num toWhichAxis,PERS tooldata tool,PERS wobjdata wobj)
        VAR num closeAxisNo;
        VAR robtarget currentPos;

        !checking if good axis number is inputted
        IF toWhichAxis>=axisX AND toWhichAxis<=axisZ THEN
            !get current pose (TCP in WOBJ)
            currentPos:=CRobT(\Tool:=tool\WObj:=wobj);
            !finding closes axis to vector
            closeAxisNo:=axisClosestToWobj(currentPos,toWhichAxis);
            !calc align pose and move to it
            currentPos:=axisScrew(currentPos,closeAxisNo,axisToVec(toWhichAxis)\checkVec);
            MoveL currentPos,v100,fine,tool\WObj:=wobj;
        ELSE
            ErrWrite "ERROR::alignPos","Cant align pos - wrong axis inputted ["+NumToStr(toWhichAxis,0);
        ENDIF
    ENDPROC

    !function used to calc which TCP axis is nearest to coordinate system (WBOJ) axis
    ! ret: num = number of axis closest to selected wobj axis
    ! arg: inspectedPose - TCP position which closest axis we want to find
    ! arg: whichWobjAxis - reference wobj axis
    FUNC num axisClosestToWobj(robtarget inspectedPose,num whichWobjAxis)
        VAR num result;
        VAR num vecDist{3};
        VAR pos vecAxis{3};
        CONST pos vecRef{3}:=[[1,0,0],[0,1,0],[0,0,1]];
        VAR orient tempOrient;

        !find every axis vector 
        FOR axis FROM axisX TO axisZ DO
            tempOrient:=oriFromPos(vecRef{axis});
            tempOrient:=oriDivide(oriMult(inspectedPose.rot,tempOrient),inspectedPose.rot);
            vecAxis{axis}:=[tempOrient.q2,tempOrient.q3,tempOrient.q4];
        ENDFOR
        !check which axis is nearest to reference (inputted axis)
        IF whichWobjAxis=axisX THEN
            vecDist{axisX}:=Abs(vecAxis{axisX}.x);
            vecDist{axisY}:=Abs(vecAxis{axisY}.x);
            vecDist{axisZ}:=Abs(vecAxis{axisZ}.x);
        ELSEIF whichWobjAxis=axisY THEN
            vecDist{axisX}:=Abs(vecAxis{axisX}.y);
            vecDist{axisY}:=Abs(vecAxis{axisY}.y);
            vecDist{axisZ}:=Abs(vecAxis{axisZ}.y);
        ELSEIF whichWobjAxis=axisZ THEN
            vecDist{axisX}:=Abs(vecAxis{axisX}.z);
            vecDist{axisY}:=Abs(vecAxis{axisY}.z);
            vecDist{axisZ}:=Abs(vecAxis{axisZ}.z);
        ENDIF
        !the biggest element in table is the nearest to reference
        result:=tableNumSearchMargin(vecDist\biggest\elementNo);

        RETURN result;
    ENDFUNC

    !function used to calc which TCP axis is nearest to selected vector
    ! ret: num = number of axis closest to selected vector
    ! arg: inspectedPose - TCP position which closest axis we want to find
    ! arg: vecRef - reference vector to which we want to find closest axis
    FUNC num axisClosestToVec(robtarget inspectedPose,pos vecRef)
        VAR num result;
        VAR pos vector{3};
        VAR num angles{3};

        !find every axis vector
        vector{axisX}:=vectorCalc(inspectedPose.trans,robtToPos(RelTool(inspectedPose,100,0,0)));
        vector{axisY}:=vectorCalc(inspectedPose.trans,robtToPos(RelTool(inspectedPose,0,100,0)));
        vector{axisZ}:=vectorCalc(inspectedPose.trans,robtToPos(RelTool(inspectedPose,0,0,100)));
        !check angle between every axis vector and reference
        FOR axis FROM axisX TO axisZ DO
            angles{axis}:=vectorAngle(vector{axis},vecRef);
            IF angles{axis}>90 THEN
                angles{axis}:=180-angles{axis};
            ENDIF
        ENDFOR
        !the closest axis has the smallest angle
        result:=tableNumSearchMargin(angles\smallest\elementNo);

        RETURN result;
    ENDFUNC

    !function used to reorient TCP pose so its axis is aligned to inputted vector
    ! ret: robtarget = aligned position
    ! arg: inRobt - position to be aligned
    ! arg: whichAxis - which position axis we want to align to vector
    ! arg: refVec - align vector
    ! arg: checkVec - option to check if vector is lying on axis (is parallel to selected axis)
    FUNC robtarget axisScrew(robtarget inRobt,num whichAxis,pos refVec\switch checkVec)
        VAR robtarget result;
        VAR bool continueProcess:=TRUE;
        VAR num angle;
        VAR pos vector;
        VAR pos baseVector;
        VAR pos tempVector;
        VAR orient thisOrient;
        VAR orient tempOrient;

        !if user wants to check vector we do it now
        IF Present(checkVec) continueProcess:=vectorAtAxis(refVec);
        !check if everything is ok
        IF continueProcess THEN
            !remember trans, conf and extax (orient will be changed)
            result:=inRobt;
            thisOrient:=inRobt.rot;
            !get base vector from selected axis
            baseVector:=axisToVec(whichAxis);
            !calc vector from orient
            tempOrient:=oriFromPos(baseVector);
            tempOrient:=oriDivide(oriMult(thisOrient,tempOrient),thisOrient);
            vector:=[tempOrient.q2,tempOrient.q3,tempOrient.q4];
            !check angle between vector and reference
            angle:=vectorAngle(vector,refVec);
            !build final orient 
            tempVector:=crossProd(refVec,vector);
            tempVector:=vectorNorm(tempVector);
            tempOrient:=[Cos(angle/2),Sin(angle/2)*tempVector.x,Sin(angle/2)*tempVector.y,Sin(angle/2)*tempVector.z];
            result.rot:=oriMult(tempOrient,thisOrient);
        ENDIF

        RETURN result;
    ENDFUNC
ENDMODULE
