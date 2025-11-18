# ☁️ Cloud-Native Auction Platform — Infra Architecture

This document outlines the system architecture and key cloud infrastructure components used to deploy the auction platform on Google Cloud using Terraform and CI/CD.

---

## 🧱 1. High-Level Architecture (ASCII Diagram)

                 ┌────────────────────┐
                 │    User Browser    │
                 └────────┬───────────┘
                          │  HTTPS
                          ▼
                 ┌────────────────────┐
                 │ Cloud Load Balancer│
                 └────────┬───────────┘
                          │
                          ▼
                  ┌──────────────────┐
                  │   Cloud Run      │◄─────┐
                  │ (Django Backend) │      │
                  └────────┬─────────┘      │  CI/CD
                           │                │  (GitHub Actions)
                           ▼                │
     ┌────────────────────────────┐         │
     │  Cloud SQL (MySQL 8)       │◄────────┘
     │ (via Cloud SQL Proxy + IAM)│
     └────────────┬───────────────┘
                  │
                  ▼
      ┌────────────────────────────┐
      │ VPC Connector (Serverless) │
      └────────────────────────────┘

     ┌───────────────────────────────┐
     │ Artifact Registry (Docker Img)│
     └───────────────────────────────┘

Optional:
┌─────────────────────────────┐
│ Streamlit + OpenAI API      │
│ (NL→SQL module for insights)│
└─────────────────────────────┘

---

## 🧩 2. Component Breakdown

| Component              | Description |
|------------------------|-------------|
| **Cloud Run**          | Runs the Django backend as a containerized microservice with HTTPS and auto-scaling |
| **Cloud SQL (MySQL)**  | Stores auction listings, bids, users, etc. Secured with IAM and private IP |
| **VPC Connector**      | Connects Cloud Run to Cloud SQL privately (via serverless VPC access) |
| **Cloud Load Balancer**| Handles HTTPS requests and routes traffic to Cloud Run |
| **Artifact Registry**  | Stores Docker images built by CI/CD |
| **GitHub Actions**     | Builds & pushes images, triggers Cloud Run deployment |
| **Terraform**          | Manages GCP infra: VPC, IAM roles, SQL, Cloud Run, etc. |
| **Streamlit + OpenAI** | Optional: analytics module for natural-language SQL queries on the DB |

---

## 🧪 3. Terraform Module Structure

terraform/
├── main.tf              # Compose infra modules
├── modules/
│   ├── vpc/             # Serverless VPC connector
│   ├── cloudsql/        # DB instance, user, IP
│   ├── cloudrun/        # App deployment & IAM binding
│   ├── artifact/        # Registry permissions
│   └── monitoring/      # Logs + (future) alerting
└── environments/
├── dev/
└── prod/

Each module exposes input variables for project ID, region, and app-specific settings.

---

## 🔐 4. Secrets & Security

| Secret                 | Location            | Notes |
|------------------------|---------------------|-------|
| `DB_PASSWORD`          | Cloud Secret Manager or GitHub secret |
| `DJANGO_SECRET_KEY`    | GitHub / Docker env |
| `OPENAI_API_KEY`       | `.streamlit/secrets.toml` (for local dev) |

IAM service accounts are scoped with least privilege:
- Cloud Run → Cloud SQL Client
- GitHub CI → Artifact Registry Write

---

## 🔁 5. CI/CD Flow

| Step | Tool |
|------|------|
| 1. Code push to `main` | GitHub |
| 2. Build Docker image | GitHub Actions |
| 3. Push to Artifact Registry | `gcloud` CLI |
| 4. Deploy to Cloud Run | `gcloud run deploy` |
| 5. Apply migrations (optional) | `manage.py migrate` |

---

## 🚀 6. Future Extensions

| Goal | How |
|------|-----|
| Real-time bidding | Pub/Sub + Firestore + Django Channels |
| Analytics pipeline | Airflow → BigQuery (with dbt on top) |
| Observability | Cloud Monitoring + Alerting policies |
| Multi-region | Cloud Load Balancer + regional replica SQL |
| API interface | Add REST endpoints (Django DRF) or GraphQL |

---

## 🧠 Summary

This architecture reflects a practical and modular cloud-native deployment of a real-world Django system. It balances simplicity (Cloud Run) with production-grade features like CI/CD, secret management, and secure VPC connectivity.

> Terraform gives us reproducibility and infrastructure codification; CI/CD ensures fast iteration; GCP handles scalability and ops.

