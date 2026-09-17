# HealthRisk AI & HealthRisk Lab

Dual-domain intelligence platform connecting clinical informatics (EHR, ICD-10, CPT,
lab events, FDA FAERS, ClinicalTrials.gov) with quantitative financial risk models
(actuarial IBNR pricing, hospital credit scoring, pharma rNPV, Health ESG).

It ships two surfaces:

1. **HealthRisk AI** — an ensemble predictive stack (Bio_ClinicalBERT + GATv2 GNN +
   DeepSurv / Dynamic-DeepHit survival + XGBoost/LightGBM tabular + Ridge stacking
   meta-learner) that emits clinical risk vectors and longitudinal cost trajectories.
2. **HealthRisk Lab** — a 40-quarter, gamified portfolio simulation where a human
   manages a $500M health-finance book against an AI opponent under macroeconomic and
   epidemiological shocks.

## Quick start (local)

```bash
cd healthrisk-ai

# 1. Create an environment and install the project + dev tools
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -e ".[dev]"

# 2. Copy the example env and fill real values where required
cp .env.example .env

# 3. Run the test suite (fails if coverage < 60%)
pytest

# 4. Spin up the whole stack via Docker (see Docker section below)
make up  # or: docker compose up --build
```

The primary entrypoint to run locally is:

```bash
hrl-serve
```

## Directory map

- `src/acquisition/` — data ingestion adapters (MIMIC-IV schema, openFDA FAERS,
  ClinicalTrials.gov API) with retries and rate-limiting.
- `src/processing/` — clinical and financial feature engineering (CMS-HCC mappings,
  Charlson/Elixhauser comorbidity indices, polypharmacy, lab trajectories, claim
  triangles, hospital financial ratios).
- `src/models/` — the AI ensemble: clinical NLP, graph network, survival, tabular,
  and stacking meta-learner.
- `src/insurance/` — actuarial pricing: Chain Ladder and Bornhuetter-Ferguson IBNR
  estimators, loss ratio and premium calculators.
- `src/credit_risk/` — hospital probability-of-default scorecard driven by clinical
  quality and financial ratios.
- `src/pharma/` — rNPV Monte Carlo model linked to clinical trial enrollment velocity.
- `src/explainability/` — SHAP attributions and automated HTML/PDF model cards.
- `src/simulation/` — HealthRisk Lab game loop, portfolio, AI opponent, shock engine.
- `configs/config.yaml` — runtime configuration and model hyperparameters.
- `tests/` — unit and integration tests (coverage target >= 60%).

## Data sources and secrets

No credentials are hardcoded in this repository. All secrets live in `.env`, which is
ignored by Git. The `.env.example` file documents which keys are expected and where
they are used.

| Variable | Used by | Notes |
| --- | --- | --- |
| `OPENFDA_API_KEY` | `src/acquisition/openfda.py` | Optional for higher rate limits |
| `CLINICALTRIALS_EMAIL` | `src/acquisition/clinicaltrials.py` | Courtesy identification |
| `MIMIC_INGEST_PATH` | `src/acquisition/mimic_iv.py` | Path or URI to the local MIMIC-IV extract |

If a variable is missing, adapters fall back to deterministic mock data and log the
fallback at `WARNING` so local development remains fully functional.

## Simulation snapshot

The canonical reference specification for the $500M / 40-quarter gamified simulation,
AI opponent, and shock generators is the project brief (`483555D_Data_Scientist_HealthRisk_AI.docx.pdf`).

## Model quality targets (from spec)

| Model | Target metric | Notes |
| --- | --- | --- |
| Survival ensemble | C-index > 0.70 | Time-to-readmission and complications |
| Stacking meta-learner | R^2 > 0.25 | On held-out cost-trajectory targets |
| Code coverage | >= 60% | CI enforces this gate |

## Reproducibility

- Random seeds are fixed per-run via `configs/config.yaml` and exposed through the
  acquisition and simulation modules.
- Time-aware splitting is enforced in all cross-validation helpers to prevent temporal
  leakage.
- Model artifacts are meant to be tracked with MLflow/DVC in a later integration phase;
  the current phase focuses on code, tests, and containers.

## License

MIT — see the LICENSE file at the repository root.
