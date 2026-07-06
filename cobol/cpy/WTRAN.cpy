      *================================================================*
      * WTRAN.cpy                                                      *
      *================================================================*
      * -- Max 1000 transactions (Accounts.dat)
       01  TRAN-TABLE.
        02 TRAN-ENTRY OCCURS 1000 TIMES INDEXED BY TRAN-IDX.
         03 TTE-END-TO-END-ID PIC X(35).
         03 TTE-SENDER-ACCOUNT-ID.
          04 TTE-S-TRANSIT PIC X(5).
          04 TTE-S-INSTITUTION PIC X(3).
           88 TTE-S-INS-US VALUE 'CIP'.
          04 TTE-S-NUM PIC X(7).
         03 TTE-RECEIVER-ACCOUNT-ID.
          04 TTE-R-TRANSIT PIC X(5).
          04 TTE-R-INSTITUTION PIC X(3).
           88 TTE-R-INS-US VALUE 'CIP'.
          04 TTE-R-NUM PIC X(7).
         03 TTE-AMOUNT PIC 9(12)V99.
         03 TTE-CURRENCY PIC X(3).
          88 TTE-VALID-CURRENCY VALUE 'CAD'.
         03 TTE-TIMESTAMP PIC 9(13).

       01  TRND-TABLE.
        02 TRND-ENTRY OCCURS 1000 TIMES INDEXED BY TRND-IDX.
         03 TRND-ETE-ID PIC X(35).
         03 TRND-APPEAR PIC 9(4).

       01  TRAN-TABLE-COUNT PIC 9(4) VALUE ZERO.
