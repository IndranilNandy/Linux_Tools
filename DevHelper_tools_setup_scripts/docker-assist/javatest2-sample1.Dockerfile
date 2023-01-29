# [[<TAG>]][[SNP]]

#   Ref: https://spring.io/guides/topicals/spring-boot-docker"

# [[<TAG>]][[SNP]][[<<USAGE>>]]
# ------------------
# USAGE:
# ------------------
#   * Use it for Java projects (NOT for Spring Boot projects)
#   * Use it when all you want is just a basic dockerfile to copy the entire fat jar to the docker image
# ------------------
# PREREQ:
# ------------------
#   * Build script should have task for creating fat jar
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
#   * docker build --build-arg JAR_FILE=build/libs/all-in-one-jar.jar -t myorg/myapp:v1 -f <dockerfile> .
#   * docker run --mount type=bind,src="$(pwd)"/temp_volume,target=/application/logs myorg/myapp:v1
# [[</TAG>]][[SNP]][[<<EXECUTION>>]]

# [[</TAG>]][[SNP]]
# _________________________________________________________________________________________________

FROM eclipse-temurin:17-jre-alpine
# RUN addgroup -S devguest && adduser -S devguest -G devguest
# USER devguest
# RUN addgroup --system spring && adduser --ingroup spring spring
# USER spring:spring
VOLUME [ "/tmp" ]
WORKDIR /application
ARG JAR_FILE=./build/libs/all-in-one-jar.jar
COPY ${JAR_FILE} app.jar
# ENTRYPOINT [ "java", "-jar", "app.jar" ]
ENTRYPOINT [ "/bin/sh" ]
# _________________________________________________________________________________________________