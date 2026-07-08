      *================================================================*
      * PEC.cpy                                                        *
      *================================================================*

       ABORT-WITH-FATAL.
           PERFORM LOGGING-FATAL.
       PERFORM CLEAN-UP.

       CLEAN-UP.
           PERFORM PRE-CLOSE

           EVALUATE TRUE
           WHEN LG-TRAN-PROCESSED = LG-TRAN-FAILED
                 OR LG-RETURN-FATAL
            IF LG-RETURN-CODE > LG-END-RETURN-CODE
             MOVE LG-RETURN-CODE TO LG-END-RETURN-CODE
            END-IF
            COMPUTE RETURN-CODE = LG-END-RETURN-CODE
           WHEN OTHER
            COMPUTE RETURN-CODE = 0
           END-EVALUATE.

           MOVE RETURN-CODE TO LG-END-RETURN-CODE

           PERFORM LOG-CLOSE.
       GOBACK.
