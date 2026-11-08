# Multi-Asset Trade Reconciliation & Operational Audit System

A lightweight relational database pipeline built to audit post-trade execution metrics, identify transactional data breaks, and capture clearing lifecycle exceptions. 

## Project Objective
In institutional middle offices, execution datasets from internal order management systems (OMS) must match clearing log registries. Discrepancies (price slippage, partial execution matching, or clearing system timeouts) introduce systemic risk. This project replicates production ledger architecture to run diagnostic validations across digital assets and equities.

## Relational Architecture
- `instruments`: Multi-asset static data parameters.
- `orders`: Front-office execution intent logs.
- `settlements`: Post-trade clearing and transaction lifecycles.

## Core Operational Audits Executed
1. **Price & Volume Integrity Checks:** Compares target intent variables with actual clearing execution parameters to highlight transaction variances.
2. **SLA Aging Analysis:** Isolates processing blockages that violate standard 24-hour turnaround thresholds.

## Technical Execution & AI Framework Note
The fundamental database tables and structural relational dependencies were built utilizing generative AI design scaffolding to fast-track schema setup. All individual analytical data queries, verification scenarios, and financial boundary breaks were explicitly configured and validated manually to ensure real-world middle-office application accuracy.
