      *================================================================*
      * DACCT.cpy                                                      *
      *================================================================*   
       
       01  ACC-RECORD.
        02 ACC-ID PIC X(10).
        02 ACC-HOLDER-NAME PIC X(30).
        02 ACC-CURRENT-BALANCE PIC S9(12)V99.
        02 ACC-DAILY-LIMIT PIC 9(12)V99.
        02 ACC-DAILY-SPENT PIC 9(12)V99.
        02 ACC-STATUS PIC X.
