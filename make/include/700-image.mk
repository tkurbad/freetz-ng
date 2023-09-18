#
# Download rules for the original/unmodified image file(s)
#


# Define DL_SOURCE/DL_SITE related variables
#  $(1) Suffix
define DEFINE_DL_SOURCE_VARS
ifneq ($(strip $(FREETZ_DL_SOURCE$(1))),)
DL_SITE$(1):=$(call qstrip,$(FREETZ_DL_SITE$(1)))
DL_SOURCE$(1):=$(call qstrip,$(FREETZ_DL_SOURCE$(1)))
DL_SOURCE$(1)_LOCAL:=$(call GET_STRING_COMPONENT,$(call qstrip,$(FREETZ_DL_SOURCE$(1))),/,1)
DL_SOURCE$(1)_REMOTE:=$(call GET_STRING_COMPONENT,$(call qstrip,$(FREETZ_DL_SOURCE$(1))),/,2)
DL_SOURCE$(1)_HASH:=$(call qstrip,$(FREETZ_DL_SOURCE$(1)_HASH))
endif

ifneq ($(strip $(FREETZ_DL_SOURCE$(1)_CONTAINER)),)
DL_SOURCE$(1)_CONTAINER:=$(call qstrip,$(FREETZ_DL_SOURCE$(1)_CONTAINER))
DL_SOURCE$(1)_CONTAINER_HASH:=$(call qstrip,$(FREETZ_DL_SOURCE$(1)_CONTAINER_HASH))
endif
endef

$(eval $(call DEFINE_DL_SOURCE_VARS))
$(eval $(call DEFINE_DL_SOURCE_VARS,2))
$(eval $(call DEFINE_DL_SOURCE_VARS,3))



DL_IMAGE:=
image:

# Download Firmware Image
#  $(1) Suffix
define DOWNLOAD_FIRMWARE
ifneq ($(strip $(DL_SOURCE$(1))),)
IMAGE$(1):=$(DL_FW_DIR)/$(DL_SOURCE$(1)_LOCAL)
DL_IMAGE+=$$(IMAGE$(1))
image: $$(IMAGE$(1))
.PHONY: $$(IMAGE$(1))
$$(IMAGE$(1)): | $(DL_FW_DIR)
ifeq ($$(strip $$(DL_SITE$(1))),)
	@if [ ! -e "$$(IMAGE$(1))" ]; then \
		echo -e "\nPlease copy the following file into the './$$(DL_FW_DIR)/' sub-directory manually:\n$$(DL_SOURCE$(1)_LOCAL)\n$$(if $$(DL_SOURCE$(1)_REMOTE),(rename original AVM '$$(DL_SOURCE$(1)_REMOTE)' for that)\n)"; \
		exit 3; \
	fi
else
	@ \
	if [ "$$(call qstrip,$(FREETZ_TYPE_FIRMWARE_DETECT_LATEST))" == "y" -a -z "$(1)" ]; then \
		echo -n "JUIS: "; \
		find $$(DL_FW_DIR) -maxdepth 1 -name $$(DL_SOURCE$(1)_LOCAL).url -mmin +360 -exec rm -f {} ';'; \
		DL_URL_FIRMWARE="$$$$(cat $$(IMAGE$(1)).url.own 2>/dev/null)"; \
		if [ -n "$$$$DL_URL_FIRMWARE" ]; then \
			echo -n "Using custom value ... "; \
		fi; \
		if [ -z "$$$$DL_URL_FIRMWARE" ]; then \
			DL_URL_FIRMWARE="$$$$(cat $$(IMAGE$(1)).url 2>/dev/null)"; \
			echo -n "Using cached value ... "; \
		fi; \
		if [ -z "$$$$DL_URL_FIRMWARE" ]; then \
			echo -n "No cached value, asking avm for latest firmware ... "; \
			DL_URL_FIRMWARE="$$$$(tools/juis $$(FREETZ_DL_JUIS_STRING))"; \
			echo "$$$$DL_URL_FIRMWARE" > "$$(IMAGE$(1)).url"; \
		fi; \
		if [ -z "$$$$DL_URL_FIRMWARE" ]; then \
			echo -n "no valid answer, trying backup ... "; \
			DL_URL_FIRMWARE="$$$$(cat $$(IMAGE$(1)).url.bak 2>/dev/null)"; \
		fi; \
		if [ -z "$$$$DL_URL_FIRMWARE" ]; then \
			$$(call ERROR,3,Failed to detect the URL of the latest firmware version) \
		fi; \
		echo -n "$$$$DL_URL_FIRMWARE ... " 2>/dev/null; \
		echo "done."; \
		echo "$$$$DL_URL_FIRMWARE" > "$$(IMAGE$(1)).url.bak"; \
		DL_SITE0="$$$${DL_URL_FIRMWARE%/*}"; \
		DL_SOURCE0_CONTAINER="$$$${DL_URL_FIRMWARE##*/}"; \
	else \
		DL_SITE0="$$(DL_SITE$(1))"; \
		DL_SOURCE0_CONTAINER="$$(DL_SOURCE$(1)_CONTAINER)"; \
	fi; \
	if [ "$$(call qstrip,$(FREETZ_DL_DETECT_IMAGE_NAME))" == "y" ]; then \
		rm -f "$$(IMAGE$(1))"; \
	fi; \
	if [ ! -e "$$(IMAGE$(1))" ]; then \
		if [ -n "$$$$DL_SOURCE0_CONTAINER" ]; then \
			if [ ! -r $$(DL_FW_DIR)/$$$$DL_SOURCE0_CONTAINER ]; then \
				if ! $$(DL_TOOL) --delete-on-trap --no-append-servers --checksum-optional $$(DL_FW_DIR) "$$$$DL_SOURCE0_CONTAINER" "$$$$DL_SITE0" $$(DL_SOURCE$(1)_CONTAINER_HASH) $$(SILENT); then \
					$$(call ERROR,3,Could not download firmware image. See https://freetz-ng.github.io/freetz-ng/wiki/FAQ#Couldnotdownloadfirmwareimage for details.) \
				fi; \
			fi; \
			case "$$$${DL_SOURCE0_CONTAINER^^}" in \
				*.IMAGE) \
					DL_SOURCE_DETECTED=$$$$DL_SOURCE0_CONTAINER; \
					;; \
				*.ZIP) \
					if [ "$$(FREETZ_DL_DETECT_IMAGE_NAME)" == "y" ]; then \
						DL_SOURCE_DETECTED=$$$$(unzip -j $$(QUIETSHORT) -l $$(DL_FW_DIR)/$$$$DL_SOURCE0_CONTAINER *.image | sed -rn 's/.*( |\/)(.*\.image)/\2/p'); \
						echo "Using detected .image name: $$$$DL_SOURCE_DETECTED" >/dev/null; \
					else \
						DL_SOURCE_DETECTED=$$(DL_SOURCE$(1)_LOCAL); \
						echo "Using hardcoded .image name: $$$$DL_SOURCE_DETECTED" >/dev/null; \
					fi; \
					if [ ! -f $$(DL_FW_DIR)/$$$$DL_SOURCE_DETECTED ]; then \
						echo "Unzipping archive file: $$$$DL_SOURCE0_CONTAINER" >/dev/null; \
						if ! unzip -j $$(QUIETSHORT) $$(DL_FW_DIR)/$$$$DL_SOURCE0_CONTAINER *$$$$DL_SOURCE_DETECTED -d $$(DL_FW_DIR); then \
							$$(call ERROR,3,Could not unzip firmware image.) \
						fi; \
					fi; \
					;; \
				*.RAR) \
					if ! which unar &>/dev/null; then \
						$$(call ERROR,3,Prerequisite unar is missing.) \
					fi; \
					if [ "$$(FREETZ_DL_DETECT_IMAGE_NAME)" == "y" ]; then \
						DL_SOURCE_DETECTED=$$$$(unar -D -q $$(DL_FW_DIR)/$$$$DL_SOURCE0_CONTAINER *.image -o /dev/null 2>&1 | sed -rn 's/.*( |\/)(.*\.image).*/\2/p'); \
						echo "Using detected .image name: $$$$DL_SOURCE_DETECTED" >/dev/null; \
					else \
						DL_SOURCE_DETECTED=$$(DL_SOURCE$(1)_LOCAL); \
						echo "Using hardcoded .image name: $$$$DL_SOURCE_DETECTED" >/dev/null; \
					fi; \
					if [ ! -f $$(DL_FW_DIR)/$$$$DL_SOURCE_DETECTED ]; then \
						echo "Unaring archive file: $$$$DL_SOURCE0_CONTAINER" >/dev/null; \
						if ! unar -D -q $$(DL_FW_DIR)/$$$$DL_SOURCE0_CONTAINER *$$$$DL_SOURCE_DETECTED -o $$(DL_FW_DIR); then \
							$$(call ERROR,3,Could not unar firmware image.) \
						fi; \
					fi; \
					;; \
				*) \
					$$(call ERROR,3,Not able to extract '$$$$DL_SOURCE0_CONTAINER' archive at all.) \
					;; \
			esac; \
			if [ "$$(FREETZ_DL_DETECT_IMAGE_NAME)" == "y" ]; then \
				[ -f $$(DL_FW_DIR)/$$$$DL_SOURCE_DETECTED ] && ln -s $$$$DL_SOURCE_DETECTED $$(IMAGE$(1)); \
				echo "Created symlink for .image file: $$(DL_SOURCE$(1)_LOCAL)" >/dev/null; \
			fi; \
		elif ! $$(DL_TOOL) $$(if $$(DL_SOURCE$(1)_REMOTE),--out-file $$(DL_SOURCE$(1)_LOCAL)) --delete-on-trap --no-append-servers --checksum-optional $$(DL_FW_DIR) \
			  "$$(if $$(DL_SOURCE$(1)_REMOTE),$$(DL_SOURCE$(1)_REMOTE),$$(DL_SOURCE$(1)_LOCAL))" "$$$$DL_SITE0" $$(DL_SOURCE$(1)_HASH) $$(SILENT); then \
			$$(call ERROR,3,Could not download firmware image. See https://freetz-ng.github.io/freetz-ng/wiki/FAQ#Couldnotdownloadfirmwareimage for details.) \
		fi; \
	fi
endif
endif
endef

$(eval $(call DOWNLOAD_FIRMWARE))
$(eval $(call DOWNLOAD_FIRMWARE,2))
$(eval $(call DOWNLOAD_FIRMWARE,3))

