      *================================================================*
      * WACCT.cpy                                                      *
      *================================================================*

      * -- Max 1000 accounts (Accounts.dat)
       01  AT-TABLE.
        02 AT-ENTRY OCCURS 1000 TIMES INDEXED BY AT-IDX.
         03 AT-ACCOUNT-ID PIC X(15).
         03 AT-HOLDER-NAME PIC X(30).
         03 AT-BALANCE PIC S9(12)V99.
         03 AT-DAILY-LIMIT PIC 9(12)V99.
         03 AT-DAILY-SPENT PIC 9(12)V99.
         03 AT-STATUS PIC X.
          88 AT-STATUS-ACTIVE VALUE 'A'.
          88 AT-STATUS-FROZEN VALUE 'F'.
          88 AT-STATUS-CLOSED VALUE 'C'.
