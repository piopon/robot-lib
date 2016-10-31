MODULE libVars(NOVIEW)
    !*******************************************************************!
    ! Copyright (C) 2016 Piotr Ponikowski <pipon.github@gmail.com>      !
    !*******************************************************************!
    ! Module Name:  libVars                                             !
    ! Description:  global variables used in robot-lib files            !
    ! Date:         2016-10-15                                          !
    ! Author:       Piotr Ponikowski <pipon.github@gmail.com>           !
    ! Contributors:                                                     !
    !*******************************************************************! 
    
    !===================================================
    !===================  RECORDS  =====================
    !===================================================

    !record defining line2D represented by linear equation (y = Ax + B)
    ! [NOTE: if both A and B are equal to zero the line is non-existent!]
    ! field: A = numeric coefficent - slope (gradient) of line
    ! field: B = numeric coefficent - y-intercept of line
    RECORD line2D
        num A;
        num B;
    ENDRECORD

    !record defining circle2D
    ! field: center = center pos (XYZ) of circle
    ! field: radius = radius of circle in mm 
    RECORD circle2D
        pos center;
        num radius;
    ENDRECORD

    !record defining three dimensional cuboid zone
    ! field: ID - number (identification) of zone
    ! field: name - name of zone (usefull if zones are packed in table)
    ! field: start - reference corner position of zone (XYZ and orient)
    ! field: xLen - length of zone in X direction of start position (any value)
    ! field: yLen - length of zone in Y direction of start position (any value)
    ! field: zLen - length of zone in Z direction of start position (any value)
    RECORD zone3D
        num ID;
        string name;
        pose start;
        num xLen;
        num yLen;
        num zLen;
    ENDRECORD

    !===================================================
    !==================  VARIABLES  ====================
    !===================================================

    !defince null/zero/empty robtargets, positions and poses (for comparison purposes)
    CONST robtarget zeroRobt:=[[0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0,0,0]];
    CONST pose zeroPose:=[[0,0,0],[0,0,0,0]];
    CONST pos zeroPos:=[0,0,0];
    CONST robtarget emptyRobt:=[[9E9,9E9,9E9],[9E9,9E9,9E9,9E9],[9E9,9E9,9E9,9E9],[9E9,9E9,9E9,9E9,9E9,9E9]];
    CONST pose emptyPose:=[[9E9,9E9,9E9],[9E9,9E9,9E9,9E9]];
    CONST pos emptyPos:=[9E9,9E9,9E9];

    !define numeric constants representing frame axis
    CONST num axisX:=1;
    CONST num axisY:=2;
    CONST num axisZ:=3;

    !define home/safe position(s)
    PERS jointtarget libHomePos:=[[0,0,0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]];
    
    !define zone3D (areas in wobj0) table 
    PERS zone3D zones{10};
ENDMODULE
