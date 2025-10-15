# Makefile for pindrop-challenge
# Modern Python project with Clean Architecture

.PHONY: help install dev-install test lint lint-fix format format-fix type-check coverage validate clean run \
	test-all test-unit test-integration test-fast

# ============================================================================
# Help & Documentation
# ============================================================================

help: ## Show this help message
	@echo "pindrop-challenge - Available commands:"
	@echo ""
	@echo "Setup & Installation:"
	@grep -E '^(install|dev-install):.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Development:"
	@grep -E '^(run|test|lint|format|type-check|validate):.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Testing:"
	@grep -E '^(test[^-]|test-all|test-unit|test-integration|test-fast|coverage):.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Cleanup:"
	@grep -E '^(clean.*):.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'

# ============================================================================
# Setup & Installation
# ============================================================================

install: ## Install production dependencies
	uv pip install -e .

dev-install: ## Install all dependencies including dev and test extras
	uv pip install -e ".[dev,test-integration]"
	@echo "Installing tox globally for convenience..."
	uv tool install tox --with tox-uv
	@echo "Installing pre-commit hooks..."
	pre-commit install

# ============================================================================
# Development & Running
# ============================================================================

run: ## Run the application
	uv run python -m pindrop_challenge

# ============================================================================
# Testing
# ============================================================================

test: ## Run unit tests (default)
	uv run pytest tests/unit/ -xvs --tb=short

test-all: ## Run all tests (unit + integration)
	uv run pytest tests/ -xvs --tb=short

test-unit: ## Run unit tests explicitly
	uv run pytest tests/unit/ -xvs

test-integration: ## Run integration tests only
	uv run pytest tests/integration/ -xvs --tb=short

test-fast: ## Run tests quickly (less verbose)
	uv run pytest tests/unit/ -x -q

coverage: ## Run tests with coverage report
	uv run pytest tests/ \
		--cov=src/pindrop_challenge \
		--cov-report=term-missing \
		--cov-report=html \
		--cov-report=xml
	@echo "Coverage report generated in htmlcov/index.html"

# ============================================================================
# Code Quality
# ============================================================================

lint: ## Run linter (ruff)
	uv run ruff check src/ tests/

lint-fix: ## Run linter and auto-fix issues
	uv run ruff check src/ tests/ --fix

format: ## Format code with ruff
	uv run ruff format src/ tests/

format-check: ## Check if code is properly formatted
	uv run ruff format src/ tests/ --check

type-check: ## Run type checking with ty
	uv run ty check src/ tests/

validate: ## Run all validation steps (tests, lint, format, type-check)
	@echo "🧪 Running tests..."
	@make test-fast
	@echo ""
	@echo "🔍 Running linter..."
	@make lint
	@echo ""
	@echo "📝 Checking format..."
	@make format-check
	@echo ""
	@echo "🔎 Running type checker..."
	@make type-check
	@echo ""
	@echo "✅ All validation checks passed!"

# ============================================================================
# Cleanup
# ============================================================================

clean: ## Clean Python cache and build files
	@echo "🧹 Cleaning Python files..."
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "build" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "dist" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name ".coverage" -delete 2>/dev/null || true
	@find . -type f -name "coverage.xml" -delete 2>/dev/null || true
	@find . -type f -name "*.py.bak" -delete 2>/dev/null || true
	@rm -rf .tox 2>/dev/null || true
	@echo "✅ Python cleanup complete!"

# ============================================================================
# Tox Commands (for CI/CD and multi-environment testing)
# ============================================================================

tox-unit: ## Run unit tests via tox
	tox -e unit

tox-integration: ## Run integration tests via tox
	tox -e integration

tox-coverage: ## Run coverage via tox
	tox -e coverage

tox-validate: ## Run all validation via tox
	tox -e validate

tox-py312: ## Run tests on Python 3.12 specifically
	tox -e py312

# ============================================================================
# Utility Commands
# ============================================================================

deps-tree: ## Show dependency tree
	uv pip tree

deps-outdated: ## Show outdated dependencies
	uv pip list --outdated

deps-upgrade: ## Upgrade all dependencies
	uv pip install --upgrade -e ".[dev,test-integration]"

version: ## Show project version
	@python -c "import tomllib; print(tomllib.load(open('pyproject.toml', 'rb'))['project']['version'])"

# ============================================================================
# Development Shortcuts
# ============================================================================

fix: lint-fix format ## Auto-fix all code issues (lint + format)

check: lint format-check type-check ## Run all checks without tests

quick: test-fast lint format-check ## Quick validation (fast tests + quality checks)