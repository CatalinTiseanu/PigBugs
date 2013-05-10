# author: Catalin-Stefan Tiseanu
# example script to compile one UDF and put the resulting .jar in /lib

jar cf lib/computeCheckstyle.jar src/udf/computeCheckstyle.java
javac -cp lib/computeCheckstyle.jar:lib/pig.jar:lib/checkstyle-5.6-all.jar -Xlint:deprecation src/udf/computeCheckstyle.java
mv src/udf/computeCheckstyle.class .
jar cvf lib/computeCheckstyle.jar computeCheckstyle.class
rm -f computeCheckstyle.class
