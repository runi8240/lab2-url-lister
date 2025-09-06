USER=$(shell whoami)

##
## Configure the Hadoop classpath for the GCP dataproc enviornment
##

HADOOP_CLASSPATH=$(shell hadoop classpath)

URLCount.jar: URLCount.java
	javac -classpath $(HADOOP_CLASSPATH) -d ./ URLCount.java
	jar cf URLCount.jar URLCount*.class	
	-rm -f URLCount*.class

prepare:
	-hdfs dfs -mkdir input
	curl https://en.wikipedia.org/wiki/Apache_Hadoop > /tmp/input.txt
	hdfs dfs -put /tmp/input.txt input/file01
	curl https://en.wikipedia.org/wiki/MapReduce > /tmp/input.txt
	hdfs dfs -put /tmp/input.txt input/file02

filesystem:
	-hdfs dfs -mkdir /user
	-hdfs dfs -mkdir /user/$(USER)

run: URLCount.jar
	-rm -rf output
	hadoop jar URLCount.jar URLCount input output


##
## You may need to change the path for this depending
## on your Hadoop / java setup
##
HADOOP_V=3.3.4
STREAM_JAR = /usr/local/hadoop-$(HADOOP_V)/share/hadoop/tools/lib/hadoop-streaming-$(HADOOP_V).jar

stream:
	-rm -rf stream-output
	hadoop jar $(STREAM_JAR) \
	-mapper Mapper.py \
	-reducer Reducer.py \
	-file Mapper.py -file Reducer.py \
	-input input -output stream-output
