#!/bin/bash

response="script: security db init;"

if [[ $CKAN__PLUGINS == *"canada_security"* ]]; then
  echo "Setup security"
  ckan -c $CKAN_INI security migrate
  if [[ $? -ne 0 ]]; then
    response="$response cmd: ckan security migrate: non-zero exit, check output manually;"
  else
    response="$response ckan security migrate completed;"
  fi
else
  response="$response DB not migrated for security."
fi

echo $response
