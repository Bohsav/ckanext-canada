#!/bin/bash

response="script: apply alembic migrations for each plugin;"

if [[ -z "$CKAN_APPLY_ALEMBIC_MIGRATIONS" ]]; then
  echo "Attempt to perform alembic migrations for every plugin"
  ckan -c $CKAN_INI db pending-migrations --apply
  if [[ $? -ne 0 ]]; then
    response="$response cmd: ckan -c $CKAN_INI db pending-migrations --apply: non-zero exit, check logs manually;"
  else
    response="$response ckan alembic migrations completed;"
  fi
else
  response="$response CKAN_APPLY_ALEMBIC_MIGRATIONS env variable not set, not performing migrations."
fi

echo $response
