# Copyright (c) 2019 and later Unicode, Inc. and others. All Rights Reserved.

# Keep the tomcat version and port in sync with the `cargo.containerId` and
# the `cargo.servlet.port` in pom.xml
FROM tomcat:9-jdk11-temurin
ADD target/icu4jweb.war /usr/local/tomcat/webapps/
EXPOSE 8080
