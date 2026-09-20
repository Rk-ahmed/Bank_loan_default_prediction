# Bank Loan Default Prediction

An end-to-end banking analytics and machine learning project for predicting the probability that a borrower will default on a loan.

## Project Objective

Build a practical loan-risk prediction workflow using SQL, R, Shiny, and GitHub.

## Business Problem

A bank wants to identify borrowers who may have a higher probability of defaulting on a loan. The solution will use borrower and loan characteristics to estimate default probability and present the result through an interactive Shiny application.

## Core Business Questions

1. What borrower and loan characteristics are associated with loan default?
2. Which customer segments have higher observed default rates?
3. What is the estimated probability of default for a new loan application?
4. Which factors contribute most to the model's prediction?
5. How well does the model distinguish between default and non-default cases?

## Target Variable

`default_flag`

- `0` = No Default
- `1` = Default

## Technology Stack

| Layer | Technology |
|---|---|
| Data generation | R |
| Database | SQL Server |
| Data analysis | SQL + R |
| Machine learning | R |
| Web application | Shiny |
| Version control | Git / GitHub |

## Project Structure

- `data/raw/` — generated raw data
- `data/processed/` — model-ready data
- `sql/` — database and analysis scripts
- `R/` — data generation, preparation, modeling, evaluation
- `model/` — trained model artifacts
- `shiny/` — Shiny application
- `reports/` — project reports

## Project Phases

1. Business definition and data design
2. Synthetic banking data generation
3. SQL database creation and analysis
4. R data preparation and feature engineering
5. Loan-default classification model
6. Model evaluation and interpretation
7. Shiny application
8. GitHub documentation
9. Deployment

## Important Note

This project uses synthetic data for learning and portfolio purposes. It is not intended for real-world credit decisions.
