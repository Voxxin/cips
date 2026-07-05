      *================================================================*
      * PVRF.cpy                                                       *
      *================================================================*

       VTO-FILE-WRITE.
           IF NOT VTO-FILE-OK
            DISPLAY "FATAL: Unable to write to ValidationResults.dat" 
            " Status: " VTO-FILE-STATUS
            GOBACK
           END-IF.

           ADD 1 TO VTO-TC.
       WRITE VTO-RECORD FROM VTO-FILE-OUT.
