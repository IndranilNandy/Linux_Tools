# [[<TAG>]][[SNP]]

#   Ref: https://spring.io/guides/topicals/spring-boot-docker"

# [[<TAG>]][[SNP]][[<<USAGE>>]]
# ------------------
# USAGE:
# ------------------
#   * Use it for Java projects (NOT for Spring Boot projects)
#   * Use it when you
#					   - build your jar and fat jar on your host machine, and t
#					   - extract the fat jar locally on your host machine using the script 'jar_layered_extracter.sh' to create layers
#					   - and transfer the layers to the docker image
# ------------------
# PREREQ:
# ------------------
#   * Build script should have task for creating fat jar
#   * You should use the script 'jar_layered_extracter.sh' to extract and create layers
# [[<TAG>]][[SNP]][[<<USAGE>>]]

# [[<TAG>]][[SNP]][[<<PROJECT_STRUCTURE>>]]
# ------------------
# PROJECT STRUCTURE:
# ------------------
# RootProject
#		   |__ gradlew
#		   |__ settings.gradle
#		   |__ .gradle
#		   |__ app (<-- MODULE)
#							   |__ this dockerfile
#							   |__ build.gradle
#							   |__ jar_layered_extracter.sh
#							   |__ extracted
#											|__ app (fat jar extracted here in layers using 'jar_layered_extracter.sh' script)
#							   |__ src (SOURCE folder)
#							   |__ build
#											|__ libs
#													|__ all-in-one-jar.jar (fat jar created using 'customFatJar' task)
# [[</TAG>]][[SNP]][[<<PROJECT_STRUCTURE>>]]

# [[<TAG>]][[SNP]][[<<EXECUTION>>]]
# ------------------
# Sample instructions:
# ------------------
#   * Build the fat jar, using 'gradle customFatJar' task
#   * Extract it in layers using 'jar_layered_extracter.sh' script
#   * docker build --build-arg EXTRACTED_JAR=extracted/app -t myorg/myapp:v1 -f <dockerfile> .
#   * docker run --mount type=bind,src="$(pwd)"/temp_volume,target=/application/logs myorg/myapp:v1
# [[</TAG>]][[SNP]][[<<EXECUTION>>]]

# [[</TAG>]][[SNP]]
# _________________________________________________________________________________________________

FROM eclipse-temurin:17-jre-alpine
VOLUME [ "/tmp" ]
WORKDIR /application
ARG EXTRACTED_JAR=extracted/app

COPY ${EXTRACTED_JAR}/libs app/libs
COPY ${EXTRACTED_JAR}/rs app/rs
COPY ${EXTRACTED_JAR}/META-INF app/META-INF
COPY ${EXTRACTED_JAR}/classes app/classes

ENTRYPOINT [ "java", "-cp", "app:app/libs/:app/classes/:app/rs/", "com.example.App" ]
# _________________________________________________________________________________________________