# Lab 06 – Infrastructure as code

## Why the state file is in .gitignore

- The state file (`terraform.tfstate`) is Terraform's memory: it records every resource it built, with IDs, settings and sometimes secrets (passwords, tokens, connection strings) in plain text.
- If it were committed, anyone with access to the repository could read those secrets, and they would stay in the Git history forever.
- It changes on every apply, so several people working on it through Git would create conflicts and could corrupt it.
- It describes one specific environment at a given moment; it is generated, not source code.
- In a team, the state is stored in a protected remote backend (e.g. Terraform Cloud, Azure Storage, S3) with locking and encryption, not in Git.

What goes in Git: `main.tf` (the desired state) and `.terraform.lock.hcl` (the pinned provider versions).