# PAN Card Validation in SQL | Data Cleaning & Validation Project

## 📌 Project Overview
This project focuses on **cleaning and validating PAN card numbers** using SQL.  
PAN (Permanent Account Number) in India follows a strict format: **5 letters + 4 digits + 1 letter** (e.g., `ABCDE1234F`).  
The dataset contained ~1,800 raw PAN records with issues like invalid formats, duplicates, sequential patterns, and incorrect characters.  

The goal was to build a **robust SQL validation pipeline** to standardize, clean, and validate these records for real-world usage in financial systems.

---

## 🛠️ Key Features
- **Format Validation** – Ensured PAN matches the official structure: `[A-Z]{5}[0-9]{4}[A-Z]`.
- **Data Cleaning** – Removed nulls, blanks, and unwanted characters using `TRIM`, `UPPER`, and `REGEXP_REPLACE`.
- **Quality Rules Applied**:
  - Excluded **sequential alphabets** (e.g., `ABCDE1234F`).
  - Excluded **sequential digits** (e.g., `ABCD1234E` with `1234`).
  - Prevented **triple adjacent duplicates** in letters or digits.
  - Validated **4th character type code** against allowed PAN holder categories.
- **Deduplication** – Selected only distinct, valid PANs from the dataset.
- **Cross-platform** – Queries tested in **PostgreSQL** and **BigQuery**.

---

## 📂 Dataset
- **Input:** 3000 raw PAN records (with noise, duplicates, and invalid entries).  
- **Output:** ~1,200 cleaned and validated PAN records ready for downstream financial applications.  

---


