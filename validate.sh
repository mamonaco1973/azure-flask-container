#!/bin/bash

CONTAINER_APP="flask-container-app"
RESOURCE_GROUP="flask-container-rg"

# Get the service URL
SERVICE_URL=$(az containerapp show --name "$CONTAINER_APP" --resource-group "$RESOURCE_GROUP" --query "properties.configuration.ingress.fqdn" --output tsv)

# Check if the SERVICE_URL is empty
if [[ -z "$SERVICE_URL" || "$SERVICE_URL" == "None" ]]; then
  echo "ERROR: Service URL for $CONTAINER_APP is not found. Please check if the service exists and try again."
  exit 1
fi

echo "NOTE: Checking the status of Azure Container App: $CONTAINER_APP"

while true; do
    # Extract the RunningState of the active revision
    STATUS=$(az containerapp revision list --name "$CONTAINER_APP" --resource-group "$RESOURCE_GROUP" --query "[?properties.active].properties.runningState" --output tsv)

    if [[ -n "$STATUS" && "$STATUS" == "Running" ]]; then
        echo "NOTE: Container App is now running!"
        break
    else
        echo "WARNING: Current state: ${STATUS:-Unknown}. Waiting..."
        sleep 30
    fi
done

# Move to the directory and run the test script
cd ./02-docker
SERVICE_URL="https://$SERVICE_URL"
echo "NOTE: Testing the Azure Container App Solution."
echo "NOTE: URL for Azure Container App is $SERVICE_URL/gtg?details=true"
./test_candidates.py "$SERVICE_URL"

cd ..
