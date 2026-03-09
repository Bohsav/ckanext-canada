#!/bin/bash

response="script: recombinant init;"

if [[ $CKAN__PLUGINS == *"recombinant"* ]]; then
  echo "Setup recombinant"
  ckan -c $CKAN_INI recombinant update
  if [[ $? -ne 0 ]]; then
    response="$response cmd: ckan recombinant update: non-zero exit, check output manually;"
  else
    response="$response ckan recombinant update completed;"
  fi
else
  response="$response Not configuring recombinant"
fi

echo $response
