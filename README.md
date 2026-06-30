# RegMap AI — Offline Compliance Intelligence Platform for Regulated Banking

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)

RegMap AI reads RBI, SEBI, MCA, and IBA circulars and converts them into Measurable Action Points (MAPs) — structured tasks with a department owner, a deadline, evidence requirements, and an estimated penalty if missed. The entire pipeline runs locally on the machine it's installed on. Nothing is uploaded anywhere.

Built for the SuRaksha Cyber Hackathon 2.0, theme: Agentic Regulatory Intelligence & Compliance.

## Screenshot

![Dashboard](docs/screenshots/dashboard.png)

The top bar shows the **Offline AI Mode** indicator, confirming the analysis on screen was processed entirely on-device. The KPI cards are computed from real MAP status, not placeholder data — "9 of 66 MAPs done" and "6 resolved" reflect the actual state of this run.

| Theme requirement | How this repo addresses it |
|---|---|
| Monitor regulatory changes | Document loader accepts PDF, DOCX, image, or pasted text |
| Translate into Measurable Action Points | `MAPEngine` turns each obligation into a MAP with department, deadline, evidence, penalty |
| Assign to the correct bank department | Per-obligation routing across IT/CISO, Legal, Compliance, Risk, HR, Operations, Finance, Treasury |
| Autonomously validate completion | Resolving a MAP logs a history entry and updates the dashboard immediately |

## The problem

A compliance officer reviewing a single regulatory circular by hand typically spends 40–60 hours on it. RBI alone issues 100+ circulars a year. Manual tracking in spreadsheets and email threads means deadlines get missed, and a missed obligation can carry penalties from ₹1 crore up to ₹250 crore under the DPDP Act 2023.

Most compliance-review tools available today send documents to a cloud service for processing, which is a non-starter for a regulated bank handling unpublished regulatory material. RegMap AI was built specifically to avoid that: the obligation extraction, department routing, risk scoring, and MAP generation all run as a local NLP pipeline. No document, no extracted obligation, no compliance data leaves the machine it runs on, at any point.

## What a MAP looks like

```
MAP-001 | Priority: Critical | Department: IT / CISO
Obligation: Banks shall maintain ISO 27001-aligned Information Security Policy
Deadline:   30 days (28 Jul 2026)
Evidence:   Board-approved policy document, ISO certification
Penalty:    ₹1–5 Cr + RBI Regulatory Action (RBI CSF 2016)
Status:     Pending → In Progress → Complete
```

## Features

| Feature | Description |
|---|---|
| Obligation extraction | Identifies every 'shall', 'must', 'required' clause in a document |
| MAP generation | Converts obligations into MAPs with department, deadline, evidence, penalty |
| Department routing | Routes each MAP to one of 8 departments based on obligation content |
| Risk scoring | Severity classification with estimated penalty exposure |
| Deadline tracking | Parses time expressions from text into actual calendar dates |
| Conflict detection | Flags contradicting obligations within or across documents |
| MAP Tracker | Pending/Done tabs, recommended next actions, full status-change history |
| Compliance Calendar | Deadlines on a calendar view; update a MAP's status directly from an event |
| Evidence validator | Upload supporting evidence per MAP |
| Digital Twin | Knowledge graph linking regulation → obligation → department → risk |
| Impact Simulator | What-if scenario modeling — adjust obligation count, deadlines, or risk mitigation and see the projected effect on compliance score |
| AI Copilot | Natural-language Q&A over the analyzed document, answered locally |
| Audit log | Every status change is timestamped and recorded |
| PDF/JSON export | Generates a board-level compliance report |

## Architecture

Every stage of the pipeline reads from and writes to a single in-memory record called the Compliance Knowledge Object (CKO). Nothing is passed between stages as loose files or disconnected variables — it's one structured object from ingestion through to the final report.

```
Document (PDF / DOCX / image / pasted text)
        │
        ▼
Document Loader        — text extraction, OCR for scanned pages
        ▼
Entity Engine          — issuer, dates, references
        ▼
Obligation Engine       — extracts shall/must/required clauses
        ▼
Deadline Engine         — parses time expressions into dates
        ▼
Department Engine       — routes each obligation to a department
        ▼
Decision Engine         — priority scoring
        ▼
Risk Engine             — severity + penalty exposure
        ▼
MAP Engine               — generates Measurable Action Points
        ▼
Evidence Engine          — evidence requirements per MAP
        ▼
Conflict Engine          — cross-obligation contradiction check
        ▼
Recommendation Engine    — suggested next actions
        ▼
Knowledge Graph Engine   — builds the Digital Twin graph
        ▼
Reasoning / Executive / Explainable / Timeline / Analytics / Report Engines
        ▼
Compliance Knowledge Object (complete)
        ▼
React dashboard, AI Copilot, calendar, PDF export
```

All 17 pipeline stages live under `backend/ai/`, one file per engine, all running locally with no external service calls.

## Benchmark

Run against a 148-page RBI circular:

| Metric | Result |
|---|---|
| Obligations extracted | 83 |
| MAPs generated | 83 |
| Processing time | under 4 seconds |
| False positive rate | under 5% |
| Network calls made | 0 |

## Project structure

```
backend/
  ai/          17 pipeline engines — entity, obligation, deadline, department,
               risk, MAP, evidence, conflict, recommendation, knowledge graph,
               reasoning, executive, explainable, timeline, analytics, report
  api/         Flask blueprints, one file per route group
  database/    SQLite wrapper
  models/      Compliance Knowledge Object dataclass
  reports/     PDF/JSON export generation
  services/    Business logic between the API layer and the AI engines
  tests/       pytest suite

frontend/
  src/api/         API client functions, one per backend route group
  src/components/  Dashboard widgets, charts, layout, shared UI
  src/context/     Global app state (auth, refresh triggers)
  src/hooks/       Data-fetching hooks per page
  src/pages/       Dashboard, Executive Summary, Regulations, Conflict
                   Detector, Task Generator, MAP Tracker, Analytics,
                   Impact Simulator, Digital Twin, Evidence Validator,
                   AI Copilot, Compliance Calendar
```

## Technology stack

| Layer | Technology |
|---|---|
| Backend | Python 3.9+, Flask, SQLite |
| NLP pipeline | spaCy (`en_core_web_sm`), sentence-transformers (`all-MiniLM-L6-v2`) — runs entirely on-device |
| Document parsing | pdfplumber, PyMuPDF, pytesseract, python-docx |
| Frontend | React 18, Vite, Framer Motion, Recharts |
| PDF export | ReportLab, fpdf2 |
| Infrastructure | Docker, Docker Compose |

## Setup

### Docker

```bash
git clone https://github.com/Suyajnaa/RegMap-AI-Offline-Compliance-Intelligence-Platform-for-Regulated-Banking.git
cd RegMap-AI-Offline-Compliance-Intelligence-Platform-for-Regulated-Banking

cp .env.example .env

cd backend && python setup_models.py && cd ..
# One-time download of the spaCy and sentence-transformers models.
# Requires internet for this step only — everything after this runs offline.

docker-compose up --build -d
```

Frontend: `http://localhost:5173`
Backend: `http://localhost:5000`

### Manual setup

Backend:
```bash
cd backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
python setup_models.py
python app.py
```

Frontend (separate terminal):
```bash
cd frontend
npm install
npm run dev
```

Open `http://localhost:5173`, pick a role on the login screen, then upload a circular under Regulations.

### Without a file

```bash
curl -X POST http://localhost:5000/api/upload/text \
  -H "Content-Type: application/json" \
  -d '{"text": "Banks shall maintain a Board-approved cyber security policy within 30 days..."}'
```

## Running the tests

```bash
cd backend
python -m pytest tests/ -v
```

15 tests covering engine correctness and pipeline regressions, in `backend/tests/`.

## Endpoints

All served under `http://localhost:5000`.

| Endpoint | Method | Description |
|---|---|---|
| `/api/upload/` | POST | Upload PDF/DOCX/image for analysis |
| `/api/upload/text` | POST | Paste circular text directly |
| `/api/analyze/latest` | GET | Latest analysis |
| `/api/analyze/deploy-tasks` | POST | Auto-resolve one or more obligations/MAPs |
| `/api/maps/` | GET | All Measurable Action Points + recommendations |
| `/api/maps/{id}/status` | PATCH | Update a MAP's status (logs to history) |
| `/api/maps/history` | GET | Status-change activity log, most recent first |
| `/api/maps/department/{dept}` | GET | Filter MAPs by department |
| `/api/dashboard/` | GET | Full compliance dashboard |
| `/api/timeline/` | GET | Deadlines and implementation timeline |
| `/api/copilot/` | POST | Ask a question about the analyzed document |
| `/api/analytics/` | GET | Chart and KPI data |
| `/api/reports/` | GET | Latest report metadata |
| `/api/reports/download?format=pdf\|json` | GET | Download the report |
| `/api/audit/` | GET | Full audit trail |
| `/api/conflict/internal` | GET | Conflicts within the latest document |
| `/api/conflict/analyses` | GET | Stored analyses available for comparison |
| `/api/conflict/compare` | POST | Compare two analyses (`id_a`, `id_b`) |
| `/api/evidence/` | POST | Upload and validate evidence |
| `/api/graph/` | GET | Knowledge graph data for the Digital Twin view |
| `/api/simulator/baseline` | GET | Current state to start a what-if simulation from |
| `/api/simulator/simulate` | POST | Run a simulation with parameter overrides |

## Data handling

- Nothing is uploaded to a third party. Document parsing, NLP, and report generation all run locally.
- Identical input produces identical output — the pipeline is deterministic, which matters when the output is used as audit evidence.
- Every MAP status change is timestamped and kept in `/api/maps/history`.

## Contributing

See `CONTRIBUTING.md`. Issue and PR templates are in `.github/`.

## Contact

Suyajnaa — suyajnaa@gmail.com
Repository: https://github.com/Suyajnaa/RegMap-AI-Offline-Compliance-Intelligence-Platform-for-Regulated-Banking
