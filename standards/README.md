# Salesforce Development Standards

All coding standards and rules for this project.

## Files

### Amazon Q Rules (Auto-Applied)
Located in `/.amazonq/rules/`:
- **apex-standards.md** - Apex class templates and best practices
- **trigger-standards.md** - Trigger patterns and handler templates

### Static Analysis
- **pmd-ruleset.xml** - PMD configuration for code scanning

## Usage

**Amazon Q:** Automatically applies rules from `/.amazonq/rules/` when generating code

**PMD:** Run static analysis with VS Code Apex PMD extension using `pmd-ruleset.xml`
