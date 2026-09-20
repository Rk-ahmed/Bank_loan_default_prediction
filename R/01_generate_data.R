# Bank Loan Default Prediction
# Step 1: Generate synthetic banking data

set.seed(2026)

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
})

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

n_customers <- 10000
n_loans <- 15000

# 1. Customer data
customers <- tibble(
  customer_id = 1:n_customers,
  age = sample(21:70, n_customers, replace = TRUE),
  gender = sample(c("Male", "Female"), n_customers, replace = TRUE, prob = c(0.62, 0.38)),
  marital_status = sample(c("Single", "Married", "Divorced", "Widowed"), n_customers, replace = TRUE, prob = c(0.32, 0.56, 0.08, 0.04)),
  education = sample(c("High School", "Diploma", "Bachelor", "Master", "Other"), n_customers, replace = TRUE, prob = c(0.18, 0.17, 0.40, 0.20, 0.05)),
  employment_type = sample(c("Salaried", "Self-Employed", "Business", "Contract", "Unemployed"), n_customers, replace = TRUE, prob = c(0.48, 0.18, 0.20, 0.09, 0.05)),
  monthly_income = round(pmax(12000, rlnorm(n_customers, log(65000), 0.55)), 2)
)

customers <- customers %>%
  mutate(
    credit_score = round(pmin(850, pmax(300,
      580 + 0.0008 * monthly_income +
      if_else(employment_type == "Salaried", 35, 0) +
      if_else(employment_type == "Unemployed", -70, 0) +
      rnorm(n_customers, 0, 55)
    )))
  )

# 2. Loan data
loans <- tibble(
  loan_id = 1:n_loans,
  customer_id = sample(customers$customer_id, n_loans, replace = TRUE),
  loan_type = sample(c("Personal", "Auto", "Home", "Education", "Business"), n_loans, replace = TRUE, prob = c(0.38, 0.20, 0.12, 0.10, 0.20)),
  application_date = sample(seq(as.Date("2023-01-01"), as.Date("2025-12-31"), by = "day"), n_loans, replace = TRUE)
) %>%
  left_join(customers %>% select(customer_id, monthly_income, credit_score, employment_type), by = "customer_id") %>%
  mutate(
    loan_amount = round(pmax(10000, monthly_income * runif(n(), min = if_else(loan_type == "Home", 8, 1.5), max = if_else(loan_type == "Home", 30, 12))), 2),
    loan_term_months = case_when(
      loan_type == "Personal" ~ sample(c(12, 24, 36, 48, 60), n(), replace = TRUE),
      loan_type == "Auto" ~ sample(c(24, 36, 48, 60, 72), n(), replace = TRUE),
      loan_type == "Home" ~ sample(c(120, 180, 240, 300), n(), replace = TRUE),
      loan_type == "Education" ~ sample(c(24, 36, 48, 60), n(), replace = TRUE),
      loan_type == "Business" ~ sample(c(24, 36, 48, 60, 84), n(), replace = TRUE)
    ),
    interest_rate = round(pmax(4, pmin(24,
      10 - (credit_score - 650) * 0.012 +
      if_else(loan_type == "Personal", 1.5, 0) +
      if_else(loan_type == "Business", 1, 0) +
      rnorm(n(), 0, 1.3)
    )), 2)
  )

# 3. Historical risk variables available around loan origination
loans <- loans %>%
  mutate(
    existing_loan_count = rpois(n(), lambda = pmin(3.5, pmax(0.3, monthly_income / 90000))),
    previous_late_payments = pmin(rpois(n(), lambda = pmax(0.15, 1.4 - (credit_score - 550) / 250)), 8),
    debt_to_income_ratio = round(pmin(0.85, pmax(0.05,
      0.12 + existing_loan_count * 0.06 + previous_late_payments * 0.025 + rnorm(n(), 0, 0.07)
    )), 3),
    loan_to_income_ratio = round(loan_amount / (monthly_income * 12), 3)
  )

# 4. Generate synthetic default probability
risk_score <- with(loans,
  -3.7 +
  0.010 * (650 - credit_score) +
  2.6 * debt_to_income_ratio +
  0.35 * previous_late_payments +
  0.18 * existing_loan_count +
  0.06 * (interest_rate - 10) +
  0.035 * pmax(0, loan_to_income_ratio - 0.5) * 10 +
  ifelse(employment_type == "Unemployed", 0.9, 0) +
  ifelse(loan_type == "Personal", 0.15, 0) +
  ifelse(loan_type == "Business", 0.10, 0) +
  rnorm(nrow(loans), 0, 0.35)
)

default_probability <- plogis(risk_score)

loans <- loans %>%
  mutate(
    default_probability = round(default_probability, 4),
    default_flag = rbinom(n(), 1, default_probability)
  ) %>%
  select(loan_id, customer_id, loan_type, loan_amount, interest_rate, loan_term_months,
         application_date, existing_loan_count, previous_late_payments,
         debt_to_income_ratio, loan_to_income_ratio, default_probability, default_flag)

# 5. Payment history
payment_counts <- sample(4:12, n_loans, replace = TRUE)

loan_payments <- tibble(loan_id = loans$loan_id, payment_count = payment_counts) %>%
  tidyr::uncount(payment_count, .id = "payment_number") %>%
  left_join(loans %>% select(loan_id, loan_amount, loan_term_months, application_date, default_flag), by = "loan_id") %>%
  mutate(
    payment_id = row_number(),
    payment_date = application_date + sample(30:900, n(), replace = TRUE),
    payment_amount = round(pmax(500, loan_amount / loan_term_months * runif(n(), 0.85, 1.15)), 2),
    days_past_due = if_else(
      default_flag == 1,
      sample(c(0, 5, 15, 30, 60, 90), n(), replace = TRUE, prob = c(0.15, 0.10, 0.12, 0.20, 0.23, 0.20)),
      sample(c(0, 0, 0, 5, 10, 15), n(), replace = TRUE)
    )
  ) %>%
  select(payment_id, loan_id, payment_date, payment_amount, days_past_due)

# 6. Export
write_csv(customers, "data/raw/customers.csv")
write_csv(loans, "data/raw/loans.csv")
write_csv(loan_payments, "data/raw/loan_payments.csv")

# 7. Basic validation
cat("Customers:", nrow(customers), "\n")
cat("Loans:", nrow(loans), "\n")
cat("Payments:", nrow(loan_payments), "\n")
cat("Default rate:", round(mean(loans$default_flag) * 100, 2), "%\n")
cat("Average credit score:", round(mean(customers$credit_score), 1), "\n")
cat("Average loan amount:", round(mean(loans$loan_amount), 2), "\n")

print(
  loans %>%
    group_by(default_flag) %>%
    summarise(
      loans = n(),
      avg_loan_amount = mean(loan_amount),
      avg_dti = mean(debt_to_income_ratio),
      avg_late_payments = mean(previous_late_payments),
      .groups = "drop"
    )
)
