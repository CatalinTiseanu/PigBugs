jar cf lib/computeMetrics.jar src/udf/computeMetrics.java
javac -cp lib/computeMetrics.jar:lib/pig.jar:lib/checkstyle-5.6-all.jar -Xlint:deprecation src/udf/computeMetrics.java
mv src/udf/computeMetrics.class .
jar cvf lib/computeMetrics.jar computeMetrics.class
rm -f computeMetrics.class
