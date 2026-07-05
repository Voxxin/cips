      *================================================================*
      * PTS.cpy                                                        *
      *================================================================*
       
       TIMESTAMP.
           MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-FIELDS
           STRING
               WS-CURRENT-YEAR DELIMITED BY SIZE
               "-" DELIMITED BY SIZE
               WS-CURRENT-MONTH DELIMITED BY SIZE
               "-" DELIMITED BY SIZE
               WS-CURRENT-DAY DELIMITED BY SIZE
               "T" DELIMITED BY SIZE
               WS-CURRENT-HOUR DELIMITED BY SIZE
               ":" DELIMITED BY SIZE
               WS-CURRENT-MINUTE DELIMITED BY SIZE
               ":" DELIMITED BY SIZE
               WS-CURRENT-SECOND DELIMITED BY SIZE
               "." DELIMITED BY SIZE
               WS-CURRENT-MS DELIMITED BY SIZE
               WS-DIFF-FROM-GMT DELIMITED BY SIZE
               INTO LG-TIMESTAMP
       END-STRING.       
