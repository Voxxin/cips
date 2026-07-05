      *================================================================*
      * PFR.cpy                                                        *
      *================================================================*

       READ-:FNAME:-FILE.
           MOVE ":FFILE:" TO LG-LOG-FILE-NAME.

           IF :FNAME:-FILE-IS-CLOSED
            MOVE ERR-FILE-CLOSED TO LG-STATUS-CODE
            PERFORM LOGGING-WARN
            PERFORM OPEN-:FNAME:-FILE
           END-IF.

           READ :FNAME:-FILE
            AT END
             SET :FNAME:-FILE-EOF TO TRUE
             IF :FNAME:-FILE-EMPTY-Y
              MOVE ERR-FILE-EMPTY TO LG-STATUS-CODE
              PERFORM LOGGING-ERROR
             ELSE
              MOVE INFO-FILE-EOF TO LG-STATUS-CODE
              PERFORM LOG-FILE-ACTION
             END-IF
            NOT AT END
             IF :FNAME:-FILE-EMPTY-Y
              MOVE INFO-FILE-READ-FIRST TO LG-STATUS-CODE
              PERFORM LOG-FILE-ACTION
              SET :FNAME:-FILE-EMPTY-N TO TRUE
             END-IF
       END-READ.
