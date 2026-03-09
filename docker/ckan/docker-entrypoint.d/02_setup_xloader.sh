#!/bin/bash

echo "script: xloader setup"

if [[ $CKAN__PLUGINS == *"xloader"* ]]; then
  echo "Xloader detected; setting up Xloader"
  
  echo "Checking API token..."
  if [[ -z "$CKAN__XLOADER__API_TOKEN" ]]; then
    echo "Generating new API token..."
    ckan config-tool $CKAN_INI "ckanext.xloader.api_token=$(ckan -c $CKAN_INI user token add ckan_admin xloader | tail -n 1 | tr -d '\t')"
  else
    echo "Xloader API token provided: ${CKAN__XLOADER__API_TOKEN:0:6}"
  fi
  echo "API token checked"

  echo "Checking SQL aclhemy"
  if [[ -z "${CKAN_SQLALCHEMY_URL:-}" ]]; then
    echo "WARNING: CKAN_SQLALCHEMY_URL is not set; cannot configure jobs_db.uri for ckan. Please perform manual setup"
  else
    echo "Setting ckanext.xloader.jobs_db.uri in ${CKAN_INI}"
    ckan config-tool "$CKAN_INI" "ckanext.xloader.jobs_db.uri=${CKAN_SQLALCHEMY_URL}"
  fi
  echo "SQL Alchemy checked"

  echo "Looking to initialize xloader jobs database table"
  ckan -c $CKAN_INI xloader db-init
  if [[ $? -ne 0 ]]; then
    echo "cmd: ckan xloader db-init: non-zero exit, check output manually"
  else
    echo "xloader jobs db setup complete;"
  fi 
  echo "Attempted to initialize xloader jobs db"

  echo "Xloader is ready"
else
  echo "Not configuring Xloader"
fi

echo "Xloader checked"
