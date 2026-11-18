# Lab 07 – Configuration management vs orchestration

## Configuration management (Exercise 7.2 – web.yml)
- Goal: bring every server to a **desired state** (packages installed, page deployed, firewall rule, nginx running).
- Each server is handled **independently**; Ansible works on all of them in parallel (forks = 10).
- The order between servers does not matter.
- Idempotent: running it again changes nothing if the state is already correct (changed=0).
- Question it answers: "**What** must each server look like?"

## Orchestration (Exercise 7.3 – rolling.yml)
- Goal: run a **sequence of steps across several servers in a controlled order**.
- `serial: 1`: one server at a time, so the service stays available on the others.
- Health check + assert after each server: the new version is verified before moving on.
- `max_fail_percentage: 0`: at the first failure the run **stops**, so a bad version never reaches the whole tier.
- Question it answers: "**In what order and under which conditions** do we change the servers?"

## What I observed
- Normal run: one host per batch (web01, then web02), both on version 1.1.0.
- With nginx stopped on WEB02 and version 1.2.0: web01 was updated and checked, then the health check failed on web02 and the run stopped (failed=1).

## In short
Configuration management defines the **target state** of each server; orchestration controls **how and when** a change is rolled out across servers, to avoid a full outage.
