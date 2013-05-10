PigBugs
=======

Final project for Hadoop class.
Most of the source files have explanatory comments related to what they do.
The relevant files are contained in

+ /scripts : everything
+ /src/udf : computeCheckstyle.java,computeAggregate.java,computeNcss.java
+ /src/pig : join_with_tickets.pig,main.pig,process_tickets.pig
+ /src/scraper : everything
+ /data : bugs_by_project_and_file.txt,bugs_by_project.txt,ticket_bug_count.txt

Introduction
------------

Input: A project folder (having all the relevant .java files)
i.e 

+ apache_hadoop/src/main/HelloWorld.java
+ apache_hadoop/src/main/GoodbyeWorld.java
+ apache_hadoop/src/test/HopeItWorks.java
+ apache_hadoop/readme.md

Processing step: Take the project folder, flatten it's structure (discarding non-java files)
i.e

+ apache_hadoop/HelloWorld.java
+ apache_hadoop/GoodbyeWorld.java
+ apache_hadoop/HopeItWorks.java


Usage
-----

* Note that all .sh and .pig scripts should be run from the root of PigBugs (i.e use pig src/pig/main.pig)
* The main pig script can be found at src/pig/main.pig.
* The aggregation udf source can be found at src/udf/computeAggregate.java, and is compiled and packaged by running ./scripts/doJarComputeAggregate.sh 
* The source for the udf which computes the metrics for each java file can be found at src/udf/compute[Ncss|Checkstyle].java, and is compiled and packaged by running the relevant ./scripts/doJarCompute* 
