# Changelog

This template is versioned with [semantic versioning](https://semver.org). `TEMPLATE_VERSION` and
`chart/Chart.yaml`'s `version` hold the same number, and CI fails if they disagree or if the chart
changes without one of them moving.

What counts as which, for this repository:

| Change | Bump |
|---|---|
| A **values-schema change** — a key removed, renamed, or given a narrower type | **major** |
| A chart-major bump of anything this chart depends on | **major** |
| A new template, a new value with a default, a pinned image version | **minor** |
| A comment, a README, a CI tweak | **patch** |

The first row is the one worth stating out loud: `values.schema.json` is the interface. A clone
that set a key the schema stopped accepting does not degrade, it stops rendering.

## 1.0.0 — 2026-09-22

Initial template.

- `chart/` renders a Deployment, a Service and a ConfigMap — namespaced, non-RBAC, and nothing
  else. An Ingress is available and off by default.
- `serviceAccount.create: false` as a default, with the reason written next to it, and a template
  that renders the ServiceAccount anyway if you insist rather than silently ignoring the value.
- `values.schema.json` with `additionalProperties: false`, and a CI step that asserts it refuses.
- `hack/check-byo-contract.sh` — an allowlist check of every rendered kind, usable against any
  chart, plus a CI step that asserts the check itself fails on a contract-breaking render.
- The restricted Pod Security Standard by default: non-root, no capabilities, read-only root
  filesystem, seccomp `RuntimeDefault`.
