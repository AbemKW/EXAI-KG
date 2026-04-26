FROM eclipse-temurin:17-jdk

# Install dependencies
RUN apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

# Work directory
WORKDIR /app

# Download the latest pre-compiled Synthea release JAR (Version 3.2.0)
RUN wget -qO synthea-with-dependencies.jar https://github.com/synthetichealth/synthea/releases/download/master-branch-latest/synthea-with-dependencies.jar

# Entrypoint runs the JAR. We pass any additional arguments (like -p 1000) from the run command.
ENTRYPOINT ["java", "-jar", "synthea-with-dependencies.jar"]
