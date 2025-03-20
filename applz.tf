resource "azurerm_resource_group" "app" {
  location = var.location # app rg
  name     = "rg-app"
}

resource "azurerm_resource_group" "network" {
  location = var.location # network rg
  name     = "rg-network"
}

resource "azurerm_resource_group" "secrets" {
  location = var.location # KV rg
  name     = "rg-secrets"
}

resource "azurerm_resource_group" "db" {
  location = var.location # DB rg
  name     = "rg-db"
}

resource "azurerm_user_assigned_identity" "this" {
  location            = var.location
  name                = "uami-aks-test-001"
  resource_group_name = azurerm_resource_group.app.name
}

# Datasource of current tenant ID
data "azurerm_client_config" "current" {}


########## NETWORK #############

resource "azurerm_virtual_network" "this" {
  name                = "spoke1"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.1.0.0/16"]

  tags = {
    environment = "Test"
  }
}

resource "azurerm_subnet" "snet_contoso_dev_aks" {
  name                 = "snet-contoso-dev-aks-001"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.1.1.0/24"]

  // network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet" "snet_contoso_dev_db" {
  name                 = "snet-contoso-dev-db-001"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.1.2.0/24"]

  // network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet" "snet_contoso_dev_pe" {
  name                 = "snet-contoso-dev-pe-001"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.1.3.0/24"] // Ensure this is a unique address space
}

resource "azurerm_subnet" "snet_contoso_dev_agw" {
  name                 = "snet-contoso-dev-agw-001"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.1.4.0/24"] // Ensure this is a unique address space
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.network.name
}


module "nsg_aks" {
    source              = "./modules/nsg"
    name                = "nsg-snet-contoso-dev-aks-001"  
    resource_group_name = azurerm_resource_group.network.name
    location            = var.location
    inbound_rules = [
        {
            name                                   = "allow_http_inbound",
            priority                               = 100,
            access                                 = "Allow",
            protocol                               = "Tcp",
            source_port_range                      = "*"
            destination_port_range                 = "80"
            source_address_prefix                  = "10.1.4.0/24",
            destination_address_prefix             = "10.1.1.0/24"
        },
        {
            name                                   = "allow_https_inbound",
            priority                               = 150,
            access                                 = "Allow",
            protocol                               = "Tcp",
            source_port_range                      = "*"
            destination_port_range                 = "443"
            source_address_prefix                  = "10.1.4.0/24",
            destination_address_prefix             = "10.1.1.0/24"
        },
        {
            name                                   = "allow_ssh_inbound",
            priority                               = 200,
            access                                 = "Allow",
            protocol                               = "Tcp",
            source_port_range                      = "*"
            destination_port_range                 = "22"
            source_address_prefix                  = "10.1.10.0/24", //bastion subnet, in connectivity subsc
            destination_address_prefix             = "10.1.1.0/24"
        },
        {
            name                                   = "deny_all_inbound",
            priority                               = 4096,
            access                                 = "Deny",
            protocol                               = "*",
            source_port_range                      = "*"
            destination_port_range                 = "*"
            source_address_prefix                  = "*",
            destination_address_prefix             = "*"
        },
    ]
    outbound_rules = [
        {
            name                                   = "allow_sql_outbound",
            priority                               = 100,
            access                                 = "Allow",
            protocol                               = "Tcp",
            source_port_range                      = "*"
            destination_port_range                 = "1433"
            source_address_prefix                  = "10.1.1.0/24"
            destination_address_prefix             = "10.1.2.0/24"
        },
        {
            name                                   = "allow_dns-outbound",
            priority                               = 150,
            access                                 = "Allow",
            protocol                               = "Udp",
            source_port_range                      = "*"
            destination_port_range                 = "53"
            source_address_prefix                  = "10.1.1.0/24"
            destination_address_prefix             = "168.63.129.16/32"
        },
        {
            name                                   = "allow_https-outbound",
            priority                               = 200,
            access                                 = "Allow",
            protocol                               = "Tcp",
            source_port_range                      = "*"
            destination_port_range                 = "443"
            source_address_prefix                  = "10.1.1.0/24"
            destination_address_prefix             = "Internet"
        },
        {
            name                                   = "deny_all_outbound",
            priority                               = 4096,
            access                                 = "Deny",
            protocol                               = "*",
            source_port_range                      = "*"
            destination_port_range                 = "*"
            source_address_prefix                  = "*",
            destination_address_prefix             = "*"
        },
    ]
}

module "nsg_sql" {
    source = "./modules/nsg"
    name                = "nsg-snet-contoso-dev-db-001"  
    resource_group_name = azurerm_resource_group.network.name
    location            = var.location
    inbound_rules = [
        {
            name                                   = "allow_sql_inbound",
            priority                               = 100,
            access                                 = "Allow",
            protocol                               = "Tcp",
            source_port_range                      = "*"
            destination_port_range                 = "1433"
            source_address_prefix                  = "10.1.4.0/24",
            destination_address_prefix             = "10.1.1.0/24"
        },
        {
            name                                   = "deny_all_inbound",
            priority                               = 4096,
            access                                 = "Deny",
            protocol                               = "*",
            source_port_range                      = "*"
            destination_port_range                 = "*"
            source_address_prefix                  = "*",
            destination_address_prefix             = "*"
        },
    ]
    outbound_rules = [
        {
            name                                   = "deny_all_outbound",
            priority                               = 4096,
            access                                 = "Deny",
            protocol                               = "*",
            source_port_range                      = "*"
            destination_port_range                 = "*"
            source_address_prefix                  = "*",
            destination_address_prefix             = "*"
        },
    ]
}

resource "azurerm_subnet_network_security_group_association" "aks" {

  subnet_id                 = azurerm_subnet.snet_contoso_dev_aks.id
  network_security_group_id = module.nsg_aks.id

}

resource "azurerm_subnet_network_security_group_association" "sql" {

  subnet_id                 = azurerm_subnet.snet_contoso_dev_db.id
  network_security_group_id = module.nsg_sql.id

}

############ AKS ################


resource "azurerm_kubernetes_cluster" "default" {
  name                = "aks-contoso-test-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.app.name
  dns_prefix          = "dns-k8s-test"
  kubernetes_version  = "1.30"

  default_node_pool {
    name            = "testnodepool"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
    vnet_subnet_id  = azurerm_subnet.snet_contoso_dev_aks.id
  }

  identity {
    type = "SystemAssigned"
  }
  
  network_profile {
    network_plugin = "azure"
  }

#   service_principal {
#     client_id     = var.clientId
#     client_secret = var.clientSecret
#   }

  role_based_access_control_enabled = true

  tags = {
    environment = "test"
  }
}

###########   DB ################

resource "azurerm_mssql_server" "this" {
  name                          = "sqlserver-contoso-dev-001"
  resource_group_name           = azurerm_resource_group.db.name
  location                      = var.location

  version                       = "12.0"
  minimum_tls_version           = "1.2"

  administrator_login           = "SQLadmin"
  //administrator_login_password  = data.azurerm_key_vault_secret.sql_admin.value
  administrator_login_password  = "Fortigate5678"
  
  connection_policy             = "Default"
  public_network_access_enabled = "true" //update to false, after PE are in place

  identity {
    type          = "SystemAssigned"
  }

}


resource "azurerm_mssql_database" "this" {
  name                        = "sqldb-contoso-dev-001"
  create_mode                 = "Default"
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  license_type                = "LicenseIncluded"
  max_size_gb                 = 50
  sku_name                    = "S0"
  server_id                   = azurerm_mssql_server.this.id
  zone_redundant              = false
  auto_pause_delay_in_minutes = 70

#   identity {
#     type          = "SystemAssigned"
#   }

  geo_backup_enabled = false
  ledger_enabled = true

}
