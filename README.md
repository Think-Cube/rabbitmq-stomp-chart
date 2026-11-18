# rabbitmq-stomp-chart

[![Chart](https://github.com/Think-Cube/rabbitmq-stomp-chart/actions/workflows/chart.yml/badge.svg)](https://github.com/Think-Cube/rabbitmq-stomp-chart/actions/workflows/chart.yml)
[![Release](https://img.shields.io/github/v/release/Think-Cube/rabbitmq-stomp-chart)](https://github.com/Think-Cube/rabbitmq-stomp-chart/releases)
[![License](https://img.shields.io/github/license/Think-Cube/rabbitmq-stomp-chart)](LICENSE)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/rabbitmq-stomp-chart)](https://artifacthub.io/packages/search?repo=rabbitmq-stomp-chart)

Helm chart for a single-node [RabbitMQ](https://www.rabbitmq.com/) with the management, STOMP and Web STOMP plugins, using the [Think-Cube rabbitmq-stomp image](https://github.com/Think-Cube/docker-rabbitmq-stomp).

The chart is published to GitHub Container Registry as an OCI artifact and signed with keyless Cosign. It is tested with Helm 4 and also installs with Helm 3.8 or newer, the first version with OCI support.

## Install

```bash
helm install rabbitmq oci://ghcr.io/think-cube/charts/rabbitmq-stomp \
  --namespace rabbitmq --create-namespace \
  --set auth.username=admin \
  --set auth.password='change-me'
```

This installs the newest version. In production, pin one from [Releases](https://github.com/Think-Cube/rabbitmq-stomp-chart/releases) with `--version`.

The install fails until you set a user and password, or point `auth.existingSecret` to a Secret you manage with the keys `username` and `password`. RabbitMQ creates this user on its first start only; to change the password later, use the management UI or `rabbitmqctl change_password`.

The built-in `guest` account only works from inside the pod.

## Connecting

| Protocol | Port | Address inside the cluster |
|---|---|---|
| AMQP | `5672` | `amqp://<release>-rabbitmq-stomp.<namespace>.svc:5672` |
| STOMP | `61613` | `<release>-rabbitmq-stomp.<namespace>.svc:61613` |
| STOMP over WebSockets | `15674` | `ws://<release>-rabbitmq-stomp.<namespace>.svc:15674/ws` |
| Management UI and HTTP API | `15672` | `http://<release>-rabbitmq-stomp.<namespace>.svc:15672` |
| Prometheus metrics | `15692` | `http://<release>-rabbitmq-stomp.<namespace>.svc:15692/metrics` |

Set `ingress.enabled` to publish the management UI. The install notes print the exact addresses for your release.

Run CLI tools inside the pod as they are, for example `kubectl exec <release>-rabbitmq-stomp-0 -- rabbitmqctl status`. The pod runs as the `rabbitmq` user, so they can read the node's Erlang cookie.

## Memory and disk

RabbitMQ blocks publishers when it uses more memory than `rabbitmq.memoryHighWatermark`, or when free disk space falls below `rabbitmq.diskFreeLimit`. Inside a container RabbitMQ does not reliably see its memory limit, so the chart sets an absolute threshold. Keep it at about 75% of `resources.limits.memory`; the defaults are `768Mi` of `1Gi`.

## Storage

Messages and definitions are stored in a PersistentVolumeClaim of the cluster's default storage class. The claim is kept when the release is uninstalled; set `persistence.keepOnUninstall: false` to delete it with the release.

## High availability

This chart runs one node. For a highly available cluster with quorum queues, use the [RabbitMQ Cluster Operator](https://www.rabbitmq.com/kubernetes/operator/operator-overview).

## Values

| Key | Default | Description |
|---|---|---|
| `image.repository` | `ghcr.io/think-cube/rabbitmq-stomp` | Image |
| `image.tag` | `2.0.0` | Image tag |
| `image.digest` | `""` | Image digest; used instead of the tag when set |
| `auth.existingSecret` | `""` | Existing Secret with `username` and `password` |
| `auth.username` / `auth.password` | `""` | Admin user created on first start |
| `rabbitmq.memoryHighWatermark` | `768Mi` | Memory use at which publishers are blocked |
| `rabbitmq.diskFreeLimit` | `1Gi` | Free disk space below which publishers are blocked |
| `rabbitmq.extraConfig` | `""` | Extra `rabbitmq.conf` settings |
| `rabbitmq.extraEnv` | `[]` | Extra environment variables |
| `resources` | requests `250m`/`1Gi`, limit `1Gi` | Resources of the RabbitMQ container |
| `service.type` | `ClusterIP` | Service type |
| `service.ports.*` | `5672`, `15672`, `61613`, `15674`, `15692` | Service ports |
| `ingress.enabled` | `false` | Create an Ingress for the management UI |
| `ingress.className` / `annotations` / `host` / `tls` | | Ingress settings |
| `persistence.enabled` | `true` | Store data in a PersistentVolumeClaim |
| `persistence.storageClass` | `""` | Storage class; `-` disables dynamic provisioning |
| `persistence.size` | `8Gi` | Size of the claim |
| `persistence.keepOnUninstall` | `true` | Keep the claim when the release is uninstalled |
| `serviceAccount.create` | `true` | Create a ServiceAccount |
| `podSecurityContext` | non-root UID `100`, `RuntimeDefault` seccomp | Pod security context |
| `securityContext` | no privilege escalation, all capabilities dropped | Container security context |
| `terminationGracePeriodSeconds` | `60` | Time RabbitMQ gets to shut down |
| `nodeSelector`, `tolerations`, `affinity` | empty | Scheduling |

`values.schema.json` validates every value, so a typo in a key fails the install instead of being ignored.

## Verify the chart

```bash
cosign verify ghcr.io/think-cube/charts/rabbitmq-stomp:<version> \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github\.com/Think-Cube/workflows/\.github/workflows/helm-chart\.yml@refs/tags/v.+$'
```

## Development

Pull requests lint the chart, validate the rendered manifests with kubeconform and install it into a kind cluster with each file in `ci/`, then run `helm test`. The test logs in to the management API, checks that `guest` is refused, and connects over STOMP and Web STOMP. Pushing a `vX.Y.Z` tag that matches `version` in `Chart.yaml` publishes the chart.

## License

This project is licensed under the [MIT License](LICENSE).
