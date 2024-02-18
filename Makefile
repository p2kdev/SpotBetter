export THEOS_PACKAGE_SCHEME=rootless
export TARGET = iphone:clang:13.7:13.0
PACKAGE_VERSION=$(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

export ARCHS = arm64 arm64e

TWEAK_NAME = SpotBetter
SpotBetter_FILES = Tweak.xm
#SpotBetter_EXTRA_FRAMEWORKS = Altlist
SpotBetter_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Spotlight"
SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
