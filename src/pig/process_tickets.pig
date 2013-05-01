rmf data/bugs_by_project_and_file.txt
rmf data/bugs_by_project.txt

-- pig script to process the ticket data
-- example row: Apache Abdera,12343428,CommonsClient.java,1


-- load the data in format (project_name, ticket_id, file_name, nr_of_bugs) 
data = load 'data/ticket_bug_count.txt' using PigStorage(',') as
	(project_name: chararray,
	 ticket_id: int,
	 file_name: chararray,
	 nr_of_bugs: int);

-- group by bug_id
data_by_ticket_id = group data by ticket_id;
bugs_per_ticket_id = foreach data_by_ticket_id generate
		       group as ticket_id,
		       SUM(data.nr_of_bugs) as total_nr_of_bugs;

--dump bugs_per_ticket_id;

-- now we have the same table we started with, only it has the correct fractional
-- bug counts
joined_data = join data by ticket_id, bugs_per_ticket_id by ticket_id;
divided_bugs_per_file_name =
  foreach joined_data generate
  data::project_name as project_name,
  data::file_name as file_name,
  data::ticket_id as ticket_id,
  (1.0 * data::nr_of_bugs / bugs_per_ticket_id::total_nr_of_bugs) as normalized_bugs;

-- all that's left is to group and store the data
group_bugs_by_project = group divided_bugs_per_file_name by project_name;
nr_of_bugs_by_project = foreach group_bugs_by_project generate
                          group as project_name,
			  SUM(divided_bugs_per_file_name.normalized_bugs) as total_nr_of_bugs;

store nr_of_bugs_by_project into 'data/bugs_by_project.txt';

group_bugs_by_project_file = group divided_bugs_per_file_name by (project_name, file_name);
nr_of_bugs_by_project_file = foreach group_bugs_by_project_file generate
                             FLATTEN(group) as (project_name, file_name),
			     SUM(divided_bugs_per_file_name.normalized_bugs) as total_nr_of_bugs;

store nr_of_bugs_by_project_file into 'data/bugs_by_project_and_file.txt';
