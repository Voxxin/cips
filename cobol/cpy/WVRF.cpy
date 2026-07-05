      *================================================================*
      * WVRF.cpy                                                       *
      *================================================================*

       01  VTO-TC PIC 9(4) VALUE ZERO.

      * -- Max 1000 transactions (ValidationResults.dat)
       01  VT-TABLE.
        02 VT-ENTRY OCCURS 1000 TIMES INDEXED BY VT-IDX.
         03 VT-TRNS-STATUS PIC 9.
          88 VT-T-FAIL VALUE 0.
          88 VT-T-SUCCESS VALUE 1.
         03 VT-T-ETE-ID PIC X(35).
         03 VT-T-SNDRA-ID PIC X(10).
         03 VT-T-RCVRA-ID PIC X(10).
         03 VT-T-AMOUNT PIC 9(12)V99.
         03 VT-T-CURRENCY PIC X(3).

       01  VT-TC PIC 9(4) VALUE ZERO.

       01  VT-LOOKUP-KEY PIC X(10).
       01  VT-LOOKUP-RESULT-IDX PIC 9(4) VALUE ZERO.
        88 VT-LOOKUP-RESULT-EMPTY VALUE ZERO.
