# Fork Maintenance

This repository is a maintained fork of `microsoft/llmwiki`. It exists to carry
reviewed dependency and security changes until they are available upstream. A
single maintainer owns it. This document describes the human maintenance
workflow and contains no consumer-project details.

## Review Cadence

- Review Dependabot alerts, GitHub security advisories, and CI failures at
  least weekly and after every upstream release.
- Check `microsoft/llmwiki` releases at each review and plan a synchronization
  when a release contains required fixes.
- Keep automated security fixes disabled until governance CI is installed and
  verified; re-enablement is a deliberate maintainer decision.

## Upstream Synchronization

1. Fetch `upstream main` and record the exact SHA.
2. Fast-forward fork `main` to that SHA through a reviewed pull request; never
   force-push or rewrite published history.
3. Rebase or merge `develop` changes deliberately, then run the complete
   verification sequence below before merging anything.
4. Record the sync, advisory review, and verification result for every pin
   update.

## Local Verification

Before local execution, review source and lockfile changes, package scripts,
dependency provenance, and credentials available to the process. In a fresh
isolated workspace, run the complete verification sequence:

```bash
npm ci
npm audit
npm run build
npm test
npm run lint
git diff --check
```

Review the complete history-gate script and record its SHA256 before running it
after a commit:

```bash
bash .github/scripts/verify-public-history.sh HEAD^
```

## Runtime Verification

The GitHub-hosted pull-request CI independently repeats install, audit, build,
tests, and lint. The workflow uses no configured secrets, persists no checkout
credentials, and has read-only repository permissions. Every required check
must pass before merge.

## Commit Identity

Use the standard GitHub `noreply` address through command-scoped
`GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`, `GIT_COMMITTER_NAME`, and
`GIT_COMMITTER_EMAIL` variables. Never publish a normal email address and
never change global Git configuration.

## Escalation

- Suspected upstream vulnerabilities are reported privately through Microsoft
  `SECURITY.md`; never open a public issue or pull request for them.
- If an advisory cannot be addressed within the review cadence, consumers
  should repin to the last verified fork commit until a fix is published.
- Unanswerable maintenance questions escalate to the maintainer through a
  repository issue; response times depend on single-maintainer availability.

## Support

Repository issues are for reproducible fork-specific defects only. There is no
service-level agreement or on-call rotation. CI failures block every merge.

## Decommissioning

1. Migrate every consumer to an upstream release containing the required
   fixes.
2. Verify no consumer gitlink references a fork-only commit.
3. Retain license and provenance records.
4. Archive or delete the fork only after an explicit maintainer approval.

## Recovery

If a pinned commit becomes unreachable or a synchronization regresses CI,
consumers repin to the last verified commit. The maintainer restores the
affected branch from its recorded SHA, reruns local static verification, and
requires the complete pull-request CI before republishing.
