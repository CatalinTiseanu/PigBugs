jar cf computeMetrics.jar computeMetrics.java
javac -cp -computeMetrics.jar:pig.jar -Xlint:deprecation computeMetrics.java
jar cvf computeMetrics.jar computeMetrics.class
