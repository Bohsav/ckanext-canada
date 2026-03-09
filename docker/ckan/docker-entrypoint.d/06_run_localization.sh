#!/bin/bash

ckanext_canada_path=${SRC_DIR}/ckanext-canada

response="script: ckanext-canada localization setup;"
if [[ -f $ckanext_canada_path/setup.py ]]; then
  cd ${ckanext_canada_path} && python setup.py extract_messages && python setup.py update_catalog && python setup.py compile_catalog
  if [[ $? -ne 0 ]]; then
    response="$response one of the commands failed, check output manually;"
  else
    response="$response localization update complete;"
  fi
else
  response="$response failed to find setup.py under \$SRC_DIR/ckanext-canada. Skipping..."
fi

echo $response
