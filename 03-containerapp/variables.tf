variable "resource_group_name" {
  description = "The name of the Azure resource group"
  type        = string
  default     = "flask-container-rg"
}

# This is to get around the chicken and egg problem with deploying
# a container app with an ACR image. You need the container app created 
# to assign the AcrPull role but you can't create the container app with
# an ACR image because it doesn't have the role. The solution is to
#
# 1. Build the container app with a public image such as nginx
# 2. The container app successfully builds with the public image and
#    applies the AcrPull role.  
# 3. Re-run the terraform build and specify the ACR image - we use
#    variable to accomplish this.

variable "container_image" {
  description = "The name of the container image to use in the container app"
  type        = string
  default     = "nginx"
}