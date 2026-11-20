# Lab 10 – Secrets inventory

No secret value is written in this file or anywhere in the repository (gitleaks: 18 commits scanned, no leaks found).
All values are stored in the administrator's password manager.

| Secret | Where it lives | Who can read it | How it is rotated | If it leaks |
|---|---|---|---|---|
| Vercel API token `bh-terraform` | Codespaces secret `VERCEL_API_TOKEN` | Repo owner, Codespaces of blueharbor-infra- | Vercel > Tokens: delete + create (30-day expiry), update the Codespaces secret, restart Codespace. **Rotated on 2026-11-20, old token refused ("forbidden – Not authorized").** | Attacker can change or delete the Vercel project and its environment variables |
| Supabase access token (organisation "Cloud CESI") | Codespaces secret `SUPABASE_ACCESS_TOKEN` | Repo owner, Codespaces | Supabase > Account > Access Tokens: revoke + generate, update the secret | Full control of the Supabase organisation: create/delete projects, read data. A previous token was exposed in a chat and must be revoked |
| Supabase database password | Password manager; Terraform variable `TF_VAR_db_password` (memory only); **Terraform state in clear text** | Admin; anyone who can read `terraform.tfstate` | Supabase > Database settings > Reset password (Terraform ignores changes) | Direct access to the whole database, bypassing RLS |
| Supabase publishable key (`sb_publishable_…`) | Vercel env `SUPABASE_KEY` (sensitive), TrackIt | Public by design (any client) | API Keys: create new key, update Vercel through Terraform, delete old key | Low risk: limited to what RLS policies allow anon/authenticated |
| Supabase secret key (`sb_secret_…`) | Password manager only; used once in a terminal (signed URL test) | Admin | API Keys: revoke + create | Bypasses RLS: full read/write/delete on data and storage |
| Supabase S3 access keys `web01-backup` | `/root/.aws/credentials` on WEB01 (root only) | root on WEB01 | Storage > S3 > Access keys: revoke + create, `aws configure` again | Read/delete the off-site backups (encrypted by restic) |
| restic repository password | `/root/.restic-pass` on WEB01 (chmod 600) + password manager | root on WEB01 | `restic key add` then `restic key remove` the old key | Backups become readable; without it, backups are unrecoverable |
| GitHub classic token `web02-push` (repo, workflow) | Password manager; typed at `git push` on WEB02 | Admin | GitHub > Developer settings > Tokens: delete + regenerate (30-day expiry) | Push code and change workflows in all repos |
| `GITHUB_TOKEN` (CI) | Created by GitHub Actions for each run | The workflow run only | Automatic, expires at the end of the run | Limited to `contents: read, packages: write` during the run |
| SSH keys (laptop key, WEB01 `id_ed25519` for Ansible) | `~/.ssh/` on the laptop and on WEB01 | The owner account | Generate a new key, replace it in `authorized_keys`, remove the old one | Shell access as opsadmin on the servers |
| opsadmin sudo password | Password manager; typed for sudo / Ansible `-K` | Admin | `passwd` on each server (Ansible can automate) | Root access on the servers (with SSH access) |
| Grafana admin password | Grafana database on WEB01 | Admin | Grafana > Profile > Change password | Change dashboards and alerts, hide incidents |
| Supabase users `ops` / `viewer` passwords | Supabase Auth (hashed) + password manager | Each user | Reset in Authentication > Users | ops: create/modify shipments; viewer: read only |
| AD / DC01 administrator password | Password manager | Domain admins | Change password, then reset the KRBTGT account if compromise is suspected | Full control of the Windows domain |

## Rules
- Never in Git, chats, screenshots or tickets; Push protection and Secret scanning are enabled on the repository.
- Short expiry (30 days) for API tokens; least scope (organisation token only where needed).
- Terraform state is git-ignored; in production it goes to an encrypted remote backend with restricted access.
- Any exposure = revoke and rotate immediately, then check the logs for misuse.