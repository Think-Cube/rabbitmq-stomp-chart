# Contributing to rabbitmq-stomp-chart

Thank you for your interest in contributing!

## How to Contribute

1. **Fork** this repository.
2. **Create a branch**: `git checkout -b fix/description` or `feat/description`
3. **Make your changes** — see guidelines below.
4. **Open a Pull Request** using the PR template.

## Chart Guidelines

- Bump `version` in `Chart.yaml` for every change to the chart, following semantic versioning. Changes that break existing values need a new major version.
- Keep `appVersion` in step with the RabbitMQ version of the image in `values.yaml`.
- Add every new value to `values.yaml` with a `# --` comment, to `values.schema.json` and to the values table in the README.
- Use the name and label helpers in `templates/_helpers.tpl`; do not hard-code names or namespaces.
- Pin images to a specific tag, and run containers as non-root.
- Do not embed secrets, tokens, or credentials.

## Testing Locally

```bash
helm lint --strict . --values ci/default-values.yaml
helm template test . --values ci/ingress-values.yaml
```

To install into a local cluster such as kind:

```bash
helm install test . --values ci/default-values.yaml --wait
helm test test
```

Pull requests run the same checks for every file in `ci/`. Add a file there when you add a configuration worth testing.

## Reporting Issues

Use the issue templates:
- **Bug report** — something is broken or behaves unexpectedly.
- **Feature request** — suggest an improvement.

Problems in the container image belong in [docker-rabbitmq-stomp](https://github.com/Think-Cube/docker-rabbitmq-stomp/issues).

## Code of Conduct

By contributing, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).
