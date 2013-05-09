--UNIQUE

data = load 'PigBugs/Apache.txt' using PigStorage('\\x07') as (project_name: chararray, file_name: chararray, adjusted_file: chararray);
user_grp = GROUP data BY file_name;
filtered = FOREACH user_grp {top_rec = LIMIT data 1; GENERATE FLATTEN(top_rec);};

store filtered into 'PigBugs/APACHEUNIQUE' using PigStorage('\\x07');


data = load 'PigBugs/ncss/labeled_data_by_file' using PigStorage('\\x07') as (project_name: chararray, file_name: chararray, adjusted_file: chararray);
user_grp = GROUP data BY file_name;
filtered = FOREACH user_grp {top_rec = LIMIT data 1; GENERATE FLATTEN(top_rec);};

store filtered into 'PigBugs/filtered_ncss' using PigStorage('\\x07');


data = load 'PigBugs/check/labeled_data_by_file' using PigStorage('\\x07') as (project_name: chararray, file_name: chararray, adjusted_file: chararray);
user_grp = GROUP data BY file_name;
filtered = FOREACH user_grp {top_rec = LIMIT data 1; GENERATE FLATTEN(top_rec);};

store filtered into 'PigBugs/filtered_check' using PigStorage('\\x07');

--WITH BUGS

-- load the data in format (project_name, adjusted_file)) 
proper_data = load 'PigBugs/APACHEUNIQUE' using PigStorage('\\x07') as (project_name: chararray, file_name: chararray, proper_file: chararray);

-- replace the 'male' separator ('\\x0B') to ('\n')
--proper_data = foreach data generate project_name,file_name,REPLACE(adjusted_file, '\\x0B', '\n') as proper_file;

-- load ticket data for file
bugs_by_file = load 'PigBugs/bugs_by_project_and_file.txt' as (project_name: chararray, file_name: chararray,nr_of_bugs: float);

-- join metrics with ticket data by file and store the result
joined_bugs_by_file = join bugs_by_file by (project_name, file_name), proper_data by (project_name, file_name);

labeled_data_by_file = foreach joined_bugs_by_file generate proper_data::project_name as project_name, proper_data::file_name as file_name,bugs_by_file::nr_of_bugs as nr_of_bugs, proper_data::proper_file as proper_file;

B = FILTER labeled_data_by_file BY nr_of_bugs > 0.0;

store B into 'PigBugs/filtered_joined_data' using PigStorage('\\x07');

--RUN CODE



register lib/compute_metrics.jar;
register lib/jhbasic.jar;
register lib/javancss.jar;
register lib/ccl.jar;

-- load the data in format (project_name, adjusted_file)) 
data = load 'PigBugs/filtered_joined_data' using PigStorage('\\x07') as (project_name: chararray, file_name: chararray, bugs: float, adjusted_file: chararray);

-- replace the 'male' separator ('\\x0B') to ('\n')
proper_data = foreach data generate project_name, file_name, bugs, REPLACE(adjusted_file, '\\x0B', '\n') as proper_file;

-- run metrics on proper data
metrics = foreach proper_data generate project_name, file_name, compute_metrics(proper_file) as metrics_vector, bugs;

store metrics into 'PigBugs/ncss2/'; 


register lib/computeMetrics.jar;
register lib/checkstyle-5.6-all.jar;
register lib/pigbugs_checks.xml;

-- load the data in format (project_name, adjusted_file)) 
data = load 'PigBugs/filtered_joined_data' using PigStorage('\\x07') as (project_name: chararray, file_name: chararray, bugs: float, adjusted_file: chararray);

data = FILTER data by (project_name is not null) and (file_name is not null) and (adjusted_file is not null);

-- replace the 'male' separator ('\\x0B') to ('\n')
proper_data = foreach data generate project_name, file_name, bugs, REPLACE(adjusted_file, '\\x0B', '\n') as proper_file;

-- run metrics on proper data
metrics = foreach proper_data generate project_name, file_name, computeMetrics(proper_file) as metrics_vector, bugs;

store metrics into 'PigBugs/check2';