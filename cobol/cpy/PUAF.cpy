      *================================================================*
      * PUAF.cpy                                                       *
      *================================================================*

       UAO-FILE-WRITE.
           IF NOT UAO-FILE-OK
            DISPLAY "FATAL: Unable to write to UpdatedAccounts.dat" 
            " Status: " UAO-FILE-STATUS
            GOBACK
           END-IF.

           ADD 1 TO UAO-TC.
       WRITE UAO-RECORD FROM UAO-FILE-OUT.
