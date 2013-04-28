jar cf lib/computeAggregate.jar src/udf/computeAggregate.java
javac -cp lib/computeMetrics.jar:lib/pig.jar -Xlint:deprecation src/udf/computeAggregate.java
mv src/udf/computeAggregate.class .
jar cvf lib/computeAggregate.jar computeAggregate.class
rm -f computeAggregate.class
