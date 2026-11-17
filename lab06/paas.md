# Lab 06 – PaaS (Vercel) compared with Lab 03 (VM) and 6.3 (Terraform + Docker)

## Tasks I did NOT have to do on Vercel

| Task | Lab 03 (VM WEB01) | 6.3 (Docker + Terraform) | 6.4 (Vercel PaaS) |
|---|---|---|---|
| Operating system (install, patch, harden) | Done by me | Base image chosen by me | Done by Vercel |
| Web server (nginx/gunicorn, config) | Done by me | nginx container defined by me | Done by Vercel |
| TLS certificate (HTTPS) | Done by me | Not configured | Automatic (Vercel) |
| Scaling (more servers when traffic grows) | Manual (clone VMs) | Manual (web_count) | Automatic (Vercel) |
| Network, firewall, ports | Done by me (UFW, netplan) | Ports mapped by me | Done by Vercel |
| Deployment | Manual copy | terraform apply | Automatic on git push |

## What is still my job on Vercel
- The application code and its tests
- Environment variables (APP_VERSION, later Supabase keys)
- Who has access to the project and to previews
- The domain name and watching usage against free-plan limits

## Conclusion
With PaaS I only manage the code and its settings. The platform runs the OS, web server, HTTPS and scaling. I gain speed and less maintenance, but I have less control and depend on Vercel's limits and pricing (lock-in).