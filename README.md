# CIPS - Canadian Interbank Payment Simulator

CIPS is a batch payment processing pipeline written in GnuCOBOL, modeled on how a Canadian financial institution actually settles interbank payments overnight. It takes a batch of transaction requests, validates every item against a set of account rules, posts the ones that pass, and produces a full settlement report and audit trail, regardless of how many items succeeded or failed.

This is not a toy exercise in COBOL syntax. It is a working simulation of the kind of nightly batch job that runs inside real payment rails like ACSS, built from the ground up to behave the way production COBOL behaves: strict file layouts, return code contracts between steps, and a run that never halts just because one transaction in the batch was bad.

## Why this exists

Canada's financial sector still runs a large share of its core infrastructure on COBOL, and it's a language fewer people are learning every year while the systems built on it keep running. I got interested in that gap and wanted to actually build something inside it rather than just read about the syntax.

CIPS started from that. Instead of working through isolated exercises, I picked a real process, a Canadian interbank settlement batch, and built it with the same constraints that process would actually run under: fixed-width files, exact column positions, return codes that carry real meaning between steps, and a batch job that keeps going when part of it fails instead of stopping the whole run.

## How the pipeline works

A batch run is three programs, executed in strict sequence, each one reading the output of the last:

**ValidateTransactions** reads the account snapshot and the incoming batch of transactions, sorts the batch by timestamp, flags in-batch duplicate end-to-end IDs, then runs each transaction through a full validation chain: sender and receiver account status, sufficient funds, supported currency, and daily spending limit. Every pass or fail is written out with a reason code, and in-memory balances are updated as it goes so a second transaction in the same batch against the same account sees the correct running total.

**PostTransactions** reads those validation results and posts every transaction that passed. Anything that failed validation is skipped and logged as skipped, without stopping the run. Sender and receiver balances are recalculated and every account touched by the batch gets its final state written out for the next step.

**ReportTransactions** always runs, no matter what happened in the two steps before it. It reads the validation results and the updated account file, and produces two outputs at once: a formatted, human-readable settlement report built with COBOL's Report Writer, and a structured settlement manifest meant to be consumed downstream by a Java middleware for generating pacs.002 response messages and updating an account database.

That last point matters more than it might look. A batch job that silently stops because one program failed is a batch job nobody would trust with real money. CIPS is built so the reporting step is unconditional, the same way a real settlement job has to close out and report on the batch whether every item cleared or not.

## Output files

Every run produces the following inside `output/`:

- `BatchAuditTrail.report`: the formatted report of the whole run, generated with Report Writer
- `BatchSettlementManifest.dat`: structured output built for the Java middleware to generate pacs.002 responses and update account balances
- `JOB.log`: a complete log of every step and change across all three programs
- `ValidationResults.dat`: validation state handed from ValidateTransactions to PostTransactions
- `UpdatedAccounts.dat`: final account state handed from PostTransactions to ReportTransactions

## Running it

From inside `cobol/`:

```
./submit_batch
```

This compiles all three programs, runs them in sequence, and writes every output file above into `output/`. Nothing needs to be run individually. The script is the whole job.

## Some of the design decisions

The account and transaction files are fixed-width, no delimiters, implied decimals, the same layout constraints you'd hit on an actual mainframe job. The three programs pass state between each other through flat files and return codes rather than shared memory, because that is how COBOL batch steps actually communicate in a JCL-style job stream. PostTransactions never halts on a failed item, it just skips it and keeps going, because a single bad transaction should never take down an entire settlement batch. And ReportTransactions runs unconditionally, independent of whether PostTransactions had anything to post, because a settlement job that doesn't report is worse than one that reports failures.

The copybook layer underneath all three programs is built around reusable, parameterized patterns rather than copy-pasted logic. File open and close handling, table iteration, account lookups, and logging are all shared copybooks referenced with `COPY REPLACING`, so adding a fourth program to this pipeline means writing new business logic, not rebuilding file handling from scratch.

## What's next

The COBOL core is functionally complete. The next phase is a Spring Boot middleware that parses incoming pacs.008 messages, writes them into the exact flat file format this pipeline expects, invokes `submit_batch`, and reads the resulting settlement manifest to generate pacs.002 responses and update a real account database. After that, a REST API and a small frontend will sit on top, so a full transaction, from XML in to settlement response out, can be triggered and watched end to end.

The goal is a complete, working simulation of a Canadian interbank settlement pipeline, from the mainframe-style batch core all the way to a modern API in front of it. The COBOL side already proves the hardest part works.