       IDENTIFICATION DIVISION.
           PROGRAM-ID. ValidateTransactions.
           AUTHOR. ELLA LOVE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT ACCT-FILE
           ASSIGN TO "../data/Accounts.dat"
           ORGANIZATION IS SEQUENTIAL
           FILE STATUS IS ACCT-FILE-STATUS.

       SELECT TRAN-FILE
           ASSIGN TO "../data/Transactions.dat"
           ORGANIZATION IS SEQUENTIAL
           FILE STATUS IS TRAN-FILE-STATUS.

       SELECT LOG-FILE
           ASSIGN TO "../output/JOB.log"
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS LOG-FILE-STATUS.

       SELECT VTO-FILE
           ASSIGN TO "../output/ValidationResults.dat"
           ORGANIZATION IS SEQUENTIAL
           FILE STATUS IS VTO-FILE-STATUS.


       DATA DIVISION.
       FILE SECTION.
       FD ACCT-FILE.
       COPY DACCT.

       FD TRAN-FILE.
       COPY DTRAN.

       FD LOG-FILE.
       01 LOG-RECORD PIC X(400).

       FD VTO-FILE.
       01 VTO-RECORD PIC X(73).

       WORKING-STORAGE SECTION.
       COPY DVRF.

       COPY WACCT.
       COPY WVRF.
       COPY WEC.
       COPY WTS.
       COPY WAF.

       COPY WLOG REPLACING "PGMNAME" BY "VALTRN".
       COPY WTRAN  REPLACING "PGMNAME" BY "VALTRN".

       COPY WFS REPLACING ==:FNAME:== BY ==ACCT==.
       COPY WFS REPLACING ==:FNAME:== BY ==TRAN==.
       COPY WFS REPLACING ==:FNAME:== BY ==LOG==.
       COPY WFS REPLACING ==:FNAME:== BY ==VTO==.

       COPY WPL REPLACING ==:NAME:== BY ==VALTRN==.
       COPY WTI REPLACING ==:NAME:== BY ==DATE==.
       COPY WTI REPLACING ==:NAME:== BY ==DUPE==.
       COPY WTI REPLACING ==:NAME:== BY ==VALIDATE==.

       01  WS-MAX-ENTRIES PIC 9(4) VALUE 1000.

       01  WS-FMT-BALANCE PIC Z(11)9.99.
       01  WS-FMT-AMOUNT PIC Z(11)9.99.
       01  WS-FMT-POST-BAL PIC Z(11)9.99.
       01  WS-FMT-LIMIT PIC Z(11)9.99.
       01  WS-FMT-SPENT PIC Z(11)9.99.
       01  WS-FMT-WOULD-LIMIT PIC Z(11)9.99.
       01  WS-CALC-POST-BAL PIC S9(12)V99.
       01  WS-CALC-WOULD-LIMIT PIC 9(12)V99.

       01  WS-TI-STATE PIC X(1) VALUE 'N'.
        88 WS-TI-DONE VALUE 'Y'.
        88 WS-TI-NOT-DONE VALUE 'N'.

       01  WS-SWAP-STATE PIC X(1) VALUE 'N'.
        88 WS-SWAP-OCCURRED VALUE 'Y'.
        88 WS-NO-SWAP VALUE 'N'.

       01  WS-T-DUPE-STATE PIC X(1) VALUE 'Y'.
        88 WS-T-NOT-DUPE VALUE 'N'.
        88 WS-T-DUPE VALUE 'Y'.

       01  WS-T-DATA.
        02 WS-T-END-TO-END-ID PIC X(35).
        02 WS-T-SENDER-ACCOUNT-ID PIC X(10).
        02 WS-T-RECEIVER-ACCOUNT-ID PIC X(10).
        02 WS-T-AMOUNT PIC 9(12)V99.
        02 WS-T-CURRENCY PIC X(3).
        02 WS-T-TIMESTAMP PIC 9(13).

       01 WS-TI-PREV-IDX PIC 9(4) VALUE 1.

       PROCEDURE DIVISION.
       MAIN.
           PERFORM LOG-START.

           PERFORM OPEN-ACCT-FILE.
           PERFORM OPEN-TRAN-FILE.
           PERFORM OPEN-VTO-FILE.

           PERFORM COMPUTE-VALIDATIONS.

       PERFORM CLEAN-UP.

       COMPUTE-VALIDATIONS.
           MOVE ZERO TO TRAN-TABLE-COUNT.
           PERFORM VALTRN-PROCESS-LOOP.

           PERFORM UNTIL WS-TI-DONE
            SET WS-NO-SWAP TO TRUE
            PERFORM DATE-ITERATE
            IF WS-NO-SWAP
             SET WS-TI-DONE TO TRUE
            END-IF
           END-PERFORM.

       PERFORM VALIDATE-ITERATE.

      * ## From oldest to the newest (Small to big).

       DATE-HANDLE-ITERATION.
           IF DATE-TI-CTR = 1
            EXIT PARAGRAPH
           END-IF.

           COMPUTE WS-TI-PREV-IDX = DATE-TI-CTR - 1.

           IF TTE-TIMESTAMP(WS-TI-PREV-IDX) >
                 TTE-TIMESTAMP(DATE-TI-CTR)

            MOVE TRAN-ENTRY(DATE-TI-CTR) TO WS-T-DATA
            MOVE TRAN-ENTRY(WS-TI-PREV-IDX) TO TRAN-ENTRY(DATE-TI-CTR)
            MOVE WS-T-DATA TO TRAN-ENTRY(WS-TI-PREV-IDX)

            SET WS-SWAP-OCCURRED TO TRUE
       END-IF.

      * ##  Loads the transactions into a table (array). Then they are
      * ##   processed: resolving the accounts then checking if each
      * ##   would be valid.

       VALTRN-LOAD-RECORD.
           MOVE TRANSACTION-END-TO-END-ID TO
            TTE-END-TO-END-ID(TRAN-TABLE-COUNT) 
            VTO-T-ETE-ID.
           MOVE TRANSACTION-SENDER-ACCOUNT-ID TO
            TTE-SENDER-ACCOUNT-ID(TRAN-TABLE-COUNT) 
            VTO-T-SNDRA-ID.
           MOVE TRANSACTION-RECEIVER-ACCOUNT-ID TO
            TTE-RECEIVER-ACCOUNT-ID(TRAN-TABLE-COUNT) 
            VTO-T-RCVRA-ID.
           MOVE TRANSACTION-AMOUNT TO
            TTE-AMOUNT(TRAN-TABLE-COUNT) 
            VTO-T-AMOUNT.
           MOVE TRANSACTION-CURRENCY TO
            TTE-CURRENCY(TRAN-TABLE-COUNT) 
            VTO-T-CURRENCY.
       MOVE TRANSACTION-TIMESTAMP TO
            TTE-TIMESTAMP(TRAN-TABLE-COUNT).

      * ## Intentionally emtpy
       VALTRN-HANDLE-RECORD.

       DUPE-HANDLE-ITERATION.
           IF TTE-END-TO-END-ID(VALIDATE-TI-CTR) 
                 EQUAL TRND-ETE-ID(DUPE-TI-CTR)

            IF TRND-APPEAR(DUPE-TI-CTR) >= 1
             SET WS-T-DUPE TO TRUE
             EXIT PARAGRAPH
            END-IF

            ADD 1 TO TRND-APPEAR(DUPE-TI-CTR)
            EXIT PARAGRAPH
           END-IF.

           MOVE TTE-END-TO-END-ID(VALIDATE-TI-CTR) 
                 TO TRND-ETE-ID(DUPE-TI-CTR).
       ADD 1 TO TRND-APPEAR(DUPE-TI-CTR).

       LOAD-VALIDATION-DATA.
           MOVE TTE-END-TO-END-ID(VALIDATE-TI-CTR) TO
               LGTE-TRANSACTION
               LGV-TRANSACTION
               VTO-T-ETE-ID.
           MOVE TTE-SENDER-ACCOUNT-ID(VALIDATE-TI-CTR) TO
               VTO-T-SNDRA-ID.
           MOVE TTE-RECEIVER-ACCOUNT-ID(VALIDATE-TI-CTR) TO
               VTO-T-RCVRA-ID.
           MOVE TTE-AMOUNT(VALIDATE-TI-CTR) TO
               VTO-T-AMOUNT.
           MOVE TTE-CURRENCY(VALIDATE-TI-CTR) TO
               VTO-T-CURRENCY.
            

       VALIDATE-HANDLE-ITERATION.
           SET WS-T-NOT-DUPE TO TRUE
           PERFORM DUPE-ITERATE.
           PERFORM LOAD-VALIDATION-DATA.

           IF WS-T-DUPE
            MOVE ERR-DUPLICATE-TRANSACTION TO LG-STATUS-CODE
            MOVE " " TO LG-TEXT
            STRING "ETE=" TTE-END-TO-END-ID(VALIDATE-TI-CTR)
                 "|MSG=DUPLICATE TRANSACTION" 
                 DELIMITED BY SIZE INTO LG-TEXT
            ADD 1 TO LG-TRAN-FAILED
            PERFORM LOGGING-ERROR

            SET VTO-T-FAIL TO TRUE
            PERFORM VTO-FILE-WRITE
            EXIT PARAGRAPH
           END-IF.

           PERFORM LOG-TRANSACTION-START

           PERFORM RESOLVE-ACCOUNTS

           IF LG-RETURN-CODE = 0
            PERFORM VALIDATE-TRANSACTION
           ELSE
            SET VTO-T-FAIL TO TRUE
            PERFORM VTO-FILE-WRITE
           END-IF
           
       PERFORM LOG-TRANSACTION-END.       

      * ##  Validates: sender/receiver account state, sufficient funds,
      * ##   supported currency, daily limit not exceeded.
      * ##   Also updates in-memory balance and daily-spent for
      * ##   subsequent transactions in the same batch.

       VALIDATE-TRANSACTION.
      * #        SENDER ACCOUNT STATE
           EVALUATE TRUE
            WHEN AT-STATUS-FROZEN(WS-SENDER-IDX)
             MOVE ERR-SENDER-FROZEN TO LG-STATUS-CODE
             MOVE TTE-SENDER-ACCOUNT-ID(VALIDATE-TI-CTR)
              TO LGTE-ACCOUNT
             MOVE 'MSG=SENDER ACCOUNT FROZEN' TO LG-TEXT
             PERFORM LOGGING-TRANSACTION-ERROR
            WHEN AT-STATUS-CLOSED(WS-SENDER-IDX)
             MOVE ERR-SENDER-CLOSED TO LG-STATUS-CODE
             MOVE TTE-SENDER-ACCOUNT-ID(VALIDATE-TI-CTR)
              TO LGTE-ACCOUNT
             MOVE 'MSG=SENDER ACCOUNT CLOSED' TO LG-TEXT
             PERFORM LOGGING-TRANSACTION-ERROR
            WHEN OTHER
             MOVE INFO-SENDER-ACTIVE TO LG-STATUS-CODE
             MOVE TTE-SENDER-ACCOUNT-ID(VALIDATE-TI-CTR)
              TO LGV-ACCOUNT
             MOVE 'MSG=SENDER ACTIVE' TO LG-TEXT
             PERFORM LOGGING-VALIDATION
           END-EVALUATE.

           IF LG-RETURN-CODE > 0
            SET VTO-T-FAIL TO TRUE
            PERFORM VTO-FILE-WRITE
            ADD 1 TO LG-TRAN-FAILED
            EXIT PARAGRAPH
           END-IF.

      * #        RECEIVER ACCOUNT STATE
           EVALUATE TRUE
            WHEN AT-STATUS-FROZEN(WS-RECEIVER-IDX)
             MOVE ERR-RECEIVER-FROZEN TO LG-STATUS-CODE
             MOVE TTE-RECEIVER-ACCOUNT-ID(VALIDATE-TI-CTR)
              TO LGTE-ACCOUNT
             MOVE 'MSG=RECEIVER ACCOUNT FROZEN' TO LG-TEXT
             PERFORM LOGGING-TRANSACTION-ERROR
            WHEN AT-STATUS-CLOSED(WS-RECEIVER-IDX)
             MOVE ERR-RECEIVER-CLOSED TO LG-STATUS-CODE
             MOVE TTE-RECEIVER-ACCOUNT-ID(VALIDATE-TI-CTR)
              TO LGTE-ACCOUNT
             MOVE 'MSG=RECEIVER ACCOUNT CLOSED' TO LG-TEXT
             PERFORM LOGGING-TRANSACTION-ERROR
            WHEN OTHER
             MOVE INFO-RECEIVER-ACTIVE TO LG-STATUS-CODE
             MOVE TTE-RECEIVER-ACCOUNT-ID(VALIDATE-TI-CTR)
              TO LGV-ACCOUNT
             MOVE 'MSG=RECEIVER ACTIVE' TO LG-TEXT
             PERFORM LOGGING-VALIDATION
           END-EVALUATE.

           IF LG-RETURN-CODE > 0
            SET VTO-T-FAIL TO TRUE
            PERFORM VTO-FILE-WRITE
            ADD 1 TO LG-TRAN-FAILED
            EXIT PARAGRAPH
           END-IF.

           MOVE TTE-AMOUNT(VALIDATE-TI-CTR) TO WS-FMT-AMOUNT.

      * #        FUNDS
           EVALUATE TRUE
            WHEN AT-BALANCE(WS-SENDER-IDX) <
              TTE-AMOUNT(VALIDATE-TI-CTR)
             MOVE ERR-INSUFFICIENT-FUNDS TO LG-STATUS-CODE
             MOVE TTE-SENDER-ACCOUNT-ID(VALIDATE-TI-CTR)
              TO LGTE-ACCOUNT
             MOVE AT-BALANCE(WS-SENDER-IDX) TO WS-FMT-BALANCE
             MOVE SPACE TO LG-TEXT
             STRING "MSG=INSUFFICIENT FUNDS|BAL=" DELIMITED BY SIZE
                    WS-FMT-BALANCE DELIMITED BY SIZE
                    "|AMT=" DELIMITED BY SIZE
                    WS-FMT-AMOUNT DELIMITED BY SIZE
               INTO LG-TEXT
             PERFORM LOGGING-TRANSACTION-ERROR
            WHEN OTHER
             MOVE INFO-FUNDS-OK TO LG-STATUS-CODE
             MOVE TTE-SENDER-ACCOUNT-ID(VALIDATE-TI-CTR)
              TO LGV-ACCOUNT
             MOVE AT-BALANCE(WS-SENDER-IDX) TO WS-FMT-BALANCE
             COMPUTE WS-CALC-POST-BAL =
               AT-BALANCE(WS-SENDER-IDX) -
               TTE-AMOUNT(VALIDATE-TI-CTR)
             MOVE WS-CALC-POST-BAL TO WS-FMT-POST-BAL
             MOVE SPACE TO LG-TEXT
             STRING "MSG=FUNDS OK|BAL=" DELIMITED BY SIZE
                    WS-FMT-BALANCE DELIMITED BY SIZE
                    "|AMT=" DELIMITED BY SIZE
                    WS-FMT-AMOUNT DELIMITED BY SIZE
                    "|POST=" DELIMITED BY SIZE
                    WS-FMT-POST-BAL DELIMITED BY SIZE
               INTO LG-TEXT
             PERFORM LOGGING-VALIDATION
           END-EVALUATE.

           IF LG-RETURN-CODE > 0
            SET VTO-T-FAIL TO TRUE
            PERFORM VTO-FILE-WRITE
            ADD 1 TO LG-TRAN-FAILED
            EXIT PARAGRAPH
           END-IF.

      * #        CURRENCY
           EVALUATE TRUE
            WHEN NOT TTE-VALID-CURRENCY(VALIDATE-TI-CTR)
             MOVE ERR-UNSUPPORTED-CURRENCY TO LG-STATUS-CODE
             MOVE TTE-SENDER-ACCOUNT-ID(VALIDATE-TI-CTR)
              TO LGTE-ACCOUNT
             MOVE 'MSG=UNSUPPORTED CURRENCY' TO LG-TEXT
             PERFORM LOGGING-TRANSACTION-ERROR
            WHEN OTHER
             MOVE INFO-CURRENCY-OK TO LG-STATUS-CODE
             MOVE TTE-SENDER-ACCOUNT-ID(VALIDATE-TI-CTR)
              TO LGV-ACCOUNT
             MOVE SPACE TO LG-TEXT
             STRING "MSG=CURRENCY OK|CURR=" DELIMITED BY SIZE
                    TTE-CURRENCY(VALIDATE-TI-CTR) DELIMITED BY SIZE
               INTO LG-TEXT
             PERFORM LOGGING-VALIDATION
           END-EVALUATE.

           IF LG-RETURN-CODE > 0
            SET VTO-T-FAIL TO TRUE
            PERFORM VTO-FILE-WRITE
            ADD 1 TO LG-TRAN-FAILED
            EXIT PARAGRAPH
           END-IF.

      * #        DAILY LIMIT
           EVALUATE TRUE
            WHEN (AT-DAILY-SPENT(WS-SENDER-IDX) +
              TTE-AMOUNT(VALIDATE-TI-CTR)) >
              AT-DAILY-LIMIT(WS-SENDER-IDX)
             MOVE ERR-DAILY-LIMIT-EXCEEDED TO LG-STATUS-CODE
             MOVE TTE-SENDER-ACCOUNT-ID(VALIDATE-TI-CTR)
              TO LGTE-ACCOUNT
             MOVE AT-DAILY-LIMIT(WS-SENDER-IDX) TO WS-FMT-LIMIT
             MOVE AT-DAILY-SPENT(WS-SENDER-IDX) TO WS-FMT-SPENT
             COMPUTE WS-CALC-WOULD-LIMIT =
               AT-DAILY-SPENT(WS-SENDER-IDX) +
               TTE-AMOUNT(VALIDATE-TI-CTR)
             MOVE WS-CALC-WOULD-LIMIT TO WS-FMT-WOULD-LIMIT
             MOVE SPACE TO LG-TEXT
             STRING "MSG=DAILY LIMIT EXCEEDED|LIMIT=" DELIMITED BY SIZE
                    WS-FMT-LIMIT DELIMITED BY SIZE
                    "|SPENT=" DELIMITED BY SIZE
                    WS-FMT-SPENT DELIMITED BY SIZE
                    "|WOULD=" DELIMITED BY SIZE
                    WS-FMT-WOULD-LIMIT DELIMITED BY SIZE
               INTO LG-TEXT
             PERFORM LOGGING-TRANSACTION-ERROR
            WHEN OTHER
             MOVE INFO-LIMIT-OK TO LG-STATUS-CODE
             MOVE TTE-SENDER-ACCOUNT-ID(VALIDATE-TI-CTR)
              TO LGV-ACCOUNT
             MOVE AT-DAILY-LIMIT(WS-SENDER-IDX) TO WS-FMT-LIMIT
             MOVE AT-DAILY-SPENT(WS-SENDER-IDX) TO WS-FMT-SPENT
             COMPUTE WS-CALC-WOULD-LIMIT =
               AT-DAILY-SPENT(WS-SENDER-IDX) +
               TTE-AMOUNT(VALIDATE-TI-CTR)
             MOVE WS-CALC-WOULD-LIMIT TO WS-FMT-WOULD-LIMIT
             MOVE SPACE TO LG-TEXT
             STRING "MSG=DAILY LIMIT OK|LIMIT=" DELIMITED BY SIZE
                    WS-FMT-LIMIT DELIMITED BY SIZE
                    "|SPENT=" DELIMITED BY SIZE
                    WS-FMT-SPENT DELIMITED BY SIZE
                    "|NEW=" DELIMITED BY SIZE
                    WS-FMT-WOULD-LIMIT DELIMITED BY SIZE
               INTO LG-TEXT
             PERFORM LOGGING-VALIDATION
           END-EVALUATE.

           IF LG-RETURN-CODE > 0
            SET VTO-T-FAIL TO TRUE
            PERFORM VTO-FILE-WRITE
            ADD 1 TO LG-TRAN-FAILED
            EXIT PARAGRAPH
           END-IF.

      * ## Update in-memory balances for subsequent batch transactions.
      * ## Never written back to the DB ## that is POSTRN's job.

           SUBTRACT TTE-AMOUNT(VALIDATE-TI-CTR)
            FROM AT-BALANCE(WS-SENDER-IDX).
           ADD TTE-AMOUNT(VALIDATE-TI-CTR)
            TO AT-DAILY-SPENT(WS-SENDER-IDX).
           ADD 1 TO LG-TRAN-PASSED.

           SET VTO-T-SUCCESS TO TRUE.
       PERFORM VTO-FILE-WRITE.

      * ##     UTILITY PARAGRAPHS

       ABORT-WITH-FATAL.
           PERFORM LOGGING-FATAL.
       PERFORM CLEAN-UP.

       CLEAN-UP.
           PERFORM CLOSE-TRAN-FILE.
           PERFORM CLOSE-ACCT-FILE.
           PERFORM CLOSE-VTO-FILE.

      * ## All fail or fatal -> skips PostTransactions
      * ## Partial fail -> PostTransactions processes the OK ones.

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

      * #        COPY BOOKS

      * ## File open/close procedures
       COPY PFT
            REPLACING ==:FNAME:== BY ==TRAN==
                     ":FFILE:" BY "Transactions.dat"
                     ==:FMODE:== BY ==INPUT==
                     ==:TC:== BY ==TRAN-TABLE-COUNT==.

       COPY PFT
            REPLACING ==:FNAME:== BY ==ACCT==
                     ":FFILE:" BY "Accounts.dat"
                     ==:FMODE:== BY ==INPUT==
                     ==:TC:== BY ==AT-TC==.

       COPY PFT
            REPLACING ==:FNAME:== BY ==VTO==
                     ":FFILE:" BY "ValidationResults.dat"
                     ==:FMODE:== BY ==OUTPUT==
                     ==:TC:== BY ==VTO-TC==.

       COPY PFT
            REPLACING ==:FNAME:== BY ==LOG==
                     ":FFILE:" BY "JOB.log"
                     ==:FMODE:== BY ==OUTPUT==
                     ==:TC:== BY ==LG-TRAN-PROCESSED==.
      * ## File read paragraphs
       COPY PFR
            REPLACING ==:FNAME:== BY ==TRAN==
                     ":FFILE:" BY "Transactions.dat".

       COPY PFR
            REPLACING ==:FNAME:== BY ==ACCT==
                     ":FFILE:" BY "Accounts.dat".

      * ## Main transaction processing loop
       COPY PPL 
               REPLACING ==:NAME:== BY ==VALTRN==
                         ==:AUTO:== BY ==TRUE==
                         ==:FNAME:== BY ==TRAN==
                         ==:SFNAME:== BY =="Transactions.dat"==
                         ==:TC:== BY ==TRAN-TABLE-COUNT==.

      * ## Table iterators (validation sub-steps)
       COPY PTI 
               REPLACING ==:NAME:== BY ==DATE==
                         ==:TC:== BY ==TRAN-TABLE-COUNT==.
       COPY PTI 
               REPLACING ==:NAME:== BY ==DUPE==
                         ==:TC:== BY ==TRAN-TABLE-COUNT==.
       COPY PTI 
               REPLACING ==:NAME:== BY ==VALIDATE==
                         ==:TC:== BY ==TRAN-TABLE-COUNT==.

      * ## Helper subroutines used during validation
       COPY PAF 
                 REPLACING ==:TC:== BY ==VALIDATE-TI-CTR==
                           ==:ETE:== BY ==TTE-END-TO-END-ID==
                           ==:SAI:== BY ==TTE-SENDER-ACCOUNT-ID==
                           ==:RAI:== BY ==TTE-RECEIVER-ACCOUNT-ID==.
       COPY PLOG 
                 REPLACING ==":REASON:"== BY =="INIT"==
                           ==:LC:== BY ==V==
                           ==:TC:== BY ==VALIDATE-TI-CTR==
                           ==:ETE:== BY ==TTE-END-TO-END-ID==
                           ==:SAI:== BY ==TTE-SENDER-ACCOUNT-ID==
                           ==:RAI:== BY ==TTE-RECEIVER-ACCOUNT-ID==
                           ==:AMT:== BY ==TTE-AMOUNT== 
                           ==:CUR:== BY ==TTE-CURRENCY==.
       COPY PTS.

      * ## Final output of validation results
       COPY PVRF.
