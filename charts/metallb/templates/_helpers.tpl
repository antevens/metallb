{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "metallb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "metallb.fullname" -}}
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
{{- define "metallb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "metallb.labels" -}}
helm.sh/chart: {{ include "metallb.chart" . }}
{{ include "metallb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "metallb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "metallb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the controller service account to use
*/}}
{{- define "metallb.controller.serviceAccountName" -}}
{{- if .Values.controller.serviceAccount.create }}
{{- default (printf "%s-controller" (include "metallb.fullname" .)) .Values.controller.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.controller.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the speaker service account to use
*/}}
{{- define "metallb.speaker.serviceAccountName" -}}
{{- if .Values.speaker.serviceAccount.create }}
{{- default (printf "%s-speaker" (include "metallb.fullname" .)) .Values.speaker.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.speaker.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the settings Secret to use.
*/}}
{{- define "metallb.secretName" -}}
    {{ default ( printf "%s-memberlist" (include "metallb.fullname" .)) .Values.speaker.secretName | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "metrics.exposedportname" -}}
{{- if .Values.prometheus.secureMetricsPort -}}
"metricshttps"
{{- else -}}
"metrics"
{{- end -}}
{{- end -}}

{{- define "metrics.exposedfrrportname" -}}
{{- if .Values.speaker.frr.secureMetricsPort -}}
"frrmetricshttps"
{{- else -}}
"frrmetrics"
{{- end }}
{{- end }}

{{- define "metrics.exposedport" -}}
{{- if .Values.prometheus.secureMetricsPort -}}
{{ .Values.prometheus.secureMetricsPort }}
{{- else -}}
{{ .Values.prometheus.metricsPort }}
{{- end -}}
{{- end }}

{{- define "metrics.exposedfrrport" -}}
{{- if .Values.speaker.frr.secureMetricsPort -}}
{{ .Values.speaker.frr.secureMetricsPort }}
{{- else -}}
{{ .Values.speaker.frr.metricsPort }}
{{- end }}
{{- end }}

{{/*
Returns a string representing the Kubernetes platform e.g. openshift, microk8s, tanzu, etc
*/}}
{{- define "metallb.k8sPlatform" }}
  {{- if ( dig "global" "k8sPlatform" false .Values.AsMap ) }}
    {{- .Values.global.k8sPlatform }}
  {{- else }}
    {{- $nodes := lookup "v1" "Node" "" "" }}
    {{- if $nodes }}
      {{- $node := first $nodes.items }}
      {{- if ( dig "metadata" "labels" "node.openshift.io/os_id" false $node ) }}
        {{- "openshift" }}
      {{- else if ( dig "metadata" "labels" "microk8s.io/cluster" false $node ) }}
        {{- "microk8s" }}
      {{- else if ( dig "metadata" "labels" "eks.amazonaws.com/nodegroup" false $node ) }}
        {{- "eks" }}
      {{- else if ( dig "metadata" "labels" "node.cluster.x-k8s.io/esxi-host" false $node ) }}
        {{- "tanzu" }}
      {{- else }}
        {{- "kubernetes" }}
      {{- end }}
    {{- else }}
        {{- "kubernetes" }}
    {{- end }}
  {{- end }}
{{- end }}
