# CI/CD Setup

## GitHub Secrets Required

Add `SFDX_AUTH_URL` to your repository secrets:

1. Authenticate locally:
   ```bash
   sf org login web --alias myorg
   ```

2. Get auth URL:
   ```bash
   sfdx force:org:display -u myorg --verbose --json
   ```

3. Copy the `sfdxAuthUrl` value

4. Add to GitHub: Settings → Secrets → Actions → New repository secret
   - Name: `SFDX_AUTH_URL`
   - Value: (paste the sfdxAuthUrl)

## Workflow Triggers
- Push to `main` branch → Deploy + Test
- Pull requests → Validate + Test
