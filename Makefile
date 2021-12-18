ETC_DIR := /etc/godaddy-ddns
ETC_CONFIG := /etc/godaddy-ddns/ddns.env
USR_BIN_SCRIPT := /etc/godaddy-ddns/godaddy-ddns.bash
SYSTEMD_SERVICE := /etc/systemd/system/godaddy-ddns.service

all: build

.PHONY: build install

 ifeq (, $(shell which curl))
 $(error "No command curl in PATH=$(PATH)")
 endif

$(ETC_DIR): 
	mkdir /etc/godaddy-ddns

$(ETC_CONFIG):
	echo "GODADDY_DDNS_KEY=" > $(ETC_CONFIG)
	echo "GODADDY_DDNS_SECRET=" >> $(ETC_CONFIG)
	echo "GODADDY_DDNS_DOMAIN=" >> $(ETC_CONFIG)
	echo "GODADDY_DDNS_NAME=" >> $(ETC_CONFIG)
	echo "GODADDY_DDNS_IPV6=" >> $(ETC_CONFIG)

$(USR_BIN_SCRIPT):
	cp ./godaddy-ddns.bash $(USR_BIN_SCRIPT)

$(SYSTEMD_SERVICE):
	cp ./godaddy-ddns.service $(SYSTEMD_SERVICE)

install: $(ETC_DIR) $(ETC_CONFIG) $(USR_BIN_SCRIPT) $(SYSTEMD_SERVICE)

build:

clean:
	