      *================================================================*
      * DVRF.cpy                                                       *
      *================================================================*

       01  VTO-FILE-OUT.
        02 VTO-TRNS-STATUS PIC 9.
         88 VTO-T-FAIL VALUE 0.
         88 VTO-T-SUCCESS VALUE 1.
        02 VTO-TRANS.
         03 VTO-T-ETE-ID PIC X(35).
         03 VTO-T-SNDRA-ID PIC X(10).
         03 VTO-T-RCVRA-ID PIC X(10).
         03 VTO-T-AMOUNT PIC 9(12)V99.
         03 VTO-T-CURRENCY PIC X(3).
