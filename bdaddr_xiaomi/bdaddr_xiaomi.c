/*
 * Copyright (C) 2016 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "bdaddr_xiaomi"
#define LOG_NDEBUG 0

#include <cutils/log.h>

// Android 14 Clang rejects implicit C library declarations; include the
// owning header for FILE, fopen(), fprintf(), and fclose() explicitly.
#include <stdio.h>
#include <string.h>

#define MAC_ADDR_SIZE 6
#define BD_ADDR_FILE "/data/misc/bluetooth/bdaddr"

extern int qmi_nv_read_bd_addr(char** mac);

static int valid_address(const unsigned char *address)
{
    int i, nonzero = 0;
    if (address[0] & 1) {
        return 0;
    }
    for (i = 0; i < MAC_ADDR_SIZE; i++) {
        nonzero |= address[i];
    }
    return nonzero != 0;
}

static int saved_address_is_valid(void)
{
    unsigned int values[MAC_ADDR_SIZE];
    unsigned char address[MAC_ADDR_SIZE];
    FILE *fp = fopen(BD_ADDR_FILE, "r");
    int i, fields;
    if (!fp) {
        return 0;
    }
    fields = fscanf(fp, "%2x:%2x:%2x:%2x:%2x:%2x", &values[0], &values[1],
                    &values[2], &values[3], &values[4], &values[5]);
    fclose(fp);
    if (fields != MAC_ADDR_SIZE) {
        return 0;
    }
    for (i = 0; i < MAC_ADDR_SIZE; i++) {
        address[i] = values[i];
    }
    return valid_address(address);
}

int main()
{
    unsigned char bt_addr[] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
    char* nv_bt_mac = NULL;
    int ret, i;
    FILE *fp;

    // Keep an already provisioned address when a later NV read is unavailable.
    // In particular, do not replace it with the all-zero NV response.
    if (saved_address_is_valid()) {
        ALOGI("Using the saved Bluetooth address");
        return 0;
    }

    // Read bluetooth address from modem NV
    ret = qmi_nv_read_bd_addr(&nv_bt_mac);
    if (!nv_bt_mac) {
        ALOGE("qmi_nv_read_bd_addr error %d", ret);
        return 1;
    }

    // Swap bytes
    for (i = 0; i < MAC_ADDR_SIZE; i++) {
        bt_addr[i] = nv_bt_mac[6 - 1 - i];
    }
    if (!valid_address(bt_addr)) {
        ALOGE("Modem NV returned an invalid Bluetooth address");
        return 1;
    }

    // Store bluetooth address in a file
    fp = fopen(BD_ADDR_FILE, "w");
    if (!fp) {
        ALOGE("Cannot create %s", BD_ADDR_FILE);
        return 1;
    }
    fprintf(fp, "%02X:%02X:%02X:%02X:%02X:%02X\n",
            bt_addr[0], bt_addr[1], bt_addr[2], bt_addr[3], bt_addr[4], bt_addr[5]);
    fclose(fp);

    ALOGV("%s was successfully generated", BD_ADDR_FILE);

    return 0;
}
