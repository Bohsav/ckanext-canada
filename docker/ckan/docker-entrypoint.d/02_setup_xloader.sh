#!/bin/bash

if [[ $CKAN__PLUGINS == *"xloader"* ]]; then
  echo "Xloader detected; setting up Xloader"
  
  echo "Checking API token..."
  if [ -z "$CKAN__XLOADER__API_TOKEN" ]; then
    echo "Generating new API token..."
    ckan config-tool $CKAN_INI "ckanext.xloader.api_token=$(ckan -c $CKAN_INI user token add ckan_admin xloader | tail -n 1 | tr -d '\t')"
  else
    echo "Xloader API token provided: ${CKAN__XLOADER__API_TOKEN:0:6}"
  fi
  echo "API token checked"

  echo "Checking SQL aclhemy"
  if [[ -z "${CKAN_SQLALCHEMY_URL:-}" ]]; then
    echo "ERROR. CKAN_SQLALCHEMY_URL is not set; cannot configure jobs_db.uri"
    exit 1
  else
    echo "Setting ckanext.xloader.jobs_db.uri in ${CKAN_INI}"
    ckan config-tool "$CKAN_INI" "ckanext.xloader.jobs_db.uri=${CKAN_SQLALCHEMY_URL}"
  fi
  echo "SQL Alchemy checked"

  echo "Xloader is ready"
else
  echo "Not configuring Xloader"
fi

echo "Xloader checked."
