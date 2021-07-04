{{- define "dashboard.container.port" -}}
{{- print 8080 -}}
{{- end -}}
{{- define "dashboard.deployment.name" -}}
{{- print "rebugit-dashboard" -}}
{{- end -}}
{{- define "dashboard.service.name" -}}
{{- print "rebugit-dashboard" -}}
{{- end -}}

{{- define "tracer.deployment.name" -}}
{{- print "rebugit-tracer" -}}
{{- end -}}
{{- define "tracer.service.name" -}}
{{- print "rebugit-tracer" -}}
{{- end -}}
{{- define "tracer.container.port" -}}
{{- print 8080 -}}
{{- end -}}

{{- define "database.port" -}}
{{- print 5432 -}}
{{- end -}}
{{- define "database.name" -}}
{{- print "rebugit" -}}
{{- end -}}
{{- define "database.user.name" -}}
{{- print "app" -}}
{{- end -}}
{{- define "database.host" -}}
{{- print "rebugit-postgresql" -}}
{{- end -}}

{{- define "authentication.host" -}}
{{- print "http://rebugit-keycloak:8080/rebugit/keycloak" -}}
{{- end -}}