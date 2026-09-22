{{/*
Name helpers. `fullname` is bounded at 63 characters because it becomes the name of a Service,
whose name is a DNS label — and a truncation that happens silently at apply time is worse than one
that happens the same way every render.
*/}}
{{- define "alethia-starter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "alethia-starter.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "alethia-starter.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "alethia-starter.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "alethia-starter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "alethia-starter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
The ServiceAccount the pod runs as.

`serviceAccount.create` defaults to false and should stay false — see values.yaml. When it is
false and no name is given, the field is omitted entirely and the pod uses the namespace's
`default` ServiceAccount, which is what the BYO project expects.
*/}}
{{- define "alethia-starter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "alethia-starter.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}
