#
# Batch script to run the upload grader process
#
TPZ_PASSWORD=H6CmXQOGRc34zRYyKzIa9y
TPZ_USERNAME=er1k@andrew.cmu.edu

mvn package
mvn upload-grader:upload -Dupload.andrewId=$TPZ_USERNAME -Dupload.password=$TPZ_PASSWORD -Dupload.filename=target/java_grader.jar
