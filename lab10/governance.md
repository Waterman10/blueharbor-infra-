# Lab 10 – Governance and policy as code

## Naming rule
- Cloud resources are named `bh-<service>-<initials>` (e.g. `bh-trackit-gb`), environments `dev`, `test` or `prod`.
- Initials: 2 or 3 lower-case letters, enforced by Terraform.

## Terraform validation rules
| Variable | Rule | Message on failure | Tested |
|---|---|---|---|
| `initials` (cloud/platform) | regex `^[a-z]{2,3}$` | initials: 2 or 3 lower-case letters. | `-var initials=JD` refused |
| `region` (cloud/platform) | only `eu-west-3`, `eu-central-1` | Only EU regions are allowed for BlueHarbor data. | `-var region=us-east-1` refused |
| `env` (cloud/lab-infra) | only `dev`, `test`, `prod` | env must be dev, test or prod. | `-var env=qa` refused (Lab 06) |
With the default region, `terraform plan` shows no change on the Supabase project (no recreation).

## Checkov results
| Scope | Before | After |
|---|---|---|
| Terraform (`cloud/`) | no built-in policies for the vercel/supabase providers | idem – guardrails are the validation rules above |
| Dockerfile | HEALTHCHECK missing (CKV_DOCKER_2) | 48 passed, 0 failed |
| Kubernetes (`k8s/`) | 75 passed, 15 failed | 0 failed, 4 skipped (justified) |

## Checks fixed
| Check | Fix |
|---|---|
| CKV_DOCKER_2 | `HEALTHCHECK` in the Dockerfile |
| CKV_K8S_20 | `allowPrivilegeEscalation: false` |
| CKV_K8S_22 | `readOnlyRootFilesystem: true` + `emptyDir` on `/tmp` |
| CKV_K8S_23, CKV_K8S_40 | `runAsNonRoot: true`, `runAsUser: 10001` |
| CKV_K8S_28, CKV_K8S_37 | `capabilities.drop: ["ALL"]` |
| CKV_K8S_29, CKV_K8S_30 | pod and container `securityContext` |
| CKV_K8S_31 | `seccompProfile: RuntimeDefault` |
| CKV_K8S_38 | `automountServiceAccountToken: false` |
| CKV_K8S_15 | `imagePullPolicy: Always` |
| CKV2_K8S_6 | NetworkPolicy allowing ingress only on TCP 8000 |

## Accepted exceptions (annotations `checkov.io/skip` next to the resource)
| Check | Reason | Production action |
|---|---|---|
| CKV_K8S_43 (image digest) | Lab image referenced by tag | Pin the image by digest |
| CKV_K8S_14 (no `latest`) | Lab uses the `latest` tag built by CI | Deploy the commit SHA tag |
| CKV_K8S_21 (default namespace), Deployment + Service + NetworkPolicy | Single-application minikube lab cluster | Dedicated namespace per application |

## Enforcement
- CI job `policy` runs Checkov on every push and pull request; `build` needs `test` and `policy`.
- Ruleset `protect-main`: pull request required, status checks `test` and `policy` required, force pushes blocked, deletion restricted. A direct push to main was refused (GH013).
- `.github/CODEOWNERS`: `/cloud/ @Waterman10` – every infrastructure change has an owner.