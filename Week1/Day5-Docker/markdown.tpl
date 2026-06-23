{{- range . }}
## Target: `{{ .Target }}`

{{- if (eq (len .Vulnerabilities) 0) }}
No vulnerabilities found
{{- else }}
| ID | Package | Severity | Installed Version | Fixed Version |
|---|---|---|---|---|
{{- range .Vulnerabilities }}
| {{ .VulnerabilityID }} | {{ .PkgName }} | **{{ .Severity }}** | `{{ .InstalledVersion }}` | `{{ .FixedVersion }}` |
{{- end }}
{{- end }}

---
{{- end }}
