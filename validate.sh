
#!/bin/bash

SERVICE_URL=$(az containerapp show --name flask-container-app --resource-group flask-container-rg --query "properties.configuration.ingress.fqdn" --output tsv)

# Check if the SERVICE_URL is empty
if [[ -z "$SERVICE_URL" || "$SERVICE_URL" == "None" ]]; then
  echo "ERROR: Service url for flask-container-app is not found. Please check if the service exists and try again."
  exit 1
fi

cd ./02-docker
SERVICE_URL="https://$SERVICE_URL"
echo "NOTE: Testing the Azure Container App Solution."
echo "NOTE: URL for Azure Container App is $SERVICE_URL/gtg?details=true"
./test_candidates.py $SERVICE_URL

cd ..
