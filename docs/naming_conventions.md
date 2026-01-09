Naming Conventions

This document describes the standard naming conventions followed in the data warehouse project. The objective of these conventions is to maintain consistency, improve readability, and ensure long-term maintainability across all database objects such as schemas, tables, columns, and stored procedures.

General Principles

All database object names must follow the snake_case naming style, using only lowercase letters and underscores to separate words. English must be used consistently for all names. SQL reserved keywords should be avoided to prevent conflicts and confusion. Names should be clear, meaningful, and descriptive so that the purpose of each object is easily understood by both technical and business users.

Table Naming Conventions

Table naming conventions vary depending on the data warehouse layer in which the table exists. Each layer has a specific purpose, and naming reflects that purpose.

Bronze Layer

In the Bronze layer, table names must start with the source system name. The entity name must exactly match the original table name from the source system, without any renaming or business transformation. This ensures traceability and preserves the raw structure of the source data.

The naming pattern for Bronze tables is <sourcesystem>_<entity>, where the source system represents the origin of the data, such as crm or erp. For example, crm_customer_info represents customer information ingested directly from the CRM system.

Silver Layer

Silver layer tables follow the same naming convention as the Bronze layer. The table names still begin with the source system name and retain the original entity name. Although the data in this layer is cleaned, standardized, and transformed, the naming remains unchanged to maintain a clear lineage back to the source system.

An example of a Silver table name is erp_product_master, which represents cleaned and standardized product data originating from the ERP system.

Gold Layer

Gold layer tables are business-facing and must use meaningful, descriptive names aligned with business terminology. These tables do not retain source system prefixes. Instead, they begin with a category prefix that identifies the role of the table, followed by a descriptive entity name.

Common category prefixes include dim for dimension tables, fact for fact tables, and report for reporting tables. Examples include dim_customers for customer dimension data and fact_sales for sales transaction data.

Column Naming Conventions

Column names must also follow the snake_case format and clearly describe the data they store. Special rules apply to surrogate keys and technical columns.

Surrogate Keys

All surrogate primary keys used in dimension tables must end with the suffix _key. The name of the key should clearly indicate the entity it represents. For example, customer_key is the surrogate key used in the dim_customers table.

Technical Columns

Technical or system-generated columns must start with the prefix dwh_. These columns are used to store metadata such as load dates, update timestamps, or audit information. Examples include dwh_load_date and dwh_update_timestamp.

Stored Procedure Naming Conventions

All stored procedures used for loading data into the data warehouse must follow a consistent naming pattern. The procedure name must start with the prefix load_, followed by the name of the data warehouse layer being loaded.

For example, load_bronze is used to load data into the Bronze layer, load_silver is used for the Silver layer, and load_gold is used for the Gold layer.

Conclusion

Adhering to these naming conventions ensures consistency across the data warehouse, simplifies maintenance, improves collaboration, and aligns the project with industry-standard best practices.
