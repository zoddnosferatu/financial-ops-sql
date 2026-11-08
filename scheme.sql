-- -----------------------------------------------------------------
-- trade operations setup script (local testing sandbox)
-- hamza - 2026
-- -----------------------------------------------------------------

-- drop tables if re-running script to keep env clean
DROP TABLE IF EXISTS settlements;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS instruments;

-- tables for basic order routing analytics
CREATE TABLE instruments (
    instrument_id VARCHAR(10) PRIMARY KEY,
    ticker VARCHAR(12) NOT NULL,
    asset_class VARCHAR(15) CHECK (asset_class IN ('EQUITY', 'FX', 'COMMODITY', 'DIGITAL_ASSET')),
    base_currency VARCHAR(3) DEFAULT 'USD'
);

CREATE TABLE orders (
    order_id VARCHAR(12) PRIMARY KEY,
    instrument_id VARCHAR(10) REFERENCES instruments(instrument_id),
    side VARCHAR(4) CHECK (side IN ('BUY', 'SELL')),
    quantity DECIMAL(18, 4) NOT NULL,
    target_price DECIMAL(18, 4) NOT NULL,
    order_status VARCHAR(12) CHECK (order_status IN ('PENDING', 'FILLED', 'REJECTED'))
);

-- ledger for tracking post-trade fails and clearing anomalies
CREATE TABLE settlements (
    settlement_id VARCHAR(12) PRIMARY KEY,
    order_id VARCHAR(12) REFERENCES orders(order_id),
    execution_price DECIMAL(18, 4) NOT NULL,
    execution_quantity DECIMAL(18, 4) NOT NULL,
    settlement_date DATE NOT NULL,
    clearing_status VARCHAR(12) CHECK (clearing_status IN ('SETTLED', 'FAILED', 'UNMATCHED')),
    sla_hours_elapsed INT DEFAULT 0
);

-- -----------------------------------------------------------------
-- populating mock transactions & testing boundary conditions (breaks)
-- -----------------------------------------------------------------

INSERT INTO instruments VALUES ('INST-01', 'BTC-USD', 'DIGITAL_ASSET', 'USD');
INSERT INTO instruments VALUES ('INST-02', 'ETH-USD', 'DIGITAL_ASSET', 'USD');
INSERT INTO instruments VALUES ('INST-03', 'AAPL',    'EQUITY',        'USD');

-- normal matched transaction
INSERT INTO orders VALUES ('ORD-99001', 'INST-01', 'BUY', 1.5000, 95000.00, 'FILLED');
INSERT INTO settlements VALUES ('SET-001', 'ORD-99001', 95000.00, 1.5000, '2026-11-06', 'SETTLED', 12);

-- price variance break (slippage check)
INSERT INTO orders VALUES ('ORD-99002', 'INST-01', 'BUY', 0.5000, 95200.00, 'FILLED');
INSERT INTO settlements VALUES ('SET-002', 'ORD-99002', 95450.00, 0.5000, '2026-11-07', 'SETTLED', 24);

-- partial fill mismatch (quantity tracking fail)
INSERT INTO orders VALUES ('ORD-99003', 'INST-03', 'SELL', 100.0000, 180.00, 'FILLED');
INSERT INTO settlements VALUES ('SET-003', 'ORD-99003', 180.00, 75.0000, '2026-11-07', 'UNMATCHED', 48);

-- hard settlement fail (sla threshold validation)
INSERT INTO orders VALUES ('ORD-99004', 'INST-02', 'BUY', 10.0000, 2700.00, 'FILLED');
INSERT INTO settlements VALUES ('SET-004', 'ORD-99004', 2700.00, 10.0000, '2026-11-02', 'FAILED', 144);
