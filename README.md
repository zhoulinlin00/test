 --Data Model

Step 1. Data exploration and seperate the array column - in RewardItemDetails

Step 2. Create the data model as PDF


One-to-Many Relationships: As you know, there are one-to-many relationships between the tables:

---- A single receipt can have multiple items (represented in RewardItemDetails), so ensuring that receipt_id and barcode are correct and unique is crucial.

---- A user can scan many receipts over time, which means we need to ensure accurate linking of users to receipts.

---- A barcode may appear across multiple items in different receipts, so ensuring the barcode in the Brand table is unique and correctly categorized is essential for accurate brand performance tracking.

