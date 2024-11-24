{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "rsyncd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rsyncd.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rsyncd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "rsyncd.labels" -}}
app.kubernetes.io/name: {{ include "rsyncd.name" . }}
helm.sh/chart: {{ include "rsyncd.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Data directory volume definition.
Expected argument: dict{
  "currentRsyncComponent": <string>,
  "rootContext": { },
}
*/}}
{{- define "rsyncd.datadir-volumedefinition" -}}
{{- if .currentRsyncComponent.volumeTpl -}}
persistentVolumeClaim:
  claimName: {{ printf "%s" (tpl .currentRsyncComponent.volumeTpl .rootContext) | trim | trunc 63 -}}
{{- else if .currentRsyncComponent.volume -}}
  {{- toYaml .currentRsyncComponent.volume -}}
{{- else -}}
emptyDir: {}
{{- end -}}
{{- end -}}

{{/* Define the port exposed by the pod (depends on the RsyncD daemon specified, usually unprivileged port) */}}
{{- define "rsyncd.port" -}}
{{/* Overrides defaults if the top level `port` value exists */}}
{{- if .Values.port -}}
{{ .Values.port }}
{{- else if eq .Values.configuration.rsyncd_daemon "rsyncd" -}}
1873
{{- else if eq .Values.configuration.rsyncd_daemon "sshd" -}}
2222
{{- end -}}
{{- end -}}

{{/* Define the port exposed by the service (usually standard RsyncD or SSH ) */}}
{{- define "rsyncd.service.port" -}}
{{/* Overrides defaults if the `service.port` value exists */}}
{{- if .Values.service.port -}}
{{ .Values.service.port }}
{{- else if eq .Values.configuration.rsyncd_daemon "rsyncd" -}}
873
{{- else if eq .Values.configuration.rsyncd_daemon "sshd" -}}
22
{{- end -}}
{{- end -}}
