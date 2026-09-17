# HealthRisk AI / HealthRisk Lab — Makefile
#
# Convenience targets mirroring the CI gates and common local workflows.

.PHONY: install lint format typecheck test test-cov clean up down help

help:
	@echo "Targets:"
	@echo "  install      install project + dev deps in editable mode"
	@echo "  lint         run ruff (non-fixing)"
	@echo "  format       run ruff format"
	@echo "  typecheck    run mypy over src and tests"
	@echo "  test         run pytest with coverage gating"
	@echo "  test-cov     run pytest and emit an HTML coverage report"
	@echo "  check        run lint + typecheck + tests (CI mirror)"
	@echo "  up           docker compose up --build (default app profile)"
	@echo "  down         docker compose down"
	@echo "  clean        remove local caches and build artifacts"

install:
	python -m pip install --upgrade pip
	pip install -e ".[dev]"

lint:
	ruff check .

format:
	ruff format .

typecheck:
	mypy src tests

test:
	pytest

test-cov:
	pytest --cov-report=html

check: lint typecheck test

up:
	docker compose up --build

down:
	docker compose down

clean:
	rm -rf .pytest_cache .mypy_cache .ruff_cache htmlcov .coverage
	rm -rf build dist *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} + || true
