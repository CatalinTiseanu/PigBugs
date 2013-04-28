-- rm -f output/anakia_metrics_by_file
-- rm -f output/anakia_metrics_aggregate

register lib/computeMetrics.jar;
register lib/computeAggregate.jar;

-- load the data in format (project_name, adjusted_file)) 
data = load 'data/Anakia.txt' using PigStorage('\\x07') as (project_name: chararray, adjusted_file: chararray);

-- replace the 'male' separator ('\\x0B') to ('\n')
proper_data = foreach data generate
	        project_name,
                REPLACE(adjusted_file, '\\x0B', '\n') as proper_file;

-- run metrics on proper data
metrics = foreach proper_data generate
	    project_name,
	    computeMetrics(proper_file) as metrics_vector;

-- store metrics by file
store metrics into 'output/anakia_metrics_by_file';

-- group by project name and aggregate the metrics
grouped_metrics = group metrics by project_name;
grouped_metrics_aggregate = foreach grouped_metrics generate
			      group as project_name,
			      computeAggregate(metrics.metrics_vector) as metrics_vector;
			 

-- store final result
store grouped_metrics_aggregate into 'output/anakia_metrics_aggregate';
