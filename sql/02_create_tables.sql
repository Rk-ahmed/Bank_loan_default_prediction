USE BankLoanDefault;
GO

CREATE TABLE dbo.Customer (
    customer_id INT PRIMARY KEY,
    age INT NOT NULL,
    gender VARCHAR(20),
    marital_status VARCHAR(30),
    education VARCHAR(50),
    employment_type VARCHAR(50),
    monthly_income DECIMAL(12,2),
    credit_score INT
);
GO

CREATE TABLE dbo.Loan (
    loan_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    loan_type VARCHAR(50),
    loan_amount DECIMAL(14,2),
    interest_rate DECIMAL(5,2),
    loan_term_months INT,
    application_date DATE,
    default_flag BIT NOT NULL,
    CONSTRAINT FK_Loan_Customer FOREIGN KEY (customer_id) REFERENCES dbo.Customer(customer_id)
);
GO

CREATE TABLE dbo.Loan_Payment (
    payment_id INT PRIMARY KEY,
    loan_id INT NOT NULL,
    payment_date DATE,
    payment_amount DECIMAL(14,2),
    days_past_due INT DEFAULT 0,
    CONSTRAINT FK_LoanPayment_Loan FOREIGN KEY (loan_id) REFERENCES dbo.Loan(loan_id)
);
GO
