       IDENTIFICATION DIVISION.
           PROGRAM-ID. PostTransaction.
           AUTHOR. ELLA LOVE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT ACCT-FILE
           ASSIGN TO "../data/Accounts.dat"
           ORGANIZATION IS SEQUENTIAL
           FILE STATUS IS ACCT-FILE-STATUS.

       SELECT LOG-FILE
           ASSIGN TO "../output/JOB.log"
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS LOG-FILE-STATUS.

       SELECT VTO-FILE
           ASSIGN TO "../output/ValidationResults.dat"
           ORGANIZATION IS SEQUENTIAL
           FILE STATUS IS VTO-FILE-STATUS.

       SELECT UAO-FILE
           ASSIGN TO "../output/UpdatedAccounts.dat"
           ORGANIZATION IS SEQUENTIAL
           FILE STATUS IS UAO-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD ACCT-FILE.
       COPY DACCT.

       FD VTO-FILE.
       COPY DVRF.

       FD LOG-FILE.
       01 LOG-RECORD PIC X(400).

       FD UAO-FILE.
       01 UAO-RECORD PIC X(52).

       WORKING-STORAGE SECTION.
       COPY DUAF.

       COPY WACCT.
       COPY WVRF.
       COPY WSC.
       COPY WTS.
       COPY WAF.
       COPY WUAF.

       COPY WLOG REPLACING "PGMNAME" BY "POSTRN".
       COPY WTRAN  REPLACING "PGMNAME" BY "POSTRN".

       COPY WFS REPLACING ==:FNAME:== BY ==ACCT==.
       COPY WFS REPLACING ==:FNAME:== BY ==LOG==.
       COPY WFS REPLACING ==:FNAME:== BY ==VTO==.
       COPY WFS REPLACING ==:FNAME:== BY ==UAO==.

       COPY WPL REPLACING ==:NAME:== BY ==POSTRN==.
       COPY WTI REPLACING ==:NAME:== BY ==POSTRN==.

       01  WS-MAX-ENTRIES PIC 9(4) VALUE 1000.

       01  WS-ACC-BAL-OLD PIC S9(12)V99.
       01  WS-ACC-DAILY-OLD PIC 9(12)V99.
       
       PROCEDURE DIVISION.

       MAIN.
           PERFORM LOG-START.

           PERFORM OPEN-ACCT-FILE.
           PERFORM OPEN-VTO-FILE.
           PERFORM OPEN-UAO-FILE.

           MOVE ZERO TO VT-TC.
           PERFORM POSTRN-PROCESS-LOOP.

      * ##  Writes every resolved account's final values out,
      * ##   to be passed onto the database.
           PERFORM POSTRN-ITERATE.

       PERFORM CLEAN-UP.

       POSTRN-LOAD-RECORD.
           MOVE VTO-TRNS-STATUS TO VT-TRNS-STATUS(VT-TC)
           MOVE VTO-T-ETE-ID TO VT-T-ETE-ID(VT-TC)
           MOVE VTO-T-SNDR-ID TO VT-T-SNDR-ID(VT-TC)
           MOVE VTO-T-RCVR-ID TO VT-T-RCVR-ID(VT-TC)
           MOVE VTO-T-AMOUNT TO VT-T-AMOUNT(VT-TC)
       MOVE VTO-T-CURRENCY TO VT-T-CURRENCY(VT-TC).

       POSTRN-HANDLE-RECORD.
      * ## If the transaction didn't pass in the previous step
      * ##  fully skipped.  
           IF NOT VT-T-SUCCESS(VT-TC)
            ADD 1 TO LG-TRAN-SKIPPED
            PERFORM LOG-TRANSACTION-SKIP
            EXIT PARAGRAPH
           END-IF

           PERFORM LOG-TRANSACTION-START

           PERFORM RESOLVE-ACCOUNTS

           IF LG-RETURN-CODE = 0
            PERFORM COMPUTE-TRANSACTION
           END-IF

       PERFORM LOG-TRANSACTION-END.
           

       COMPUTE-TRANSACTION.
      * ##  Perform calculations from the sender's account
           IF WS-SENDER-US
            MOVE AT-BALANCE(WS-SENDER-IDX) TO
               WS-ACC-BAL-OLD
            MOVE AT-DAILY-SPENT(WS-SENDER-IDX) TO
               WS-ACC-DAILY-OLD
            
            SUBTRACT VT-T-AMOUNT(VT-TC)
             FROM AT-BALANCE(WS-SENDER-IDX)
            ADD VT-T-AMOUNT(VT-TC)
             TO AT-DAILY-SPENT(WS-SENDER-IDX)
            
            MOVE AT-ACCOUNT-ID(WS-SENDER-IDX) TO LGV-ACCOUNT
            MOVE VT-T-ETE-ID(VT-TC) TO LGV-TRANSACTION 
            MOVE INFO-SENDER-UPDATE TO LG-STATUS-CODE
            MOVE " " TO LG-TEXT
            STRING
              "SIDE=DEBIT|"
              "PREV-BALANCE=" WS-ACC-BAL-OLD "|"
              "NEW-BALANCE=" AT-BALANCE(WS-SENDER-IDX) "|"
              "PREV-DAILY-SPENT=" WS-ACC-DAILY-OLD "|"
              "NEW-DAILY-SPENT=" AT-DAILY-SPENT(WS-SENDER-IDX)
              DELIMITED BY SIZE INTO LG-TEXT
            
            PERFORM LOGGING-VALIDATION
           END-IF.

      * ##  Perform calculations to the reciever's account
           IF WS-RECEIVER-US
            MOVE AT-BALANCE(WS-SENDER-IDX) TO
               WS-ACC-BAL-OLD
            
            ADD VT-T-AMOUNT(VT-TC)
             TO AT-BALANCE(WS-RECEIVER-IDX)
            
            MOVE AT-ACCOUNT-ID(WS-RECEIVER-IDX) TO LGV-ACCOUNT
            MOVE VT-T-ETE-ID(VT-TC) TO LGV-TRANSACTION 
            MOVE INFO-RECEIVER-UPDATE TO LG-STATUS-CODE
            MOVE " " TO LG-TEXT
            STRING
              "SIDE=CREDIT|"
              "PREV-BALANCE=" WS-ACC-BAL-OLD "|"
              "NEW-BALANCE=" AT-BALANCE(WS-RECEIVER-IDX)
              DELIMITED BY SIZE INTO LG-TEXT
            PERFORM LOGGING-VALIDATION
           END-IF.

       ADD 1 TO LG-TRAN-PASSED.

       POSTRN-HANDLE-ITERATION.
           MOVE AT-ACCOUNT-ID(POSTRN-TI-CTR) TO UAO-ID
           MOVE AT-BALANCE(POSTRN-TI-CTR) TO UAO-CB
           MOVE AT-DAILY-LIMIT(POSTRN-TI-CTR) TO UAO-DL
           MOVE AT-DAILY-SPENT(POSTRN-TI-CTR) TO UAO-DS
       PERFORM UAO-FILE-WRITE.

       ABORT-WITH-FATAL.
           PERFORM LOGGING-FATAL.
       PERFORM CLEAN-UP.

       CLEAN-UP.
           PERFORM CLOSE-ACCT-FILE.
           PERFORM CLOSE-VTO-FILE.
           PERFORM CLOSE-UAO-FILE.

           EVALUATE TRUE
           WHEN LG-TRAN-PROCESSED = LG-TRAN-FAILED
                 OR LG-RETURN-FATAL
            IF LG-RETURN-CODE > LG-END-RETURN-CODE
             MOVE LG-RETURN-CODE TO LG-END-RETURN-CODE
            END-IF
            COMPUTE RETURN-CODE = LG-END-RETURN-CODE
           WHEN OTHER
            COMPUTE RETURN-CODE = 0
           END-EVALUATE.

           MOVE RETURN-CODE TO LG-END-RETURN-CODE

           PERFORM LOG-CLOSE.
       GOBACK.

      * #      COPY BOOKS

      * ## File open/close procedures
       COPY PFT
            REPLACING ==:FNAME:== BY ==ACCT==
                     ":FFILE:" BY "Accounts.dat"
                     ==:FMODE:== BY ==INPUT==
                     ==:TC:== BY ==AT-TC==.
       COPY PFT
            REPLACING ==:FNAME:== BY ==VTO==
                     ":FFILE:" BY "ValidationResults.dat"
                     ==:FMODE:== BY ==INPUT==
                     ==:TC:== BY ==VT-TC==.

       COPY PFT
            REPLACING ==:FNAME:== BY ==UAO==
                     ":FFILE:" BY "UpdatedAccounts.dat"
                     ==:FMODE:== BY ==OUTPUT==
                     ==:TC:== BY ==UAO-TC==.

       COPY PFT
            REPLACING ==:FNAME:== BY ==LOG==
                     ":FFILE:" BY "JOB.log"
                     ==:FMODE:== BY ==OUTPUT==
                     ==:TC:== BY ==LG-TRAN-PROCESSED==.

      * ## File read paragraphs
       COPY PFR
            REPLACING ==:FNAME:== BY ==ACCT==
                     ":FFILE:" BY "Accounts.dat".
       COPY PFR
            REPLACING ==:FNAME:== BY ==VTO==
                     ":FFILE:" BY "ValidationResults.dat".

      * ## Main account processing loop
       COPY PPL 
               REPLACING ==:NAME:== BY ==POSTRN==
                         ==:AUTO:== BY ==TRUE==
                         ==:FNAME:== BY ==VTO==
                         ==:SFNAME:== BY =="ValidationResults.dat"==
                         ==:TC:== BY ==VT-TC==.
                         
      * ## Table iterator (validation sub-steps)
       COPY PTI 
               REPLACING ==:NAME:== BY ==POSTRN==
                         ==:TC:== BY ==AT-TC==.


      * ## Helper subroutines used during validation
       COPY PAF 
                 REPLACING ==:TC:== BY ==VT-TC==
                           ==:ETE:== BY ==VT-T-ETE-ID==
                           ==:SAI:== BY ==VT-T-SNDR-ID==
                           ==:SAIB:== BY ==VT-T-SNDR-INS-US==
                           ==:RAI:== BY ==VT-T-RCVR-ID==
                           ==:RAIB:== BY ==VT-T-RCVR-INS-US==.
       COPY PLOG 
                 REPLACING ==":REASON:"== BY =="CONT"==
                           ==:LC:== BY ==P==
                           ==:TC:== BY ==VT-TC==
                           ==:ETE:== BY ==VT-T-ETE-ID==
                           ==:SAI:== BY ==VT-T-SNDR-ID==
                           ==:RAI:== BY ==VT-T-RCVR-ID==
                           ==:AMT:== BY ==VT-T-AMOUNT== 
                           ==:CUR:== BY ==VT-T-CURRENCY==.      
       COPY PTS.

      * ## Final output of account rebalances
       COPY PUAF.
