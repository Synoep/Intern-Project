#!/bin/bash
# Rollback deployment in case of failure
# Usage: ./rollback.sh <namespace> <deployment-name>

set -e

NAMESPACE=$1
DEPLOYMENT=$2

if [ -z "$NAMESPACE" ] || [ -z "$DEPLOYMENT" ]; then
  echo "Error: NAMESPACE and DEPLOYMENT parameters are required"
  echo "Usage: ./rollback.sh <namespace> <deployment-name>"
  exit 1
fi

echo "Starting rollback of $DEPLOYMENT in namespace $NAMESPACE"

# Check current deployment status
READY=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
TOTAL=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.status.replicas}')

echo "Current status: $READY/$TOTAL replicas ready"

if [ "$READY" == "$TOTAL" ]; then
  echo "Deployment appears to be healthy. Are you sure you want to roll back?"
  read -p "Continue with rollback? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Rollback canceled"
    exit 0
  fi
fi

# Check revision history
echo "Available revisions:"
kubectl rollout history deployment $DEPLOYMENT -n $NAMESPACE

# Get the previous revision number
PREVIOUS_REVISION=$(kubectl rollout history deployment $DEPLOYMENT -n $NAMESPACE | grep -v "REVISION" | sort -rn | sed -n '2p' | awk '{print $1}')

if [ -z "$PREVIOUS_REVISION" ]; then
  echo "No previous revision found. Cannot rollback."
  exit 1
fi

echo "Rolling back to revision $PREVIOUS_REVISION"

# Perform the rollback
kubectl rollout undo deployment $DEPLOYMENT -n $NAMESPACE --to-revision=$PREVIOUS_REVISION

# Watch the rollback progress
echo "Watching rollback progress..."
kubectl rollout status deployment $DEPLOYMENT -n $NAMESPACE

# Verify the rollback was successful
NEW_READY=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
NEW_TOTAL=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.status.replicas}')

echo "Rollback complete. Status: $NEW_READY/$NEW_TOTAL replicas ready"

if [ "$NEW_READY" == "$NEW_TOTAL" ]; then
  echo "✅ Rollback successful!"
  exit 0
else
  echo "⚠️ Warning: Not all replicas are ready after rollback."
  echo "Please check deployment status manually."
  exit 1
fi