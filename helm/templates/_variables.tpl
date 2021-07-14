{{/* List of internal values */}}

{{- define "dashboard.deployment.name" -}}
{{- print "rebugit-dashboard" -}}
{{- end -}}
{{- define "dashboard.service.name" -}}
{{- print "rebugit-dashboard" -}}
{{- end -}}
{{- define "dashboard.container.port" -}}
{{- print 8080 -}}
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
{{- define "tracer.network.policy.name" -}}
{{- print "rebugit-tracer-network" -}}
{{- end -}}

{{- define "authentication.keycloak.realm.name" -}}
{{- print "rebugit" -}}
{{- end -}}
{{- define "authentication.service.name" -}}
{{- print "rebugit-keycloak" -}}
{{- end -}}

{{- define "database.network.policy.name" -}}
{{- print "rebugit-database-network" -}}
{{- end -}}

{{- define "default.annotations" -}}
checksum/config: {{ include (print $.Template.BasePath "/rebugit-global-configmap.yaml") . | sha256sum }}
checksum/secrets: {{ include (print $.Template.BasePath "/rebugit-global-secrets.yaml") . | sha256sum }}
{{- end -}}

{{- define "default.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}