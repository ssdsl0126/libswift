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
	for SWIFT_DIR in "$(XCODE_USR)/lib/swift/iphoneos" $$(find "$(XCODE_USR)/lib" -maxdepth 1 -type d -name 'swift-*' 2>/dev/null | sort -u | sed 's#$$#/iphoneos#'); do \
		[ -d "$$SWIFT_DIR" ] || continue; \
		for SWIFT_LIB in "$$SWIFT_DIR"/libswift*.dylib; do \
			[ -f "$$SWIFT_LIB" ] || continue; \
			SWIFT_BASE=$$(basename "$$SWIFT_LIB"); \
			rsync -a "$$SWIFT_LIB" "$(OBJ_PATH)/$$SWIFT_BASE"; \
			FOUND_SWIFT_LIBS=1; \
		done; \
	done; \
	if [ $$FOUND_SWIFT_LIBS -eq 0 ]; then \
		echo "No libswift*.dylib found under $(XCODE_USR)/lib/swift"; \
		exit 1; \
	fi$(ECHO_END)
	$(ECHO_NOTHING)ldid -S $(OBJ_PATH)/*$(ECHO_END)

stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/$(INSTALL_PATH)$(ECHO_END)
	$(ECHO_NOTHING)rsync -ra $(OBJ_PATH)/ $(THEOS_STAGING_DIR)/$(INSTALL_PATH) $(_THEOS_RSYNC_EXCLUDE_COMMANDLINE)$(ECHO_END)
	$(ECHO_NOTHING)cp NOTICE.txt $(THEOS_STAGING_DIR)/$(INSTALL_PATH)$(ECHO_END)
