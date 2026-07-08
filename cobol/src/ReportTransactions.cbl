       IDENTIFICATION DIVISION.
           PROGRAM-ID. ReportTransactions.
           AUTHOR. ELLA LOVE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT LOG-FILE
           ASSIGN TO "../output/JOB.log"
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS LOG-FILE-STATUS.

       SELECT REPORT-FILE
           ASSIGN TO "../output/BatchAuditTrail.report"
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS REPORT-FILE-STATUS.

       SELECT VTO-FILE
           ASSIGN TO "../output/ValidationResults.dat"
           ORGANIZATION IS SEQUENTIAL
           FILE STATUS IS VTO-FILE-STATUS.

       SELECT UAO-FILE
           ASSIGN TO "../output/UpdatedAccounts.dat"
           ORGANIZATION IS SEQUENTIAL
           FILE STATUS IS UAO-FILE-STATUS.

       SELECT BSM-FILE
           ASSIGN TO "../output/BatchSettlementManifest.dat"
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS BSM-FILE-STATUS.


       DATA DIVISION.
       FILE SECTION.
       FD LOG-FILE.
       01 LOG-RECORD PIC X(400).

       FD REPORT-FILE
       REPORT IS BATCH-REPORT.

       FD VTO-FILE.
       COPY DVRF.

       FD UAO-FILE.
       COPY DUAF.

       FD BSM-FILE.
       01 BSM-RECORD PIC X(150).

       WORKING-STORAGE SECTION.
       COPY WSC.
       COPY WTS.

       COPY WVRF.
       COPY WUAF.

       COPY WLOG REPLACING "PGMNAME" BY "RPTTRN".
       
       COPY WFS REPLACING ==:FNAME:== BY ==LOG==.
       COPY WFS REPLACING ==:FNAME:== BY ==REPORT==.
       COPY WFS REPLACING ==:FNAME:== BY ==VTO==.
       COPY WFS REPLACING ==:FNAME:== BY ==UAO==.
       COPY WFS REPLACING ==:FNAME:== BY ==BSM==.

       COPY WPL REPLACING ==:NAME:== BY ==TRANSACTION==.
       COPY WPL REPLACING ==:NAME:== BY ==ACCOUNT==.

       COPY WTI REPLACING ==:NAME:== BY ==TRANSACTION==.
       COPY WTI REPLACING ==:NAME:== BY ==ACCOUNT==.


       01  WS-DUMMY-TC PIC 9(4).
       01  WS-MAX-ENTRIES PIC 9(4) VALUE 1000.

      * ##     REPORT SECTION
       01  WS-R-TIMESTAMP PIC X(27).
       01  WS-R-SECTION PIC X(150).

       01  WS-J-HEADER.
        02 FILLER VALUE "H".
        02 WS-R-PROCESSED PIC 9(4).
        02 WS-R-PASSED PIC 9(4).
        02 WS-R-FAILED PIC 9(4).
        02 WS-R-ACCOUNTS-TOTAL PIC 9(4).

       01  WS-J-FOOTER.
        02 FILLER VALUE  "F".

      * ## TRANSACTION REPORT SECTION
       01  WS-J-TRANSACTION-SECTION.
        02 FILLER VALUE "S".
        02 FILLER VALUE "T".
       
       01  TRANSACTION-DETAIL.
        02 WS-D-ETE-ID PIC X(35).
        02 WS-D-STATUS PIC X(4).
        02 WS-D-SENDER PIC X(15).
        02 WS-D-RECEIVER PIC X(15).
        02 WS-D-AMOUNT PIC 9(12)V99.
        02 WS-D-REASON PIC X(55).

       01  WS-D-REASON-INPUT. 
        02 WS-D-REASON-CODE PIC 9(4).
        02 FILLER VALUE "-".
        02 WS-D-REASON-TEXT PIC X(50).

      * ## ACCOUNT REPORT SECTION
       01  WS-J-ACCOUNT-SECTION.
        02 FILLER VALUE "S".
        02 FILLER VALUE "A".

       01  ACCOUNT-DETAIL.
        02 WS-D-ACCOUNT-ID PIC X(15).
        02 WS-D-BALANCE PIC S9(12)V99.
        02 WS-D-DAILY-TOTAL PIC 9(12)V99.

       REPORT SECTION.
       RD  BATCH-REPORT
           CONTROLS ARE WS-R-SECTION
           PAGE LIMIT IS 12 LINES
           FIRST DETAIL 1.

       01  TYPE RH.
        02 LINE 1.
         03 COL 1 VALUE "====== BATCH REPORT ======".
        02 LINE 2.
         03 COL 1 VALUE "RUN-TIME".
         03 COL 23 VALUE ":".
         03 COL 26 PIC X(27) SOURCE WS-R-TIMESTAMP.
        02 LINE 3.
         03 COL 1 VALUE "TRANSACTIONS PROCESSED:".
         03 COL 26 PIC 9(4) SOURCE WS-R-PROCESSED.
         03 COL 32 VALUE "PASSED:".
         03 COL 41 PIC 9(4) SOURCE WS-R-PASSED.
         03 COL 47 VALUE "FAILED:".
         03 COL 56 PIC 9(4) SOURCE WS-R-FAILED.
        02 LINE 4.
         03 COL 1 VALUE "ACCOUNTS PROCESSED".
         03 COL 23 VALUE ":".
         03 COL 26 PIC 9(4) SOURCE WS-R-ACCOUNTS-TOTAL.

       01  TYPE CH WS-R-SECTION.
        02 LINE PLUS 1.

       01  TRANSACTION-HEADER TYPE DE.
        02 LINE PLUS 1. 
         03 COL 1 VALUE "ETE-ID".
         03 COL 38 VALUE "STATUS".
         03 COL 46 VALUE "SENDER".
         03 COL 63 VALUE "RECEIVER".
         03 COL 80 VALUE "AMOUNT".
         03 COL 96 VALUE "REASON".

       01  TRANSACTION-DE TYPE DE.
        02 LINE PLUS 1.
         03 COL 1 PIC X(35) SOURCE WS-D-ETE-ID.
         03 COL 38 PIC X(4) SOURCE WS-D-STATUS.
         03 COL 46 PIC X(15) SOURCE WS-D-SENDER.
         03 COL 63 PIC X(15) SOURCE WS-D-RECEIVER.
         03 COL 81 PIC Z(9)9.99 SOURCE WS-D-AMOUNT.
         03 COL 96 PIC X(54) SOURCE WS-D-REASON.

       01  ACCOUNT-HEADER TYPE DE.
        02 LINE PLUS 2. 
         03 COL 1 VALUE "ID".
         03 COL 18 VALUE "BALANCE".
         03 COL 34 VALUE "DAILY TOTAL".

       01  ACCOUNT-DE TYPE DE.
        02 LINE PLUS 1.
         03 COL 1 PIC X(15) SOURCE WS-D-ACCOUNT-ID.
         03 COL 18 PIC -Z(9)Z.99 SOURCE WS-D-BALANCE.
         03 COL 34 PIC Z(9)9.99 SOURCE WS-D-DAILY-TOTAL.

       01  TYPE RF.
        02 LINE PLUS 2.
         03 COL 1 VALUE "====== END REPORT ======".

       PROCEDURE DIVISION.
       MAIN.
           PERFORM LOG-START.

           PERFORM OPEN-REPORT-FILE.
           PERFORM OPEN-VTO-FILE.
           PERFORM OPEN-OPTIONALLY-UAO-FILE.
           PERFORM OPEN-BSM-FILE.

           PERFORM TIMESTAMP.
           MOVE LG-TIMESTAMP TO WS-R-TIMESTAMP.

           PERFORM TRANSACTION-PROCESS-LOOP.
           
           IF UAO-FILE-OPENED
            PERFORM ACCOUNT-PROCESS-LOOP
           END-IF.

           INITIATE BATCH-REPORT.
           WRITE BSM-RECORD FROM WS-J-HEADER.
           
           WRITE BSM-RECORD FROM WS-J-TRANSACTION-SECTION.
           GENERATE TRANSACTION-HEADER.
           PERFORM TRANSACTION-ITERATE.

           IF UAO-FILE-OPENED
            WRITE BSM-RECORD FROM WS-J-ACCOUNT-SECTION
            GENERATE ACCOUNT-HEADER
            PERFORM ACCOUNT-ITERATE
           END-IF.

           WRITE BSM-RECORD FROM WS-J-FOOTER.
           TERMINATE BATCH-REPORT.

       PERFORM CLEAN-UP.

       TRANSACTION-LOAD-RECORD.
           MOVE VTO-TRNS-STATUS TO VT-TRNS-STATUS(VT-TC)

           MOVE VTO-T-ETE-ID TO VT-T-ETE-ID(VT-TC)
           MOVE VTO-T-SNDR-ID TO VT-T-SNDR-ID(VT-TC)
           MOVE VTO-T-RCVR-ID TO VT-T-RCVR-ID(VT-TC)
           MOVE VTO-T-AMOUNT TO VT-T-AMOUNT(VT-TC)
           MOVE VTO-T-CURRENCY TO VT-T-CURRENCY(VT-TC).

           ADD 1 TO WS-R-PROCESSED.
           IF (VTO-T-SUCCESS)
            ADD 1 TO WS-R-PASSED
           ELSE
            ADD 1 TO WS-R-FAILED
       END-IF.

       ACCOUNT-LOAD-RECORD.
           MOVE UAO-ID TO UA-ID(UA-TC).
           MOVE UAO-CB TO UA-CB(UA-TC).
           MOVE UAO-DL TO UA-DL(UA-TC).
       ADD 1 TO WS-R-ACCOUNTS-TOTAL.

       TRANSACTION-HANDLE-ITERATION.
           MOVE VT-T-ETE-ID(TRANSACTION-TI-CTR) TO WS-D-ETE-ID.
           MOVE VT-T-SNDR-ID(TRANSACTION-TI-CTR) TO WS-D-SENDER.
           MOVE VT-T-RCVR-ID(TRANSACTION-TI-CTR) TO WS-D-RECEIVER.
           MOVE VT-T-AMOUNT(TRANSACTION-TI-CTR) TO WS-D-AMOUNT.
      *    MOVE VT-T-CURRENCY(TRANSACTION-TI-CTR) TO WS-D-CURRENCY.

           IF (VT-T-SUCCESS(TRANSACTION-TI-CTR))
            MOVE "ACSC" TO WS-D-STATUS
            MOVE " " TO WS-D-REASON
           ELSE
            MOVE "RJCT" TO WS-D-STATUS
            MOVE VT-TRNS-STATUS(TRANSACTION-TI-CTR) TO WS-D-REASON-CODE
            PERFORM MOVE-ERROR-REASON
           END-IF.
       PERFORM WRITE-TRANSACTION-LINE.

       ACCOUNT-HANDLE-ITERATION.
           MOVE UA-ID(ACCOUNT-TI-CTR) TO WS-D-ACCOUNT-ID.
           MOVE UA-CB(ACCOUNT-TI-CTR) TO WS-D-BALANCE.
           MOVE UA-DL(ACCOUNT-TI-CTR) TO WS-D-DAILY-TOTAL.
       PERFORM WRITE-ACCOUNT-LINE.

       ACCOUNT-HANDLE-RECORD.
       TRANSACTION-HANDLE-RECORD.

      * ##     WRITE PARAGRAPHS
      
       WRITE-TRANSACTION-LINE.
           GENERATE TRANSACTION-DE.
           PERFORM BSM-ALIVE.
       WRITE BSM-RECORD FROM TRANSACTION-DETAIL.

       WRITE-ACCOUNT-LINE.
           GENERATE ACCOUNT-DE.
           PERFORM BSM-ALIVE.
       WRITE BSM-RECORD FROM ACCOUNT-DETAIL.

      * ##     UTILITY PARAGRAPHS

       MOVE-ERROR-REASON.
           IF WS-D-REASON-CODE EQUAL ERR-ACCT-NOT-FOUND
            MOVE "ACCOUNT NOT FOUND" TO WS-D-REASON-TEXT
           ELSE IF WS-D-REASON-CODE EQUAL ERR-ACCOUNT-FROZEN
            MOVE "ACCOUNT FROZEN" TO WS-D-REASON-TEXT
           ELSE IF WS-D-REASON-CODE EQUAL ERR-ACCOUNT-CLOSED
            MOVE "ACCOUNT CLOSED" TO WS-D-REASON-TEXT
           ELSE IF WS-D-REASON-CODE EQUAL ERR-INSUFFICIENT-FUNDS
            MOVE "INSUFFICIENT FUNDS" TO WS-D-REASON-TEXT
           ELSE IF WS-D-REASON-CODE EQUAL ERR-DAILY-LIMIT-EXCEEDED
            MOVE "DAILY LIMIT EXCEEDED" TO WS-D-REASON-TEXT
           ELSE IF WS-D-REASON-CODE EQUAL ERR-UNSUPPORTED-CURRENCY
            MOVE "UNSUPORTED CURRENCY" TO WS-D-REASON-TEXT
           ELSE IF WS-D-REASON-CODE EQUAL ERR-SELF-TRANSFER
            MOVE "SAME ACCOUNT TRANSACTION" TO WS-D-REASON-TEXT
           ELSE IF WS-D-REASON-CODE EQUAL ERR-DUPLICATE-TRANSACTION
            MOVE "DUPLICATE TRANSACTION" TO WS-D-REASON-TEXT
           ELSE IF WS-D-REASON-CODE EQUAL ERR-EXTERNAL-TRANSACTION
            MOVE "EXTERNAL TRANSACTION" TO WS-D-REASON-TEXT
           END-IF.

       MOVE WS-D-REASON-INPUT TO WS-D-REASON.

       BSM-ALIVE.
           IF NOT BSM-FILE-OK
            DISPLAY "FATAL: Unable to write to"
               "BatchSettlementManifest.dat Status: " BSM-FILE-STATUS
            GOBACK
       END-IF.

       PRE-CLOSE.
           PERFORM CLOSE-REPORT-FILE.
           PERFORM CLOSE-VTO-FILE.
           PERFORM CLOSE-UAO-FILE.
       PERFORM CLOSE-BSM-FILE.

      * #        COPY BOOKS

      * ## File open/close procedures
       COPY PFT
            REPLACING ==:FNAME:== BY ==LOG==
                     ":FFILE:" BY "JOB.log"
                     ==:FMODE:== BY ==OUTPUT==
                     ==:TC:== BY ==WS-DUMMY-TC==.

       COPY PFT
            REPLACING ==:FNAME:== BY ==REPORT==
                     ":FFILE:" BY "BatchAuditTrail.report"
                     ==:FMODE:== BY ==OUTPUT==
                     ==:TC:== BY ==WS-DUMMY-TC==.

       COPY PFT
            REPLACING ==:FNAME:== BY ==VTO==
                     ":FFILE:" BY "ValidationResults.dat"
                     ==:FMODE:== BY ==INPUT==
                     ==:TC:== BY ==VTO-TC==.

       COPY PFT
            REPLACING ==:FNAME:== BY ==UAO==
                     ":FFILE:" BY "UpdatedAccounts.dat"
                     ==:FMODE:== BY ==INPUT==
                     ==:TC:== BY ==UAO-TC==.

       COPY PFT
            REPLACING ==:FNAME:== BY ==BSM==
                     ":FFILE:" BY "BatchSettlementManifest.dat"
                     ==:FMODE:== BY ==OUTPUT==
                     ==:TC:== BY ==WS-DUMMY-TC==.

      * ## File read paragraphs
       COPY PFR
            REPLACING ==:FNAME:== BY ==VTO==
                     ":FFILE:" BY "ValidationResults.dat".
       COPY PFR
            REPLACING ==:FNAME:== BY ==UAO==
                     ":FFILE:" BY "UpdatedAccounts.dat".             

      * ## Main processing loop
       COPY PPL 
               REPLACING ==:NAME:== BY ==TRANSACTION==
                         ==:AUTO:== BY ==TRUE==
                         ==:FNAME:== BY ==VTO==
                         ==:SFNAME:== BY =="ValidationResults.dat"==
                         ==:TC:== BY ==VT-TC==.
       COPY PPL 
               REPLACING ==:NAME:== BY ==ACCOUNT==
                         ==:AUTO:== BY ==TRUE==
                         ==:FNAME:== BY ==UAO==
                         ==:SFNAME:== BY =="UpdatedAccounts.dat"==
                         ==:TC:== BY ==UA-TC==.
      * ## Table iterator (validation sub-steps)
       COPY PTI 
               REPLACING ==:NAME:== BY ==TRANSACTION==
                         ==:TC:== BY ==VT-TC==.
       COPY PTI 
               REPLACING ==:NAME:== BY ==ACCOUNT==
                         ==:TC:== BY ==UA-TC==.
      * ## Helper subroutines used during validation
       COPY PLOG 
                 REPLACING ==":REASON:"== BY =="CONT"==
                           ==:LC:== BY ==R==
      * ## These won't be used, so doesn't matter.  
                           ==:TC:== BY ==VT-TC==
                           ==:ETE:== BY ==VT-T-ETE-ID==
                           ==:SAI:== BY ==VT-T-SNDR-ID==
                           ==:RAI:== BY ==VT-T-RCVR-ID==
                           ==:AMT:== BY ==VT-T-AMOUNT== 
                           ==:CUR:== BY ==VT-T-CURRENCY==. 
       COPY PTS.
       COPY PEC.
