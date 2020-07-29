{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ddf.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ddf.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ddf.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ddf.labels" -}}
helm.sh/chart: {{ include "ddf.chart" . }}
{{ include "ddf.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ddf.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ddf.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ddf.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ddf.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* 
Generate the hostaliases for the ddf
*/}}
{{- define "ddf.spec.hostAlias" -}}
{{- if .hostname -}}
hostAliases:
  - ip: '127.0.0.1'
    hostnames:
      - {{ .hostname }}
{{- end -}}
{{- end -}}

{{/*
Create the volume configuration for any trusted certificates
*/}}
{{- define "ddf.trustedCertsVol" -}}
- name: trusted-certs-vol
  configMap:
      name: {{ .Values.trustedCertsConfigName }}
      defaultMode: 0644
{{- end -}}

{{/*
Create the volume mount for any trusted certificates
*/}}
{{- define "ddf.trustedCertsMount" -}}
{{- if hasKey $.Values "trustedCertsConfigName" -}}
- name: trusted-certs-vol
  mountPath: /trusted_certs
{{- end -}}
{{- end -}}

{{/*
Generate environment variables for injecting tls certs.
*/}}
{{- define "ddf.env.tls" -}}
{{- if and .secret.name .secret.name }}
- name: SSL_CERT
  valueFrom:
    secretKeyRef: 
      name: {{ .secret.name }}
      key: {{ .secret.certKey }}
- name: SSL_KEY
  valueFrom:
    secretKeyRef: 
      name: {{ .secret.name }}
      key: {{ .secret.keyKey }}
- name: SSL_CA_BUNDLE
  valueFrom:
   # configMapKeyRef: 
   #   name: {{ .ca.name }}
   #   key: {{ .ca.caKey }}
     secretKeyRef:
      name: {{ .secret.name }}
      key: {{ .secret.caKey }}
{{ end -}}
{{- end -}}

{{/*
Generate environment variable for security profile
*/}}
{{- define "ddf.env.securityProfile" -}}
{{- if .securityProfile }}
- name: SECURITY_PROFILE
  value: {{ .securityProfile.name }}
{{ end -}}
{{- end -}}

{{/*
Generate environment variable for internal hostname
*/}}
{{- define "ddf.env.internalHostname" -}}
{{- if .internalHostname }}
- name: INTERNAL_HOSTNAME
  value: {{ .internalHostname }}
{{ end -}}
{{- end -}}

{{/*
Generate environment variable for external hostname
*/}}
{{- define "ddf.env.externalHostname" -}}
{{- if .hostname }}
- name: EXTERNAL_HOSTNAME
  value: {{ .hostname }}
{{ end -}}
{{- end -}}

{{/*
Generate the environment variable for the install profile
*/}}
{{- define "ddf.env.installProfile" -}}
{{- if .installProfile }}
- name: INSTALL_PROFILE
  value: {{ .installProfile }}
{{ end -}}
{{- end -}}

{{/*

{{/*
Generate environment variables for port settings
*/}}
{{- define "ddf.env.ports" -}}
- name: EXTERNAL_HTTPS_PORT
  value: '443'
- name: EXTERNAL_HTTP_PORT
  value: '80'
{{- end -}}

{{/*
Generate environment variables for memory settings
TODO: Need to support multiple memory formats, not just Gi - oconnormi
*/}}
{{- define "ddf.env.memory" -}}
{{- if .resources.limits }}
{{- if .resources.limits.memory }}
- name: JAVA_MAX_MEM
  value: '{{ trimSuffix "Gi" .resources.limits.memory }}'
{{ end -}}
{{ end -}}
{{- end -}}

{{/*
Generate environment variables for ssh endpoint config
TODO: Need to link this setting to something in the values file - oconnormi
*/}}
{{- define "ddf.env.ssh" -}}
- name: SSH_ENABLED
  value: 'true'
{{- end -}}

{{/*
Generate environment variables for security manager configuration
TODO: Need to link this setting to something in the values file - oconnormi
*/}}
{{- define "ddf.env.securityManager" -}}
- name: SECURITY_MANAGER_DISABLED
  value: 'true'
{{- end -}}

{{/*
Generate environment variables for site name
*/}}
{{- define "ddf.env.siteName" -}}
{{- if .siteName }}
- name: SITE_NAME
  value: {{ .siteName }}
{{ end -}}
{{- end -}}
