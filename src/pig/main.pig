-- author: Catalin-Stefan Tiseanu

-- main pig script
-- please note that initially two compute* UDF's were used, computeNcss and computeChecktyle, and ran separetely. The computeCombined represents the abstraction for the merged version which we are missing from the repo right now :(

register lib/computeCombined.jar;
register lib/computeAggregate.jar;
register lib/pigbugs_checks.xml

-- load the data in format (project_name, adjusted_file)) 
data = load 'data/ApacheFull' using PigStorage('\\x07') as (project_name: chararray, file_name: chararray, adjusted_file: chararray);

-- replace the 'male' separator ('\\x0B') to ('\n')
proper_data = foreach data generate
	        project_name,
                file_name,
                REPLACE(adjusted_file, '\\x0B', '\n') as proper_file;

-- run metrics on proper data
-- computeCombined should be replaced by computeNcss or computeCheckstyle for a real run
metrics = foreach proper_data generate
	    project_name,
	    file_name,
	    computeCombined(proper_file) as metrics_vector;

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

-- group project by metrics
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
