      *================================================================*
      * DVRF.cpy                                                       *
      *================================================================*

       01  VTO-FILE-OUT.
        02 VTO-TRNS-STATUS PIC 9(4).
         88 VTO-T-SUCCESS VALUE 0.
        02 VTO-TRANS.
         03 VTO-T-ETE-ID PIC X(35).
         03 VTO-T-SNDR-ID PIC X(15).
         03 VTO-T-RCVR-ID PIC X(15).
         03 VTO-T-AMOUNT PIC 9(12)V99.
         03 VTO-T-CURRENCY PIC X(3).
