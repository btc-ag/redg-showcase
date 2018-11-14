#!/bin/bash

DOCUMENTATION_GIT="https://github.com/btc-ag/redg-documentation.git"
VISUALIZER_GIT="https://github.com/btc-ag/redg-visualizer.git"
CODE_GIT="https://github.com/btc-ag/redg.git"
CODE_RELEASE_TAG=$1

function log {
	echo ">>>> RedG Site Builder >>>> $1"
}

function check_dependencies {
	command -v python >/dev/null 2>&1 || { echo >&2 "Python needs to be installed. Aborting."; exit 1; }
	command -v mkdocs >/dev/null 2>&1 || { echo >&2 "MkDocs & mkdocs-material need to be installed. Aborting."; exit 1; }
	command -v yarn >/dev/null 2>&1 || { echo >&2 "Yarn needs to be installed. Aborting."; exit 1; }
	command -v mvn >/dev/null 2>&1 || { echo >&2 "Maven needs to be installed. Aborting."; exit 1; }
}


function build_documentation {
	git clone --depth 1 $DOCUMENTATION_GIT documentation_src
	cd documentation_src

	mkdocs build

	mv site ../dist/documentation/
	cd ..
	rm -rf documentation_src
}

function build_visualizer {
	git clone --depth 1 $VISUALIZER_GIT visualizer_src
	cd visualizer_src

	yarn
	yarn run build

	mv dist ../dist/visualizer/
	cd ..
	rm -rf visualizer_src
}

function build_javadoc {
	git clone --depth 1 --branch $CODE_RELEASE_TAG $CODE_GIT main_src
	cd main_src

	mvn javadoc:aggregate

	mv target/site/apidocs ../dist/apidocs
	cd ..
	rm -rf main_src
}

if [ $# != 1 ]
then
    echo "You need to supply the current RedG git tag for the javadoc build!"
    exit 1
fi

check_dependencies

log "Removing old builds..."

rm -rf dist

mkdir -p dist/documentation
mkdir -p dist/visualizer
mkdir -p dist/apidocs

log "Copying showcase..."

rsync -a --exclude=img-sources src/* dist/

log "Building documentation..."

build_documentation

log "Documentation done."
log "Building visualizer..."

build_visualizer

log "Visualizer done."

log "Building Javadoc..."

build_javadoc

log "Javadoc done..."

log "Done."
