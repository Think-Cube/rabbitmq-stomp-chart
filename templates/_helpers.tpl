{{/* Chart name, truncated to fit Kubernetes name limits. */}}
{{- define "rabbitmq.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Release-qualified name used as the prefix of every resource. */}}
{{- define "rabbitmq.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "rabbitmq.headlessName" -}}
{{- printf "%s-headless" (include "rabbitmq.fullname" . | trunc 54 | trimSuffix "-") }}
{{- end }}

{{- define "rabbitmq.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "rabbitmq.labels" -}}
helm.sh/chart: {{ include "rabbitmq.chart" . }}
{{ include "rabbitmq.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "rabbitmq.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rabbitmq.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "rabbitmq.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rabbitmq.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "rabbitmq.secretName" -}}
{{- default (include "rabbitmq.fullname" .) .Values.auth.existingSecret }}
{{- end }}

{{- define "rabbitmq.image" -}}
{{- if .Values.image.digest }}
{{- printf "%s@%s" .Values.image.repository .Values.image.digest }}
{{- else }}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag }}
{{- end }}
{{- end }}
