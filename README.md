# Financial-Ratios-and-their-Relation-to-Historical-Stock-Price-Trend

## Goal:
We want to build a machine learning model to analyze the strength of the relationship between the well-known 13 financial ratios and the historical stock price of companies from 2000 to 2020.

## Early concept development:

We are inspired by __The Big Short: Inside the Doomsday Machine__ and wondering if there exists certain pattern in the financial statements in the years prior to 2008 that could be found to reflect the failure or survival of a company during the economic crisis by using the exciting technology like machine learning model.

Originally, the main target was to create a machine learning model which could determine whether a company would have failed in 2008 based on the variables in three key financial statements from 2000 to 2007

The first challenge was to determine a method to measure the survival or failure of companies from the 2008 recession. Therefore, we selected 14 companies commonly cited in the news media as companies and 30 companies that we deemed as successfully surviving the 2008 economic crisis. 

This approach raises several issues.  First, we realized that the “death” of a group of 14 companies is extremely hard for us to determine. For example, since AIG survived due to the government bailout, we considered it a failure precisely because it required the massive bailout. However, many banks, which didn’t want government oversight, had to accept the bailout packages from the government. Moreover, Tribune Company was often cited as one that failed because of the 2008 recession, but it failed in 2007 partially due to the changing market condition (more digital news services).

The second problem was that there were too many differences among companies in their respective financial statements, which were already plagued with variations in terms of their reporting. There were so many missing data points that it was extremely difficult to determine comparable variables.

The third problem was that most failures were those of financial institutions. This points to the self-evident fact that the 2008 recession was triggered by the failures in the financial sector. It is possible to safely and reasonably assume what led to the failures of these companies, thus making the whole purpose of this experiment rather trivial.

However, despite these problems, we decided to move forward with this initial concept to see whether the approach could yield some insights for us. Neither of us tried to apply the machine learning to the financial analysis. We expected that we would not come up with a better model or a more suitable algorithm unless we started with some rudimentary concepts about machine learning and its potential relations to the important financials. Below is the chronicle of our initial attempt with one of the well-known machine learning model: Support Vector Machine (*SVM*).

## Chronicle:

June 3, 2020 - June 17, 2020:

After looking through several public financial databases, we chose EDGARD as our primary source of data. https://www.sec.gov/edgar/searchedgar/companysearch.html. Then, we extracted necessary financials to calculate the annual 13 economic ratios (details explained in Process data) as the feature variables for machine learning and manually create a binary label to describe whether a company survived (1) or failed (0). For instance, each entry consists of 13 ratios and the label indicating whether the company survives the 2008 recession.

The observations were divided into 70% for training and 30% for testing. In the iteration, the SVM was selected as the machine learning model for several reasons. First, SVM performs effectively when it comes to classification with multiple features. Second, SVM has been widely used in financial industries while observing the pattern of moving average of financial factors such as stock price and equity estimate, so SVM could be effectively used with our selected feature variables.

However, the accuracy produced by the model was merely around 52-53%, which we deemed would not provide minimal predictive value. Moreover, we realized that no standard method exists to tell whether the company survived in the following year. This led us to create the survival binary label based on some subjective or, even, arbitrary factors (i.e. public perception, media portrayal).

June 22, 2020:

After the first attempt, we considered two major changes as priorities for improvement in the next iteration.
First, we decided to change the primary source of data to WRDS because it can provide us with a metadata balance sheet through 2000-2020 containing all US companies listed in S&P 500 and Dow Jones (list_companies.txt). The WRDS provides all the info needed to generate feature variables while allowing us to extract all of necessary data without going through each company’s financial statements. It has also allowed us to import all the raw data as one file and process them all together. Lastly, we can customize the dataset with the WRDS with much-needed flexibility.
 
Second, instead of creating a label on whether a company survived or failed in the upcoming year, our new binary label is set as the performance of a company in the upcoming year by directly comparing upcoming stock prices with average from previous years. With the performance of stock price as the main target, the change mitigates the issue of uncertainty over the binary label, which we could not tell whether the labels were marked correctly and equally in the previous iteration. Also, as the comparison of stock prices could be modulated by the algorithm, the tiring manual labelling process is no longer required.

As a result, the total number of raw observations has increased to over 10,000. There was no significant improvement in accuracy as it averaged in the range of 54-55%. Moreover, since we could not see the internal of the SVM for R (Blackbox), we could not determine the causes for such low accuracies. However, the effort here was not fruitless. The main purpose of the iteration is to clarify and refine our problem space and try to acquire more and better raw data. 
 
July 11, 2020:

In order to improve the accuracy of assessing the connection between the financial indicators of a company and its stock performance, we decided to use the neuralnet package (‘NN’) in the iteration. The main reason for switching the model was due to the fact that the NN provides more customization options while training the model compared to the SVM package. Nevertheless, there was still no significant improvement in accuracy as it still averaged in the range of 55-57%.

July 14, 2020:

One factor that was missing in earlier attempts was a time dimension for the model. The decision to exclude them in previous attempts was deliberate because we first wanted to learn how the NN works. Adding time to the NN was a necessary step, but we deemed that we could add it later once we got familiar with the NN. When the NN produced similar results to the SVM, we decided to add a time variable to the NN. The new approach was to use the annual ratios from all three years prior to the target year instead of only one year. This led to the range of 60-62% accuracies on the testing dataset.

July 20, 2020:

In order to further improve the model structure, we decided to add more advanced selection on the feature variables used. Instead of selecting all 13 different ratios as the feature variables, the model would randomly pick three ratios out for each model and observe what the ratios each of them could produce with the higher accuracies. As a result, we uncovered the ratios that generate the models with the range of 68-72% accuracies on the testing dataset.

July 22, 2020:

The only remaining issue was the long processing time which sometimes takes over eight-to-nine hours while training all required models through the single CPU core. Therefore, parallel programming for R was implemented to access multi-cored computing power which could dramatically shorten the runtime to less than two hours when utilizing 8- cores/16-threads CPU.

## Concepts:

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

## Model Building:

## Analysis:

In our multiple runs, ROA has been consistently the most frequent. No other ration comes close to the level of frequency of ROA. This begs the question of why. 

ROA is calculated by dividing a company’s net income by total assets. ROA demonstrates how profitable a company is relative to its total assets. In other words, this indicator is about the efficiency of the company’s use of assets. The higher the ROA, the more efficient use of assets. Because ROA varies among industries, it is better to compare companies within a similar industry. The total assets are the sum of total liabilities and equity. Thus, for example, taking more debt may lead to a lower ROA unless there is a higher net income that outweighs both interest expenses that decrease net income and the addition of debts themselves. The major issue with ROA is that it cannot be used well across different industries because the use of assets widely varies among industries.

As noted above, ROA may not be the best indicator when comparing the performance of asset efficiency. However, our model is not about comparing one company against another. The basis of the model is to compare the company’s ROA’s indicators to its stock performance, not against other companies. 

## Conclusion:

This project is not to reveal that ROA is the best measure of a company’s stock performance. Instead, we aim to see how machine learning in R operates with some important financial indicators. We have discovered that ROA is far more relevant in measuring the company’s stock performance. There are, of course, a few caveats. The most obvious is that we are NOT able to see the neural network’s internal workings in the R package. It is essentially a black box. We are expected to assume that the model is working correctly. There is no way to confirm or deny the validity of the model itself. Lastly, the whole project has been our learning experience. Neither of us is a professional in machine learning. However, we find it highly relatable to how we are living now.
