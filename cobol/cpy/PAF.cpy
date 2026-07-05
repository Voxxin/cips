      *================================================================*
      * PAF.cpy                                                        *
      *================================================================*

      * --  Resolves sender and receiver accounts from Accounts.dat
      * -- > Uses AT-LOOKUP to find each account in the loaded table.
      * -- > Sets WS-SENDER-IDX / WS-RECEIVER-IDX for VALIDATE-TRANSACTION.

       RESOLVE-ACCOUNTS.
           MOVE :ETE:(:TC:) TO
            LGTE-TRANSACTION
            LGV-TRANSACTION.

      * --       FIND SENDER
           MOVE :SAI:(:TC:)
            TO AT-LOOKUP-KEY.

           PERFORM AT-LOOKUP.

           EVALUATE TRUE
           WHEN AT-LOOKUP-RESULT-EMPTY
            MOVE :SAI:(:TC:)
             TO LGTE-ACCOUNT
            MOVE ERR-ACCT-NOT-FOUND TO LG-STATUS-CODE
            MOVE 'MSG=SENDER ACCOUNT NOT FOUND' TO LG-TEXT
            PERFORM LOGGING-WARN
            ADD 1 TO LG-TRAN-FAILED
            EXIT PARAGRAPH

           WHEN OTHER
            MOVE AT-LOOKUP-RESULT-IDX TO WS-SENDER-IDX
            MOVE INFO-ACCT-FOUND TO LG-STATUS-CODE
            MOVE :SAI:(:TC:)
             TO LGV-ACCOUNT
            MOVE 'MSG=SENDER ACCOUNT FOUND' TO LG-TEXT
            PERFORM LOGGING-VALIDATION

           END-EVALUATE.

      * --       FIND RECEIVER
           MOVE :RAI:(:TC:)
            TO AT-LOOKUP-KEY.

           PERFORM AT-LOOKUP.

           EVALUATE TRUE
           WHEN AT-LOOKUP-RESULT-EMPTY
            MOVE :RAI:(:TC:)
             TO LGTE-ACCOUNT
            MOVE ERR-ACCT-NOT-FOUND TO LG-STATUS-CODE
            MOVE 'MSG=RECEIVER ACCOUNT NOT FOUND' TO LG-TEXT
            PERFORM LOGGING-WARN
            ADD 1 TO LG-TRAN-FAILED
            EXIT PARAGRAPH

           WHEN OTHER
            MOVE AT-LOOKUP-RESULT-IDX TO WS-RECEIVER-IDX
            MOVE INFO-ACCT-FOUND TO LG-STATUS-CODE
            MOVE :RAI:(:TC:)
             TO LGV-ACCOUNT
            MOVE 'MSG=RECEIVER ACCOUNT FOUND' TO LG-TEXT
            PERFORM LOGGING-VALIDATION

       END-EVALUATE.      
      
       AT-LOOKUP.
      * --     RESET EXISITNG VALUES
           SET AT-LOOKUP-RESULT-EMPTY TO TRUE.
           SET AT-LOOKUP-PL-NOT-DONE TO TRUE.
           MOVE ZERO TO AT-LOOKUP-RESULT-IDX.
      * --

      * --     TRYING TO FIND EXISITNG ACCOUNT SECTION
           PERFORM AT-LOOKUP-ITERATE.

           IF NOT AT-LOOKUP-RESULT-EMPTY
            EXIT PARAGRAPH
           END-IF.

      * --     TRYING TO FIND NEW ACCOUNT SECTION
           IF ACCT-FILE-EOF
            EXIT PARAGRAPH
           END-IF.

       PERFORM AT-LOOKUP-PROCESS-LOOP.

       AT-LOOKUP-HANDLE-ITERATION.
           IF AT-ACCOUNT-ID(AT-LOOKUP-TI-CTR) = AT-LOOKUP-KEY
            MOVE AT-LOOKUP-TI-CTR TO AT-LOOKUP-RESULT-IDX
            SET AT-LOOKUP-TI-DONE TO TRUE
       END-IF.

       COPY PTI 
            REPLACING ==:NAME:== BY ==AT-LOOKUP==
                      ==:TC:== BY ==AT-TC==.

       AT-LOOKUP-LOAD-RECORD.
           MOVE ACC-ID TO AT-ACCOUNT-ID(AT-TC).
           MOVE ACC-HOLDER-NAME TO AT-HOLDER-NAME(AT-TC).
           MOVE ACC-CURRENT-BALANCE TO AT-BALANCE(AT-TC).
           MOVE ACC-DAILY-LIMIT TO AT-DAILY-LIMIT(AT-TC).
           MOVE ACC-DAILY-SPENT TO AT-DAILY-SPENT(AT-TC).
       MOVE ACC-STATUS TO AT-STATUS(AT-TC).

       AT-LOOKUP-HANDLE-RECORD.
           IF AT-ACCOUNT-ID(AT-TC) = AT-LOOKUP-KEY
            MOVE AT-TC TO AT-LOOKUP-RESULT-IDX
            SET AT-LOOKUP-PL-DONE TO TRUE
       END-IF.
      
       COPY PPL
                 REPLACING ==:SFNAME:== BY =="Accounts.dat"==
                           ==:NAME:== BY ==AT-LOOKUP==
                           ==:AUTO:== BY ==FALSE==
                           ==:FNAME:== BY ==ACCT==
                           ==:TC:== BY ==AT-TC==.
