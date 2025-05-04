# Changelog

All notable changes to this project will be documented in this file.

## [2025-05-04] - Code Quality and Consistency Improvements

### Added
- **Style Guide**: Comprehensive Nix code style guide (`docs/STYLE_GUIDE.md`)
  - Defines consistent patterns for lib usage (prefer explicit `lib.` prefix)
  - Documents module structure and documentation standards
  - Establishes variable naming conventions
  - Provides module templates for consistency

- **Code Quality Tools**:
  - Style checker script (`scripts/check-style.sh`) to validate compliance
  - Module generator script (`scripts/new-module.sh`) for consistent module creation
  - Pre-commit configuration for automatic code quality checks
  - CI workflow for automated style validation

- **Development Experience**:
  - Enhanced devshell with code quality tools (nixfmt-plus, statix)
  - Pre-commit hooks for automatic formatting and linting
  - Helpful shell prompts with available commands

- **Documentation**:
  - Added style guide to documentation index
  - Created development section in main README
  - Documented code quality tools and workflows

### Changed
- Updated development shell to include code quality tools
- Enhanced CI pipeline with code quality checks

### Fixed
- Code quality and consistency issue (#9 from project improvements list)
  - Addressed inconsistent documentation patterns
  - Standardized variable naming conventions
  - Created guidelines for `with lib;` vs explicit `lib.` usage
