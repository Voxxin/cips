# INTERNAL STATUS CODES

## SYSTEM & FILE CONTROL (0000-0019)
- `0000` - Transaction Approved / Success
- `0001` - Program Started
- `0002` - Program Closed
- `0010` - File Opened
- `0011` - File Start Reading
- `0012` - File Stop Reading
- `0013` - File Closed

## TRANSACTION LIFECYCLE (0020-0029)
- `0020` - Transaction Started
- `0021` - Transaction Closed
- `0022` - Transaction Skipped

## VALIDATION PASSES (0030-0039)
- `0030` - Account Status Check Passed
- `0031` - Beneficiary Account Status Check Passed
- `0032` - Funds Check Passed
- `0033` - Currency Check Passed
- `0034` - Daily Limit Check Passed
- `0035` - Sender Account Found
- `0036` - Receiver Account Found
- `0037` - Sender Account External
- `0038` - Receiver Account External

## POSTING/UPDATE EVENTS (0040-0050)
- `0040` - Sender Account Updated
- `0041` - Receiver Account Updated

## CRITICAL / I/O ERRORS (0900-0999)
- `0901` - File Open Error
- `0902` - File Read Error
- `0903` - File Empty
- `0904` - File Mismatch
- `0905` - Attempted to read closed file
- `0906` - Attempted to close unopened file
- `0907` - Attempted to reopen a open file
- `0908` - Read-file overflow entries

## ACCOUNT STATUS ERRORS (1000-1019)
- `1001` - Account Not Found
- `1002` - Account Frozen
- `1003` - Account Closed
- `1004` - Account Expired
- `1005` - Account On Hold
- `1006` - Invalid Account Type
- `1007` - Account Dormant
- `1010` - Sender Account Mismatch
- `1011` - Receiver Account Mismatch
- `1012` - Self-Transfer Not Allowed

## FUNDS & LIMIT ERRORS (1020-1039)
- `1020` - Insufficient Funds
- `1021` - Amount Below Minimum
- `1022` - Amount Exceeds Maximum
- `1030` - Daily Limit Exceeded
- `1031` - Daily Transaction Count Limit Exceeded
- `1032` - Weekly Limit Exceeded
- `1033` - Monthly Limit Exceeded

## CURRENCY & ROUTING ERRORS (1040-1079)
- `1040` - Invalid Currency
- `1041` - Currency Mismatch
- `1042` - Unsupported Currency
- `1043` - Exchange Rate Unavailable
- `1050` - Duplicate Transaction
- `1051` - Cutoff Time Passed
- `1052` - System Downtime
- `1053` - Invalid Reference Number
- `1060` - Invalid PIN
- `1061` - Missing Authorization Code
- `1070` - Invalid Routing Number
- `1071` - Transaction External to System