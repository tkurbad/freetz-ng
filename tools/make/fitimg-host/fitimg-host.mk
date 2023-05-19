FITIMG_HOST_VERSION:=0.5
FITIMG_HOST_SOURCE:=fitimg-$(FITIMG_HOST_VERSION).tar.gz
FITIMG_HOST_SOURCE_MD5:=4634b04b30544bf0add5026b86cd4604
FITIMG_HOST_SITE:=https://boxmatrix.info/hosted/hippie2000

FITIMG_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/fitimg-host
FITIMG_HOST_DIR:=$(TOOLS_SOURCE_DIR)/fitimg-$(FITIMG_HOST_VERSION)


fitimg-host-source: $(DL_DIR)/$(FITIMG_HOST_SOURCE)
$(DL_DIR)/$(FITIMG_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(FITIMG_HOST_SOURCE) $(FITIMG_HOST_SITE) $(FITIMG_HOST_SOURCE_MD5)

fitimg-host-unpacked: $(FITIMG_HOST_DIR)/.unpacked
$(FITIMG_HOST_DIR)/.unpacked: $(DL_DIR)/$(FITIMG_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(FITIMG_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(FITIMG_HOST_MAKE_DIR)/patches,$(FITIMG_HOST_DIR))
	touch $@

$(FITIMG_HOST_DIR)/fitimg: $(FITIMG_HOST_DIR)/.unpacked

$(TOOLS_DIR)/fitimg: $(FITIMG_HOST_DIR)/fitimg
	$(INSTALL_FILE)

fitimg-host-precompiled: $(TOOLS_DIR)/fitimg


fitimg-host-clean:

fitimg-host-dirclean:
	$(RM) -r $(FITIMG_HOST_DIR)

fitimg-host-distclean: fitimg-host-dirclean
	$(RM) $(TOOLS_DIR)/fitimg

