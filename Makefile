ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = aimhub_bypass
aimhub_bypass_FILES = Tweak.xm
aimhub_bypass_CFLAGS = -fobjc-arc
aimhub_bypass_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
