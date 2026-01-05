# Library Management System Database

## 📌 Project Overview
This project is a comprehensive relational database solution designed to manage the core operations of a modern library. It handles the management of **books** (including e-books and audiobooks), **readers**, **loans**, **reservations**, and library **staff**.

The system is built using **Microsoft SQL Server (T-SQL)** and demonstrates advanced database development concepts, including strict data normalization, declarative integrity, and procedural logic.

## 🚀 Key Features

### 1. Database Design & Architecture
* **Normalization:** The schema is fully normalized up to the **Third Normal Form (3NF)** to ensure data consistency and eliminate redundancy.
* **Entities:** Manages core entities: `Biblioteka` (Library), `Czytelnik` (Reader), `Ksiazka` (Book), `Wypozyczenie` (Loan), and `Rezerwacja` (Reservation).

### 2. Data Integrity & Validation
The project uses robust constraints and triggers to ensure data quality:
* **Constraints:**
    * `CHECK` constraints for validating **PESEL** (11 digits) and **ISBN** (13 digits) formats.
    * Date validation to prevent registration dates in the future.
* **Triggers:**
    * `TRG_Wypozyczenie_Termin`: Ensures the book return deadline is strictly later than the loan date.
    * `TRG_Rezerwacja_Data`: Prevents reservations from being made for past dates.

### 3. Programmability (Stored Procedures)
The system abstracts CRUD operations through parameterized Stored Procedures, including:
* **User Management:** `DodajCzytelnika`, `DezaktywujCzytelnika`.
* **Loan Lifecycle:**
    * `ZarejestrujWypozyczenie`: Validates availability and creates a loan record.
    * `ZarejestrujZwrot`: Processes returns and automatically updates the book status back to 'Available' ('Dostępna').

### 4. Security & Administration
* **Role-Based Access Control (RBAC):** Implements specific roles:
    * `Rola_Bibliotekarza`: Permissions for day-to-day operations (SELECT, INSERT, UPDATE).
    * `Rola_Administratora`: Full database control.
* **Backup Strategy:** Scripts included for Full, Differential, and Transaction Log backups to ensure data durability.

## 📂 Repository Contents

* `script.sql` - The complete T-SQL source code containing the schema, constraints, triggers, and stored procedures.
* `biblioteka.bacpac` - A Data-Tier Application package file containing both the schema and sample data for quick deployment.
* `README.md` - Project documentation.

## ⚙️ How to Run

You have two options to set up the database:

### Option 1: Using the Source Script (Recommended for Code Review)
1.  Open **SQL Server Management Studio (SSMS)**.
2.  Create a new empty database named `Biblioteka`.
3.  Open `script.sql` from this repository.
4.  Execute the script to build the structure and populate initial data.

### Option 2: Using the BACPAC File (Quick Deploy)
1.  Open SSMS.
2.  Right-click on **Databases** > **Import Data-tier Application**.
3.  Select the `biblioteka.bacpac` file included in this repo.
4.  Follow the wizard to deploy the full database with data.

## 🛠️ Technology Stack
* **Database Engine:** Microsoft SQL Server 2022
* **Language:** T-SQL
* **Tools:** SQL Server Management Studio (SSMS)

## 👥 Authors
Project based on the documentation "Projekt Bazy Danych - Biblioteka".
* Graf
* Lesyk
* Herasymenko
