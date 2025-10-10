# CI/CD Workflows

This directory is reserved for GitHub Actions workflows.

## Planned Workflows

### 1. CI Pipeline (ci.yml)
- Run on every PR and push to main
- Execute: `flutter analyze`, `flutter test`
- Check code coverage (>85% target)
- Validate build on iOS and Android

### 2. CD Pipeline (cd.yml)
- Deploy to TestFlight (iOS) and Google Play Internal Track (Android)
- Trigger on release tags (v*.*.*)

### 3. PR Checks (pr-checks.yml)
- Lint checks
- Format checks
- Ensure development_process.md is updated

---

To be implemented in Phase 0.1 (Project Infrastructure).

