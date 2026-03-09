ARG SOLR_VERSION=9.9
FROM ckan/ckan-solr:2.10-solr${SOLR_VERSION} AS solr

EXPOSE 8983
USER root

# Override the CKAN's Solr schema with our schema
COPY --chown=solr:solr conf/ $SOLR_CONFIG_DIR/ckan/conf

USER solr

CMD ["sh", "-c", "solr-precreate ckan $SOLR_CONFIG_DIR/ckan"]
