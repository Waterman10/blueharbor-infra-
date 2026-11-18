# Lab 07 – Central logging searches

Central logs (from other hosts) are in `/var/log/remote/<host>/<program>.log` on WEB01.
Local logs are read with `journalctl`.
Note: `sudo sh -c '...'` is needed so that root expands the `*` (the normal user cannot read /var/log/remote).

## 1. Failed SSH logins on all hosts
Central (all remote hosts):
```bash
sudo sh -c 'grep -hE "Invalid user|Failed password|authentication failure" /var/log/remote/*/sshd*.log'
```
Local (WEB01):
```bash
sudo journalctl -u ssh --since today | grep -E "Invalid user|Failed password"
```
Why: detect password-guessing attacks (to compare with fail2ban bans).

## 2. bh-health warnings
Central:
```bash
sudo sh -c 'grep -hi "warn" /var/log/remote/*/bh-health.log'
```
Local:
```bash
sudo journalctl -t bh-health -p warning --since today
```
Why: find health-check warnings from the BlueHarbor monitoring script on every server.

## 3. sudo usage (who ran what as root)
Central:
```bash
sudo sh -c 'grep -h "COMMAND=" /var/log/remote/*/sudo.log'
```
Local:
```bash
sudo journalctl _COMM=sudo --since today
```
Why: audit administrator actions (who, when, which command) – useful for security and compliance.

## Test result
- `logger -t bhtest "hello from web02"` arrived in `/var/log/remote/web02/bhtest.log`.
- With rsyslog stopped on WEB01, 3 messages sent from WEB02 were queued and arrived after the restart: no log lost.
