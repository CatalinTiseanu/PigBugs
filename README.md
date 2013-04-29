PigBugs
=======

Final project for Hadoop class

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
* The source for the udf which computes the metrics for each java file can be found at src/udf/computeMetrics.java, and is compiled and packaged by running ./scripts/doJarComputeMetrics.sh 

Data flow
---------
