      *================================================================*
      * PTI.cpy                                                        *
      *================================================================*

       :NAME:-ITERATE.
           SET :NAME:-TI-NOT-DONE TO TRUE.
           MOVE ZERO TO :NAME:-TI-CTR.

           PERFORM UNTIL :NAME:-TI-CTR >= :TC: OR :NAME:-TI-DONE
            ADD 1 TO :NAME:-TI-CTR
            PERFORM :NAME:-HANDLE-ITERATION
       END-PERFORM.
