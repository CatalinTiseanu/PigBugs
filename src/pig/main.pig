

-- load the data in format (project_name, adjusted_file)) 
data = load '../../data/Anakia.txt' using PigStorage('\\x07') as (project_name: chararray, adjusted_file: chararray);

-- replace the 'male' separator ('\b') to '\n'
proper_data = foreach data generate project_name,
                                    REPLACE(adjusted_file, '\b', '\n') as proper_file;

dump proper_data;

-- run metrics on proper data

-- group by project name and aggregate the metrics

-- store final result

