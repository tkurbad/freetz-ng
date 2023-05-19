TOOLS_HOST_VERSION:=2021-03-06
TOOLS_HOST_SOURCE:=tools-$(TOOLS_HOST_VERSION).tar.xz
TOOLS_HOST_SOURCE_SHA256:=80b5a16c123b00d98bd85a5fa1ec63d7e17f03fe6bad49b1b640fcf4f9a7b17a
TOOLS_HOST_SITE:=@MIRROR/

TOOLS_HOST_DIR:=$(TOOLS_SOURCE_DIR)/tools-host-$(TOOLS_HOST_VERSION)


tools-host-source: $(DL_DIR)/$(TOOLS_HOST_SOURCE)
$(DL_DIR)/$(TOOLS_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(TOOLS_HOST_SOURCE) $(TOOLS_HOST_SITE) $(TOOLS_HOST_SOURCE_SHA256)

tools-host-unpacked: $(TOOLS_HOST_DIR)/.unpacked
$(TOOLS_HOST_DIR)/.unpacked: $(DL_DIR)/$(TOOLS_HOST_SOURCE) | $(TOOLS_SOURCE_DIR)
	mkdir -p $(TOOLS_HOST_DIR)
	tar -C $(TOOLS_HOST_DIR) $(VERBOSE) -xf $(DL_DIR)/$(TOOLS_HOST_SOURCE)
	touch $@

$(TOOLS_HOST_DIR)/.installed: $(TOOLS_HOST_DIR)/.unpacked
	cp -a $(TOOLS_HOST_DIR)/tools $(FREETZ_BASE_DIR)/
	touch $@

tools-host-precompiled: $(TOOLS_HOST_DIR)/.installed


tools-host-clean:

tools-host-dirclean:
	$(RM) -r $(TOOLS_HOST_DIR)

tools-host-distclean: tools-host-dirclean $(patsubst %,%-distclean,$(filter-out $(TOOLS_BUILD_LOCAL),$(TOOLS)))

