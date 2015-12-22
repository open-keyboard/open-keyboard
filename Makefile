# Requirements
NPM = $(shell command -v npm || { echo "npm not found." >&2; exit 1; })
COMPOSER = $(shell command -v composer || \
	{ echo "composer not found." >&2; exit 1; })
DEV_APPSERVER = $(shell command -v dev_appserver.py || \
	{ echo "dev_appserver.py not found." >&2; exit 1; })

# Directories
NODE_DIR = $(CURDIR)/node_modules
COMPOSER_DIR = $(CURDIR)/vendor
NODE_BIN_DIR = $(NODE_DIR)/.bin
COMPOSER_BIN_DIR = $(COMPOSER_DIR)/bin
SRC_DIR = $(CURDIR)/src
API_DIR = $(SRC_DIR)/api
DIST_DIR = $(CURDIR)/dist
TEST_DIR = $(CURDIR)/test

# Dev tools
BROWSERIFYINC := $(NODE_BIN_DIR)/browserifyinc
ESLINT        := $(NODE_BIN_DIR)/eslint
ISPARTA       := $(NODE_BIN_DIR)/isparta
JSCS          := $(NODE_BIN_DIR)/jscs
MOCHA         := $(NODE_BIN_DIR)/mocha
PHPCS         := $(COMPOSER_BIN_DIR)/phpcs
WATCHIFY      := $(NODE_BIN_DIR)/watchify

# Files
SRC = index.js
DIST = app.js

# Options
UGLIFY_OPTS = \
	--compress \
	--mangle

MINIFYIFY_OPTS = \
	--no-map \
	--uglify [ $(UGLIFY_OPTS) ]

BROWSERIFY_OPTS = \
	$(SRC_DIR)/$(SRC) \
	-t babelify \
	-p [ minifyify $(MINIFYIFY_OPTS) ] \
	-o $(DIST_DIR)/$(DIST)

WATCHIFY_OPTS = \
	$(SRC_DIR)/$(SRC) \
	-t babelify \
	-v \
	-d \
	-o $(DIST_DIR)/$(DIST)

MOCHA_OPTS = \
	--compilers js:babel-core/register \
	--recursive

# Tasks
RM    := rm -f
MKDIR := mkdir -p

.PHONY: all
all: publish

.PHONY: publish
publish: lint test cover build

.PHONY: build
build: $(BROWSERIFYINC)
	@$(MKDIR) $(DIST_DIR)
	@$(BROWSERIFYINC) $(BROWSERIFY_OPTS)

.PHONY: watch
watch: $(WATCHIFY)
	@$(WATCHIFY) $(WATCHIFY_OPTS)

.PHONY: start
start:
	@$(DEV_APPSERVER) $(CURDIR)

.PHONY: lint
lint: lint-phpcs lint-jscs lint-eslint

.PHONY: lint-phpcs
lint-phpcs: $(PHPCS)
	@$(PHPCS) $(API_DIR)

.PHONY: lint-jscs
lint-jscs: $(JSCS)
	@$(JSCS) $(SRC_DIR) $(TEST_DIR) --esnext

.PHONY: lint-eslint
lint-eslint: $(ESLINT)
	@$(ESLINT) $(SRC_DIR) $(TEST_DIR)

.PHONY: test
test: test-js

.PHONY: test-js
test-js: $(MOCHA)
	@$(MOCHA) $(MOCHA_OPTS)

.PHONY: cover
cover: cover-js

.PHONY: cover-js
cover-js: $(ISPARTA)
	@$(ISPARTA) cover $(SRC_DIR)

.PHONY: deep-clean
deep-clean: clean
	@$(RM) -r node_modules vendor

.PHONY: clean
clean:
	@$(RM) -r browserify-cache.json dist

$(COMPOSER_DIR): $(COMPOSER)
	@$(COMPOSER) install

$(NODE_DIR): $(NPM)
	@$(NPM) install

$(PHPCS): $(COMPOSER_DIR)

$(BROWSERIFYINC): $(NODE_DIR)

$(ESLINT): $(NODE_DIR)

$(ISPARTA): $(NODE_DIR)

$(JSCS): $(NODE_DIR)

$(MOCHA): $(NODE_DIR)

$(WATCHIFY): $(NODE_DIR)