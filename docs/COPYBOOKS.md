## TOOLS

### STATUS CODES
*NAMING CONVETION: {divisionLetter} <u>S</u>tatus <u>C</u>odes*

- [WORKING STORAGE DIVISION](../cobol/cpy/WSC.cpy)

### TIMESTAMP
*NAMING CONVETION: {divisionLetter} <u>T</u>ime <u>S</u>tamp*

- [WORKING STORAGE DIVISION](../cobol/cpy/WTS.cpy)
- [PROCEDURE DIVISION](../cobol/cpy/PTS.cpy)

### LOGGING
*NAMING CONVETION: {divisionLetter} <u>Log</u>ging*

- [WORKING STORAGE DIVISION](../cobol/cpy/WLOG.cpy)
- [PROCEDURE DIVISION](../cobol/cpy/PLOG.cpy)

### ACCOUNT FINDER
*NAMING CONVETION: {divisionLetter} <u>A</u>ccount <u>F</u>inder*

- [WORKING STORAGE DIVISION](../cobol/cpy/WAF.cpy)
- [PROCEDURE DIVISION](../cobol/cpy/PAF.cpy)

### FILE PROCCESS LOOPER
*NAMING CONVETION: {divisionLetter} <u>P</u>roccess <u>L</u>oop*

- [WORKING STORAGE DIVISION](../cobol/cpy/WPL.cpy)
- [PROCEDURE DIVISION](../cobol/cpy/PPL.cpy)

### TABLE ITTERATOR
*NAMING CONVETION: {divisionLetter} Proccess <u>T</u>ransactions <u>L</u>oop*

- [WORKING STORAGE DIVISION](../cobol/cpy/WTI.cpy)
- [PROCEDURE DIVISION](../cobol/cpy/PTI.cpy)

### ESSENTIAL CLEANUP
*NAMING CONVETION: {divisionLetter} <u>E</u>ssential <u>C</u>lean-Up*

- [PROCEDURE DIVISION](../cobol/cpy/PEC.cpy)

## FILE IO

### STATUS
*NAMING CONVETION: {divisionLetter} <u>F</u>ile <u>S</u>tructure*

- [WORKING STORAGE DIVISION](../cobol/cpy/WFS.cpy)

### OPEN & CLOSE
*NAMING CONVETION: {divisionLetter} <u>F</u>ile <u>T</u>oggle*

- [PROCEDURE DIVISION](../cobol/cpy/PFT.cpy)

### READ
*NAMING CONVETION: {divisionLetter} <u>F</u>ile <u>R</u>eader*

- [PROCEDURE DIVISION](../cobol/cpy/PFR.cpy)

## FILES

### [ACCOUNTS](../cobol/data/Accounts.dat)
*NAMING CONVETION: {divisionLetter} <u>Acc</u>oun<u>t</u>*

- [DATA DIVISION](../cobol/cpy/DACCT.cpy)
- [WORKING STORAGE DIVISION (table)](../cobol/cpy/WACCT.cpy)

### [TRANSACTIONS](../data/Transactions.dat)
*NAMING CONVETION: {divisionLetter} <u>Tran</u>sactions*

- [DATA DIVISION](../cobol/cpy/DTRAN.cpy)
- [WORKING STORAGE DIVISION (table)](../cobol/cpy/WTRAN.cpy)

### [ValidationResults](../output/ValidationResults.dat)
*NAMING CONVETION: {divisionLetter} <u>V</u>alidation <u>R</u>esults <u>F</u>ile*

- [DATA DIVISION](../cobol/cpy/DVRF.cpy)
- [WORKING STORAGE DIVISION (table)](../cobol/cpy/WVRF.cpy)
- [PROCEDURE DIVISION (write file)](../cobol/cpy/PVRF.cpy)

### [UpdatedAccounts](../output/UpdatedAccounts.dat)
*NAMING CONVETION: {divisionLetter} <u>U</u>pdated <u>A</u>ccounts <u>F</u>ile*

- [DATA DIVISION](../cobol/cpy/DUAF.cpy)
- [WORKING STORAGE DIVISION (table)](../cobol/cpy/WUAF.cpy)
- [PROCEDURE DIVISION (write file)](../cobol/cpy/PUAF.cpy)