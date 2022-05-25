DATA_DIR = data
BOOMER_INPUT_DIR = boomer_input
BOOMER_OUTPUT_DIR = boomer_output

ALL_RUNS=mondo_all 

$(DATA_DIR)/ $(BOOMER_INPUT_DIR)/ $(BOOMER_OUTPUT_DIR)/:
	mkdir -p $@

#####################
## Ontologies #######
#####################

$(BOOMER_INPUT_DIR)/symbiont-merged-all.owl: | $(BOOMER_INPUT_DIR)/
	wget https://www.dropbox.com/s/q82fm7oxl1m16mh/symbiont-merged-all.owl?dl=0 -O $@

#####################
## Mappings #########
#####################

ALL_MAPPINGS=		$(DATA_DIR)/empty.sssom.tsv \
								$(DATA_DIR)/mondo.sssom.tsv \
								$(DATA_DIR)/mondo_all.sssom.tsv


$(BOOMER_INPUT_DIR)/combined.sssom.tsv $(BOOMER_INPUT_DIR)/prefix.yaml: $(ALL_MAPPINGS) mondo-omim-ordo-do.symbiont.yaml | $(BOOMER_INPUT_DIR)/
	python scripts/gen_boomer_input.py run \
		--source-location $(DATA_DIR) \
		--target-location $(BOOMER_INPUT_DIR)/ \
		--config mondo-omim-ordo-do.symbiont.yaml \
		--run-id mondo_all

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
