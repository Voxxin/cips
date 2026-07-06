      *================================================================*
      * WUAF.cpy                                                       *
      *================================================================*

       01  UAO-TC PIC 9(4) VALUE ZERO.

      * -- Max 1000 transactions (UpdatedAccounts.dat)
       01  UA-TABLE.
        02 UA-ENTRY OCCURS 1000 TIMES INDEXED BY UA-IDX.
         03 UA-ID PIC X(15).
         03 UA-CB PIC S9(12)V99.
         03 UA-DL PIC 9(12)V99.
         03 UA-DS PIC 9(12)V99.

       01  UA-TC PIC 9(4) VALUE ZERO.

       01  UA-LOOKUP-KEY PIC X(15).
       01  UA-LOOKUP-RESULT-IDX PIC 9(4) VALUE ZERO.
        88 UA-LOOKUP-RESULT-EMPTY VALUE ZERO.
