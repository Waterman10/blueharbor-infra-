# Lab 09 – Kubernetes (minikube on WEB02)

## What was demonstrated
- Deployment of 3 pods from `ghcr.io/waterman10/trackit:latest` + NodePort Service: 6 requests answered by different pods (load balancing).
- Self-healing: a deleted pod was recreated automatically (3 replicas kept).
- Scaling: 3 → 5 → 3 replicas with `kubectl scale` (horizontal scaling).
- Rolling update to APP_VERSION=1.3.0, then `kubectl rollout undo` back to 1.2.0.
- Failed release (tag `nope`): new pod in ImagePullBackOff, old pods kept serving, then rollback.

## What each probe protects against
| Probe | Checks | Protects against |
|---|---|---|
| readinessProbe (`/health`, after 3 s) | Is the pod ready to receive traffic? | Sending users to a pod that is still starting or temporarily unable to answer. During a rolling update, old pods are only removed once new ones are ready, so a broken version never receives traffic. |
| livenessProbe (`/health`, after 10 s) | Is the pod still alive? | A process that is frozen or deadlocked but not crashed: Kubernetes restarts the container automatically instead of leaving a dead pod in the Service. |

## What each resource setting protects against
| Setting | Value | Protects against |
|---|---|---|
| requests.cpu | 50m | The scheduler placing more pods than the node can run: each pod is guaranteed at least this CPU. |
| requests.memory | 64Mi | Overloading a node with pods that will not have enough memory. |
| limits.cpu | 250m | One pod (bug, infinite loop, attack) taking all the CPU and slowing the other pods ("noisy neighbour"): the pod is throttled. |
| limits.memory | 128Mi | A memory leak exhausting the node's RAM: the container is killed (OOMKilled) and restarted, the node and the other pods stay safe. |

## Rolling update settings
- `maxUnavailable: 1`: at most one pod is down during an update, so the service stays available.
- `maxSurge: 1`: at most one extra pod is created, which limits the resources needed during the update.
