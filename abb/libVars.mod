MODULE libVars(NOVIEW)
    RECORD line2D 
        num A;
        num B;
    ENDRECORD
    
    RECORD circle2D
        pos center;
        num radius;
    ENDRECORD
    
    CONST robtarget zeroRobt:=[[0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0,0,0]];
    CONST pose zeroPose:=[[0,0,0],[0,0,0,0]];

    CONST num axisX:=1;
    CONST num axisY:=2;
    CONST num axisZ:=3;
ENDMODULE
