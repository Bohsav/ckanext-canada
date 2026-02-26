#!/bin/bash

response="script: datapusher setup"

if [[ $CKAN__PLUGINS == *"datapusher"* ]]; then
   # Datapusher settings have been configured in the .env file
   # Set API token if necessary
   if [ -z "$CKAN__DATAPUSHER__API_TOKEN" ] ; then
      echo "Set up ckan.datapusher.api_token in the CKAN config file"
      ckan config-tool $CKAN_INI "ckan.datapusher.api_token=$(ckan -c $CKAN_INI user token add ckan_admin datapusher | tail -n 1 | tr -d '\t')"
      if [ $? -ne 0 ]; then
        response="$response; ckan config-tool: non-zero exit"
      fi 
   fi
else
   response="$response; Not configuring DataPusher"
fi

echo $response
