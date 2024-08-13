provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = data.azurerm_resource_group.existing.name

  tags = var.tags
}

resource "azurerm_subnet" "internal" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.existing.name

  security_rule {
    name                       = "deny_all_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_inbound_vnet"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.0.0/16"
  }

  security_rule {
    name                       = "allow_outbound_vnet"
    priority                   = 102
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.0.0/16"
  }

  security_rule {
    name                       = "allow_inbound_http_from_lb"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "10.0.0.0/16"  # Assuming the LB is in the same VNet
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_public_ip" "nic_public_ip" {
  count               = var.vm_count
  name                = "myapp-nic-publicip-${count.index}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.existing.name
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "myapp-lb-publicip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.existing.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "myapp-nic-${count.index}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nic_public_ip[count.index].id
  }
}

resource "azurerm_lb" "main" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.existing.name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "publicIp"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "myapp-backend-pool"
}

resource "azurerm_lb_rule" "lb_rule" {
  name                         = "myapp-lbrule"
  loadbalancer_id              = azurerm_lb.main.id
  protocol                     = "Tcp"
  frontend_port                = 80
  backend_port                 = 80
  frontend_ip_configuration_name = "publicIp"
  backend_address_pool_ids     = [azurerm_lb_backend_address_pool.backend_pool.id]
}

resource "azurerm_availability_set" "main" {
  name                         = var.availability_set_name
  location                     = var.location
  resource_group_name          = data.azurerm_resource_group.existing.name
  managed                      = true
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5

  tags = var.tags
}

data "azurerm_image" "packer_image" {
  name                = var.packer_image_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

resource "azurerm_linux_virtual_machine" "main" {
  count                     = var.vm_count
  name                      = "myapp-vm-${count.index}"
  location                  = var.location
  resource_group_name       = data.azurerm_resource_group.existing.name
  network_interface_ids     = [azurerm_network_interface.main[count.index].id]
  size                      = var.vm_size
  admin_username            = var.admin_username
  admin_password            = var.admin_password
  availability_set_id       = azurerm_availability_set.main.id
  source_image_id           = data.azurerm_image.packer_image.id

  os_disk {
    caching                   = "ReadWrite"
    storage_account_type      = "Standard_LRS"
  }

  disable_password_authentication = false

  tags = var.tags
}
