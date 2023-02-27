terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "9789ec83-d3a8-45e9-82f3-0d31d8d7213b"
  tenant_id       = "f795bab8-f723-4a7c-afbf-4a7b5369243b"
  client_id       = "e2bc339f-894f-4327-8e90-071d364a8afb"
  client_secret   = "NuG8Q~-BX~XxJU8rE0JbDdRqv0np~6j-sHrsqdBq"
}