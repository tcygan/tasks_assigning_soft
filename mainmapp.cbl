       IDENTIFICATION DIVISION.                                         
       PROGRAM-ID. MAINMAPP.                                            
      * THIS IS TRANSACTION PROGRAM THAT ALLOWS ADMIN USERS    TO             
      * ASSIGN TASKS FOR PARTICULAR USER                                
      * AND ALSO THANKS TO USSHOWP USER CAN SEE ALL USER BY PAGING LOGIC
      * IN CASE HE DON'T WANT TO REMEBER THEM ALL                       
       DATA DIVISION.                                                   
       WORKING-STORAGE SECTION.                                         
           COPY MAINMAP.                                                
           COPY DFHAID.                                                 
       01 WS-COMMAREA PIC X VALUE 'A'.                                  
       01 RESPCODE PIC S9(8) COMP.                                      
       01 FS-USERS.                                                     
           05 USERS-USERNAME PIC X(20).                                 
           05 FILLER PIC X(20).                                         
       01 FS-TASKS.                                                     
           05 T-TASKID PIC X(10).                                       
           05 T-USERNAME PIC X(20).                                     
           05 T-TASKVALUE PIC X(180).                                   
       01 MSG-FOR-USER.                                                 
           05 EXIT-MSG PIC X(22) VALUE 'TRANSACTION TERMINATED'.        
           05 INVALID-KEY-MSG PIC X(11) VALUE 'INVALID KEY'.            
           05 ENFILE-MSG PIC X(15) VALUE 'END OF THE DATA'.             
           05 ERROR-MSG PIC X(13) VALUE 'ERROR OCCURED'.                
           05 USER-NOT-FND PIC X(21) VALUE 'THERE IS NO SUCH USER'.     
           05 MAPFAIL-MSG PIC X(24) VALUE 'YOU NEED TO PROVIDE DATA'.   
           05 DUPKEY-MSG PIC X(27) VALUE 'THIS TASK ID ALREADY EXISTS'. 
           05 INVALID-DATA-MSG PIC X(15) VALUE 'INVALID DATA!!!'.       
           05 SUCCESS-MSG PIC X(22) VALUE 'TASK HAS BEEN ASSIGNED'.     
       01 WHAT-MAP-FLAG PIC X.                                          
           88 DATA-ONLY VALUE 'D'.                                      
           88 WHOLE-MAP VALUE 'M'.                                      
                                                                        
       01 IF-USERNAME-VALID PIC X.                                      
           88 USERNAME-VALID VALUE 'Y'.                              
       01 PROGRAM-VARIABLES.                                         
           05 WS-TASKID PIC X(10).                                   
           05 WS-USERNAME PIC X(20).                                 
           05 WS-TASKVALUE PIC X(180).                               
       PROCEDURE DIVISION.                                           
       MAIN.                                                         
           IF EIBCALEN = 0 THEN                                      
               PERFORM FIRST-TIME-RUN-PARA                           
           ELSE                                                      
              EVALUATE EIBAID                                        
              WHEN DFHENTER                                          
                   PERFORM SAVE-TASK-PARA                            
              WHEN DFHPF5                                            
      * FOR NOW NOTHING IT WILL BE XCTL-ING THE USSHOWP              
      *          CONTINUE                                            
               EXEC CICS                                             
               XCTL PROGRAM('USSHOWP')                        
               END-EXEC                                       
              WHEN DFHPF3                                     
      * TERMINATION OF THE TRANSACTION                        
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
      * RETURNING TO THE CICIS                               
           EXEC CICS                                         
           RETURN TRANSID('MAIN') COMMAREA(WS-COMMAREA)      
           END-EXEC                                          
           GOBACK.                                           
       SEND-THE-MAP-PARA.                                    
           EVALUATE TRUE                                     
           WHEN DATA-ONLY                                    
                EXEC CICS                                    
                SEND MAP('MAP1') MAPSET('MAINMAP')           
                FROM(MAP1O)                                  
                DATAONLY                                     
                FREEKB                                       
                NOHANDLE                                     
                END-EXEC                                     
           WHEN WHOLE-MAP                                    
                EXEC CICS                                    
                SEND MAP('MAP1') MAPSET('MAINMAP')                    
                FROM(MAP1O)                                           
                ERASE                                                 
                NOHANDLE                                              
                END-EXEC                                              
           END-EVALUATE                                               
           MOVE SPACE TO MSGO                                         
           EXIT.                                                      
       SAVE-TASK-PARA.                                                
      * THIS PARAGRAPH WILL VALIDATE IF THE ALL REQUIRED DATA         
      * WAS SUCCESSFULLY RETRIVED FROM THE USER                       
      * WILL VALIDATE IF DATA IS CORRECT                              
      * AND IN THE CASE THAT ALL IS CORRECT IT WILL SAVE THAT         
      * TO TASKS FILE THAT WILL  BE LATER USED IN OTHER PROGRAMS      
           MOVE LOW-VALUES TO MAP1I                                   
           EXEC CICS                                                  
           RECEIVE MAP('MAP1') MAPSET('MAINMAP')                      
           INTO(MAP1I)                                            
           RESP(RESPCODE)                                         
           END-EXEC                                               
           EVALUATE RESPCODE                                      
           WHEN DFHRESP(NORMAL)                                   
      * IN CASE OF SUCCESSFULL RETRIEIVE WE NEED TO CHECK IF DATA 
      * IS CORRECT                                                
                                                                  
              MOVE TASKIDI TO WS-TASKID                           
              INSPECT WS-TASKID REPLACING ALL '_' BY ' '          
              MOVE USERI TO WS-USERNAME                           
              INSPECT WS-USERNAME REPLACING ALL '_' BY ' '        
              STRING  POLE1I,                                     
                      POLE2I,                                     
                      POLE3I,                                     
                      POLE4I DELIMITED BY SIZE                    
              INTO WS-TASKVALUE                                   
              INSPECT WS-TASKVALUE REPLACING ALL '_' BY ' '            
              IF WS-TASKID = ' ' OR WS-TASKID = '__________' OR        
              WS-USERNAME = ' ' OR WS-USERNAME = '____________________'
              OR WS-TASKVALUE = ' ' THEN                               
                   MOVE INVALID-DATA-MSG TO MSGO                       
                   MOVE 'D' TO WHAT-MAP-FLAG                           
                   PERFORM SEND-THE-MAP-PARA                           
              ELSE                                                     
      * WE NEED TO CHECK IF WS-USERNAME EXITS SO:                      
                 MOVE WS-USERNAME TO USERS-USERNAME                    
                    PERFORM CHECK-USER-NAME-PARA                       
                   IF USERNAME-VALID THEN                              
      * WE WILL TRY TO SAVE ALL OF INFOS TO TASKS FILE                 
      * ONLY WAY SOMETHING CAN GO WRONG IS WHEN TASKID WILL BE A       
      * DUPLICATE                                                      
                       PERFORM SEND-TO-THE-TASKS-FILE                  
      * THAT PARAGRAPH WILL DO THE REST OF PROCESSING                  
      * AND WILL SAVE PROPER OUTPUT IN CASE OF THE ERROR              
                   ELSE                                               
      * USERNAME WAS NOT VALID SO WE NEED TO DISPLAY PROPER OUTPUT    
                     MOVE USER-NOT-FND TO MSGO                        
                     MOVE 'D' TO WHAT-MAP-FLAG                        
                     PERFORM SEND-THE-MAP-PARA                        
                   END-IF                                             
              END-IF                                                  
           WHEN DFHRESP(MAPFAIL)                                      
               MOVE MAPFAIL-MSG TO MSGO                               
               MOVE 'D' TO WHAT-MAP-FLAG                              
               PERFORM SEND-THE-MAP-PARA                              
           WHEN OTHER                                                 
               PERFORM ABNORMAL-EXIT-PARA                             
           END-EVALUATE                                               
           EXIT.                                                      
       ABNORMAL-EXIT-PARA.                                            
           EXEC CICS                                        
           SEND TEXT FROM(ERROR-MSG)                        
           ERASE                                            
           END-EXEC                                         
           EXEC CICS                                        
           RETURN END-EXEC                                  
           GOBACK.                                          
       CHECK-USER-NAME-PARA.                                
            EXEC CICS                                       
            READ FILE('USERS')                              
            INTO(FS-USERS)                                  
            RIDFLD(USERS-USERNAME)                          
            RESP(RESPCODE)                                  
            END-EXEC                                        
            EVALUATE RESPCODE                               
            WHEN DFHRESP(NORMAL)                            
                 MOVE 'Y' TO IF-USERNAME-VALID              
            WHEN DFHRESP(NOTFND)                         
                 MOVE 'N' TO IF-USERNAME-VALID           
            END-EVALUATE                                 
           EXIT.                                         
       SEND-TO-THE-TASKS-FILE.                           
           MOVE WS-USERNAME TO T-USERNAME                
           MOVE WS-TASKID TO T-TASKID                    
           MOVE WS-TASKVALUE TO T-TASKVALUE              
           EXEC CICS                                     
           WRITE FILE('TASKS')                           
           RIDFLD(T-TASKID)                              
           FROM(FS-TASKS)                                
           RESP(RESPCODE)                                
           END-EXEC                                      
           EVALUATE RESPCODE                             
           WHEN DFHRESP(NORMAL)                          
               MOVE SUCCESS-MSG TO MSGO                  
           WHEN DFHRESP(DUPKEY)                     
               MOVE DUPKEY-MSG TO MSGO              
           WHEN OTHER                               
               MOVE ERROR-MSG TO MSGO               
           END-EVALUATE                             
               MOVE 'D' TO WHAT-MAP-FLAG            
               PERFORM SEND-THE-MAP-PARA            
           EXIT.                                    
       FIRST-TIME-RUN-PARA.                         
           MOVE LOW-VALUES TO MAP1O                 
           MOVE 'M' TO WHAT-MAP-FLAG                
           PERFORM SEND-THE-MAP-PARA                
           EXIT.                                    
