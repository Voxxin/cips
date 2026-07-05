      *================================================================*
      * WTS.cpy                                                        *
      *================================================================*

       01  WS-CURRENT-DATE-FIELDS.
           05 WS-CURRENT-DATE.
              10 WS-CURRENT-YEAR PIC 9(4).
              10 WS-CURRENT-MONTH PIC 9(2).
              10 WS-CURRENT-DAY PIC 9(2).
           05 WS-CURRENT-TIME.
              10 WS-CURRENT-HOUR PIC 9(2).
              10 WS-CURRENT-MINUTE PIC 9(2).
              10 WS-CURRENT-SECOND PIC 9(2).
              10 WS-CURRENT-MS PIC 9(2).
           05 WS-DIFF-FROM-GMT PIC X(5).

       01  LG-TIMESTAMP PIC X(27).
