-- -----------------------------------------------------------------
-- core audit queries for isolating ledger breaks
-- -----------------------------------------------------------------

-- query 1: locate price slippage and quantity mismatch exceptions
SELECT 
    s.settlement_id,
    o.order_id,
    i.ticker,
    o.side,
    (o.target_price - s.execution_price) AS price_slippage,
    (o.quantity - s.execution_quantity) AS quantity_discrepancy,
    s.clearing_status
FROM settlements s
JOIN orders o ON s.order_id = o.order_id
JOIN instruments i ON o.instrument_id = i.instrument_id
WHERE o.target_price != s.execution_price 
   OR o.quantity != s.execution_quantity;


-- query 2: track aging fails breaching 24h operational SLAs
SELECT 
    order_id,
    settlement_id,
    settlement_date,
    sla_hours_elapsed
FROM settlements
WHERE clearing_status = 'FAILED' 
  AND sla_hours_elapsed > 24
ORDER BY sla_hours_elapsed DESC;
