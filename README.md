# alethia-starter-chart

A minimal-but-real **bring-your-own Helm chart** for [Alethia](https://alethialabs.io): a chart in
your own Git repository that Alethia installs as an add-on, under an ArgoCD project that confines
it to its own namespace.

It renders three resources — a Deployment, a Service and a ConfigMap — and every one of them is
namespaced and not RBAC. That is not a coincidence, it is the contract, and
`hack/check-byo-contract.sh` fails the build if a change ever breaks it.

```
chart/
  Chart.yaml            chart version 1.0.0, app version 1.29
  values.yaml           every knob, each with the reason for its default
  values.schema.json    the interface — a change here is a MAJOR bump
  templates/            Deployment · Service · ConfigMap · optional Ingress
hack/
  check-byo-contract.sh the contract, mechanised — run it against your own chart
```

## Use it

1. **Use this template** to create your own repository.
2. In Alethia: **Add-ons → Bring your own chart**.
   - **Chart repository** — `https://github.com/<you>/<your-repo>`
   - **Chart path** — `chart`
   - **Ref** — `HEAD`, or a tag if you want deploys to be explicit
3. Deploy. Alethia creates the namespace, registers a per-repository credential, applies the
   hardened project, and applies the Application.

Locally, before any of that:

```bash
helm lint chart --strict
helm template starter chart
hack/check-byo-contract.sh chart
```

## What your chart may create — the whole rule

Alethia applies an ArgoCD `AppProject` per project that is **default-deny**:

| | Permitted |
|---|---|
| Cluster-scoped resources — `Namespace`, `ClusterRole`, `CustomResourceDefinition`, `StorageClass`, … | **none**, of any kind |
| `Role`, `RoleBinding`, `ServiceAccount` — namespaced, but blacklisted | **none** |
| Other namespaced resources, in the chart's own namespace | yes |
| Source repositories | only the one you configured |

`serviceAccount.create` therefore defaults to **`false`**, and `automountServiceAccountToken` is
`false` on the pod: a workload that never calls the API server has no use for a token, and the
project would refuse the ServiceAccount that would carry one anyway.

**If your chart needs a cluster-scoped resource it cannot be a BYO chart as it stands.** Split the
cluster-scoped part out and have an administrator apply it once — from the apps-destination
repository, where the project is wide open — or request the capability as a marketplace add-on.
[`alethia-starter-ai`](https://github.com/alethialabs-io/alethia-starter-ai) is the worked example
of that split: KServe and Kueue on one side of the line, the workloads on the other.

## `hack/check-byo-contract.sh`

Point it at any chart, not just this one:

```bash
hack/check-byo-contract.sh ../my-other-chart --values prod.yaml
```

It renders the chart and checks every `kind:` against an **allowlist** of namespaced, non-RBAC
kinds. An allowlist and not a list of forbidden kinds, because "is this kind cluster-scoped?" has
no offline answer for a kind nobody anticipated, and a deny list answers *no* for every one of
them — which is the direction that passes on exactly the regression it exists to catch.

It also refuses to report a pass on a render it could not read: an empty render, or one with no
`kind:` in it, exits 2 rather than 0.

## Sync behaviour, once it is installed

Two things Alethia deliberately does **not** do to your chart:

- **Prune is off.** A resource you delete from the chart keeps running. To remove it, delete it
  yourself or disable the add-on — which deletes everything the chart created, finalizer and all.
- **Self-heal is off.** A `kubectl edit` sticks, and the Application reports `OutOfSync` and leaves
  it alone. An `OutOfSync` BYO chart is informational, not an error.

Because self-heal is off, a deploy will not revert a hand edit — there is nothing to sync. Push a
commit, delete the edited resource, or sync the Application from ArgoCD directly.

**A push to the tracked ref deploys.** Attach a tag or a commit SHA instead of a branch if you want
a release step.

## Versioning

`TEMPLATE_VERSION` and `chart/Chart.yaml`'s `version` hold the same semver, and CI fails if they
disagree or if the chart changes without one of them moving. A **values-schema change is a major**
— see CHANGELOG.md.

## CI

`.github/workflows/validate.yml`, on every push, free: `helm lint --strict`, `helm template` with
the defaults and with every documented option on, an assertion that `values.schema.json` actually
refuses an unknown key, the contract check, and — the part that matters — an assertion that the
contract check **fails** on a chart that breaks the contract. A check that had quietly stopped
looking would otherwise report a pass on every run and read exactly like a working one.

## The other starter templates

| Repository | What it is |
|---|---|
| [`alethia-starter-apps`](https://github.com/alethialabs-io/alethia-starter-apps) | the apps-destination repository — root manifest, overlays, add-ons |
| [`alethia-starter-chart`](https://github.com/alethialabs-io/alethia-starter-chart) | this one |
| [`alethia-starter-ai`](https://github.com/alethialabs-io/alethia-starter-ai) | RAG, a vector DB, CPU model serving and batch queueing, split across both trust levels |
| [`alethia-examples`](https://github.com/alethialabs-io/alethia-examples) | larger worked references, including the isolation ladder |

Full contract: [Bring Your Own Charts](https://alethialabs.io/docs/concepts/bring-your-own-charts).
