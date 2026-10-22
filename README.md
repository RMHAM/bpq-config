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

Install the development dependencies used by the lint check:

```sh
cpanm --with-develop --installdeps .
```

If `cpanm` is not installed, bootstrap it with
`curl -L https://cpanmin.us | perl - --local-lib=~/perl5 App::cpanminus`.

The pre-commit hook runs before every commit:

1. **Syntax check** — `perl -c bpq-config` rejects files with compile errors.
2. **Test suite and lint** — `BPQ_REQUIRE_LINT=1 prove t/` runs all tests in
   `t/`, including `t/12-critic.t`, which lints `bpq-config` with Perl::Critic.
   The commit is blocked if any test fails or the linter reports a violation.

## Linting

`bpq-config` is checked with [Perl::Critic](https://metacpan.org/pod/Perl::Critic)
at severity 3 using `.perlcriticrc`. The profile enforces unsafe and surprising
constructs (two-argument `open`, explicit `return undef`, reused/ambiguous
names, missing final returns) and documents the legacy style rules that are
switched off to avoid risky rewrites.

```sh
perlcritic --profile .perlcriticrc bpq-config
```

Plain `prove t/` skips the lint test when `perlcritic` is not installed; the
pre-commit hook requires it.

## Download host unavailable

The upstream file host for `pilinbpq`, the HTML pages and the APRS tools can be
down or return 403. Failed downloads never replace existing files. To use a
mirror that serves the same layout, set `BPQ_MIRROR`:

```sh
BPQ_MIRROR=https://example.org/bpq ./bpq-config
```

The mirror must provide `Downloads/pilinbpq`, `Downloads/HTMLPages.zip`,
`Downloads/pitnc_getset.zip`, `Downloads/piBPQAPRS`,
`Downloads/LinBPQAPRS.zip` and `Documents/Samples/APRSHTML.zip`.
