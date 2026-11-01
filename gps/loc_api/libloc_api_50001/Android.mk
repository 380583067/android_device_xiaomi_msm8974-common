LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libloc_eng
LOCAL_PROPRIETARY_MODULE := true

LOCAL_MODULE_TAGS := optional

LOCAL_SHARED_LIBRARIES := \
    libutils \
    libcutils \
    libdl \
    liblog \
    libloc_core \
    libgps.utils

LOCAL_SRC_FILES += \
    loc_eng.cpp \
    loc_eng_agps.cpp \
    loc_eng_xtra.cpp \
    loc_eng_ni.cpp \
    loc_eng_log.cpp \
    loc_eng_nmea.cpp \
    LocEngAdapter.cpp

LOCAL_SRC_FILES += \
    loc_eng_dmn_conn.cpp \
    loc_eng_dmn_conn_handler.cpp \
    loc_eng_dmn_conn_thread_helper.c \
    loc_eng_dmn_conn_glue_msg.c \
    loc_eng_dmn_conn_glue_pipe.c

LOCAL_CFLAGS += \
     -fno-short-enums \
     -D_ANDROID_ \
     -Wno-unused-parameter

LOCAL_C_INCLUDES:= \
    $(TARGET_OUT_HEADERS)/gps.utils \
    $(TARGET_OUT_HEADERS)/libloc_core \
    $(LOCAL_PATH) \
    $(TARGET_OUT_HEADERS)/libflp

# Android 14 requires hardware/gps.h to arrive through an explicit header
# library; keep both Qualcomm API header sets alongside libhardware_headers.
LOCAL_HEADER_LIBRARIES := libgps.utils_headers libloc_core_headers libhardware_headers

include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libloc_eng_headers
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)
# loc_eng public headers also include hardware/gps.h, so export that dependency.
LOCAL_HEADER_LIBRARIES := libhardware_headers
include $(BUILD_HEADER_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := gps.$(TARGET_BOARD_PLATFORM)
LOCAL_PROPRIETARY_MODULE := true

LOCAL_MODULE_TAGS := optional

## Libs
LOCAL_SHARED_LIBRARIES := \
    libutils \
    libcutils \
    liblog \
    libloc_eng \
    libloc_core \
    libgps.utils \
    libdl

LOCAL_SRC_FILES += \
    loc.cpp \
    gps.c

LOCAL_CFLAGS += \
    -fno-short-enums \
     -D_ANDROID_ \
     -Wno-unused-parameter

## Includes
LOCAL_C_INCLUDES:= \
    $(TARGET_OUT_HEADERS)/gps.utils \
    $(TARGET_OUT_HEADERS)/libloc_core \
    $(TARGET_OUT_HEADERS)/libflp

LOCAL_MODULE_RELATIVE_PATH := hw

# This HAL compiles the legacy GPS ABI and needs the same explicit Android 14
# libhardware header dependency as the Qualcomm location libraries above.
LOCAL_HEADER_LIBRARIES := libgps.utils_headers libloc_core_headers libhardware_headers

include $(BUILD_SHARED_LIBRARY)
