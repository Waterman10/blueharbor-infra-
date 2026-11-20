# Lab 10 – Compliance map and security posture

Frameworks: NIST Cybersecurity Framework 2.0 (functions: Govern, Identify, Protect, Detect, Respond, Recover)
and ISO/IEC 27001:2022 Annex A (themes: Organisational 5.x, People 6.x, Physical 7.x, Technological 8.x).

## Controls implemented during the course

| # | Control | Where | NIST CSF 2.0 | ISO/IEC 27001:2022 Annex A | Evidence in the repository |
|---|---|---|---|---|---|
| 1 | File/folder ACLs (least privilege on shares) | DC01 / file server | Protect (PR.AA) | Technological – 8.3 Information access restriction | lab02/ (ACL notes) |
| 2 | Host firewall ufw (default deny, allow-lists by subnet) | WEB01, WEB02, STOR01 | Protect (PR.IR) | Technological – 8.20 Networks security | lab03/ (hardening), lab09/docker.md (Docker/ufw trap) |
| 3 | SSH key authentication, passwords disabled | All Linux servers, Ansible | Protect (PR.AA) | Technological – 8.5 Secure authentication | lab03/, ansible/inventory.ini |
| 4 | GPO password policy | Active Directory (DC01) | Protect (PR.AA) | Organisational – 5.17 Authentication information | lab02/ (GPO notes) |
| 5 | fail2ban on SSH (ban after 4 failures) | WEB01 | Protect / Detect (PR.AA, DE.CM) | Technological – 8.5 Secure authentication; 8.16 Monitoring activities | lab05/incident-report.md |
| 6 | Suricata IDS with custom rule | WEB01 | Detect (DE.CM, DE.AE) | Technological – 8.16 Monitoring activities | lab05/incident-report.md |
| 7 | Incident drill: timeline and report | WEB01/WEB02 | Respond (RS.MA, RS.AN) | Organisational – 5.26 Response to information security incidents | lab05/incident-report.md |
| 8 | Central logging with rsyslog (queue, no loss) | WEB01 collector, WEB02 | Detect (DE.CM) | Technological – 8.15 Logging | lab07/logging.md |
| 9 | Monitoring and CPU alert (Prometheus + Grafana) | WEB01 | Detect (DE.CM) | Technological – 8.16 Monitoring activities | lab07/ (dashboard + alert screenshots) |
| 10 | Configuration as code + rolling update with health checks | Ansible | Protect (PR.PS) | Technological – 8.9 Configuration management; 8.32 Change management | ansible/web.yml, ansible/rolling.yml, lab07/orchestration.md |
| 11 | RAID 1 + LVM on the storage server | STOR01 | Protect (PR.IR) | Technological – 8.14 Redundancy of information processing facilities | lab08/ (RAID notes), lab08/nas.md |
| 12 | Encrypted backups 3-2-1 (restic, off-site copy), restore tested and timed | WEB01 → STOR01 → Supabase bucket | Recover (RC.RP); Protect (PR.DS) | Technological – 8.13 Information backup | lab08/dr-plan.md |
| 13 | Disaster recovery plan (RPO/RTO per service) | All services | Recover (RC.RP) | Organisational – 5.30 ICT readiness for business continuity | lab08/dr-plan.md |
| 14 | Private bucket without policy, signed URLs | Supabase Storage | Protect (PR.DS) | Technological – 8.3 Information access restriction | lab08/object-storage.md |
| 15 | Row level security policies (anon read, ops write, viewer refused 403) | Supabase DB | Protect (PR.AA) | Technological – 8.3 Information access restriction | lab10/access-matrix.md |
| 16 | GitHub teams (ops Maintain, auditors Read) + access matrix | GitHub org bh-gb-org | Govern / Protect (GV.RR, PR.AA) | Organisational – 5.15 Access control; 5.18 Access rights | lab10/access-matrix.md |
| 17 | Branch ruleset (PR + checks required, no force push) + CODEOWNERS | GitHub repository | Protect (PR.PS) | Technological – 8.32 Change management | lab10/governance.md, .github/CODEOWNERS |
| 18 | Policy as code: Terraform validation (EU region, naming) + Checkov job in CI | Terraform, CI | Govern / Identify (GV.PO, ID.RA) | Technological – 8.9 Configuration management; 8.25 Secure development life cycle; Organisational – 5.34 Privacy and protection of PII | cloud/platform/main.tf, .github/workflows/ci.yml, lab10/governance.md |
| 19 | Container hardening (non-root, read-only FS, drop ALL capabilities, seccomp, NetworkPolicy) | Docker / Kubernetes | Protect (PR.PS) | Technological – 8.9 Configuration management; 8.27 Secure system architecture | trackit/Dockerfile, k8s/trackit.yaml, lab09/kubernetes.md |
| 20 | CI tests before build + image registry with commit tags | GitHub Actions, GHCR | Protect (PR.PS) | Technological – 8.29 Security testing in development and acceptance | .github/workflows/ci.yml, lab09/ |
| 21 | Secret scanning + push protection + gitleaks history scan | GitHub repository | Detect / Protect (DE.CM, PR.DS) | Technological – 8.12 Data leakage prevention | lab10/secrets.md |
| 22 | Secrets inventory and token rotation (Vercel token rotated, old one refused) | Codespaces secrets, Vercel, Supabase | Protect (PR.AA) | Organisational – 5.17 Authentication information; Technological – 8.24 Use of cryptography | lab10/secrets.md |
| 23 | MFA on GitHub, Vercel, Supabase | Admin accounts | Protect (PR.AA) | Technological – 8.5 Secure authentication | lab10/secrets.md (screenshots kept privately) |
| 24 | Vulnerability management: Dependabot + CodeQL | GitHub repository | Identify (ID.RA) | Technological – 8.8 Management of technical vulnerabilities | This file (posture section) |

People (6.x) and Physical (7.x) themes are not covered by these technical labs: physical security of the cloud data centres is the providers' responsibility (see below); awareness training (6.3) is an organisational action to plan.

## Measured posture (2026-11-20)

| Measure | Result |
|---|---|
| Checkov – Dockerfile | before 47 passed / 1 failed → after **48 passed / 0 failed** |
| Checkov – Kubernetes | before 75 passed / 15 failed → after **86 passed / 0 failed / 4 skipped (justified)** |
| Checkov – Terraform | no built-in policies for vercel/supabase providers; guardrails = Terraform validation rules |
| gitleaks (full history) | 18 commits scanned, **no leaks found** |
| GitHub Dependabot | enabled, **0 open alerts** |
| GitHub CodeQL (default setup) | enabled, **0 open alerts** on main |
| Supabase Security Advisor (bh-trackit-dev) | 0 errors, 1 warning, 0 info |
| – Leaked Password Protection Disabled | **Justified**: available only on the Pro plan. Compensating control: minimum length 12 with lower/upper case, digits and symbols; MFA on admin accounts. Enable when moving to Pro. |

## Shared responsibility

| Question | Vercel (PaaS) | Supabase (DBaaS) | GitHub Codespaces (dev environment) |
|---|---|---|---|
| Who patches the OS? | Vercel | Supabase (database servers and Postgres) | GitHub (host); BlueHarbor updates the dev container image and the tools installed in it |
| Who filters the network? | Vercel (edge, DDoS protection); BlueHarbor decides which routes the app exposes and can add firewall rules | Supabase (infrastructure); BlueHarbor controls exposure through API keys and RLS | GitHub (isolation between codespaces); BlueHarbor decides which forwarded ports are public or private |
| Who encrypts data at rest? | Vercel (platform storage, environment variables) | Supabase (database and storage encryption at rest) | GitHub (codespace disks); BlueHarbor keeps secrets out of files (Codespaces secrets) |
| Who decides access? | **BlueHarbor**: team members, tokens, preview protection | **BlueHarbor**: users, roles in app_metadata, RLS policies, keys | **BlueHarbor**: who can create codespaces on the repo, which secrets are available |
| Who responds to a leaked credential? | **BlueHarbor** (rotate the token) | **BlueHarbor** (rotate keys and passwords) | **BlueHarbor** (rotate the secret, restart the codespace) |