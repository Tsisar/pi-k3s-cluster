{{/*
Common labels
*/}}
{{- define "application.labels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Namespace }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Generate PostgreSQL password if not provided
*/}}
{{- define "postgres.password" -}}
{{- if .Values.postgres.auth.password -}}
{{- .Values.postgres.auth.password -}}
{{- else -}}
{{- randAlphaNum 16 -}}
{{- end -}}
{{- end -}}

{{/*
Generate PostgreSQL username
*/}}
{{- define "postgres.username" -}}
{{- .Values.postgres.auth.username | default "postgres" -}}
{{- end -}}
