--register ../udf/computeMetrics.jar;
register ../udf/computeMetrics.jar;
--register ../udf/pig.jar;

-- load the data in format (project_name, adjusted_file)) 
data = load '../../data/Anakia.txt' using PigStorage('\\x07') as (project_name: chararray, adjusted_file: chararray);

-- replace the 'male' separator ('\\x0B') to ('\n')
proper_data = foreach data generate
	        project_name,
                REPLACE(adjusted_file, '\\x0B', '\n') as proper_file;

-- run metrics on proper data
metrics = foreach proper_data generate
	    project_name,
	    computeMetrics(proper_file) as metrics_vector;

-- group by project name and aggregate the metrics
grouped_metrics = group metrics by project_name;

-- store final result
dump grouped_metrics;
