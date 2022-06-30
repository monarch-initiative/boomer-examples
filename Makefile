DATA_DIR = data

$(DATA_DIR)/:
	mkdir -p $@

$(DATA_DIR)/empty.sssom.tsv: | $(DATA_DIR)/
	wget https://raw.githubusercontent.com/mapping-commons/mapping-commons.github.io/main/mappings/empty.sssom.tsv -O $@

$(DATA_DIR)/mondo.sssom.tsv: | $(DATA_DIR)/
	wget https://raw.githubusercontent.com/monarch-initiative/mondo/master/src/ontology/mappings/mondo.sssom.tsv -O $@

$(DATA_DIR)/mondo_all.sssom.tsv: | $(DATA_DIR)/
	#wget http://w3id.org/sssom/commons/monarch/mondo_all.sssom.tsv -O $@
	echo "Skipped $@"

$(DATA_DIR)/mondo_%.sssom.tsv: | $(DATA_DIR)/
	wget http://purl.obolibrary.org/obo/mondo/mappings/mondo_$*.sssom.tsv -O $@

$(DATA_DIR)/ordo.sssom.tsv: | 
	wget https://github.com/monarch-initiative/mondo-ingest/releases/latest/download/ordo.sssom.tsv -O $@

$(DATA_DIR)/omim.sssom.tsv: | 
	wget https://github.com/monarch-initiative/mondo-ingest/releases/latest/download/omim.sssom.tsv -O $@

$(DATA_DIR)/doid.sssom.tsv: | 
	wget https://github.com/monarch-initiative/mondo-ingest/releases/latest/download/doid.sssom.tsv -O $@


.PRECIOUS: update-mappings
update-mappings: $(DATA_DIR)/empty.sssom.tsv \
	$(DATA_DIR)/mondo.sssom.tsv \
	$(DATA_DIR)/mondo_all.sssom.tsv \
	$(DATA_DIR)/mondo_exactmatch_omim.sssom.tsv \
	$(DATA_DIR)/mondo_exactmatch_orphanet.sssom.tsv \
	$(DATA_DIR)/mondo_exactmatch_omimps.sssom.tsv \
	$(DATA_DIR)/mondo_exactmatch_doid.sssom.tsv \
	$(DATA_DIR)/ordo.sssom.tsv \
	$(DATA_DIR)/doid.sssom.tsv \
	$(DATA_DIR)/omim.sssom.tsv