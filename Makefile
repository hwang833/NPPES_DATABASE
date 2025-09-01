# All packages in Linux that you need
needed_packages=make curl jq python psql pytest unzip 

current_directory := $(shell pwd)

.PHONY: cron target

all: clear_db clear_NPPES_data run_taxonomy run_NPPES summary

check_packages:
	@all_packages_installed=true; \
	for package in $(needed_packages); do \
		if ! command -v $$package >/dev/null 2>&1; then \
			echo "$$package is not installed on this computer. Install by doing: sudo apt-get install $$package"; \
			all_packages_installed=false; \
		fi; \
	done; \
	if [ "$$all_packages_installed" = "true" ]; then \
		echo "✅ All needed packages have been successfully installed! ✅"; \
	else \
		echo "⛔ Some packages are missing. Please install them before continuing. ⛔"; \
	fi

clear_db:
	@echo "Cleaning data from database"
	@info_json_location="$(current_directory)/info.json"; \
	db_name=$$(jq -r '.database' $$info_json_location); \
	db_username=$$(jq -r '.user' $$info_json_location); \
	db_password=$$(jq -r '.password' $$info_json_location); \
	db_host=$$(jq -r '.host' $$info_json_location); \
	db_port=$$(jq -r '.port' $$info_json_location); \
	psql "postgresql://$$db_username:$$db_password@$$db_host:$$db_port/$$db_name" -f "$(current_directory)/db/drop_tables.sql"

clear_NPPES_data:
	@echo "Removing Original_data directory in this repository"; \
	rm -rf "$(current_directory)/Original_data"

CRONFILE="$(current_directory)/lib/crontab.txt"

cron:
	@crontab "$(CRONFILE)"
	@echo "Crontab has been added!"

help:
	@echo "Command: make [target] [...target] "
	@echo "Available targets:";
	@echo " all - Automate the pipeline by deleting all data and inserting in the new data "
	@echo " check_packages - Verify all packages are installed on your computer before proceeding "
	@echo " clean_db - Drop all the tables and types in the database "
	@echo " clean_NPPES_data - Clear the Original_data directory when the run command is finished "
	@echo " cron - Have the system perform the all command for the 1st day of every month"
	@echo " run_NPPES - Run the script which performs ETL (Extract, Transfer, Load) on NPPES data into the database "
	@echo " run_taxonomy - Run the script which performs ETL (Extract, Transfer, Load) on Taxonomy data into the database "
	@echo " summary - Print out a summary of provider data "
	@echo " test - Verify all packages are installed on your computer before proceeding "

run_NPPES:
	"$(current_directory)/lib/NPPES_data_fetching.sh"

run_taxonomy:
	"$(current_directory)/lib/taxonomy_data_fetching.sh"

summary:
	@python "$(current_directory)/lib/summary.py"

test:
	pytest "$(current_directory)/tests/test_database.py"
	pytest "$(current_directory)/tests/test_db_staging.py"
