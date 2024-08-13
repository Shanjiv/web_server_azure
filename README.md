# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Getting Started
1. Clone this repository

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

1. **Set Up Your Environment:**
   - Ensure you have all dependencies installed (Azure CLI, Packer, Terraform).
   - Authenticate with Azure using the CLI:
     ```bash
     az login
     ```

2. **Create the Packer Image:**
   - Navigate to the directory containing the `server.json` Packer template.
   - Run the following command to build the custom image:
     ```bash
     packer build server.json
     ```
   - This will create a custom image named `myPackerImage_2` in the specified Azure resource group.

3. **Set Up Terraform:**
   - Navigate to the directory containing the `main.tf` Terraform template.
   - Initialize Terraform:
     ```bash
     terraform init
     ```
   - Run Terraform plan to review the infrastructure changes:
     ```bash
     terraform plan -out solution.plan
     ```
   - Apply the Terraform plan to create the infrastructure:
     ```bash
     terraform apply solution.plan
     ```

4. **Verify the Deployment:**
   - After Terraform completes, it will output the public IP address of the load balancer.
   - Open a web browser and navigate to the public IP address. You should see the "Hello, World!" message indicating that the deployment was successful.

5. **Clean Up Resources:**
   - To avoid unnecessary costs, you can destroy the infrastructure when you're done:
     ```bash
     terraform destroy
     ```
   - You can also manually delete the resource group from the Azure portal if needed.

### Customizing `vars.tf`

The `vars.tf` file contains several variables that allow you to customize the deployment according to your needs. Here’s a brief description of what each variable does and how you might want to change them:

- **`location`:** The Azure region where your resources will be deployed. The default is `West Europe`, but you can change it to any region supported by Azure.
- **`resource_group_name`:** The name of the resource group where all resources will be created. You can use an existing resource group or create a new one.
- **`vnet_name`:** The name of the virtual network. Adjust this if you have a specific naming convention or if you want to use an existing virtual network.
- **`subnet_name`:** The name of the subnet within the virtual network. Customize it according to your subnet structure.
- **`nsg_name`:** The name of the Network Security Group (NSG). You can change it to fit your naming standards or existing NSGs.
- **`lb_name`:** The name of the load balancer. Modify it if needed.
- **`availability_set_name`:** The name of the availability set. Adjust if you have specific availability set requirements.
- **`vm_count`:** The number of virtual machines to deploy. The default is `2`, but you can increase or decrease this based on your needs.
- **`vm_size`:** The size of the virtual machines. The default is `Standard_B1s`, but you can select a different size according to the workload.
- **`admin_username` and `admin_password`:** The credentials for the VMs. Ensure you use secure values.
- **`packer_image_name`:** The name of the image created by Packer. Ensure this matches the image you built with Packer.
- **`tags`:** Tags applied to all resources. Modify or add more tags as required by your organization.

### Output

After successfully running the Packer and Terraform templates, you should expect the following:

1. **Custom Packer Image:**
   - A custom image named `myPackerImage_2` is created in the specified Azure resource group. This image includes the necessary configurations to run a simple web server that serves a "Hello, World!" page.

2. **Infrastructure Resources:**
   - **Virtual Network (`myapp-network`)**: A virtual network with a defined address space.
   - **Subnet (`internal`)**: A subnet within the virtual network.
   - **Network Security Group (`myapp-nsg`)**: A security group with rules allowing inbound SSH (port 22) and HTTP (port 80) traffic.
   - **Public IP Addresses**: Two public IP addresses, one for the network interface and one for the load balancer.
   - **Network Interface (`myapp-nic`)**: A network interface associated with the subnet and one of the public IP addresses.
   - **Load Balancer (`myapp-lb`)**: A load balancer that distributes incoming HTTP traffic to the virtual machines.
   - **Availability Set (`myapp-availability-set`)**: An availability set that ensures the VMs are distributed across multiple fault domains for high availability.
   - **Virtual Machines (`myapp-vm-0`, `myapp-vm-1`)**: Two virtual machines deployed using the custom Packer image, each connected to the load balancer.

3. **Accessing the Deployed Application:**
   - You can access the deployed web application by navigating to the public IP address associated with the load balancer in your web browser. You should see a "Hello, World!" message indicating that the web server is running correctly.
