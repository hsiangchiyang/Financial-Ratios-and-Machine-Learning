# Financial-Ratios-and-their-Relation-to-Historical-Stock-Price-Trend
## Goal
We want to build a machine learning model to analyze the strength of the relationship between the well-known 13 financial ratios and the historical stock price of companies from 2000 to 2020.

## Background:

We are inspired by __The Big Short: Inside the Doomsday Machine__ and wondering if there exists certain pattern in the financial statements in the years prior to 2008 that could be found to reflect the failure or survival of a company during the economic crisis by using the exciting technology like machine learning model.

### Concept formulation

Originally, the main target is to create an machine learning model which could determine whether a company would have failed in 2008 based on the variables from previous years financial statements. 

However, it is hard to decide the actual duration of the economic crisis that companies could have declared bankruptcy before or after 2008. In advance, there is no justifications on whether the companies which needed the aid from the government to survive should be counted as the failure cases. 

Therefore, instead of training the machine learning model on whether a company would have failed, we decide to train the model to determine the performance of the company by the stock price comparison during the period from 2000-2020. 


### Initial attempts

## Prepare Data:

1. Database

    - Serviced by __WRDS: Wharton Research Data Services__: https://wrds-www.wharton.upenn.edu/
    - Require subscription (Free if one is a student or a faculty member of post-secondary institutions in Canada
    - Compustat - Capital IQ from Standard & Poor's
2. Extract the names of companies in S&P 500 and Dow Jones and compile them into a list. The total number of companies in this experiment amounts to 632 companies.
3. The information in the balance sheet, the income statement, and the cash flow statement has been extracted and compiled into the one master file “realannual.xlsx.”
4. The information from companies in financial services can be misleading because the database used here has created a separate balance sheet, income statement, and cash flow statement. We have checked several financial companies to see whether such division would create a distorted picture on the health of a company in financial services. We have determined that such distortion is worrisome but not significant. However, this may need more scrutiny later.

## Process Data into the Well-Used Economic Ratios

1. Use  read_excel to import the master file “realannual.xlsx”  into R environment 
2. Subset the required fields which are required for further calculations. 
3. Generate advanced estimators:

    - First, filter out the entries with NA in prcc_c (the annual stock price). Since prcc_c is the primary target to estimate the performance of companies, the entries containing NA in the field are not useful.
    - Generate the proper estimators (13 ratios) as mentioned in factors to considered with the following formula:
        1. __Current ratio__: Current Assets/Current Liabilities = act/lct
        2. __Quick Ratio__: (Current Assets - Inventories)/Current Liabilities = (act - invt)/lct
        3. __Cash Ratio__: Cash Equivalent/Current Liabilities =  che/lct
        4. __Operating Cash Flow Ratio__: Operating Cash flow/Current Liabilities  = oancf/lct
        5. __Debt Ratio: Total Debt/Total Assets__ = dltt/lse
        6. __Debt-To-Equity Ratio__: Total Debt/Total Equity = dltt/seq
        7. __Interest Coverage Ratio__: Operating Income Before Depreciation /Interest Expenses = oibdp/ xint
        8. __Debt Service Coverage Ratio__: Operating Income Before Depreciation /Debt (Long-Term) Due in One Year = oibdp/dd1
        9. __Asset Turnover Ratio__:  Operating Income Before Depreciation/Total Assets = oibdp/at
        10. __Inventory Turnover Ratio__: Cost of Goods/Inventories = cogs/invt
        11. __Gross Margin Ratio__: Gross Profit/Total Revenue = gp/revt
        12. __Operating Margin Ratio__:  Operating Income Before Depreciation/Total Revenue = oibdp/revt
        13. __Return On Assets Ratio__: Net Income/Total Assets = ib/at
      
      Note: Since not every entry contains actual values in the required fields, ifelse() is used to verify and replace NA with 0 in the desire location; moreover, some field generation has to be filled with the sum of the values coming from different field, so rowSums() is called to serve the purpose of summing the desired fields.
      For example, the following lines,
      
      ``rawdata_r$act<-ifelse(is.na(rawdata_r$act),rowSums(rawdata_r[,c('acoxar', 'che', 'invt', 'rect')]),rawdata_r$act)``
      ``rawdata_r$act<-ifelse(rawdata_r$act==0,rowSums(rawdata_r[,c('acoxar', 'che', 'invt', 'rect')]),rawdata_r$act)``
    
       are used to calculate the value of Current Assets as it is the sum of 5 different fields and there is no guarantee that every required field would be filled with actual value.  
        
4. Calculate the average prcc_c based on previous years for each observation
5. Create the binary label/Mask 0 or 1 whether the next year prcc_c is higher than the average_prcc_c
