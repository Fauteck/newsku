# Security Policy

## Supported Versions

Only the `main` branch receives security fixes. There are no LTS branches; please upgrade to the latest container image (`ghcr.io/fauteck/newsku:latest`) before reporting issues.

## Reporting a Vulnerability

Please **do not open a public GitHub issue** for security problems.

Use **[GitHub's Private Vulnerability Reporting](https://github.com/fauteck/newsku/security/advisories/new)** instead. This keeps the report private to the maintainers until a fix is published.

When reporting, please include:

- A clear description of the issue and its impact
- Steps to reproduce (a minimal proof of concept where possible)
- The newsku version / commit SHA you tested against
- Whether the issue is reachable in a default deployment or requires specific configuration

## Response Time

We aim to acknowledge new reports **within 7 days**. For confirmed issues we will:

1. Triage and assign a severity (CVSS-style) within 14 days
2. Coordinate a fix and a release timeline with the reporter
3. Publish a GitHub Security Advisory and credit the reporter (unless anonymity is requested)

newsku is maintained as a self-hosted side project, not a managed service — please keep that in mind when expecting response cadence. We will do our best.

## Out of Scope

The following are **not** considered vulnerabilities for this project:

- Issues that require physical access to the host or local shell access to the running container
- Self-hosted instances deployed without authentication or behind compromised reverse proxies
- Denial-of-service from intentionally malformed RSS feeds added to a user's own account (use feeds you trust)
- Findings against demo or staging instances run by third parties — please report those to whoever runs them
- Missing security headers on `/api/public/**` endpoints, which are intentionally public
- robots.txt directives — see `robots.txt` for the current exclusion list; this is not a security boundary

## Disclosure Policy

We follow a **coordinated disclosure** model. Please give us a reasonable window to ship a fix before publishing details. Once a fix is released, the corresponding GitHub Security Advisory will be made public, with credit to the reporter where applicable.
