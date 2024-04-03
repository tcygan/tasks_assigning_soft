USSHOW DFHMSD TYPE=&SYSPARM,LANG=COBOL,MODE=INOUT,TERM=ALL,            X
               STORAGE=AUTO,DSATTS=COLOR,MAPATTS=COLOR,TIOAPFX=YES,    X
               CTRL=(FREEKB,FRSET)                                      
MAP1   DFHMDI SIZE=(24,80),LINE=1,COLUMN=1                              
       DFHMDF POS=(1,1),ATTRB=ASKIP,INITIAL='USSHOW',LENGTH=6           
POLE1  DFHMDF POS=(3,1),ATTRB=PROT,LENGTH=20,                          X
               INITIAL='____________________'                           
POLE2  DFHMDF POS=(4,1),ATTRB=PROT,LENGTH=20,                          X
               INITIAL='____________________'                           
POLE3  DFHMDF POS=(5,1),ATTRB=PROT,LENGTH=20,                          X
               INITIAL='____________________'                           
POLE4  DFHMDF POS=(6,1),ATTRB=PROT,LENGTH=20,                          X
               INITIAL='____________________'                           
POLE5  DFHMDF POS=(7,1),ATTRB=PROT,LENGTH=20,                          X
               INITIAL='____________________'                           
POLE6  DFHMDF POS=(8,1),ATTRB=PROT,LENGTH=20,                          X
               INITIAL='____________________'                           
POLE7  DFHMDF POS=(9,1),ATTRB=PROT,LENGTH=20,                          X
               INITIAL='____________________'                           
POLE8  DFHMDF POS=(10,1),ATTRB=PROT,LENGTH=20,                         X
               INITIAL='____________________'                           
MSG    DFHMDF POS=(12,1),ATTRB=PROT,LENGTH=79,INITIAL=' '               
       DFHMDF POS=(13,1),ATTRB=PROT,LENGTH=36,                         X
               INITIAL='F6 TO SEE FORWARD, F5 TO SE BACKWARD'           
       DFHMDF POS=(13,38),ATTRB=PROT,LENGTH=10,                        X
               INITIAL='F3 TO EXIT'                                     
       DFHMSD TYPE=FINAL                                                
       END                                                              