MAINMAP DFHMSD TYPE=&SYSPARM,LANG=COBOL,MODE=INOUT,TERM=ALL,           X
               STORAGE=AUTO,DSATTS=COLOR,MAPATTS=COLOR,TIOAPFX=YES,    X
               CTRL=(FREEKB,FRSET)                                      
MAP1    DFHMDI SIZE=(24,80),LINE=1,COLUMN=1                             
        DFHMDF POS=(1,1),ATTRB=PROT,INITIAL='MAINMAP',LENGTH=7          
        DFHMDF POS=(2,1),ATTRB=PROT,INITIAL='USERNAME: ',LENGTH=10      
USER    DFHMDF POS=(2,12),ATTRB=(IC,UNPROT),                           X
               INITIAL='____________________',LENGTH=20                 
        DFHMDF POS=(2,33),ATTRB=ASKIP,INITIAL='TASK ID: ',LENGTH=9      
TASKID  DFHMDF POS=(2,43),ATTRB=UNPROT,INITIAL='__________',           X
               LENGTH=10                                                
        DFHMDF POS=(2,54),ATTRB=ASKIP,INITIAL=' ',LENGTH=1              
        DFHMDF POS=(3,1),ATTRB=ASKIP,LENGTH=33,                        X
               INITIAL='PUT THE TASKS DESCRIPTION BELOW: '              
POLE1   DFHMDF POS=(4,1),ATTRB=UNPROT,LENGTH=45,                       X
               INITIAL='_____________________________________________'  
        DFHMDF POS=(4,47),ATTRB=ASKIP,INITIAL=' ',LENGTH=1              
POLE2   DFHMDF POS=(5,1),ATTRB=UNPROT,LENGTH=45,                       X
               INITIAL='_____________________________________________'  
        DFHMDF POS=(5,47),ATTRB=ASKIP,INITIAL=' ',LENGTH=1              
POLE3   DFHMDF POS=(6,1),ATTRB=UNPROT,LENGTH=45,                       X
               INITIAL='_____________________________________________'  
        DFHMDF POS=(6,47),ATTRB=ASKIP,INITIAL=' ',LENGTH=1              
POLE4   DFHMDF POS=(7,1),ATTRB=UNPROT,LENGTH=45,                       X
               INITIAL='_____________________________________________'  
        DFHMDF POS=(7,47),ATTRB=PROT,INITIAL=' ',LENGTH=1               
        DFHMDF POS=(10,1),ATTRB=PROT,LENGTH=40,                        X
               INITIAL='PRESS ENTER TO ASSIGN TASK, PRESS F5 TO '       
        DFHMDF POS=(10,42),ATTRB=PROT,LENGTH=19,                       X
               INITIAL='SEE ALL THE USERS, '                            
        DFHMDF POS=(11,1),ATTRB=PROT,INITIAL='PRESS F3 TO EXIT',       X
               LENGTH=16                                                
MSG     DFHMDF POS=(12,1),ATTRB=PROT,INITIAL=' ',LENGTH=79              
        DFHMSD TYPE=FINAL                                               
	END