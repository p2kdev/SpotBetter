export THEOS_PACKAGE_SCHEME=rootless
export TARGET = iphone:clang:13.7:13.0
include $(THEOS)/makefiles/common.mk

export ARCHS = arm64 arm64e

BUNDLE_NAME = SpotBetter
$(BUNDLE_NAME)_FILES = SBetterRootListController.m
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_FRAMEWORKS = UIKit CoreGraphics QuartzCore
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_EXTRA_FRAMEWORKS = Altlist
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SpotBetter.plist$(ECHO_END)
