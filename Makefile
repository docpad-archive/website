# If you change something here, be sure to reflect the changes in:
# - the scripts section of the package.json file
# - the .travis.yml file

# -----------------
# Variables

BIN=node_modules/.bin/
COFFEE=$(BIN)coffee
OUT=app/out
SRC=app/src


# -----------------
# Documentation

# Usage: coffee [options] path/to/script.coffee -- [args]
# -b, --bare         compile without a top-level function wrapper
# -c, --compile      compile to JavaScript and save as .js files
# -o, --output       set the output directory for compiled JavaScript
# -w, --watch        watch scripts for changes and rerun commands


# -----------------
# Commands

# Watch and recompile our files
dev:
	$(COFFEE) -cbwo $(OUT) $(SRC)

# Compile our files
compile:
	$(COFFEE) -cbo $(OUT) $(SRC)

# Clean up
clean:
	rm -Rf $(OUT) site/out node_modules *.log

# Install dependencies
install:
	npm install

# Reset
reset:
	make clean
	make install
	make compile

# Ensure the listed commands always re-run and are never cached
.PHONY: dev compile clean install reset
