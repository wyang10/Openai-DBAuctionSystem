provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
module "enable_apis" {
  source = "../../terraform/modules/enable_apis"
  project_id = var.project_id
}

# Create VPC + connector
module "vpc" {
  source     = "../../terraform/modules/vpc"
  project_id = var.project_id
  region     = var.region
  vpc_name   = "auction-vpc"
}

# Create Cloud SQL instance
module "cloudsql" {
  source              = "../../terraform/modules/cloudsql"
  project_id          = var.project_id
  region              = var.region
  instance_name       = "auction-db"
  db_name             = var.db_name
  db_user             = var.db_user
  db_password         = var.db_password
  db_tier             = "db-f1-micro"
  db_version          = "MYSQL_8_0"
  vpc_connector_name  = module.vpc.connector_name
}

# Deploy to Cloud Run
module "cloudrun" {
  source              = "../../terraform/modules/cloudrun"
  project_id          = var.project_id
  region              = var.region
  service_name        = "auction-api"
  docker_image        = var.docker_image
  vpc_connector       = module.vpc.connector_name
  cloudsql_instance   = module.cloudsql.instance_connection_name
  env_vars = {
    DB_NAME     = var.db_name
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
    DJANGO_SECRET_KEY = var.django_secret_key
  }
}