--SQL Questions
---Question 1 What are the top 5 brands by receipts scanned for most recent month?
WITH CleanReceipts AS (
    SELECT DISTINCT
        receipt_id,
        userId,
        dateScanned,
        rewardsReceiptStatus,
        totalSpent
    FROM Receipt
    WHERE
        receipt_id IS NOT NULL
        AND userId IS NOT NULL
        AND dateScanned IS NOT NULL
        AND totalSpent > 0
),
CleanBrands AS (
    SELECT DISTINCT
        barcode,
        name
    FROM Brand
    WHERE
        barcode IS NOT NULL
        AND name IS NOT NULL
        AND category IS NOT NULL
        AND categoryCode IS NOT NULL
)
SELECT
    b.name AS brand_name,
    COUNT(r.receipt_id) AS receipts_scanned
FROM
    CleanReceipts r
JOIN
    RewardItemDetails rid ON r.receipt_id = rid.receipt_id
JOIN
    CleanBrands b ON rid.barcode = b.barcode
WHERE
    r.dateScanned >= DATEADD(MONTH, -1, GETDATE()) -- Most recent month
GROUP BY
    b.name
ORDER BY
    receipts_scanned DESC
LIMIT 5;

-- Question 2 How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
WITH CleanReceipts AS (
    SELECT DISTINCT
        receipt_id,
        userId,
        dateScanned,
        rewardsReceiptStatus,
        totalSpent
    FROM Receipt
    WHERE
        receipt_id IS NOT NULL
        AND userId IS NOT NULL
        AND dateScanned IS NOT NULL
        AND totalSpent > 0
),
CleanBrands AS (
    SELECT DISTINCT
        barcode,
        name
    FROM Brand
    WHERE
        barcode IS NOT NULL
        AND name IS NOT NULL
        AND category IS NOT NULL
        AND categoryCode IS NOT NULL
),
RecentMonth AS (
    SELECT
        b.name AS brand_name,
        COUNT(r.receipt_id) AS receipts_scanned,
        'Recent Month' AS period
    FROM
        CleanReceipts r
    JOIN
        RewardItemDetails rid ON r.receipt_id = rid.receipt_id
    JOIN
        CleanBrands b ON rid.barcode = b.barcode
    WHERE
        r.dateScanned >= DATEADD(MONTH, -1, GETDATE()) -- Most recent month
    GROUP BY
        b.name
),
PreviousMonth AS (
    SELECT
        b.name AS brand_name,
        COUNT(r.receipt_id) AS receipts_scanned,
        'Previous Month' AS period
    FROM
        CleanReceipts r
    JOIN
        RewardItemDetails rid ON r.receipt_id = rid.receipt_id
    JOIN
        CleanBrands b ON rid.barcode = b.barcode
    WHERE
        r.dateScanned >= DATEADD(MONTH, -2, GETDATE()) -- Previous month
        AND r.dateScanned < DATEADD(MONTH, -1, GETDATE())
    GROUP BY
        b.name
)
SELECT
    COALESCE(rm.brand_name, pm.brand_name) AS brand_name,
    COALESCE(rm.receipts_scanned, 0) AS recent_month_receipts,
    COALESCE(pm.receipts_scanned, 0) AS previous_month_receipts
FROM
    RecentMonth rm
FULL OUTER JOIN
    PreviousMonth pm ON rm.brand_name = pm.brand_name
ORDER BY
    recent_month_receipts DESC,
    previous_month_receipts DESC
LIMIT 5;

-- Question 3 When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
WITH CleanReceipts AS (
    SELECT DISTINCT
        receipt_id,
        rewardsReceiptStatus,
        totalSpent
    FROM Receipt
    WHERE
        receipt_id IS NOT NULL
        AND rewardsReceiptStatus IN ('Accepted', 'Rejected')
        AND totalSpent > 0
)
SELECT
    rewardsReceiptStatus,
    AVG(totalSpent) AS average_spend
FROM
    CleanReceipts
GROUP BY
    rewardsReceiptStatus
ORDER BY
    average_spend DESC;

-- Question 4 When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
WITH CleanReceipts AS (
    SELECT DISTINCT
        receipt_id,
        rewardsReceiptStatus,
        purchasedItemCount
    FROM Receipt
    WHERE
        receipt_id IS NOT NULL
        AND rewardsReceiptStatus IN ('Accepted', 'Rejected')
        AND purchasedItemCount > 0
)
SELECT
    rewardsReceiptStatus,
    SUM(purchasedItemCount) AS total_items_purchased
FROM
    CleanReceipts
GROUP BY
    rewardsReceiptStatus
ORDER BY
    total_items_purchased DESC;

-- Question 5 Which brand has the most spend among users who were created within the past 6 months?
WITH CleanUsers AS (
    SELECT DISTINCT
        user_id
    FROM User
    WHERE
        user_id IS NOT NULL
        AND createdDate >= DATEADD(MONTH, -6, GETDATE()) -- Users created in the past 6 months
),
CleanReceipts AS (
    SELECT DISTINCT
        receipt_id,
        userId,
        totalSpent
    FROM Receipt
    WHERE
        receipt_id IS NOT NULL
        AND userId IS NOT NULL
        AND totalSpent > 0
),
CleanBrands AS (
    SELECT DISTINCT
        barcode,
        name
    FROM Brand
    WHERE
        barcode IS NOT NULL
        AND name IS NOT NULL
        AND category IS NOT NULL
        AND categoryCode IS NOT NULL
)
SELECT
    b.name AS brand_name,
    SUM(r.totalSpent) AS total_spend
FROM
    CleanReceipts r
JOIN
    CleanUsers u ON r.userId = u.user_id
JOIN
    RewardItemDetails rid ON r.receipt_id = rid.receipt_id
JOIN
    CleanBrands b ON rid.barcode = b.barcode
GROUP BY
    b.name
ORDER BY
    total_spend DESC
LIMIT 1;

-- Question 6 Which brand has the most transactions among users who were created within the past 6 months?
WITH CleanUsers AS (
    SELECT DISTINCT
        user_id
    FROM User
    WHERE
        user_id IS NOT NULL
        AND createdDate >= DATEADD(MONTH, -6, GETDATE()) -- Users created in the past 6 months
),
CleanReceipts AS (
    SELECT DISTINCT
        receipt_id,
        userId
    FROM Receipt
    WHERE
        receipt_id IS NOT NULL
        AND userId IS NOT NULL
),
CleanBrands AS (
    SELECT DISTINCT
        barcode,
        name
    FROM Brand
    WHERE
        barcode IS NOT NULL
        AND name IS NOT NULL
        AND category IS NOT NULL
        AND categoryCode IS NOT NULL
)
SELECT
    b.name AS brand_name,
    COUNT(r.receipt_id) AS total_transactions
FROM
    CleanReceipts r
JOIN
    CleanUsers u ON r.userId = u.user_id
JOIN
    RewardItemDetails rid ON r.receipt_id = rid.receipt_id
JOIN
    CleanBrands b ON rid.barcode = b.barcode
GROUP BY
    b.name
ORDER BY
    total_transactions DESC
LIMIT 1;