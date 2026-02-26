#!/bin/bash

response="script: validation db setup"

if [[ $CKAN__PLUGINS == *"validation"* ]]; then
  echo "Setup validation db"
  ckan -c $CKAN_INI validation init-db
  if [ $? -ne 0 ]; then
    response="$response; ckan config-tool: non-zero exit"
  fi 
else
  response="$response; Not configuring validation db."
fi

echo $response
