USLOG  DFHMSD TYPE=&SYSPARM,LANG=COBOL,MODE=INOUT,TERM=ALL,            X
               STORAGE=AUTO,DSATTS=COLOR,MAPATTS=COLOR,TIOAPFX=YES,    X
               CTRL=(FREEKB,FRSET)                                      
MAP1   DFHMDI SIZE=(24,80),LINE=1,COLUMN=1                              
       DFHMDF POS=(1,1),ATTRB=PROT,INITIAL='USLOG',LENGTH=5             
       DFHMDF POS=(3,1),ATTRB=PROT,INITIAL='USERNAME: ',LENGTH=10       
USER   DFHMDF POS=(3,12),ATTRB=(IC,UNPROT),LENGTH=20,                  X
               INITIAL='____________________'                           
       DFHMDF POS=(3,33),ATTRB=ASKIP,INITIAL=' ',LENGTH=1               
       DFHMDF POS=(4,1),ATTRB=ASKIP,INITIAL='PASSWORD: ',LENGTH=10      
PASS   DFHMDF POS=(4,12),ATTRB=(UNPROT,DRK),LENGTH=20,                 X
               INITIAL=' '                                              
       DFHMDF POS=(4,33),ATTRB=PROT,INITIAL=' ',LENGTH=1                
       DFHMDF POS=(5,1),ATTRB=PROT,LENGTH=40,                          X
               INITIAL='PRESSS ENTER TO LOG IN, PRESS F3 TO EXIT'       
MSG    DFHMDF POS=(7,1),ATTRB=PROT,INITIAL=' ',LENGTH=79                
       DFHMSD TYPE=FINAL                                                
       END
