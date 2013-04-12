

-- load data 
project = load '' using PigStorage('\a') as (project_name: chararray, file: chararray);
