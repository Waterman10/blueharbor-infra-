# Lab 09 – Docker

## Image
- Base `python:3.12-slim`, dependencies installed before copying the code (layer cache).
- Runs as `appuser` (not root): `docker exec trackit id` → uid=1001(appuser).
- `.dockerignore` excludes caches and tests.
- Rebuild after changing app.py: layers up to `pip install` are CACHED; only `COPY app.py` and the following layers are rebuilt.

## The firewall trap
Observation: `ufw status` on WEB02 has no rule for 8000, yet `curl 10.10.20.21:8000/health` from WEB01 answers.

Why:
- `docker run -p 8000:8000` makes Docker add its **own iptables/nftables rules** (NAT `DNAT` in PREROUTING + accept rules in the `DOCKER` chain).
- Incoming packets to port 8000 are redirected to the container **before** they reach the INPUT chain where ufw filters. They go through the **FORWARD** path (host → container network), which ufw's rules do not cover.
- So ufw "says" the port is closed, but Docker has opened it to every network the host is on.

Risk: a container published "for a test" is exposed to the whole network (or the Internet on a public server), bypassing the firewall policy.

How to avoid it:
- Publish only on localhost when external access is not needed: `-p 127.0.0.1:8000:8000`.
- Put filtering rules in the `DOCKER-USER` chain (evaluated before Docker's rules), or use a tool such as `ufw-docker`.
- Put a reverse proxy (nginx) in front and expose only 80/443.
- Always test from another host (as done here), never trust `ufw status` alone.
