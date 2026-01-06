/* ============================================================
   GOLD LAYER – STAR SCHEMA VIEWS
   ------------------------------------------------------------
   Purpose:
   - This script creates Gold layer views for analytics.
   - Gold layer represents business-ready data using
     FACT and DIMENSION tables (Star Schema).

   Layers:
   Bronze → Raw data
   Silver → Cleaned & standardized data
   Gold   → Analytics & reporting layer
   ============================================================ */


/* ============================================================
   FACT TABLE: gold.fact_sales
   ------------------------------------------------------------
   Grain:
   - One record per sales transaction (order + product)

   Purpose:
   - Stores measurable business facts like sales, quantity, price
   - Connected to product and customer dimensions
   ============================================================ */

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num      AS order_number,      -- Sales order number
    pr.product_key,                           -- Surrogate key from product dimension
    cu.customer_key,                          -- Surrogate key from customer dimension
    sd.sls_order_dt     AS order_date,         -- Order date
    sd.sls_ship_dt      AS shipping_date,      -- Shipping date
    sd.sls_due_dt       AS due_date,            -- Due date
    sd.sls_sales        AS sales_amount,        -- Total sales amount
    sd.sls_quantity     AS quantity,            -- Quantity sold
    sd.sls_price        AS price                -- Price per unit
FROM silver.crm_sales_details sd

-- Join with Product Dimension
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number

-- Join with CRM Customer table to get internal customer key
LEFT JOIN silver.crm_cust_info ci
    ON sd.sls_cust_id = ci.cst_id

-- Join with Customer Dimension (final mapping)
LEFT JOIN gold.dim_customers cu
    ON ci.cst_key = cu.customer_number;
GO


/* ============================================================
   DIMENSION TABLE: gold.dim_products
   ------------------------------------------------------------
   Purpose:
   - Stores descriptive attributes of products
   - Uses surrogate key (product_key)
   - Filters only active products (no historical data)
   ============================================================ */

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) 
        AS product_key,              -- Surrogate key
    pn.prd_id        AS product_id,  -- Business product ID
    pn.prd_key       AS product_number,
    pn.prd_nm        AS product_name,
    pn.cat_id        AS category_id,
    pc.cat           AS category,
    pc.subcat        AS subcategory,
    pc.maintenance   AS maintenance,
    pn.prd_cost      AS cost,
    pn.prd_line      AS product_line,
    pn.prd_start_dt  AS start_date
FROM silver.crm_prd_info pn

-- Join category details from ERP system
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id

-- Only active products (exclude historical records)
WHERE pn.prd_end_dt IS NULL;
GO


/* ============================================================
   DIMENSION TABLE: gold.dim_customers
   ------------------------------------------------------------
   Purpose:
   - Stores customer demographic and profile information
   - CRM is treated as the master source for gender
   ============================================================ */

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) 
        AS customer_key,              -- Surrogate key
    ci.cst_id        AS customer_id,  -- Business customer ID
    ci.cst_key       AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname  AS last_name,
    la.cntry         AS country,
    ci.cst_marital_status AS marital_status,

    -- Gender logic:
    -- CRM is the master source; fallback to ERP if missing
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,

    ca.bdate         AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci

-- Join ERP customer demographic data
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid

-- Join location data
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
GO
