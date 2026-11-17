# Lab 06 – BlueHarbor workloads by service model

| Workload | Model (provider) | Why | Still BlueHarbor's job | Risk |
|---|---|---|---|---|
| Mail and office tools | SaaS (Microsoft 365) | Standard need, nothing to install or maintain | User accounts and licences, MFA and access rules, phishing awareness | Provider outage blocks all work; lock-in |
| TrackIt web application | PaaS (Vercel) | Small web app, no OS to manage | Code, environment variables, access, domain | Free-plan limits, lock-in |
| TrackIt database | DBaaS (Supabase) | Managed PostgreSQL: patching, backups and availability handled by the provider | Data and schema, row level security rules, API keys | Free plan pauses inactive projects; data protection (GDPR) depends on region |
| Active Directory | IaaS (Azure VM), synced with Entra ID | Needs full control of Windows Server, group policies and domain | OS patching, accounts and group policies, AD backups | If compromised, the whole company is exposed |
| File shares | SaaS (SharePoint / OneDrive) | Already included with Microsoft 365, accessible everywhere | Permissions, sharing settings, retention rules | Oversharing by public links; ransomware-encrypted files synced |
| Finance accounting software | IaaS (Azure VM) | Needs a specific OS version, which only IaaS allows | OS patching, application updates, network rules | Old OS version reaches end of support and becomes vulnerable |
| Backups | SaaS / BaaS (Azure Backup) | Automatic, off-site copies without own backup hardware | Backup policy (what, how often), restore tests, protect backup access (MFA, immutability) | Backups in the same account as production can be deleted in one attack |
| Monitoring | SaaS (Azure Monitor) | Ready-made dashboards and alerts, no monitoring server to run | Choose what to watch, alert thresholds, who reacts | Too many alerts are ignored; a monitoring outage goes unnoticed |