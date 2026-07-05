      *================================================================*
      * WAF.cpy                                                        *
      *================================================================*
       
       01  WS-SENDER-IDX PIC 9(4) VALUE ZERO.
       01  WS-RECEIVER-IDX PIC 9(4) VALUE ZERO.

       01  AT-LOOKUP-KEY PIC X(10).
       01  AT-LOOKUP-RESULT-IDX PIC 9(4) VALUE ZERO.
        88 AT-LOOKUP-RESULT-EMPTY VALUE ZERO.

       01  AT-TC PIC 9(4) VALUE ZERO.

       COPY WPL REPLACING ==:NAME:== BY ==AT-LOOKUP==.
       COPY WTI REPLACING ==:NAME:== BY ==AT-LOOKUP==.
