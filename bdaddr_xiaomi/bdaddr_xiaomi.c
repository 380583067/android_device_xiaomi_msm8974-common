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
#include <stdio.h>
#include <cutils/log.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
#include <private/android_filesystem_config.h>

#include <string.h>

#define MAC_ADDR_SIZE 6
#define BD_ADDR_FILE "/data/misc/bluetooth/bdaddr"

extern int qmi_nv_read_bd_addr(char** mac);

int main()
{
    unsigned char bt_addr[] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
    char* nv_bt_mac = NULL;
    int ret, i, fd;
    char address[19];
    char tmp_path[] = BD_ADDR_FILE ".XXXXXX";

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

    // Publish a complete address readable by the Bluetooth HAL. Vendor init
    // cannot observe the private init.svc.bdaddr property to fix permissions.
    snprintf(address, sizeof(address), "%02X:%02X:%02X:%02X:%02X:%02X\n",
            bt_addr[0], bt_addr[1], bt_addr[2], bt_addr[3], bt_addr[4], bt_addr[5]);
    fd = mkstemp(tmp_path);
    if (fd < 0) {
        ALOGE("Cannot create address file: %s", strerror(errno));
        return 1;
    }
    if (write(fd, address, sizeof(address) - 1) != (ssize_t)(sizeof(address) - 1) ||
            fchmod(fd, 0640) != 0 ||
            fchown(fd, AID_BLUETOOTH, AID_BLUETOOTH) != 0 || fsync(fd) != 0) {
        ALOGE("Cannot prepare address file: %s", strerror(errno));
        close(fd);
        unlink(tmp_path);
        return 1;
    }
    if (close(fd) != 0 || rename(tmp_path, BD_ADDR_FILE) != 0) {
        ALOGE("Cannot publish address file: %s", strerror(errno));
        unlink(tmp_path);
        return 1;
    }

    ALOGV("%s was successfully generated", BD_ADDR_FILE);

    return 0;
}
