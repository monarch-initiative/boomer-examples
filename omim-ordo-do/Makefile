DATA_DIR = ../data
BOOMER_INPUT_DIR = boomer_input
BOOMER_OUTPUT_DIR = boomer_output

ALL_RUNS=mondo_all
RUN_ID=mondo_omim_ordo_do
COMPARISON_DIR = $(BOOMER_OUTPUT_DIR)/$(RUN_ID)/comparison

$(DATA_DIR)/ $(BOOMER_INPUT_DIR)/ $(BOOMER_OUTPUT_DIR)/:
	mkdir -p $@

#####################
## Ontologies #######
#####################

$(BOOMER_INPUT_DIR)/symbiont-merged-all.owl: | $(BOOMER_INPUT_DIR)/
	wget https://www.dropbox.com/s/q82fm7oxl1m16mh/symbiont-merged-all.owl?dl=0 -O $@
$(BOOMER_INPUT_DIR)/mondo.owl:  | $(BOOMER_INPUT_DIR)/
	wget http://purl.obolibrary.org/obo/mondo.owl -O $@

#####################
## Mappings #########
#####################

ALL_MAPPINGS=		$(DATA_DIR)/empty.sssom.tsv \
								$(DATA_DIR)/mondo.sssom.tsv \
								$(DATA_DIR)/mondo_all.sssom.tsv


$(BOOMER_INPUT_DIR)/combined.sssom.tsv $(BOOMER_INPUT_DIR)/prefix.yaml: $(ALL_MAPPINGS) mondo-omim-ordo-do.symbiont.yaml | $(BOOMER_INPUT_DIR)/
	python ../scripts/gen_boomer_input.py run \
		--source-location $(DATA_DIR) \
		--target-location $(BOOMER_INPUT_DIR)/ \
		--config mondo-omim-ordo-do.symbiont.yaml \
		--run-id $(RUN_ID)

$(BOOMER_INPUT_DIR)/$(RUN_ID)/combined.ptable.tsv: $(DATA_DIR)/$(RUN_ID).sssom.tsv
	sssom ptable $< -o $@


#####################
## Boomer ###########
#####################

.PHONY: boomer-prepare-ptable
boomer-prepare-ptable: $(BOOMER_INPUT_DIR)/$(RUN_ID)/combined.ptable.tsv

.PHONY: boomer-prepare-ontology
boomer-prepare-ontology: $(BOOMER_INPUT_DIR)/symbiont-merged-all.owl

.PHONY: boomer-prepare
boomer-prepare: boomer-prepare-dirs boomer-prepare-ontology boomer-prepare-ptable 

boomer-prepare-dirs: 
	mkdir -p $(BOOMER_OUTPUT_DIR)/$(RUN_ID)
	mkdir -p $(BOOMER_INPUT_DIR)/$(RUN_ID)
	mkdir -p $(COMPARISON_DIR)

boomer: | $(BOOMER_OUTPUT_DIR)/$(RUN_ID)/
	boomer --ptable $(BOOMER_INPUT_DIR)/$(RUN_ID)/combined.ptable.tsv \
		--ontology $(BOOMER_INPUT_DIR)/mondo.owl \
		--prefixes $(BOOMER_INPUT_DIR)/prefix.yaml \
		--output $(BOOMER_OUTPUT_DIR)/$(RUN_ID) \
		--window-count 10 \
		--exhaustive-search-limit 20 \
		--runs 5 \
		--output-internal-axioms true
	
	find $(BOOMER_OUTPUT_DIR)/$(RUN_ID) -name "*.json" -type 'f' -size -2000c -delete # Hack for removing individual singleton json files.

#####################
## Reports ##########
#####################

%.dot: %.json
	og2dot -s ../config/boomer-style.json $< >$@
%.png: %.dot
	test `wc -c <$<` -gt 650000 || dot $< -Tpng -Grankdir=BT >$@


JSONS_NO_MAPPINGS=$(wildcard $(BOOMER_OUTPUT_DIR)/$(RUN_ID)/*.json)
PNGS_NO_MAPPINGS=$(patsubst %.json, %.png, $(filter-out singletons, $(JSONS_NO_MAPPINGS)))

.PHONY: reports
reports: $(PNGS_NO_MAPPINGS)

# Post processing

$(COMPARISON_DIR)/$(RUN_ID).json: $(BOOMER_OUTPUT_DIR)/$(RUN_ID).ofn
	robot convert -i $(BOOMER_OUTPUT_DIR)/$(RUN_ID).ofn -o $@

$(COMPARISON_DIR)/boomer.sssom.tsv: $(COMPARISON_DIR)/$(RUN_ID).json
	sssom parse $< -I obographs-json -m $(BOOMER_INPUT_DIR)/$(RUN_ID)/metadata.yaml -o $@

$(COMPARISON_DIR)/diff.sssom.tsv: $(COMPARISON_DIR)/boomer.sssom.tsv
	sssom diff $(DATA_DIR)/$(RUN_ID).sssom.tsv $< --output $@

.PHONY: uncommon_mappings
uncommon_mappings: $(COMPARISON_DIR)/diff.sssom.tsv