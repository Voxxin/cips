      *================================================================*
      * DTRAN.cpy                                                      *
      *================================================================*
       
       01  TRANSACTION-DATA.
        02 TRANSACTION-MSG-ID PIC X(35).
        02 TRANSACTION-END-TO-END-ID PIC X(35).
        02 TRANSACTION-SENDER-ACCOUNT-ID PIC X(15).
        02 TRANSACTION-RECEIVER-ACCOUNT-ID PIC X(15).
        02 TRANSACTION-AMOUNT PIC 9(12)V99.
        02 TRANSACTION-CURRENCY PIC X(3).
         88 VALID-CURRENCY VALUE 'CAD'.
        02 TRANSACTION-TIMESTAMP PIC 9(13).
