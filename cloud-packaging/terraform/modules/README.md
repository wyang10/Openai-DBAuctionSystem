<!--
 * @Author: Audrey Yang 97855340+wyang10@users.noreply.github.com
 * @Date: 2025-11-18 15:02:34
 * @LastEditors: Audrey Yang 97855340+wyang10@users.noreply.github.com
 * @LastEditTime: 2025-11-18 15:19:59
 * @FilePath: /Openai-DBAuctionSystem/cloud-packaging/terraform/modules/README.md
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->
# 📦 Terraform Modules Overview

This document describes each reusable Terraform module used in the Cloud-Native Auction Platform infrastructure stack.

Each module is designed to be environment-agnostic, configurable via input variables, and reusable across `dev`, `stage`, and `prod` environments.

---

## 📁 Module: `vpc/` — Serverless VPC Connector

| Variable | Type | Description |
|----------|------|-------------|
| `name` | `string` | Name of the VPC connector |
| `region` | `string` | Region to deploy the connector |
| `ip_cidr_range` | `string` | CIDR block for connector (e.g., `10.8.0.0/28`) |
| `project_id` | `string` | GCP project ID |

📌 **Purpose**:  
Allows Cloud Run to access Cloud SQL via internal IP.

---

## 📁 Module: `cloudsql/` — MySQL Instance

| Variable | Type | Description |
|----------|------|-------------|
| `instance_name` | `string` | Name of the Cloud SQL instance |
| `region` | `string` | Region for DB |
| `database_version` | `string` | e.g., `MYSQL_8_0` |
| `tier` | `string` | e.g., `db-f1-micro`, `db-g1-small` |
| `db_name` | `string` | Name of initial DB schema |
| `db_user` | `string` | Username |
| `db_password` | `string` | Password (usually from Secret Manager) |
| `authorized_networks` | `list(object)` | Optional IP allowlist |
| `project_id` | `string` | GCP project ID |

📌 **Purpose**:  
Manages Cloud SQL instance and initial DB setup, IAM permissions, and private IP.

---

## 📁 Module: `cloudrun/` — Django App Container Deployment

| Variable | Type | Description |
|----------|------|-------------|
| `service_name` | `string` | Name of Cloud Run service |
| `region` | `string` | Deploy region |
| `image_url` | `string` | Docker image URI from Artifact Registry |
| `env_vars` | `map(string)` | Env variables like DB creds, Django settings |
| `project_id` | `string` | GCP project ID |
| `vpc_connector` | `string` | VPC connector name |
| `service_account_email` | `string` | IAM SA with Cloud SQL Client role |

📌 **Purpose**:  
Deploys Django service to Cloud Run with secure DB connectivity, IAM binding, and autoscaling.

---

## 📁 Module: `artifact/` — Docker Artifact Registry

| Variable | Type | Description |
|----------|------|-------------|
| `location` | `string` | Region (e.g., `us-central1`) |
| `repository_id` | `string` | Name of Docker repo |
| `project_id` | `string` | GCP project ID |

📌 **Purpose**:  
Creates a Docker artifact repository and grants push/pull roles to CI/CD service accounts.

---

## 📁 Module: `monitoring/` — (Optional) Logging + Monitoring

| Variable | Type | Description |
|----------|------|-------------|
| `project_id` | `string` | GCP project ID |
| `alert_email` | `string` | Email to receive alerts (optional) |

📌 **Purpose**:  
Sets up basic logging sink and monitoring alert policies. Extendable for uptime checks, error logs, latency, etc.

---

## 🧠 How to Use

In `environments/dev/main.tf`:

```hcl
module "cloudsql" {
  source = "../../modules/cloudsql"
  instance_name = "auction-db"
  db_name       = "auction"
  db_user       = "root"
  db_password   = var.db_password
  ...
}