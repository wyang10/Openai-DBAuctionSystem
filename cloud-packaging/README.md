
# Cloud-Native Auction Platform (GCP + Django + Streamlit)

An end-to-end cloud-native auction platform for furniture listings and bidding, built with Django and securely deployed on Google Cloud Platform. Includes a lightweight data exploration module powered by Streamlit and OpenAI for natural-language SQL queries.

---

## ✨ 项目亮点 (Quick Highlights)

| 🎯 核心价值 | 🛠️ 技术深度 | ☁️ 部署实践 |
| :--- | :--- | :--- |
| **全栈应用** | **Python** / **Django** (Web/API) | **GCP** (Cloud Run, Cloud SQL) |
| **IaC 自动化** | **Terraform** (VPC, SQL, IAM) | **CI/CD** (GitHub Actions + gcloud CLI) |
| **智能分析** | **Streamlit** + **OpenAI** (NL → SQL) | **安全隔离** (CloudSQL Proxy, Private IP) |

---

## 🗂️ 架构概览 (Overview)

本项目旨在模拟一个真实的云原生在线拍卖平台，重点展示数据工程与应用部署的实践能力：

* **Web 平台**: Django-based backend for listing, bidding, and auction management.
* **数据库层**: Google Cloud SQL (MySQL)，支持自动化配置和安全认证。
* **云部署**: 应用以容器化方式部署在 **Cloud Run** 上，配合 **GitHub Actions** 构建 CI/CD 管道。
* **基础设施即代码 (IaC)**: 使用 **Terraform** 模块实现 VPC、Cloud SQL、IAM、Monitoring 等基础设施的可重复部署。
* **数据探索模块**: 基于 **Streamlit** 构建，利用 **OpenAI API** 实现自然语言转 SQL (NL → SQL) 查询功能，赋能非技术用户探索拍卖数据。
* **云安全实践**: 采用 IAM 服务绑定、通过 **CloudSQL Proxy** 走私有 IP 连接数据库、以及环境变量管理敏感配置 (Secrets)。

---

## 🧠 核心功能与技术栈 (Key Features)

| 层级 (Layer) | 组件 (Component) | 关键特性 (Feature) |
| :--- | :--- | :--- |
| **Web & API** | Django CRUD | Listings, Bids, Users, Comments, Watchlists 的创建、读取、更新、删除操作。 |
| **Database** | Google Cloud SQL (MySQL) | 数据库 schema 设计、Managed Backups，预留 Read Replicas (未来增强)。 |
| **API / Events** | Bidding Logic | 竞价逻辑触发实时价格更新和拍卖状态处理 (如：倒计时结束)。 |
| **Infra Layer** | Terraform Modules | **IaC 自动化**：VPC、Cloud Run、CloudSQL、IAM Roles、Logging 的模块化配置。 |
| **Analytics** | Streamlit + OpenAI | **自然语言查询**：实现 NL → SQL 功能，用于非技术用户查询拍卖指标。 |
| **DevOps** | GitHub Actions | **持续部署 (CD)** 到 Cloud Run，支持 Secrets 管理和 Preview Deploys。 |

---

## ☁️ 架构图 (Architecture Diagram)

![Cloud Architecture](diagrams/gcp-architecture.png)

📝 **架构详情：** 请查阅 [`infra-architecture.md`](./infra-architecture.md)，其中包含图表分解和每个模块的详细用途说明。

---

## 🚀 快速启动 (Quick Start)

> **注意：** 完整的云端部署指令 (IaC) 将在 [`terraform/`](./terraform/) 目录和 `ci-cd.yml` 文件中提供。

### 本地运行 (Local Development)

```bash
# 1. 运行 Django Web 平台
cd dbauction
python manage.py migrate          # 初始化数据库
python manage.py runserver        # 启动本地服务

# 2. 启动 Streamlit 数据探索应用 (需要配置 OpenAI API Key)
cd StreamLitApp
streamlit run app.py
````

### 💬 Demo Queries (NL → SQL 示例)

借助 OpenAI，无需编写 SQL 即可探索拍卖数据：

| 自然语言输入 (Natural Language Input) | 生成的 SQL (Generated SQL) |
| :--- | :--- |
| “What are the top 5 most bid-on items?” | `SELECT item, COUNT(*) FROM bids GROUP BY ...` |
| “Show average bid amounts by category” | `SELECT category, AVG(bid_amount) ...` |
| “List all closed auctions in the last 7 days” | `SELECT * FROM listings WHERE closed = 1 ...` |

### 🧱 Terraform 基础设施模块

详细的设计笔记请参考 `terraform/modules/` 目录。

| 模块 (Module) | 用途 (Purpose) |
| :--- | :--- |
| `vpc` | 具有子网的私有网络，用于安全隔离服务。 |
| `cloudsql` | MySQL 数据库实例、用户配置和 IAM 绑定。 |
| `cloudrun` | 部署 Django 容器，配置 IAM Token 认证。 |
| `monitoring` | 导出日志和基础告警设置。 |

-----

## 🔍 数据流与未来分析 (Data & Analysis)

| 主题 (Topic) | 特性 (Feature) |
| :--- | :--- |
| **Bidding Events** | 通过 Django ORM 逻辑实现实时价格更新和状态变更。 |
| **Analytics Demo** | **Streamlit** + **OpenAI** 驱动的 GPT 辅助 SQL 生成，用于快速指标分析。 |
| **未来增强 (Future)** | 计划集成 **Airflow** 管道，将数据抽取至 **Snowflake/BigQuery**，并添加 **dbt** 建模层。 |

-----

## 🧠 Why This Project Matters (项目价值总结)

本项目在一个真实的应用程序场景中，全面展示了云原生数据工程 (Cloud-Native Data Engineering) 的实践技能，涵盖了以下关键领域：

  * **云基础设施 IaC：** 使用 Terraform 对 GCP 资源进行自动化和可复现的编排。
  * **安全部署实践：** 实施 IAM 权限管理、CloudSQL Proxy 私有连接和 Secrets 管理。
  * **全栈开发与数据建模：** Django Web 开发与数据库 Schema 设计（MySQL）。
  * **轻量级数据应用：** 使用 Streamlit 和 GPT 实现创新的自然语言数据探索界面。

-----

## 🔗 相关资料 (Related Artifacts)

| 资料 (Artifact) | 描述 (Description) |
| :--- | :--- |
| 📄 [`interview-prep.md`](https://www.google.com/search?q=./interview-prep.md) | STAR 原则的问答示例和系统设计问答集。 |
| 📄 [`infra-architecture.md`](https://www.google.com/search?q=./infra-architecture.md) | GCP 架构图和组件的详细分解。 |
| 📄 [`pipeline.md`](https://www.google.com/search?q=./pipeline.md) | 竞价处理和数据流动的详细说明。 |
| 🖼 `/diagrams` | 全系统架构图、Terraform 结构图和竞价事件流图。 |
| 📊 `exploration-module/` | Streamlit + NL→SQL 模块的截图和代码。 |
