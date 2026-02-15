NULL_NAME := libswift
INSTALL_PATH := /usr/lib/libswift/stable
OBJ_PATH = $(THEOS_OBJ_DIR)

XCODE ?= $(shell xcode-select -p)/../..
XCODE_USR = $(XCODE)/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/null.mk

all::
	$(ECHO_NOTHING)rm -rf $(OBJ_PATH)$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p $(OBJ_PATH)$(ECHO_END)
	$(ECHO_NOTHING)set -e; \
	FOUND_SWIFT_LIBS=0; \
	for SWIFT_DIR in $$(find "$(XCODE_USR)/lib/swift" -type d -name 'iphoneos*' 2>/dev/null | sort -u); do \
		if find "$$SWIFT_DIR" -maxdepth 1 -type f -name 'libswift*.dylib' | grep -q .; then \
			rsync -ra "$$SWIFT_DIR"/libswift*.dylib $(OBJ_PATH); \
			FOUND_SWIFT_LIBS=1; \
		fi; \
	done; \
	if [ $$FOUND_SWIFT_LIBS -eq 0 ]; then \
		echo "No libswift*.dylib found under $(XCODE_USR)/lib/swift (searched iphoneos*)"; \
		exit 1; \
	fi$(ECHO_END)
	$(ECHO_NOTHING)ldid -S $(OBJ_PATH)/*$(ECHO_END)

stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/$(INSTALL_PATH)$(ECHO_END)
	$(ECHO_NOTHING)rsync -ra $(OBJ_PATH)/ $(THEOS_STAGING_DIR)/$(INSTALL_PATH) $(_THEOS_RSYNC_EXCLUDE_COMMANDLINE)$(ECHO_END)
	$(ECHO_NOTHING)cp NOTICE.txt $(THEOS_STAGING_DIR)/$(INSTALL_PATH)$(ECHO_END)
