register lib/computeMetrics.jar;
register lib/checkstyle-5.6-all.jar;
register lib/pigbugs_checks.xml;

-- load the data in format (project_name, adjusted_file))
data = load 'data/filtered_joined_data' using PigStorage('\\x07') as (project_name: chararray, file_name: chararray, bugs: float, adjusted_file: chararray);
--data = load 'data/modified.in' using PigStorage('\\x07') as (project_name: chararray, file_name: chararray, bugs: float, adjusted_file: chararray);

data = FILTER data by (project_name is not null) or (file_name is not null) or (adjusted_file is not null);

-- replace the 'male' separator ('\\x0B') to ('\n')
proper_data = foreach data generate
                project_name,
                file_name,
                bugs,
                REPLACE(adjusted_file, '\\x0B', '\n') as proper_file;

-- run metrics on proper data
combined_metrics = foreach proper_data generate project_name, file_name, computeMetrics(proper_file) as checkstyle_metrics_vector, <NCSS UDF> as ncss_metrics_vector, bugs;

store metrics into 'output/combined_metrics';
