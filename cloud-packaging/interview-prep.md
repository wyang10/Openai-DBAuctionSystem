# Interview Prep — Cloud-Native Auction Platform

This document provides a structured STAR format for interview storytelling, plus technical Q&A for system design rounds.

---

## 🪧 1. Project Intro (30s elevator pitch)

> "I built a cloud-native auction platform deployed on Google Cloud using Django + MySQL. The project includes a bidding system, user-facing web interface, and a Streamlit-based analytics module that allows natural-language querying using OpenAI. I used Terraform for infrastructure, and CI/CD with GitHub Actions to deploy to Cloud Run."

---

## 🧱 2. STAR — Tell me about this project

### ⭐️ Situation
Our team wanted to simulate a real-world online auction platform. The goals were:

- Design a scalable, secure architecture on GCP
- Build realistic auction logic with bidding and listing flows
- Provide a data exploration tool for non-technical users

### 🎯 Task
I led the backend system architecture and cloud deployment. My focus was:

- Designing the data model and auction logic
- Automating infra provisioning (Cloud SQL, IAM, VPC)
- Deploying Django via CI/CD to Cloud Run
- Creating a GPT-powered NL→SQL analytics interface

### ⚙️ Action
- Used **Django ORM** to model auction entities (Listings, Bids, Comments)
- Implemented **bid logic**: real-time updates to highest bid, closing logic
- Deployed the system via **Cloud Run**, with Docker + GitHub Actions
- Provisioned **Cloud SQL (MySQL)** using Terraform + IAM bindings
- Built a **Streamlit app** that lets users type questions and view SQL results
- Managed secrets via **env variables** and `.streamlit/secrets.toml`

### ✅ Result
- The system handled end-to-end listing and bidding logic with proper data consistency
- CI/CD to GCP reduced deployment friction; Terraform made re-setup easy
- Streamlit demo impressed stakeholders by simplifying SQL insights

---

## 🔎 3. Technical Deep Dive Q&A

### Q: How did you structure the system architecture on GCP?
- Cloud Run for serving containerized Django
- Cloud SQL (MySQL) for transactional data
- VPC + CloudSQL Proxy for secure DB access
- Terraform modules for repeatable infra (VPC, IAM, SQL, Run)
- Streamlit app deployed locally (dev) with OpenAI key for NL→SQL

### Q: How is bidding logic handled?
- Each Listing tracks `current_bid` and `highest_bidder`
- New bid checks against current, updates if valid
- Django model methods + form validation ensure atomicity

### Q: How is the infrastructure deployed?
- Terraform module structure:
  - `vpc/`: Subnet + private IP setup
  - `cloudsql/`: MySQL instance + user
  - `cloudrun/`: Container setup, IAM access
  - `monitoring/`: Logging + future alerting
- GitHub Actions workflow builds Docker, pushes to Artifact Registry, and deploys to Cloud Run

### Q: How does the Streamlit + OpenAI module work?
- Users enter plain English questions (e.g., "Top 5 listings by bids")
- OpenAI completion model returns SQL
- Streamlit executes SQL via Python client and shows results

---

## 🔁 4. Follow-up Questions You May Get

| Question | Suggested Response |
|---------|--------------------|
| How would you scale this system to 10x users? | Add read replicas to Cloud SQL; use Cloud Tasks for async bidding; consider switching to BigQuery for heavy analytics |
| Any issues with Django + Cloud Run? | Cold start latency; mitigated via min instances + warmed routes |
| Why GCP over AWS? | More familiar; built-in integration for Cloud Run + SQL + Artifact Registry |
| How would you add real-time bidding? | Use Pub/Sub + Firestore + WebSockets (Django Channels) for true push updates |
| If this were multi-region? | Use global Cloud Load Balancer + multi-region SQL (or migrate to Spanner) |

---

## 🧩 5. Key Technologies

| Area | Stack |
|------|------|
| Backend | Django, Python |
| Infra | Terraform, GCP (Cloud SQL, Cloud Run, IAM) |
| CI/CD | GitHub Actions, Docker, gcloud CLI |
| Data | MySQL, Streamlit, OpenAI API |
| Security | IAM roles, VPC, secrets via env vars |

---

## 🪜 6. Next Steps / Extension Ideas

- Add **Airflow** pipeline to ingest bid logs to BigQuery
- Use **dbt** for transforming raw → analytical models
- Expose **REST API** for mobile frontend
- Enhance **NL→SQL** UX with fine-tuned prompts and caching
- Add **tests**: Pytest for Django views + integration

---

## 💡 Tip for Delivery

End with:

> "This project helped me build confidence in cloud-native architectures, Terraform infra-as-code, and practical backend workflows. It also sharpened my thinking in user experience — especially how to make analytics more accessible using tools like Streamlit + GPT."