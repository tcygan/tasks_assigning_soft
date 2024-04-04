       IDENTIFICATION DIVISION.                                       
       PROGRAM-ID. USLOGP.                                            
      * PROGRAM WILL BE USED BY USER TO ACCESS HIS PANEL              
      * IN THE PROGRAM I WILL USER SUBPROG CONCEPT WHERE              
      * CHECKING IF LOGIN DATA IS DONE                                
       DATA DIVISION.                                                 
       WORKING-STORAGE  SECTION.                                      
           COPY USLOG.                                                
           COPY DFHAID.                                               
           COPY DFHBMSCA.                                             
       01 WS-COMMAREA.                                                
           05 COM-USERNAME PIC X(20) VALUE 'A'.                       
           05 SUCCESSFULL-LOGIN PIC X.                                
       01 RESPCODE PIC S9(8) COMP.                                    
       01 WHAT-MAP-FLAG PIC X.                                        
           88 DATA-ONLY VALUE 'D'.                                    
           88 WHOLE-MAP VALUE 'M'.                                    
       01 USER-MESSAGES.                                                
           05 INVALID-KEY-MSG PIC X(11) VALUE 'INVALID KEY'.            
           05 INVALID-DATA-MSG PIC X(12) VALUE 'INVALID DATA'.          
           05 ERROR-MSG       PIC X(13) VALUE 'ERROR OCCURED'.          
           05 MAPFAIL-MSG PIC X(24) VALUE 'YOU NEED TO PROVIDE DATA'.   
           05 SUCCESS-MSG PIC X(42) VALUE 'SUCCESSFULL LOG IN PRESS ENTE
      - 'R TO CONTINUE'.                                                
           05 EXIT-MSG PIC X(22) VALUE 'TRANSACTION TERMINATED'.        
       01 SUB-DATA.                                                     
           05 WS-USERNAME PIC X(20).                                    
           05 WS-PASSWORD PIC X(20).                                    
           05 SUB-STATUS PIC XX.                                        
       01 IF-SUCCESSFULL-RECEIVE PIC X.                                 
           88 SUCCESSFULL-RECEIVE VALUE 'Y'.                            
                                                                        
       LINKAGE SECTION.                                                 
       01 DFHCOMMAREA PIC X(21).                                        
       PROCEDURE DIVISION USING DFHCOMMAREA.                          
       MAIN.                                                          
           IF EIBCALEN = 0 THEN                                       
              MOVE 'N' TO SUCCESSFULL-LOGIN                           
              MOVE LOW-VALUES TO MAP1O                                
              MOVE 'M' TO WHAT-MAP-FLAG                               
              PERFORM SEND-THE-MAP-PARA                               
              EXEC CICS                                               
              RETURN TRANSID('ULOG') COMMAREA(WS-COMMAREA)            
              END-EXEC                                                
           ELSE                                                       
              MOVE DFHCOMMAREA TO WS-COMMAREA                         
              EVALUATE EIBAID                                         
              WHEN DFHENTER                                           
                   IF SUCCESSFULL-LOGIN = 'Y' THEN                    
                       EXEC CICS                                      
                       XCTL PROGRAM('USMAINP')  COMMAREA(WS-COMMAREA) 
                       END-EXEC                                       
                   ELSE                                               
      * MAIN LOGIC  USER DIDN'T PROVIDE VALID DATA YET                
                       PERFORM RECEIVE-DATA-PARA                      
                        IF SUCCESSFULL-RECEIVE THEN                   
      * I WILL LINK CONTROL TO SUBPROGRAM THAT WILL                   
      * VALIDATE IF INPUT DATA IS CORRECT                             
                    EXEC CICS                                         
                    LINK PROGRAM('SUBLOG') COMMAREA(SUB-DATA)         
                    END-EXEC                                          
                          EVALUATE SUB-STATUS                         
                          WHEN '00'                                   
                              MOVE 'Y' TO SUCCESSFULL-LOGIN           
                              MOVE DFHBMPRO TO USERA                  
                              MOVE SUCCESS-MSG TO MSGO                
                          WHEN 'XX'                                   
                              MOVE INVALID-DATA-MSG TO MSGO           
                          WHEN OTHER                                   
                              MOVE ERROR-MSG TO MSGO                   
                          END-EVALUATE                                 
                              MOVE 'D' TO WHAT-MAP-FLAG                
                              PERFORM SEND-THE-MAP-PARA                
                        ELSE                                           
      * IN RECEIVE-DATA-PARA PROPER MSG IS ASSIGNED TO SCREEN VARIABLES
                          PERFORM SEND-THE-MAP-PARA                    
                        END-IF                                         
                   END-IF                                              
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
           RETURN TRANSID('ULOG') COMMAREA(DFHCOMMAREA)           
           END-EXEC                                               
           GOBACK.                                                
       SEND-THE-MAP-PARA.                                         
           EVALUATE TRUE                                          
           WHEN DATA-ONLY                                         
                EXEC CICS                                         
                SEND MAP('MAP1') MAPSET('USLOG')                  
                FROM(MAP1O)                                         
                DATAONLY                                            
                FREEKB                                              
                NOHANDLE                                            
                END-EXEC                                            
           WHEN WHOLE-MAP                                           
                EXEC CICS                                           
                SEND MAP('MAP1') MAPSET('USLOG')                    
                FROM(MAP1O)                                         
                ERASE                                               
                NOHANDLE                                            
                END-EXEC                                            
           END-EVALUATE                                             
           EXIT.                                                    
       RECEIVE-DATA-PARA.                                           
           MOVE LOW-VALUES TO MAP1I                                 
           EXEC CICS                                                
           RECEIVE MAP('MAP1') MAPSET('USLOG')                     
           INTO(MAP1I)                                             
           RESP(RESPCODE)                                          
           END-EXEC                                                
            EVALUATE RESPCODE                                      
            WHEN DFHRESP(NORMAL)                                   
             MOVE 'Y' TO IF-SUCCESSFULL-RECEIVE                    
             MOVE USERI TO WS-USERNAME                             
             MOVE PASSI TO WS-PASSWORD                             
             INSPECT WS-USERNAME REPLACING ALL '_' BY ' '          
             INSPECT WS-PASSWORD REPLACING ALL '_' BY ' '          
            WHEN DFHRESP(MAPFAIL)                                  
             MOVE 'N' TO IF-SUCCESSFULL-RECEIVE                    
             MOVE 'D' TO WHAT-MAP-FLAG                             
             MOVE MAPFAIL-MSG TO WHAT-MAP-FLAG                     
            WHEN OTHER                                             
             MOVE 'N' TO IF-SUCCESSFULL-RECEIVE                    
             MOVE 'D' TO WHAT-MAP-FLAG      
             MOVE ERROR-MSG TO MSGO         
            END-EVALUATE                    
           EXIT.                            