      *================================================================*
      * PLOG.cpy                                                       *
      *================================================================*

      * -- Dispatch paragraphs

       LOGGING-VALIDATION.
           SET LT-INFO TO TRUE.
       PERFORM LOG-VALIDATION.

       LOGGING-WARN.
           SET LT-WARN TO TRUE.
           SET LG-RETURN-ERROR TO TRUE.
       PERFORM LOG-ERROR.

       LOGGING-ERROR.
           SET LT-ERROR TO TRUE.
           SET LG-RETURN-ERROR TO TRUE.
       PERFORM LOG-ERROR.

       LOGGING-TRANSACTION-ERROR.
           SET LT-ERROR TO TRUE.
           SET LG-RETURN-ERROR TO TRUE.
       PERFORM LOG-TRAN-ERROR.

       LOGGING-FATAL.
           SET LT-FATAL TO TRUE.
           SET LG-RETURN-FATAL TO TRUE.
       PERFORM LOG-ERROR.

      * -- Booleans
       CHECK-FILE-OR-DIE.
           IF NOT LOG-FILE-OK
            DISPLAY "FATAL: Unable to open JOB.log. Status: " 
               LOG-FILE-STATUS
            GOBACK
       END-IF.

      * -- Core log paragraphs

       LOG-START.
           IF ":REASON:" EQUAL "INIT"
            OPEN OUTPUT LOG-FILE 
           ELSE
            OPEN EXTEND LOG-FILE
           END-IF.

           PERFORM CHECK-FILE-OR-DIE.

           SET LOG-FILE-IS-OPEN TO TRUE.

           PERFORM TIMESTAMP.
           MOVE LG-TIMESTAMP TO LGS-TIMESTAMP.

       WRITE LOG-RECORD FROM LOG-ACTION-START.

       LOG-CLOSE.
           PERFORM CHECK-FILE-OR-DIE.

           PERFORM TIMESTAMP.
           MOVE LG-TIMESTAMP TO LGC:LC:-TIMESTAMP.

           MOVE LG-END-RETURN-CODE TO LGC:LC:-JOB-STATUS.
           MOVE LG-TRAN-PROCESSED TO LGC:LC:-JOB-PROCESSED.
           MOVE LG-TRAN-PASSED TO LGC:LC:-JOB-PASSED.
           IF ":REASON:" NOT EQUAL TO "INIT"
            MOVE LG-TRAN-SKIPPED TO LGC:LC:-JOB-SKIPPED
           END-IF
           MOVE LG-TRAN-FAILED TO LGC:LC:-JOB-FAILED.

           WRITE LOG-RECORD FROM LOG-ACTION-CLOSE-:LC:.

       PERFORM CLOSE-LOG-FILE.

       LOG-BASE-ERROR.
           PERFORM CHECK-FILE-OR-DIE.

           PERFORM TIMESTAMP.
           MOVE LG-TIMESTAMP TO 
               LGE-TIMESTAMP
               LGTE-TIMESTAMP.
           MOVE LG-TYPE TO 
               LGE-TYPE
               LGTE-TYPE.
           MOVE LG-STATUS-CODE TO 
               LGE-STATUS-CODE
               LGTE-STATUS-CODE.
       MOVE LG-TEXT TO 
           LGE-MESSAGE
           LGTE-MESSAGE.

       LOG-ERROR.
           PERFORM LOG-BASE-ERROR.
       WRITE LOG-RECORD FROM LOG-ACTION-ERROR.

       LOG-TRAN-ERROR.
           PERFORM LOG-BASE-ERROR.
       WRITE LOG-RECORD FROM LOG-TRANSACTION-ERROR.
           

       LOG-VALIDATION.
           PERFORM CHECK-FILE-OR-DIE.

           PERFORM TIMESTAMP.
           MOVE LG-TIMESTAMP TO LGV-TIMESTAMP.
           MOVE LG-STATUS-CODE TO LGV-STATUS-CODE.
           MOVE LG-TEXT TO LGV-MESSAGE.

       WRITE LOG-RECORD FROM LOG-ACTION-VALID.

      * -    FILE SECTION IDENTIFIER

       LOG-FILE-ACTION.
           PERFORM CHECK-FILE-OR-DIE.

           PERFORM TIMESTAMP.
           MOVE LG-TIMESTAMP TO
            LGF-TIMESTAMP
            LGFC-TIMESTAMP.
           MOVE LG-STATUS-CODE TO
            LGF-STATUS-CODE
            LGFC-STATUS-CODE.
           MOVE LG-LOG-FILE-NAME TO
            LGF-FILE
            LGFC-FILE.

           IF LG-STATUS-CODE = 0013
            WRITE LOG-RECORD FROM LOG-ACTION-FILE-CLOSE
           ELSE
            WRITE LOG-RECORD FROM LOG-ACTION-FILE
       END-IF.


      * -    TRANSACTION SECTION IDENTIFIER

      * --  GENERAL SECTION

       LOG-TRANSACTION-START.
           PERFORM TIMESTAMP.

           MOVE LG-TIMESTAMP TO LGTS-TIMESTAMP.
           MOVE :ETE:(:TC:)
            TO LGTS-TRANSACTION-ETE-ID.

       WRITE LOG-RECORD FROM LOG-ACTION-TRANSACTION-START.

       LOG-TRANSACTION-SKIP.
           PERFORM TIMESTAMP.

           MOVE LG-TIMESTAMP TO LGTZ-TIMESTAMP.
           MOVE :ETE:(:TC:)
            TO LGTZ-TRANSACTION-ETE-ID.

       WRITE LOG-RECORD FROM LOG-ACTION-TRANSACTION-ZKIP.

       LOG-TRANSACTION-END.
           PERFORM TIMESTAMP.

           IF (LG-RETURN-CODE > 0)
            SET LT-WARN TO TRUE
           ELSE
            SET LT-INFO TO TRUE
           END-IF.

           MOVE LG-TIMESTAMP TO LGTC-TIMESTAMP.
           MOVE LG-TYPE TO LGTC-TYPE.
           MOVE LG-RETURN-CODE TO LGTC-RETURN-CODE.

           MOVE :ETE:(:TC:)
            TO LGTC-TRANSACTION-ETE-ID.
           MOVE :SAI:(:TC:)
            TO LGTC-SENDER-ID.
           MOVE :RAI:(:TC:)
            TO LGTC-RECEIVER-ID.
           MOVE :AMT:(:TC:)
            TO LGTC-AMOUNT.
           MOVE :CUR:(:TC:)
            TO LGTC-CURRENCY.

           WRITE LOG-RECORD FROM LOG-ACTION-TRANSACTION-CLOSE.

           IF LG-RETURN-CODE > LG-END-RETURN-CODE
            MOVE LG-RETURN-CODE TO LG-END-RETURN-CODE
           END-IF.

       MOVE '0000' TO LG-RETURN-CODE.
