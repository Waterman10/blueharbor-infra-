# Lab 10 – Access matrix (least privilege)

| Role | Platform | Permission | Scope | How it is granted | How it is removed |
|---|---|---|---|---|---|
| Anonymous customer | Supabase (TrackIt API) | Read only (SELECT) | Table `public.shipments`; no write, no other table | RLS policy "anyone can read shipments" for role `anon`; public (publishable) key in TrackIt | Drop the policy or revoke/rotate the publishable key |
| Viewer | Supabase Auth + DB | Sign in + read; **insert refused (403)** | Table `public.shipments` | Supabase user `viewer@blueharbor.test`, no `role` in app_metadata | Delete or ban the user in Authentication > Users |
| Ops | Supabase Auth + DB | Read, insert, update (**201**) | Table `public.shipments` | User `ops@blueharbor.test` with `app_metadata.role = "ops"` (set by an admin, not editable by the user) + policies "ops can insert/update shipments" | Remove the role from app_metadata (effective at next token) or delete the user; drop the policies |
| Ops team | GitHub org `bh-gb-org` | Maintain (push, issues, PRs, some settings) | Repository `bh-runbooks` | Member of team `ops`, team role Maintain | Remove from the team / organisation |
| Auditor | GitHub org `bh-gb-org` | Read + open issues; **push refused** | Repository `bh-runbooks` | Member of team `auditors`, team role Read | Remove from the team / organisation |
| CI pipeline | GitHub Actions / GHCR | Read the code, publish images | Repository `blueharbor-infra-`, package `ghcr.io/waterman10/trackit` | `GITHUB_TOKEN` per run with `permissions: contents: read, packages: write` | Token expires at the end of each run; reduce `permissions` in ci.yml |
| Terraform | Vercel + Supabase | Create/change/delete projects, env variables, Supabase project | Vercel team project `bh-trackit-gb`, Supabase organisation "Cloud CESI" | Codespaces secrets `VERCEL_API_TOKEN` (30-day token) and `SUPABASE_ACCESS_TOKEN` (organisation-scoped) | Revoke the token in Vercel/Supabase and delete the Codespaces secret |
| Repository owner | GitHub | Admin (can bypass rules) | Repository `blueharbor-infra-`, org `bh-gb-org` | Account owner (MFA required) | Transfer ownership; limit bypass in the ruleset |

## Principles applied
- **Least privilege:** each role gets only what it needs (viewer reads, ops writes, auditors read).
- **Roles, not individuals:** access is given to teams (GitHub) and roles (Supabase app_metadata).
- **Deny by default:** without a policy, Supabase refuses; the `backups` bucket has no policy.
- **Short-lived credentials:** CI token per run, Terraform tokens with expiry, rotation documented in lab10/secrets.md.