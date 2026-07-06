      *================================================================*
      * WAF.cpy                                                        *
      *================================================================*
       
       01  WS-SENDER-IDX PIC 9(4) VALUE ZERO.
       01  WS-RECEIVER-IDX PIC 9(4) VALUE ZERO.

       01  WS-SENDER-CASE PIC X(1) VALUE 'U'.
        88 WS-SENDER-US VALUE 'U'.
        88 WS-SENDER-NOT-US VALUE 'N'.

       01  WS-RECEIVER-CASE PIC X(1) VALUE 'U'.
        88 WS-RECEIVER-US VALUE 'U'.
        88 WS-RECEIVER-NOT-US VALUE 'N'.
       
       01  AT-LOOKUP-KEY PIC X(15).
       01  AT-LOOKUP-RESULT-IDX PIC 9(4) VALUE ZERO.
        88 AT-LOOKUP-RESULT-EMPTY VALUE ZERO.

       01  AT-TC PIC 9(4) VALUE ZERO.

       COPY WPL REPLACING ==:NAME:== BY ==AT-LOOKUP==.
       COPY WTI REPLACING ==:NAME:== BY ==AT-LOOKUP==.
