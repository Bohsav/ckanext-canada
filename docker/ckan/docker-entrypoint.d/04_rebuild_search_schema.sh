#!/bin/bash

echo "This container assumes we are using ckanext custom Solr index... Rebuilding search index"
ckan -c $CKAN_INI search-index rebuild
if [[ $? -ne 0 ]]; then
  echo "cmd: ckan search-index rebuild: non-zero script exit. Not rebuilding search index"
else
  echo "Solr search index rebuilt"
fi 
