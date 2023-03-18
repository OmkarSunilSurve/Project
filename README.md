# Project


SQL :::

Name of File : 1. PortfolioProject.sql  .

Covid Data File can be downloaded from the link below
Link : https://ourworldindata.org/explorers/coronavirus-data-explorer?zoomToSelection=true&facet=none&pickerSort=asc&pickerMetric=location&hideControls=false&Metric=Confirmed+deaths&Interval=7-day+rolling+average&Relative+to+Population=true&Color+by+test+positivity=false&country=IND~USA~GBR~CAN~DEU~FRA.

The above data consists the record from start of the epidemic till the current date.

The data then was separated into two files which were used for further analysis and for quering the data to be used in Dashboard making using Tableau.
Those file Names are Covid_Vaccination and Covid_Deaths. Since the files were too heavy in terms of data (more than 2 lakh entries ), one can verify by looking at the table structure in the sql file as to which file contained which columns of the original data from the above link.

Name of File : 2. Data_Cleaning.sql   .

Original data File Name : Housing data.
Transformed file Name : Data_Cleaning_Project.

This project has helped me understand the process of cleaning the data. It helped me to think from the point of view of a Data Analyst as to which data fields would be important to keep in our table for performing some analysis. Comments are included in the sql file at various steps to understand how we were processing this data.
Due to file size being too much , the file does not open in git hub , but a raw copy is made available which can be downloaded.

Tableau File ::: 

Link to DashBoard is attached.

Here the data that is being used was the result of the queries from the Portfolio project. you can find the queries in Portfolio.sql file.
Files used were TT1,TT2,TT3,TT4.Format of the files is XLSX. Link to tableau dashboard is given below.
Link : https://public.tableau.com/app/profile/omkar.surve/viz/CovidDashBoard_16790433263410/Dashboard1?publish=yes




Julia :::

Name of File : SIR_Model.jl  .

Here the file name is Ebola Data. The data was collected from internet. A screenshot of the table is also attached so that we have the idea of the table we will be talking about during our analysis (name  : EbolaVirusTable.png)
The model is based on 1 year of available data. File from which data is taken is present here with name EbolaVirus.csv .
Plots are also present. Some Images of different plots are also attached like virus spread across various countries and model fitting .
