FROM public.ecr.aws/bitnami/keycloak:13.0.1

RUN sed -i -e 's/<web-context>auth<\/web-context>/<web-context>rebugit\/keycloak\/auth<\/web-context>/' /opt/bitnami/keycloak/standalone/configuration/standalone-ha-default.xml
RUN sed -i -e 's/<web-context>auth<\/web-context>/<web-context>rebugit\/keycloak\/auth<\/web-context>/' /opt/bitnami/keycloak/standalone/configuration/standalone.xml
