$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# call the proprietary setup
$(call inherit-product, vendor/xiaomi/msm8974-common/msm8974-common-vendor.mk)

# System properties
-include $(LOCAL_PATH)/system_prop.mk

# Boot animation
TARGET_SCREEN_HEIGHT := 1920
TARGET_SCREEN_WIDTH := 1080

# Device uses ultra-high-density artwork where available
PRODUCT_AAPT_CONFIG := normal hdpi xhdpi xxhdpi
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay \
    $(LOCAL_PATH)/overlay-lineage

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/handheld_core_hardware.xml:system/vendor/etc/permissions/handheld_core_hardware.xml \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:system/vendor/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:system/vendor/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:system/vendor/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:system/vendor/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:system/vendor/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:system/vendor/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/vendor/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/vendor/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.barometer.xml:system/vendor/etc/permissions/android.hardware.sensor.barometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:system/vendor/etc/permissions/android.hardware.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:system/vendor/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:system/vendor/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:system/vendor/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:system/vendor/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:system/vendor/etc/permissions/android.hardware.sensor.stepdetector.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/vendor/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/vendor/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/vendor/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/vendor/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:system/vendor/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.telephony.cdma.xml:system/vendor/etc/permissions/android.hardware.telephony.cdma.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/vendor/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.software.midi.xml:system/vendor/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.print.xml:system/vendor/etc/permissions/android.software.print.xml

# ANT+
# Android 14's source tree no longer provides the legacy Java shared-library
# package or its permission XML. Keep the ANT HIDL service and native radio
# driver, which are built from external/ant-wireless, and drop only that
# obsolete application-library declaration.
PRODUCT_PACKAGES += \
    AntHalService \
    libantradio

# Linux 3.4 has no cgroup v2. Supply the v1 process-tracking hierarchy used
# by libprocessgroup's mounted-controller fallback.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/cgroups.json:$(TARGET_COPY_OUT_VENDOR)/etc/cgroups.json

# APEX
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/ld.config.txt:system/etc/swcodec/ld.config.txt

# Audio
# Android 14's legacy Qualcomm primary HAL is hosted by the HIDL 6.0 wrapper;
# keep the generic service binary and MSM8974 implementation paired with the
# matching manifest version. audio_policy.msm8974 is obsolete, and audiod is
# optional with no init service here, so neither old package is requested.
PRODUCT_PACKAGES += \
    android.hardware.audio.service \
    android.hardware.audio@6.0-impl \
    android.hardware.audio.effect@6.0-impl \
    android.hardware.broadcastradio@1.0-impl \
    android.hardware.soundtrigger@2.0-impl \
    audio.primary.msm8974 \
    audio.r_submix.default \
    audio.usb.default \
    libaudio-resampler \
    libqcompostprocbundle \
    libqcomvisualizer \
    libqcomvoiceprocessing \
    tinymix

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio/audio_policy_configuration.xml:system/vendor/etc/audio_policy_configuration.xml \
    $(LOCAL_PATH)/audio/audio_effects.xml:system/vendor/etc/audio_effects.xml \
    $(LOCAL_PATH)/audio/listen_platform_info.xml:system/vendor/etc/listen_platform_info.xml

PRODUCT_COPY_FILES += \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:system/vendor/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:system/vendor/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:system/vendor/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:system/vendor/etc/usb_audio_policy_configuration.xml

# Baseband assertion
PRODUCT_PACKAGES += librecovery_updater_xiaomi

# Android 14's A2DP policy routes through the Bluetooth Audio HIDL 2.1
# provider and Bluetooth audio hardware module. Keep these paired with the
# manifest and bluetooth_audio_policy_configuration.xml include; the retired
# standalone platform A2DP module is not part of this stack.
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl \
    android.hardware.bluetooth.audio@2.1-impl \
    audio.bluetooth.default \
    bdaddr_xiaomi \
    libbt-vendor

# Camera
# The old LineageOS Snap package is not present in this Android 14 source
# checkout. Use the maintained AOSP Camera2 module while keeping the MSM8974
# camera provider and device HALs required by the proprietary camera stack.
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-impl \
    camera.device@1.0-impl \
    camera.msm8974 \
    libxml2 \
    Camera2

# Charger
PRODUCT_PACKAGES += \
    chargeonlymode

# Filesystem management tools
# Android 14's host-side image tools replace the old on-device make_ext4fs,
# setup_fs, mkntfs, dumpe2fs, and mke2fs_static module names. Keep only the
# e2fsprogs runtime modules that still exist and are useful for device repair.
PRODUCT_PACKAGES += \
    resize2fs \
    e2fsck_static \
    resize2fs_static

# Gatekeeper
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-service.software

# GPS
PRODUCT_PACKAGES += \
    android.hardware.gnss@1.0-impl.legacy \
    android.hardware.gnss@1.0-service.legacy \
    gps.msm8974 \
    msm8974_gps_conf_legacy_link \
    msm8974_flp_conf_legacy_link \
    msm8974_izat_conf_legacy_link \
    msm8974_sap_conf_legacy_link
 
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/gps/etc/gps.conf:system/vendor/etc/gps.conf \
    $(LOCAL_PATH)/gps/etc/flp.conf:system/vendor/etc/flp.conf \
    $(LOCAL_PATH)/gps/etc/izat.conf:system/vendor/etc/izat.conf \
    $(LOCAL_PATH)/gps/etc/sap.conf:system/vendor/etc/sap.conf

# Graphics
PRODUCT_PACKAGES += \
    android.hardware.configstore@1.1-service \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.graphics.mapper@2.0-impl \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service \
    copybit.msm8974 \
    gralloc.msm8974 \
    hwcomposer.msm8974 \
    memtrack.msm8974 \
    liboverlay

# Health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-impl.recovery \
    android.hardware.health@2.1-service

# IPC router config
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/sec_config:system/vendor/etc/sec_config

# KeyLayout
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/keylayout/atmel-maxtouch.kl:system/vendor/usr/keylayout/atmel-maxtouch.kl \
    $(LOCAL_PATH)/keylayout/msm8974-taiko-mtp-snd-card_Button_Jack.kl:system/vendor/usr/keylayout/msm8974-taiko-mtp-snd-card_Button_Jack.kl \
    $(LOCAL_PATH)/keylayout/synaptics_rmi4_i2c.kl:system/vendor/usr/keylayout/synaptics_rmi4_i2c.kl

# Keep the legacy Keymaster 3.0 service because this MSM8974 vendor set ships
# the original Keymaster firmware but no verified 4.1 device adapter. The
# Cancro reference's 4.1 service is not interchangeable with this secure-world
# interface; declaring both would also advertise duplicate keymaster services.
PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service

# Lights
PRODUCT_PACKAGES += \
    android.hardware.light@2.0-service.xiaomi_msm8974

# Media
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/media_codecs.xml:system/vendor/etc/media_codecs.xml \
    $(LOCAL_PATH)/configs/media_profiles_V1_0.xml:system/vendor/etc/media_profiles_V1_0.xml \
    $(LOCAL_PATH)/configs/media_codecs_performance.xml:system/vendor/etc/media_codecs_performance.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/vendor/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:system/vendor/etc/media_codecs_google_telephony.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/vendor/etc/media_codecs_google_video.xml

PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service \
    libc2dcolorconvert \
    libOmxAacEnc \
    libOmxAmrEnc \
    libOmxCore \
    libOmxEvrcEnc \
    libOmxQcelp13Enc \
    libOmxVdec \
    libOmxVenc \
    libstagefrighthw

# Misc dependency packages
# Android 14's QCOM Wi-Fi and hostapd builds select external/libnl's libnl
# module directly. The old libnl_2 alias, ebtables/ethertypes helpers, and
# libbson are not provided by this tree and have no device-tree consumers.
PRODUCT_PACKAGES += \
    libnl

# Power
PRODUCT_PACKAGES += \
    android.hardware.power-service-qti

# Privapp Whitelist
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/privapp-permissions-qti.xml:system/etc/permissions/privapp-permissions-qti.xml

# Proprietery Firmware
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/xtwifi.conf:system/etc/xtwifi.conf \
    $(LOCAL_PATH)/configs/calib.cfg:system/etc/calib.cfg \
    $(LOCAL_PATH)/configs/modem/Diag.cfg:system/etc/modem/Diag.cfg

# QCOM Config Script
PRODUCT_PACKAGES += \
    changepowermode.sh \
    init.qcom.bt.sh \
    init.class_main.sh \
    init.qcom.early_boot.sh \
    init.qcom.factory.sh \
    init.qcom.sh \
    init.qcom.ssr.sh \
    init.qcom.usb.sh \
    init.qcom.class_core.sh \
    init.qcom.post_boot.sh \
    usf_post_boot.sh

# Ramdisk
PRODUCT_PACKAGES += \
    fstab.qcom \
    init.qcom.rc \
    init.target.rc \
    init.qcom.usb.rc

# Radio
PRODUCT_PACKAGES += \
    libaudioclient_shim \
    libcnefeatureconfig \
    librmnetctl

# RenderScript HAL
 PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0-impl

# Seccomp policy
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/seccomp_policy/mediacodec.policy:system/vendor/etc/seccomp_policy/mediacodec.policy \
    $(LOCAL_PATH)/seccomp_policy/mediaextractor.policy:system/vendor/etc/seccomp_policy/mediaextractor.policy

# Sensor
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-impl

# SoftAP
# The legacy QSAP SDK/configuration helper packages were removed from the
# Android 14 Qualcomm source set. Keep the WCNSS QMI helper and service, which
# are present in this tree and used by this device's Wi-Fi initialization.
PRODUCT_PACKAGES += \
    libwcnss_qmi \
    wcnss_service

# Thermal config
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/thermal-engine-perf.conf:system/vendor/etc/thermal-engine-perf.conf

# Publish the Android 14 HIDL thermal service using the source tree's generic
# thermal implementation. The proprietary thermal-engine daemon remains the
# MSM8974 policy/tuning component and is kept separately above.
PRODUCT_PACKAGES += \
    android.hardware.thermal@1.0-impl \
    android.hardware.thermal@1.0-service \
    thermal.default

# TimeKeep
PRODUCT_PACKAGES += \
    timekeep \
    TimeKeep

# USB is provided through the MSM8974 legacy gadget init rules and Android's
# FunctionFS ADB path. The retired HIDL basic USB service is not part of the
# Android 14 source tree and is not declared by this device's VINTF manifest.

# Vibrator
PRODUCT_PACKAGES += \
    android.hardware.vibrator@1.0-impl \
    android.hardware.vibrator@1.0-service

# WiFi
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/wifi/WCNSS_cfg.dat:system/vendor/firmware/wlan/prima/WCNSS_cfg.dat \
    $(LOCAL_PATH)/wifi/WCNSS_qcom_cfg.ini:system/vendor/etc/wifi/WCNSS_qcom_cfg.ini \
    $(LOCAL_PATH)/wifi/WCNSS_qcom_cfg.ini:system/vendor/firmware/wlan/prima/WCNSS_qcom_cfg.ini \
    $(LOCAL_PATH)/wifi/WCNSS_qcom_wlan_nv_x5.bin:system/vendor/firmware/wlan/prima/WCNSS_qcom_wlan_nv_x5.bin

PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service.legacy \
    hostapd \
    libwpa_client \
    wificond \
    wpa_supplicant \
    wpa_supplicant.conf \
    wpa_supplicant_overlay.conf \
    p2p_supplicant_overlay.conf

# XiaomiParts
PRODUCT_PACKAGES += \
    XiaomiParts
