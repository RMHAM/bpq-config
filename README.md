# bpq-config

Modified copy of the original [bpq-config](https://www.prinmath.com/ham/) by Willem A. Schreuder (AC0KQ).

This repo is for testing purposes only. See the [original](https://www.prinmath.com/ham/) for the latest version.

Self-update (`bpq-config -u`, or the update option in the menu) downloads
`bpq-config` from this repo's `main` branch:
`https://raw.githubusercontent.com/RMHAM/bpq-config/main/bpq-config`. Because
GitHub sends no `Last-Modified` header, the published copy is compared byte
for byte with the local one and only replaced when it differs.

## Setup

After cloning, enable the pre-commit hooks:

```sh
git config core.hooksPath .githooks
```

The pre-commit hook runs before every commit:

1. **Syntax check** — `perl -c bpq-config` rejects files with compile errors.
2. **Test suite** — `prove t/` runs all tests in `t/`. The commit is blocked if any test fails.
