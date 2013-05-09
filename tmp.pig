register lib/computeMetrics.jar;
register lib/checkstyle-5.6-all.jar;
register lib/pigbugs_checks.xml;

-- load the data in format (project_name, adjusted_file))
data = load 'PigBugs/filtered_joined_data' using PigStorage('\\x07') as (project_name: chararray, file_name: chararray, bugs: float, adjusted_file: chararray);

data = FILTER data by (project_name is not null) and (file_name is not null) and (adjusted_file is not null);

-- replace the 'male' separator ('\\x0B') to ('\n')
-- run metrics on proper data
metrics = foreach proper_data generate project_name, file_name, computeMetrics(proper_file) as metrics_vector, bugs;

store metrics into 'PigBugs/checkstyle_metrics';
