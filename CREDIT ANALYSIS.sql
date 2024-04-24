#1 CUSTOMER SEGMENTATION

	SELECT 
		C.CLIENT_NUM,
        C.CARD_CATEGORY,
        CC.CUSTOMER_AGE,
        CC.GENDER, 
        CC.MARITAL_STATUS, 
        CASE 
			WHEN CC.INCOME > 60000 THEN "LOW"
            WHEN CC.INCOME BETWEEN 60000 AND 150000 THEN "MEDIUM"
            ELSE "HIGH" END AS INCOMEGROUP,
		CASE 
			WHEN CC.CUSTOMER_AGE <= 30 THEN "YOUNG" 
            WHEN CC.CUSTOMER_AGE between 30 AND 50 THEN "MEDIUM"
            ELSE "SENIOR" END AS AGEGROUP
	FROM 
		CARDS C
        JOIN 
		CUSTOMERS CC
        ON 
        C.CLIENT_NUM = CC.CLIENT_NUM;
        
#2 CREDIT RISK ANALYSIS
SELECT
	CLIENT_NUM, 
    CREDIT_LIMIT, 
    TOTAL_REVOLVING_BAL,
    Delinquent_Acc,
    Annual_Fees,
    CASE
        WHEN Total_Revolving_Bal / Credit_Limit > 0.7 THEN 'High'
        WHEN Delinquent_Acc = 1 THEN 'Delinquent'
        ELSE 'Low'
    END AS Credit_Risk
FROM
    cards;

#3 CUSTOMER LIFETIME VALUE (CLV) 
SELECT
    c.Client_Num,
    c.Income,
    c.Cust_Satisfaction_Score,
    cc.Total_Trans_Amt,
    cc.Total_Trans_Vol,
    cc.Avg_Utilization_Ratio,
    (cc.Total_Trans_Amt / c.Income) * c.Cust_Satisfaction_Score AS Lifetime_Value
FROM
    customers c
JOIN
    cards cc ON c.Client_Num = cc.Client_Num
ORDER BY 
	LIFETIME_VALUE DESC;

#4 CUSTOMER ACQUISITION COST (CAC) AVG, MAX, MIN, TOTAL, & COUNT OF CUSTOMERS
SELECT 
	AVG(CUSTOMER_ACQ_COST) AS AVGCAC, 
    MAX(CUSTOMER_ACQ_COST) AS MAXCAC,
    MIN(CUSTOMER_ACQ_COST) AS MINCAC,
    SUM(CUSTOMER_ACQ_COST) AS TOTALCAC,
    COUNT(*) AS CUSTOMERS
    FROM CARDS;

#5 CHURNS
SELECT
	COUNT(*) COUNT,
    CASE
        WHEN Delinquent_Acc = 1 THEN 'Churned'
        ELSE 'Active'
    END AS Churn_Status
FROM
    cards c
JOIN
    customers cc ON c.Client_Num = cc.Client_Num
    GROUP BY CHURN_STATUS;

## Intermediate Level Problems:

/* 1. Customer Demographics Analysis:
   - Analyze the distribution of customer age, gender, education level, and marital status.*/
   SELECT
	(CASE
		WHEN CUSTOMER_AGE BETWEEN 18 AND 30 THEN "YOUNG"
        WHEN CUSTOMER_AGE BETWEEN 30 AND 50 THEN "MEDIUM" 
        ELSE "OLD" END) AS AGEGROUP , 
        COUNT(*) COUNT
	FROM 
		CUSTOMERS
	GROUP BY
		AGEGROUP;
# GENDER DISTRIBUTION 
	SELECT 
		COUNT(*) COUNT, 
        GENDER
	FROM 
		CUSTOMERS
	GROUP BY 
		GENDER
	ORDER BY COUNT;
    
# EDUCATIONAL DISTRIBUTION
   SELECT EDUCATION_LEVEL,
	COUNT(*) COUNT
    FROM CUSTOMERS
    GROUP BY 
		EDUCATION_LEVEL
	ORDER BY COUNT DESC;
   
# MARITAL STATUS
SELECT MARITAL_STATUS, 
	COUNT(*) COUNT
FROM 
	CUSTOMERS
GROUP BY 
	MARITAL_STATUS
ORDER BY COUNT DESC;

# Determine the average age of customers who hold credit cards.
SELECT 
	AVG(CUSTOMER_AGE) AVGAGE FROM CUSTOMERS;

# 2. Customer Behavior Analysis:
   -- Investigate the relationship between customer age and credit card spending behavior.
   SELECT 
		CASE 
			WHEN CUSTOMER_AGE BETWEEN 18 AND 30 THEN "YOUNG"
            WHEN CUSTOMER_AGE BETWEEN 30 AND 50 THEN "MEDIUM" 
            ELSE "OLD" END AS AGEGROUP, 
            SUM(TOTAL_TRANS_AMT) AS SPENDING
	FROM CUSTOMERS
    JOIN CARDS
	ON 
		CUSTOMERS.CLIENT_NUM = CARDS.CLIENT_NUM
GROUP BY
	AGEGROUP
ORDER BY 
	SPENDING DESC;
    
-- Compare the average transaction amount and volume between different genders.
SELECT 
	GENDER, 
    SUM(TOTAL_TRANS_AMT) SPENDING
FROM CUSTOMERS
JOIN CARDS
ON 
	CUSTOMERS.CLIENT_NUM = CARDS.CLIENT_NUM
GROUP BY GENDER
ORDER BY SPENDING DESC;

# 3. Credit Card Activation Analysis:
   -- Calculate the percentage of credit cards activated within 30 days of issuance.
SELECT 
	ROUND(SUM(ACTIVATION_30_DAYS) * 100 / COUNT(*), 2) AS ACTIVATION_PERCENTAGE
FROM CARDS;
   
   -- Identify any patterns or trends in activation rates based on customer demographics.
SELECT 
	GENDER, 
    ROUND(SUM(ACTIVATION_30_DAYS) * 100 / COUNT(*), 2) AS ACTIVATION_PERCENTAGE
    FROM 
		CARDS
        JOIN CUSTOMERS
        ON CARDS.CLIENT_NUM = CUSTOMERS.CLIENT_NUM
        GROUP BY GENDER;
	
    # BOTH AGE GROUP AND GENDER WISE
    SELECT 
		GENDER, 
        CASE WHEN CUSTOMER_AGE BETWEEN 18 AND 30 THEN "YOUNG"
        WHEN CUSTOMER_AGE BETWEEN 30 AND 50 THEN "MEDIUM"
        ELSE "OLD" END AS AGEGROUP, 
        ROUND(SUM(ACTIVATION_30_DAYS)/COUNT(*) * 100, 2) AS ACTIVATIONRATE
        FROM 
			CARDS 
        JOIN 
			CUSTOMERS
        ON 
			CARDS.CLIENT_NUM = CUSTOMERS.CLIENT_NUM
            GROUP BY 
				GENDER, AGEGROUP
			ORDER BY 
				ACTIVATIONRATE DESC;
				
# 4. Credit Limit Utilization Analysis:
   -- Calculate the average utilization ratio of credit limits for different age groups.
   SELECT 
		CASE 
			WHEN CUSTOMER_AGE BETWEEN 18 AND 30 THEN "YOUNG"
            WHEN CUSTOMER_AGE BETWEEN 30 AND 50 THEN "MEDIUM" 
            ELSE 
				"OLD" END AS AGEGROUP,
			SUM(AVG_UTILIZATION_RATIO) AS UTILIZATION
	FROM 
		CARDS JOIN CUSTOMERS
	ON 
		CARDS.CLIENT_NUM = CUSTOMERS.CLIENT_NUM
	GROUP BY 
		AGEGROUP
	ORDER BY 
		UTILIZATION DESC;
   
   -- Identify customers with high credit limits who are utilizing a low percentage of their available credit.
SELECT 
	CLIENT_NUM,
    CREDIT_LIMIT,
		AVG_UTILIZATION_RATIO
        FROM CARDS
	ORDER BY 
		CREDIT_LIMIT DESC, AVG_UTILIZATION_RATIO ASC;

# 5. Income vs. Credit Card Spending:
   -- Analyze the relationship between customer income levels and credit card spending behavior.
SELECT 
    CASE 
		WHEN INCOME < 100000 THEN "LOW"
        WHEN INCOME BETWEEN 100000 AND 300000 THEN "MEDIUM" 
        ELSE "HIGH" END AS INCOMEGROUP, 
        ROUND(SUM(AVG_UTILIZATION_RATIO), 2) AS UTILIZATION
FROM
	CUSTOMERS 
JOIN
	CARDS
ON
 CUSTOMERS.CLIENT_NUM = CARDS.CLIENT_NUM
GROUP BY 
	INCOMEGROUP
ORDER BY 
	UTILIZATION;
    
-- Determine if there's a correlation between income and average transaction amounts.
SELECT
	INCOME, 
    ROUND(AVG(TOTAL_TRANS_AMT),2 ) AS AVGAMOUNT
FROM 
	CUSTOMERS
JOIN 
	CARDS 
ON 
	CUSTOMERS.CLIENT_NUM = CARDS.CLIENT_NUM
GROUP BY
	INCOME
ORDER BY 
	INCOME DESC;

# 6. Customer Satisfaction Analysis:
-- Analyze the distribution of customer satisfaction scores.
SELECT 
    COUNT(*) COUNT,
	CUST_SATISFACTION_SCORE CSS
FROM 
	CUSTOMERS
GROUP BY 
	CSS 
ORDER BY 
	CSS DESC;

-- Identify any correlations between satisfaction scores and customer demographics or spending behavior.
SELECT 
	SUM(TOTAL_TRANS_AMT) AS TOTAL_TRANSACTIONS, 
    CUST_SATISFACTION_SCORE CSS
FROM CARDS
JOIN CUSTOMERS
ON CARDS.CLIENT_NUM = CUSTOMERS.CLIENT_NUM
GROUP BY 
	CUST_SATISFACTION_SCORE
ORDER BY 
	TOTAL_TRANSACTIONS DESC;
    
# 7. Delinquency Prediction:
-- Predict the likelihood of an account becoming delinquent based on historical data.
SELECT
    Credit_Limit,
    Total_Revolving_Bal AS BALANCE,
    Total_Trans_Amt,
    Delinquent_Acc
FROM
    cards
WHERE DELINQUENT_ACC = 1
ORDER BY 
	BALANCE DESC;

# 8. Customer Segmentation:
-- Segment customers based on their spending behavior, income, and satisfaction scores.
SELECT 
	INCOME,
    TOTAL_TRANS_AMT,
    CUST_SATISFACTION_SCORE
FROM 
	CARDS
JOIN
	CUSTOMERS
ON 
	CARDS.CLIENT_NUM = CUSTOMERS.CLIENT_NUM
ORDER BY 
	TOTAL_TRANS_AMT DESC;

-- Identify distinct customer groups for targeted marketing strategies.
SELECT
    CASE
        WHEN CUSTOMER_AGE BETWEEN 18 AND 30 THEN 'YOUNG'
        WHEN Customer_Age BETWEEN 30 AND 50 THEN 'MIDDLE'
        ELSE 'OLD'
    END AS AGE_GROUP,
    CASE
        WHEN INCOME < 100000 THEN 'LOW'
        WHEN INCOME BETWEEN 100000 AND 300000 THEN 'MEDIUM'
        ELSE 'HIGH'
    END AS INCOME_GROUP,
    CASE
        WHEN CUST_SATISFACTION_SCORE < 3 THEN 'LOW'
        WHEN CUST_SATISFACTION_SCORE BETWEEN 3 AND 4 THEN 'MEDIUM'
        ELSE 'HIGH'
    END AS SATISFACTION_GROUP,
    AVG(TOTAL_TRANS_AMT) AS AVG_AMOUNT
FROM
    CUSTOMERS
JOIN 
	CARDS
ON 
	CUSTOMERS.CLIENT_NUM = CARDS.CLIENT_NUM
GROUP BY
    AGE_GROUP, INCOME_GROUP, SATISFACTION_GROUP
ORDER BY 
	AVG_AMOUNT DESC;

# 9. Lifetime Value Analysis:
   -- Calculate the lifetime value of customers based on their spending habits and retention rates.
   # TRANSACTION & RETENTION INFORMATION
   SELECT 
		CLIENT_NUM,
		SUM(TOTAL_TRANS_AMT) SPENDING,
        COUNT(DISTINCT WEEK_NUM) AS WEEKS_ACTIVE
	FROM CARDS
    GROUP BY 
		CLIENT_NUM
	ORDER BY 
		SPENDING DESC;

# AVERAGE SPENDING PER WEEK
SELECT
    CLIENT_NUM,
    TOTAL_SPENDING / WEEKS_ACTIVE AS AVG_SPENDING_PER_WEEK
FROM
    (SELECT
        CLIENT_NUM,
        SUM(TOTAL_TRANS_AMT) AS TOTAL_SPENDING,
        COUNT(DISTINCT WEEK_NUM) AS WEEKS_ACTIVE
    FROM
        CARDS
    GROUP BY
        CLIENT_NUM) AS SPENDING_PER_WEEK;

# ESTIMATED CUSTOMER LIFETIME VALUE 
SELECT
    Client_Num,
    CASE
        WHEN Weeks_Active <= 0 THEN 0 -- Handle cases where there are no transactions
        ELSE (52 * (FIRST_WEEK - LAST_WEEK) + 1) / Weeks_Active -- Estimate lifetime based on active weeks
    END AS Estimated_Lifetime_In_Years
FROM
    (SELECT
        Client_Num,
        COUNT(DISTINCT Week_Num) AS Weeks_Active,
        MIN(Week_Num) AS First_Week,
        MAX(Week_Num) AS Last_Week
    FROM
        cards
    GROUP BY
        Client_Num) AS customer_lifetime
	ORDER BY 
		ESTIMATED_LIFETIME_IN_YEARS DESC;
        
/* # LIFETIME VLUE
SELECT
    CLIENT_NUM,
    AVG_SPENDING_PER_WEEK * ESTIMATED_LIFETIME_IN_YEARS AS LIFETIME_VALUE
FROM
    (SELECT
        SPENDING_PER_WEEK.CLIENT_NUM,
        AVG_SPENDING_PER_WEEK,
        ESTIMATED_LIFETIME_IN_YEARS
    FROM
        (SELECT
            Client_Num,
            Total_Spending / Weeks_Active AS Avg_Spending_Per_Week
        FROM
            (SELECT
                Client_Num,
                SUM(Total_Trans_Amt) AS Total_Spending,
                COUNT(DISTINCT Week_Num) AS Weeks_Active
            FROM
                cards
            GROUP BY
                Client_Num) AS spending_per_week) AS spending_avg
    JOIN
        (SELECT
            Client_Num,
            CASE
                WHEN Weeks_Active <= 0 THEN 0 -- Handle cases where there are no transactions
                ELSE 52 * (LAST_WEEK - FIRST_WEEK + 1) / WEEKS_ACTIVE -- Estimate lifetime based on active weeks
            END AS Estimated_Lifetime_In_Years
        FROM
            (SELECT
                Client_Num,
                COUNT(DISTINCT Week_Num) AS Weeks_Active,
                MIN(Week_Num) AS First_Week,
                MAX(Week_Num) AS Last_Week
            FROM
                cards
            GROUP BY
                Client_Num) AS customer_lifetime) AS lifetime_est
    ON spending_avg.Client_Num = lifetime_est.Client_Num; */


-- Identify high-value customers for personalized retention efforts.
# LIFETIME VALUE
/* -- Calculate LTV query
SELECT
    Client_Num,
    Avg_Spending_Per_Week * Estimated_Lifetime_In_Years AS Lifetime_Value
FROM
    (SELECT
        spending_per_week.Client_Num,
        Avg_Spending_Per_Week,
        Estimated_Lifetime_In_Years
    FROM
        (SELECT
            Client_Num,
            Total_Spending / Weeks_Active AS Avg_Spending_Per_Week
        FROM
            (SELECT
                Client_Num,
                SUM(Total_Trans_Amt) AS Total_Spending,
                COUNT(DISTINCT Week_Num) AS Weeks_Active
            FROM
                cards
            GROUP BY
                Client_Num) AS spending_per_week) AS spending_avg
    JOIN
        (SELECT
            Client_Num,
            CASE
                WHEN Weeks_Active <= 0 THEN 0 -- Handle cases where there are no transactions
                ELSE 52 * (MAX(Week_Num) - MIN(Week_Num) + 1) / Weeks_Active -- Estimate lifetime based on active weeks
            END AS Estimated_Lifetime_In_Years
        FROM
            (SELECT
                Client_Num,
                COUNT(DISTINCT Week_Num) AS Weeks_Active,
                MIN(Week_Num) AS First_Week,
                MAX(Week_Num) AS Last_Week
            FROM
                cards
            GROUP BY
                Client_Num) AS customer_lifetime) AS lifetime_est
    ON spending_avg.Client_Num = lifetime_est.Client_Num;
*/
# HIGH VALUE CUSTOMER 
-- Identify high-value customers
/* WITH RANKING AS (
    SELECT
        Client_Num,
        SUM(TOTAL_TRANS_AMT),
        RANK() OVER (ORDER BY TOTAL_TRANS_AMT DESC) AS LTV_Rank
    FROM
)
SELECT
    Client_Num,
    SUM(TOTAL_TRANS_AMT)
FROM
    RANKING
WHERE
    LTV_Rank <= 10; -- Adjust this number to select desired number of high-value customers
*/

#10. Fraud Detection:
-- Analyze transaction patterns and flag suspicious activities for further investigation.
# Normal transaction pattern
SELECT
    CLIENT_NUM,
    AVG(TOTAL_TRANS_AMT) AS AVG_TRANS_AMOUNT,
    SUM(TOTAL_TRANS_AMT) AS TOTAL_TRANS_VOLUME,
    COUNT(*) AS COUNT
FROM
    CARDS
GROUP BY
    CLIENT_NUM;
    
# Anamolies in transations 
SELECT
    CLIENT_NUM,
    TOTAL_TRANS_AMT,
    CASE
        WHEN TOTAL_TRANS_AMT > (SELECT AVG(TOTAL_TRANS_AMT) * 2 FROM CARDS) THEN 'HIGH'
        WHEN TOTAL_TRANS_AMT < (SELECT AVG(TOTAL_TRANS_AMT) / 2 FROM CARDS) THEN 'LOW'
        ELSE 'NORMAL'
    END AS TRANSACTION_STATUS
FROM
    CARDS;
    
# SUSPICIOUS TRANSACTIONS
SELECT
    CLIENT_NUM,
    TOTAL_TRANS_AMT,
    CASE
        WHEN TOTAL_TRANS_AMT > (SELECT AVG(TOTAL_TRANS_AMT) * 2 FROM CARDS) THEN 'HIGH'
        WHEN TOTAL_TRANS_AMT < (SELECT AVG(TOTAL_TRANS_AMT) / 2 FROM CARDS) THEN 'LOW'
        ELSE 'NORMAL'
    END AS TRANSACTION_STATUS,
    CASE
        WHEN TOTAL_TRANS_AMT > (SELECT AVG(TOTAL_TRANS_AMT) * 2 FROM CARDS) THEN 'SUSPICIOUS'
        WHEN TOTAL_TRANS_AMT < (SELECT AVG(TOTAL_TRANS_AMT) / 2 FROM CARDS) THEN 'SUSPICIOUS'
        ELSE 'NORMAL'
    END AS TRANSACTION_STATUS
FROM
    CARDS
ORDER BY 
	TOTAL_TRANS_AMT DESC;
