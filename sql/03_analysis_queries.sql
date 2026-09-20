USE BankLoanDefault;
GO

SELECT COUNT(*) AS customer_count FROM dbo.Customer;
SELECT COUNT(*) AS loan_count FROM dbo.Loan;

SELECT default_flag, COUNT(*) AS loan_count,
       CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(6,2)) AS default_rate_pct
FROM dbo.Loan
GROUP BY default_flag;

SELECT loan_type,
       COUNT(*) AS loan_count,
       SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
       CAST(SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(6,2)) AS default_rate_pct
FROM dbo.Loan
GROUP BY loan_type
ORDER BY default_rate_pct DESC;
