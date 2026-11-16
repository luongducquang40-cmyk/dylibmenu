ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ff_ios_menu
ff_ios_menu_FILES = Tweak.xm Menu.mm
ff_ios_menu_CFLAGS = -fobjc-arc -std=c++17 -I.
ff_ios_menu_FRAMEWORKS = Foundation UIKit CoreGraphics QuartzCore
ff_ios_menu_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk
