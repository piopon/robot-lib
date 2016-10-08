MODULE libMath
    !*******************************************************************!
    ! Copyright (C) 2016 Piotr Ponikowski <pipon.github@gmail.com>      !
    !*******************************************************************!
    ! Module Name:  libMath                                             !
    ! Description:  math algorithms (basic & advanced)                  !
    ! Date:         2016-10-03                                          !
    ! Author:       Piotr Ponikowski <pipon.github@gmail.com>           !
    ! Contributors:                                                     !
    !*******************************************************************!

    !function used to calculate cross (scalar) product of two points (vectors)
    ! ret: pos = cross product result
    ! arg: vec1 - first point (vector)
    ! arg: vec2 - second point (vector)
    FUNC pos crossProd(pos vec1,pos vec2)
        RETURN [vec1.y*vec2.z-vec1.z*vec2.y,vec1.z*vec2.x-vec1.x*vec2.z,vec1.x*vec2.y-vec1.y*vec2.x];
    ENDFUNC

    !function used to check if selected value is inside set defined by upper and lower limit
    ! ret: bool = checked value is inside (TRUE) or outside (FALSE) of selected set
    ! arg: val - value to check
    ! arg: setStart - lower limit of checked set
    ! arg: setStop - upper limit of checked set
    FUNC bool numInsideSet(num val,num setStart,num setStop)
        RETURN val>=setStart AND val<=setStop;
    ENDFUNC

    !function used to check if selected value is outside set defined by upper and lower limit
    ! ret: bool = checked value is outside (TRUE) or inside (FALSE) of selected set
    ! arg: val - value to check
    ! arg: setStart - lower limit of checked set
    ! arg: setStop - upper limit of checked set
    FUNC bool numOutsideSet(num val,num setStart,num setStop)
        RETURN val<setStart OR val>setStop;
    ENDFUNC

    !function used to calculate division of two orients
    ! ret: orient = division result 
    ! arg: ori1 - first orient element (ORDER IMPORTANT!)
    ! arg: ori2 - second orient element (ORDER IMPORTANT!)
    FUNC orient oriDivide(orient ori1,orient ori2)
        RETURN NOrient(oriMult(ori1,oriInverse(ori2)));
    ENDFUNC

    !function used to calculate orient from pos (vector)
    ! ret: orient = calculated orient
    ! arg: point - pos (vector) to change 
    FUNC orient oriFromPos(pos point)
        RETURN NOrient([0,point.x,point.y,point.z]);
    ENDFUNC

    !function used to calculate inversed orient
    ! ret: orient = inversed orient
    ! arg: ori - orient to inverse
    FUNC orient oriInverse(orient ori)
        !return negated orient components (Q1 not changed)
        RETURN NOrient([ori.q1,-ori.q2,-ori.q3,-ori.q4]);
    ENDFUNC

    !function used to multiply two orients
    ! ret: orient = result of multiplication
    ! arg: ori1 - first orient (ORDER IMPORTANT!)
    ! arg: ori2 - second orient (ORDER IMPORTANT!)
    FUNC orient oriMult(orient ori1,orient ori2)
        VAR orient result;

        result.q1:=ori1.q1*ori2.q1-ori1.q2*ori2.q2-ori1.q3*ori2.q3-ori1.q4*ori2.q4;
        result.q2:=ori1.q3*ori2.q4-ori1.q4*ori2.q3+ori1.q1*ori2.q2+ori1.q2*ori2.q1;
        result.q3:=ori1.q4*ori2.q2-ori1.q2*ori2.q4+ori1.q1*ori2.q3+ori1.q3*ori2.q1;
        result.q4:=ori1.q2*ori2.q3-ori1.q3*ori2.q2+ori1.q1*ori2.q4+ori1.q4*ori2.q1;

        RETURN result;
    ENDFUNC

    !function used to calculate the product of two robtargets
    ! ret: robtarget = product of two robtargets
    ! arg: robt1 - first robtarget to multiply (ORDER IMPORTANT!)
    ! arg: robt2 - second robtarget to multiply (ORDER IMPORTANT!)
    FUNC robtarget robtMult(robtarget robt1,robtarget robt2)
        VAR robtarget result;
        VAR pose tmpPose;

        !get external axes and robconf from first robtarget
        result:=robt1;
        !calculate multiply pose (abb function)
        tmpPose:=PoseMult(robtToPose(robt1),robtToPose(robt2));
        !cast pose result to robtarget
        result:=poseToRobt(tmpPose);

        RETURN result;
    ENDFUNC

    !procedure used to swap (change places) two robtargets 
    ! arg: robt1 - first robtarget
    ! arg: robt2 - second robtarget
    PROC robtSwap(INOUT robtarget robt1,INOUT robtarget robt2)
        VAR robtarget tempRobt;

        tempRobt:=robt1;
        robT1:=robT2;
        robT2:=tempRobt;
    ENDPROC

    !function used to get sign from inputted value
    ! ret: num = sign of value
    ! arg: val - value to check
    FUNC num sign(num val)
        VAR num result:=0;

        IF val>0 result:=1;
        IF val<0 result:=-1;

        RETURN result;
    ENDFUNC

    !function used to calculate angle between two vector
    ! ret: num = angle between vectors
    ! arg: vec - current vector
    ! arg: reference - reference vector 
    FUNC num vectorAngle(pos vec,pos reference)
        VAR num result;
        VAR num numerator;
        VAR num denominator;

        !round two vectors to eliminate numerical errors
        vec:=roundPos(vec\posDec:=4);
        reference:=roundPos(reference\posDec:=4);
        !sprawdzamy czy te detale nie sa naprzeciw siebie 
        IF vec.x=-reference.x AND vec.y=-reference.y THEN
            !detale sa naprzeciwko siebie = kat miedzy nimi 180
            result:=180;
        ELSEIF vec.x=reference.x AND vec.y=reference.y THEN
            !detale sa nalozone na siebie = kat miedzy nimi 0
            result:=0;
        ELSE
            !detale nie sa naprzeciwko - sprawdzamy kat miedzy nimi
            numerator:=DotProd(vec,reference);
            denominator:=VectMagn(vec)*VectMagn(reference);
            result:=ACos(numerator/denominator);
        ENDIF

        RETURN result;
    ENDFUNC
    
    !function used to check if selected vector is parallel to any axis
    ! ret: bool = inputted vector is parallel (TRUE) to any axis
    ! arg: vec - vector to check
    FUNC bool vectorAtAxis(pos vec)
        VAR bool result;
        VAR num ones:=0;

        !normalize vector to versor (length=1)
        vec:=vectorNorm(vec);
        !check if vector contains only one 1
        IF vec.x=1 Incr ones;
        IF vec.y=1 Incr ones;
        IF vec.z=1 Incr ones;
        !if there is only one 1 its OK (vector at axis)
        result:=ones=1;

        RETURN result;
    ENDFUNC    

    !function used to caluclate vector definded by two pos
    ! ret: pos = znaleziony wektor
    ! arg: firstPos - pierwszy punkt (punkt poczatkowy wektora)
    ! arg: secondPos - drugi punkt (punkt koncowy wektora)
    FUNC pos vectorCalc(pos firstPos,pos secondPos\switch normalize)
        VAR pos result;

        !calculate vector
        result.x:=(secondPos.x-firstPos.x);
        result.y:=(secondPos.y-firstPos.y);
        result.z:=(secondPos.z-firstPos.z);
        !check if user wants to normalize
        IF Present(normalize) result:=vectorNorm(result);

        RETURN result;
    ENDFUNC

    !function used to inverse inputted vector
    ! ret: pos = vector inversed
    ! arg: vec - vector to inverse
    FUNC pos vectorInverse(pos vec)
        !return negated vector components
        RETURN [-vec.x,-vec.y,-vec.z];
    ENDFUNC

    !function used to normalize vector (versor)
    ! ret: pos = normalized vector (versor)
    ! arg: vec - vector to normalize
    FUNC pos vectorNorm(pos vec)
        VAR pos result;
        VAR num vecLen;

        !check vector length
        vecLen:=VectMagn(vec);
        !divide all components by vector length (to get versor)
        result.x:=vec.x/vecLen;
        result.y:=vec.y/vecLen;
        result.z:=vec.z/vecLen;

        RETURN result;
    ENDFUNC
ENDMODULE
