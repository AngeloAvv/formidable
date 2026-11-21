# Formidable

Formidable is a reactive form library for Flutter built on annotations and code generation. The monorepo contains these packages:
- `formidable`: the pure Dart core and annotations
- `formidable_generator`: the code generator
- `formidable_flutter`: Flutter bindings, which depend only on `widgets.dart`
- `formidable_material`: Material widgets, built on `material_ui`
- `formidable_cupertino`: Cupertino widgets, built on `cupertino_ui`

## Conventions

- **Language.** Everything versioned is written in English, including code, comments, docs, ADRs, the glossary, file names, commit messages, pull requests and issues.
- **Versioning.** Every package shares one version, starting at 0.1.0. Until the API is declared stable, stay on 0.x: breaking changes to signatures and behavior are expected.
- **Vocabulary.** Use the terms defined in `GLOSSARY.md`, and respect the decisions recorded in `docs/adr/`.

## Agent skills

### Issue tracker

Issues and specs are tracked in GitHub Issues on `AngeloAvv/formidable` through the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

The default triage vocabulary is `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human` and `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

The repo has a single context: `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
