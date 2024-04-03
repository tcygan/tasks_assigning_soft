       IDENTIFICATION DIVISION.                                         
       PROGRAM-ID. USSHOWP.                                             
      * PROGRAM IS SUBROUTINE FOR MAINMAPP THAT WILL ALLOW USER         
      * TO SEE ALL OF THE USERS BY USING PAGING LOGIC                   
      * IN CASE USER WILL WANT TO BE SURE ABOUT HIS SPELLING            
       DATA DIVISION.                                                   
       WORKING-STORAGE SECTION.                                         
       01 WS-COMMAREA.                                                  
           05 COM-LAST PIC X(20).                                       
           05 COM-FIRST PIC X(20).                                      
       01 RESPCODE PIC S9(8) COMP.                                      
           COPY USSHOW.                                                 
           COPY DFHAID.                                                 
       01 FS-USERS.                                                     
           05 FS-USERNAME PIC X(20).                                    
           05 FILLER PIC X(20).                                         
       01 MSG-FOR-USER.                                                 
           05 EXIT-MSG PIC X(22) VALUE 'TRANSACTION TERMINATED'.       
           05 INVALID-KEY-MSG PIC X(11) VALUE 'INVALID KEY'.           
           05 ENFILE-MSG PIC X(15) VALUE 'END OF THE DATA'.            
           05 ERROR-MSG PIC X(13) VALUE 'ERROR OCCURED'.               
       01 WHAT-MAP-FLAG PIC X.                                         
           88 DATA-ONLY VALUE 'D'.                                     
           88 WHOLE-MAP VALUE 'M'.                                     
       01 IF-STARTBR-CORRECT PIC X.                                    
           88 STARTBR-CORRECT VALUE 'Y'.                               
       01 ITER PIC 99.                                                 
       LINKAGE SECTION.                                                
       01 DFHCOMMAREA PIC X(40).                                       
       PROCEDURE DIVISION USING DFHCOMMAREA.                           
       MAIN.                                                           
           IF EIBCALEN = 0 THEN                                        
               MOVE LOW-VALUES TO MAP1O                                
               MOVE LOW-VALUES TO COM-LAST                             
                PERFORM READ-8-NEXT-PARA                               
                MOVE 'M' TO WHAT-MAP-FLAG                              
                PERFORM SEND-THE-MAP-PARA                              
                EXEC CICS                                              
                RETURN TRANSID('SHOW') COMMAREA(WS-COMMAREA)           
                END-EXEC                                               
            ELSE                                                       
                MOVE DFHCOMMAREA TO WS-COMMAREA                        
                EVALUATE EIBAID                                        
                WHEN DFHPF5 PERFORM  READ-8-PREV-PARA                  
                WHEN DFHPF6 PERFORM  READ-8-NEXT-PARA                  
                WHEN DFHPF3                                            
                     EXEC CICS                                         
                     SEND TEXT FROM(EXIT-MSG)                          
                     ERASE                                             
                     END-EXEC                                          
                     EXEC CICS                                         
                     RETURN                                          
                     END-EXEC                                        
                WHEN OTHER                                           
                     MOVE INVALID-KEY-MSG TO MSGO                    
                     MOVE 'D' TO WHAT-MAP-FLAG                       
                     PERFORM SEND-THE-MAP-PARA                       
                END-EVALUATE                                         
            END-IF                                                   
            MOVE WS-COMMAREA TO DFHCOMMAREA                          
            EXEC CICS                                                
            RETURN TRANSID('SHOW') COMMAREA(DFHCOMMAREA)             
            END-EXEC                                                 
            GOBACK.                                                  
        SEND-THE-MAP-PARA.                                           
            EVALUATE TRUE                                            
            WHEN DATA-ONLY                                           
                 EXEC CICS                                           
                 SEND MAP('MAP1') MAPSET('USSHOW')                  
                 FROM(MAP1O)                                        
                 DATAONLY                                           
                 FREEKB                                             
                 NOHANDLE                                           
                 END-EXEC                                           
            WHEN WHOLE-MAP                                          
                 EXEC CICS                                          
                 SEND MAP('MAP1') MAPSET('USSHOW')                  
                 FROM(MAP1O)                                        
                 ERASE                                              
                 NOHANDLE                                           
                 END-EXEC                                           
            WHEN OTHER                                              
                 MOVE ERROR-MSG TO MSGO                             
                 MOVE 'D' TO WHAT-MAP-FLAG                          
                 PERFORM SEND-THE-MAP-PARA                          
            END-EVALUATE                                         
            EXIT.                                                
        STARTBR-PARA.                                            
            EXEC CICS                                            
            STARTBR                                              
            FILE('USERS')                                        
            RIDFLD(FS-USERNAME)                                  
            RESP(RESPCODE)                                       
            END-EXEC                                             
            IF RESPCODE = DFHRESP(NORMAL) THEN                   
               MOVE 'Y' TO IF-STARTBR-CORRECT                    
            ELSE                                                 
               MOVE 'N' TO IF-STARTBR-CORRECT                    
            END-IF                                               
            EXIT.                                                
        ENDBR-PARA.                                              
            EXEC CICS                                            
            ENDBR FILE('USERS')                                       
            NOHANDLE                                                  
            END-EXEC                                                  
            EXIT.                                                     
        READ-8-NEXT-PARA.                                             
            MOVE COM-LAST TO FS-USERNAME                              
            PERFORM STARTBR-PARA                                      
            IF STARTBR-CORRECT THEN                                   
               PERFORM VARYING ITER FROM 1 BY 1 UNTIL ITER > 8        
                 EXEC CICS READNEXT FILE('USERS')                     
                 RIDFLD(FS-USERNAME)                                  
                 RESP(RESPCODE)                                       
                 INTO(FS-USERS)                                       
                 END-EXEC                                             
                   EVALUATE RESPCODE                                  
                   WHEN DFHRESP(NORMAL)                               
                       IF ITER = 1 THEN                               
                           MOVE FS-USERNAME TO COM-FIRST END-IF    
                       MOVE FS-USERNAME TO POLEO(ITER)             
                       MOVE FS-USERNAME TO COM-LAST                
                   WHEN DFHRESP(ENDFILE)                           
                       MOVE '____________________' TO POLEO(ITER)  
                   WHEN OTHER                                      
                       MOVE ERROR-MSG TO MSGO                      
                       MOVE 9 TO ITER                              
                   END-EVALUATE                                    
               END-PERFORM                                         
            ELSE                                                   
               MOVE ERROR-MSG TO MSGO                              
            END-IF                                                 
               MOVE 'D' TO WHAT-MAP-FLAG                           
               PERFORM SEND-THE-MAP-PARA                           
            PERFORM ENDBR-PARA                                     
            EXIT.                                                  
        READ-8-PREV-PARA.                                              
            MOVE COM-FIRST TO FS-USERNAME                              
            PERFORM STARTBR-PARA                                       
            IF STARTBR-CORRECT THEN                                    
       * FIRST WE NEED TO READNEXT ONE TIME TO BE ABLE TO CONTINUE     
       * WITHOUT ERROS                                                 
               EXEC CICS                                               
               READNEXT FILE('USERS')                                  
               INTO(FS-USERS)                                          
               RESP(RESPCODE)                                          
               RIDFLD(FS-USERNAME)                                     
               END-EXEC                                                
                IF RESPCODE = DFHRESP(NORMAL) THEN                     
               PERFORM VARYING ITER FROM 8 BY -1 UNTIL ITER < 1        
                 EXEC CICS READPREV FILE('USERS')                      
                 RIDFLD(FS-USERNAME)                                   
                 RESP(RESPCODE)                                        
                 INTO(FS-USERS)                                         
                 END-EXEC                                               
                   EVALUATE RESPCODE                                    
                   WHEN DFHRESP(NORMAL)                                 
                       IF ITER = 8 MOVE FS-USERNAME TO COM-LAST END-IF  
                       MOVE FS-USERNAME TO POLEO(ITER)                  
                       MOVE FS-USERNAME TO COM-FIRST                    
                   WHEN DFHRESP(ENDFILE)                                
                       MOVE '____________________' TO POLEO(ITER)       
                   WHEN OTHER                                           
                       MOVE ERROR-MSG TO MSGO                           
                       MOVE 0 TO ITER                                   
                   END-EVALUATE                                         
               END-PERFORM                                              
            ELSE                                                        
       * FIRST READNEXT FAILED                                          
               MOVE ERROR-MSG TO MSGO                                   
            END-IF                             
            ELSE                               
       *STARTBR FAILED                         
               MOVE ERROR-MSG TO MSGO          
            END-IF                             
               MOVE 'D' TO WHAT-MAP-FLAG       
               PERFORM SEND-THE-MAP-PARA       
            PERFORM ENDBR-PARA                 
            EXIT.                              