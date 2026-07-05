      *================================================================*
      * PPL.cpy                                                        *
      *================================================================*

       :NAME:-PROCESS-LOOP.
           PERFORM READ-:FNAME:-FILE.
           PERFORM UNTIL :FNAME:-FILE-EOF OR :NAME:-PL-DONE
               IF :TC: >= WS-MAX-ENTRIES
                MOVE ERR-TABLE-OVERFLOW TO LG-STATUS-CODE
                MOVE " " TO LG-TEXT
                STRING "MSG=Too many entries inside of file " 
                   :SFNAME:
                   DELIMITED BY SIZE
                   INTO LG-TEXT
               END-STRING
                PERFORM ABORT-WITH-FATAL
                EXIT PARAGRAPH
               END-IF

               ADD 1 TO :TC:

               PERFORM :NAME:-LOAD-RECORD
               PERFORM :NAME:-HANDLE-RECORD
               
               EVALUATE TRUE
               WHEN :AUTO:
                ADD 1 TO LG-TRAN-PROCESSED
               END-EVALUATE

               IF :NAME:-PL-NOT-DONE
                PERFORM READ-:FNAME:-FILE
               END-IF
       END-PERFORM.
