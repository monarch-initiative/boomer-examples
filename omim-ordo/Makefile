DATA_DIR = ../data
BOOMER_INPUT_DIR = boomer_input
BOOMER_OUTPUT_DIR = boomer_output
PROJECT=mondo-omim-ordo

ALL_RUNS=all

$(DATA_DIR)/ $(BOOMER_INPUT_DIR)/ $(BOOMER_OUTPUT_DIR)/ tmp/:
	mkdir -p $@

#####################
## Ontologies #######
#####################

tmp/mondo.owl: | tmp/
	wget http://purl.obolibrary.org/obo/mondo.owl -O $@

tmp/ordo.owl: | tmp/
	wget https://github.com/monarch-initiative/mondo-ingest/releases/latest/download/ordo.owl -O $@

tmp/omim.owl: | tmp/
	wget https://github.com/monarch-initiative/mondo-ingest/releases/latest/download/omim.owl -O $@

$(BOOMER_INPUT_DIR)/symbiont-merged-all.owl: tmp/omim.owl tmp/ordo.owl tmp/mondo.owl | $(BOOMER_INPUT_DIR)/
	robot merge $(patsubst %, -i %, $^) -o $@

#####################
## Mappings #########
#####################

ALL_MAPPINGS=	$(DATA_DIR)/mondo_exactmatch_orphanet.sssom.tsv	$(DATA_DIR)/mondo_exactmatch_omimps.sssom.tsv	$(DATA_DIR)/mondo_exactmatch_omim.sssom.tsv

$(BOOMER_INPUT_DIR)/combined.sssom.tsv $(BOOMER_INPUT_DIR)/prefix.yaml: $(ALL_MAPPINGS) $(PROJECT).symbiont.yaml | $(BOOMER_INPUT_DIR)/
	python ../scripts/gen_boomer_input.py run \
		--source-location $(DATA_DIR) \
		--target-location $(BOOMER_INPUT_DIR)/ \
		--config $(PROJECT).symbiont.yaml \
		--run-id all

$(BOOMER_INPUT_DIR)/combined.ptable.tsv: $(BOOMER_INPUT_DIR)/combined.sssom.tsv
	sssom ptable $< -o $@


#####################
## Boomer ###########
#####################

.PHONY: boomer-prepare-ptable
boomer-prepare-ptable: $(BOOMER_INPUT_DIR)/combined.ptable.tsv

.PHONY: boomer-prepare-ontology
boomer-prepare-ontology: $(BOOMER_INPUT_DIR)/symbiont-merged-all.owl

.PHONY: boomer-prepare
boomer-prepare: boomer-prepare-ontology boomer-prepare-ptable

boomer: | $(BOOMER_OUTPUT_DIR)/
	boomer --ptable $(BOOMER_INPUT_DIR)/combined.ptable.tsv \
		--ontology $(BOOMER_INPUT_DIR)/symbiont-merged-all.owl \
		--prefixes $(BOOMER_INPUT_DIR)/prefix.yaml \
		--output $(BOOMER_OUTPUT_DIR)/boomer_output \
		--window-count 1 \
		--exhaustive-search-limit 10 \
		--runs 1 \ 
