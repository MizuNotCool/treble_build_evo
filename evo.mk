$(call inherit-product, vendor/evolution/config/common_full_phone.mk)
$(call inherit-product, vendor/evolution/config/BoardConfigSoong.mk)
$(call inherit-product, device/evolution/sepolicy/common/sepolicy.mk)
-include vendor/evolution/build/core/config.mk

TARGET_BOOT_ANIMATION_RES := 720

TARGET_SUPPORTS_QUICK_TAP := true

TARGET_USES_PREBUILT_VENDOR_SEPOLICY := true
TARGET_HAS_FUSEBLK_SEPOLICY_ON_VENDOR := true

PRODUCT_PACKAGES += \
    libaptX_encoder \
    libaptXHD_encoder

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.system.ota.json_url=https://raw.githubusercontent.com/MizuNotCool/treble_build_evo/tiramisu/ota.json
