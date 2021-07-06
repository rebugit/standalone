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

{{- define "default.annotations" -}}
checksum/config: {{ include (print $.Template.BasePath "/rebugit-global-configmap.yaml") . | sha256sum }}
checksum/secrets: {{ include (print $.Template.BasePath "/rebugit-global-secrets.yaml") . | sha256sum }}
{{- end -}}

