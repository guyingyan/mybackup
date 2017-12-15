# Makefile for Board project
#
# Targets:
#   all: Builds the code
#   build: Builds the code
#   fmt: Formats the source files
#   clean_binary: cleans the code
#   install: Installs the code to the GOPATH
#   test: Runs the tests
#   vet: Vet examines source code and reports suspicious constructs
#   golint: Linter for source code
#
#

# Common
# Develop flag
#
# guyingyan add test
DEVFLAG=release
ifeq ($(DEVFLAG), release) 
	BASEIMAGE=alpine:3.5
	GOBUILDIMAGE=golang:1.8.3-alpine3.5
	WORKPATH=release
	IMAGEPREFIX=board
else
	BASEIMAGE=ubuntu:14.04
	GOBUILDIMAGE=golang:1.8.1
	WORKPATH=dev
	IMAGEPREFIX=dev
endif 
VERSIONTAG=latest

# Base shell parameters
SHELL := /bin/bash
BUILDPATH=$(CURDIR)
MAKEPATH=$(BUILDPATH)/make
MAKEWORKPATH=$(MAKEPATH)/$(WORKPATH)
SRCPATH= src
TOOLSPATH=$(BUILDPATH)/tools
IMAGEPATH=$(BUILDPATH)/make/$(MAKEWORKPATH)
PACKAGEPATH=$(BUILDPATH)/Deploy


# docker parameters
DOCKERCMD=$(shell which docker)
DOCKERBUILD=$(DOCKERCMD) build
DOCKERRMIMAGE=$(DOCKERCMD) rmi
DOCKERPULL=$(DOCKERCMD) pull
DOCKERIMASES=$(DOCKERCMD) images
DOCKERSAVE=$(DOCKERCMD) save
DOCKERCOMPOSECMD=$(shell which docker-compose)
DOCKERTAG=$(DOCKERCMD) tag

DOCKERCOMPOSEFILEPATH=$(MAKEWORKPATH)
DOCKERCOMPOSEFILENAME=docker-compose.yml
DOCKERCOMPOSEUIFILENAME=docker-compose.uibuilder.yml

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOINSTALL=$(GOCMD) install
GOTEST=$(GOCMD) test
#GODEP=$(GOTEST) -i
GOFMT=gofmt -w
GOVET=$(GOCMD) vet
GOLINT=golint
GOIMGBASEPATH=/go/src/git/inspursoft/board

# prepare parameters
PREPAREPATH=$(TOOLSPATH)
PREPARECMD=prepare
PREPARECMD_PARAMETERS=--conf $(CONFIGPATH)/$(CONFIGFILE)

# swagger parameters
SWAGGERTOOLPATH=$(TOOLSPATH)/swagger
SWAGGERFILEPATH=$(BUILDPATH)/docs

#package 
TARCMD=$(shell which tar)
ZIPCMD=$(shell which gzip)
PKGTEMPPATH=Deploy
PKGNAME=board

# Package lists
# TOPLEVEL_PKG := .
INT_LIST := apiserver tokenserver collector/cmd
IMG_LIST := apiserver tokenserver log collector gitserver jenkins mysql nginx

# List building
COMPILEALL_LIST = $(foreach int, $(INT_LIST), $(SRCPATH)/$(int))

COMPILE_LIST = $(foreach int, $(COMPILEALL_LIST), $(int)_compile)
CLEAN_LIST = $(foreach int, $(COMPILEALL_LIST), $(int)_clean)
INSTALL_LIST = $(foreach int, $(COMPILEALL_LIST), $(int)_install)
TEST_LIST = $(foreach int, $(COMPILEALL_LIST), $(int)_test)
FMT_LIST = $(foreach int, $(COMPILEALL_LIST), $(int)_fmt)
VET_LIST = $(foreach int, $(COMPILEALL_LIST), $(int)_vet)
GOLINT_LIST = $(foreach int, $(COMPILEALL_LIST), $(int)_golint)
PKG_LIST = $(foreach int, $(IMG_LIST), $(IMAGEPREFIX)_$(int):$(VERSIONTAG))

BUILDALL_LIST = $(foreach int, $(IMG_LIST), container/$(int))
BUILD_LIST = $(foreach int, $(BUILDALL_LIST), $(int)_build)
RMIMG_LIST = $(foreach int, $(BUILDALL_LIST), $(int)_rmi)

# All are .PHONY for now because dependencyness is hard
.PHONY: $(CLEAN_LIST) $(TEST_LIST) $(FMT_LIST) $(INSTALL_LIST) $(COMPILE_LIST) $(VET_LIST) $(GOLINT_LIST) $(BUILD_LIST)

all: compile 
compile: $(COMPILE_LIST)
cleanbinary: $(CLEAN_LIST)
install: $(INSTALL_LIST)
test: $(TEST_LIST)
fmt: $(FMT_LIST)
vet: $(VET_LIST)
golint: $(GOLINT_LIST)

compile_ui:
	$(DOCKERCOMPOSECMD) -f $(MAKEPATH)/dev/$(DOCKERCOMPOSEUIFILENAME) up

$(COMPILE_LIST): %_compile: # %_fmt  %_vet %_golint
	$(DOCKERCMD) run --rm -v $(BUILDPATH):$(GOIMGBASEPATH) \
					-w $(GOIMGBASEPATH)/$* $(GOBUILDIMAGE) $(GOBUILD) \
					-v -o $(GOIMGBASEPATH)/make/$(WORKPATH)/container/$(subst /cmd,,$(subst src/,,$*))/$(subst /cmd,,$(subst src/,,$*)) 

$(CLEAN_LIST): %_clean:
#	$(GOCLEAN) $(TOPLEVEL_PKG)/$* 
	rm $(MAKEWORKPATH)/container/$(subst /cmd,,$(subst src/,,$*))/$(subst /cmd,,$(subst src/,,$*))	    
$(INSTALL_LIST): %_install:
	$(GOINSTALL) $(TOPLEVEL_PKG)/$*
$(TEST_LIST): %_test:
#	$(GOTEST) $(TOPLEVEL_PKG)/$*
	$(DOCKERCMD) run --rm -v $(BUILDPATH):$(GOIMGBASEPATH) \
                                        -w $(GOIMGBASEPATH)/$* $(GOBUILDIMAGE) $(GOTEST) \
                                        -v -o $(GOIMGBASEPATH)/make/$(WORKPATH)/container/$(subst /cmd,,$(subst src/,,$*))/$(subst /cmd,,$(subst src/,,$*))
$(FMT_LIST): %_fmt:
	$(GOFMT) ./$*
$(VET_LIST): %_vet:
	$(GOVET) ./$*/...
$(GOLINT_LIST): %_golint:
	$(GOLINT) $*/...

build: $(BUILD_LIST) #container/db_build
cleanimage: $(RMIMG_LIST) #container/db_rmi

$(BUILD_LIST): %_build: 
	$(DOCKERBUILD) -f $(MAKEWORKPATH)/$(subst mysql,db,$*)/Dockerfile . -t $(IMAGEPREFIX)_$(subst container/,,$*):latest
	
$(RMIMG_LIST): %_rmi:
	$(DOCKERRMIMAGE) -f $(IMAGEPREFIX)_$(subst container/,,$*):latest

#container/db_build:
#	$(DOCKERBUILD) -f $(MAKEWORKPATH)/container/db/Dockerfile . -t $(IMAGEPREFIX)_mysql:latest
#container/db_rmi:
#	$(DOCKERRMIMAGE) $(IMAGEPREFIX)_mysql:latest

prepare:
	@echo "preparing..."
	@$(MAKEPATH)/$(PREPARECMD) $(PREPARECMD_PARA)
	@echo "Done."

start:
	@echo "loading Board images..."
	$(DOCKERCOMPOSECMD) -f $(DOCKERCOMPOSEFILEPATH)/$(DOCKERCOMPOSEFILENAME) up -d
	@echo "Start complete. You can visit Board now."

down:
	@echo "stoping Board instance..."
	$(DOCKERCOMPOSECMD) -f $(DOCKERCOMPOSEFILEPATH)/$(DOCKERCOMPOSEFILENAME) down -v
	@echo "Done."

prepare_swagger:
	@echo "preparing swagger environment..."
	@cd $(SWAGGERTOOLPATH); ./prepare-swagger.sh
	@echo "Done."

package:
	@echo "packing offline package ..."
	@if [ ! -d $(PKGTEMPPATH) ] ; then mkdir $(PKGTEMPPATH) ; fi
	@cp $(TOOLSPATH)/install.sh $(PKGTEMPPATH)/install.sh
	@cp $(MAKEPATH)/board.cfg $(PKGTEMPPATH)/.
	@cp $(MAKEPATH)/prepare $(PKGTEMPPATH)/.
	@cp -rf $(MAKEPATH)/templates $(PKGTEMPPATH)/.
	@cp $(MAKEWORKPATH)/docker-compose.yml $(PKGTEMPPATH)/.
#	@cp LICENSE $(PKGTEMPPATH)/LICENSE
#	@cp NOTICE $(PKGTEMPPATH)/NOTICE
	@sed -i "s/..\/config/.\/config/" $(PKGTEMPPATH)/docker-compose.yml
	@echo "pcakage images ..."
	@$(DOCKERSAVE) -o $(PKGTEMPPATH)/$(IMAGEPREFIX)_deployment.$(VERSIONTAG).tgz $(PKG_LIST)
	@$(TARCMD) -zcvf $(PKGNAME)-offline-installer-$(VERSIONTAG).tgz $(PKGTEMPPATH)
	
	@rm -rf $(PACKAGEPATH)

packageonestep: compile compile_ui build package

.PHONY: cleanall
cleanall: cleanbinary cleanimage

clean:
	@echo "  make cleanall:         remove binaries and Board images"
	@echo "  make cleanbinary:      remove apiserver tokenserver and collector/cmd binary"
	@echo "  make cleanimage:       remove Board images"
