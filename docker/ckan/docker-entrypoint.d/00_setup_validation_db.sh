#!/bin/bash

response="script: validation db;"

if [[ $CKAN__PLUGINS == *"validation"* ]]; then
  echo "Setup validation db"
  ckan -c $CKAN_INI validation init-db
  if [[ $? -ne 0 ]]; then
    response="$response cmd: ckan validation init-db: non-zero exit, check output manually;"
  else
    response="$response validation db setup complete;"
  fi 
else
  response="$response Not configuring validation db"
fi

echo $response
