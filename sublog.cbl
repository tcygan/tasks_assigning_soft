       IDENTIFICATION DIVISION.                                       
       PROGRAM-ID. SUBLOG.                                            
      * THIS PROGRAM IS USED TO DETERMINE IF                          
      * USER CAN LOG INTO HIS PANEL                                   
      * WE WILL CHECK IF USERNAME IS CORRECT AND IF HIS PASSWORD      
      * IS CORRECT AND WE WILL SEND PROPER OUTPUT TO MAIN PROGRAM     
      *                                                               
      * XX -> WHEN INVALID DATA                                       
      * 00 -> WHEN VALID DATA                                         
      *                                                               
      * ANY OTHER OUTPUTS WILL BE TREATED LIKE SUBPROGRAM ERROR       
       DATA DIVISION.                                                 
       WORKING-STORAGE SECTION.                                       
       01 RESPCODE PIC S9(8) COMP.                                    
       01 FS-USERS.                                                   
            05 FS-USERNAME PIC X(20).                                 
            05 FS-PASSWORD PIC X(20).                                 
       LINKAGE SECTION.                                        
       01 DFHCOMMAREA.                                         
           05 WS-USERNAME      PIC X(20).                      
           05 WS-PASSWORD      PIC X(20).                      
           05 SUB-STATUS       PIC XX.                         
       PROCEDURE DIVISION.                                     
       MAIN.                                                   
           EXEC CICS                                           
           READ FILE('USERS')                                  
           INTO(FS-USERS)                                      
           RIDFLD(WS-USERNAME)                                 
           RESP(RESPCODE)                                      
           END-EXEC                                            
               EVALUATE RESPCODE                               
               WHEN DFHRESP(NORMAL)                            
                 IF WS-PASSWORD = FS-PASSWORD THEN             
                    MOVE '00' TO SUB-STATUS                    
                 ELSE                                    
                    MOVE 'XX' TO SUB-STATUS              
                 END-IF                                  
               WHEN DFHRESP(NOTFND)                      
                 MOVE 'XX' TO SUB-STATUS                 
               END-EVALUATE                              
           EXEC CICS                                     
           RETURN                                        
           END-EXEC                                      
           GOBACK.                                       