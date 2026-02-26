#!/bin/bash

echo "This container assumes we are using ckanext custom Solr index... Rebuilding search index"
ckan -c $CKAN_INI search-index rebuild
if [ $? -ne 0 ]; then
  echo "non-zero script exit. Not rebuilding search index"
fi 
