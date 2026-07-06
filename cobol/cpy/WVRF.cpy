      *================================================================*
      * WVRF.cpy                                                       *
      *================================================================*

       01  VTO-TC PIC 9(4) VALUE ZERO.

      * -- Max 1000 transactions (ValidationResults.dat)
       01  VT-TABLE.
        02 VT-ENTRY OCCURS 1000 TIMES INDEXED BY VT-IDX.
         03 VT-TRNS-STATUS PIC 9(4).
          88 VT-T-SUCCESS VALUE 0.
         03 VT-T-ETE-ID PIC X(35).
         03 VT-T-SNDR-ID.
          04 VT-T-SNDR-T PIC X(5).
          04 VT-T-SNDR-I PIC X(3).
           88 VT-T-SNDR-INS-US VALUE 'CIP'.
          04 VT-T-SNDR-N PIC X(7).
         03 VT-T-RCVR-ID.
          04 VT-T-RCVR-T PIC X(5).
          04 VT-T-RCVR-I PIC X(3).
           88 VT-T-RCVR-INS-US VALUE 'CIP'.
          04 VT-T-RCVR-N PIC X(7).
         03 VT-T-AMOUNT PIC 9(12)V99.
         03 VT-T-CURRENCY PIC X(3).

       01  VT-TC PIC 9(4) VALUE ZERO.

       01  VT-LOOKUP-KEY PIC X(15).
       01  VT-LOOKUP-RESULT-IDX PIC 9(4) VALUE ZERO.
        88 VT-LOOKUP-RESULT-EMPTY VALUE ZERO.
