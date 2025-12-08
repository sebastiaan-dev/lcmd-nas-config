terraform {
  required_providers {
    lcmd = {
      source = "sebastiaan-dev/lcmd"
      version = "0.1.3"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "lcmd" {
  user     = "sebastiaan"
  endpoint = "https://terraform-service.senas.heiyu.space/api"
}

