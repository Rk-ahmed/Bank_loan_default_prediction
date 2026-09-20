-- Bank Loan Default Prediction
-- Database initialization

IF DB_ID('BankLoanDefault') IS NULL
BEGIN
    CREATE DATABASE BankLoanDefault;
END;
GO

USE BankLoanDefault;
GO
