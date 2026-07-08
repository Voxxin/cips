      *================================================================*
      * PFT.cpy                                                        *
      *================================================================*

       OPEN-:FNAME:-FILE.
           MOVE 
           ":FFILE:" 
               TO LG-LOG-FILE-NAME.

           IF NOT :FNAME:-FILE-IS-OPEN
            OPEN :FMODE: :FNAME:-FILE
            SET :FNAME:-FILE-IS-OPEN TO TRUE
           ELSE
            MOVE ERR-FILE-ALREADY-OPEN TO LG-STATUS-CODE
            PERFORM LOGGING-WARN
           END-IF.

           EVALUATE TRUE
           WHEN NOT :FNAME:-FILE-OK
            MOVE ERR-FILE-OPEN-FAILED TO LG-STATUS-CODE
            PERFORM ABORT-WITH-FATAL
           WHEN OTHER
            MOVE INFO-FILE-OPENED TO LG-STATUS-CODE
            PERFORM LOG-FILE-ACTION
       END-EVALUATE.

       OPEN-OPTIONALLY-:FNAME:-FILE.
           MOVE 
           ":FFILE:" 
               TO LG-LOG-FILE-NAME.

           IF NOT :FNAME:-FILE-IS-OPEN
            OPEN :FMODE: :FNAME:-FILE
            SET :FNAME:-FILE-IS-OPEN TO TRUE
           ELSE
            MOVE ERR-FILE-ALREADY-OPEN TO LG-STATUS-CODE
            PERFORM LOGGING-WARN
           END-IF.

           EVALUATE TRUE
           WHEN NOT :FNAME:-FILE-OK
            MOVE ERR-FILE-OPEN-FAILED TO LG-STATUS-CODE
            SET :FNAME:-FILE-NEVER-OPENED TO TRUE
           WHEN OTHER
            MOVE INFO-FILE-OPENED TO LG-STATUS-CODE
            PERFORM LOG-FILE-ACTION
       END-EVALUATE.

       CLOSE-:FNAME:-FILE.
           MOVE 
           ":FFILE:" 
               TO LG-LOG-FILE-NAME.

           EVALUATE TRUE
           WHEN :FNAME:-FILE-IS-OPEN
            CLOSE :FNAME:-FILE
            SET :FNAME:-FILE-IS-CLOSED TO TRUE
            MOVE INFO-FILE-CLOSED TO LG-STATUS-CODE
            MOVE :TC: TO LGFC-RECORD-COUNT
            PERFORM LOG-FILE-ACTION
           WHEN OTHER
            MOVE INFO-FILE-ALREADY-CLOSED TO LG-STATUS-CODE
            PERFORM LOG-FILE-ACTION
       END-EVALUATE.
