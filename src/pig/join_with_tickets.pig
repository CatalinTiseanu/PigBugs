-- hadoop fs -rmf output/

register lib/computeAggregate.jar;

-- load the data in format (project_name, adjusted_file)) 
metrics = load 'kent-results' using PigStorage('\t') as (project_name: chararray, file_name: chararray, metrics: chararray);

-- run metrics on proper data
metrics = foreach proper_data generate
	    project_name,
	    file_name,
	    computeMetrics(proper_file) as metrics_vector;

-- load ticket data for file
bugs_by_file = load 'data/bugs_by_project_and_file.txt' as
		(project_name: chararray,
                 file_name: chararray,
                 nr_of_bugs: float);

-- join metrics with ticket data by file and store the result
joined_bugs_by_file = join bugs_by_file by (project_name, file_name),
                           metrics by (project_name, file_name);
labeled_data_by_file = foreach joined_bugs_by_file generate
                         metrics::project_name as project_name,
                         metrics::file_name as file_name,
                         metrics::metrics_vector as metrics_vector,
                         bugs_by_file::nr_of_bugs as nr_of_bugs;

store labeled_data_by_file into 'output/labeled_data_by_file';

-- load ticket data

-- ticket_info = load 'data/ticket_counter' using PigStorage(',') as
		

-- group by project name and aggregate the metrics
grouped_metrics = group metrics by project_name;
grouped_metrics_aggregate = foreach grouped_metrics generate
			      group as project_name,
			      computeAggregate(metrics.metrics_vector) as metrics_vector;

-- load ticket data by project
bugs_by_project = load 'data/bugs_by_project.txt' as
                 (project_name: chararray,
                  nr_of_bugs: float);

-- join metrics with ticket data by project and store the result
joined_bugs_by_project = join bugs_by_project by project_name,
                           grouped_metrics_aggregate by project_name;
labeled_data_by_project = foreach joined_bugs_by_project generate
                         grouped_metrics_aggregate::project_name as project_name,
                         grouped_metrics_aggregate::metrics_vector as metrics_vector,
                         bugs_by_project::nr_of_bugs as nr_of_bugs;

store labeled_data_by_project into 'output/labeled_data_by_project';			 
