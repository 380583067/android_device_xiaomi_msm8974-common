/*
 * Copyright (C) 2020 The LineageOS Project
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

#include <dlfcn.h>
#include <log/log.h>

typedef void (*audio_error_callback)(int);
typedef void (*addErrorCallback_t)(audio_error_callback);

extern "C" void _ZN7android11AudioSystem16setErrorCallbackEPFviE(
        audio_error_callback cb) {
    static addErrorCallback_t addErrorCallback = nullptr;
    if (addErrorCallback == nullptr) {
        void* handle = dlopen("libaudioclient.so", RTLD_NOW);
        if (handle == nullptr) {
            ALOGE("libaudioclient_shim: Failed to dlopen libaudioclient.so: %s", dlerror());
            return;
        }
        addErrorCallback = (addErrorCallback_t)dlsym(handle,
                "_ZN7android11AudioSystem16addErrorCallbackEPFviE");
        if (addErrorCallback == nullptr) {
            ALOGE("libaudioclient_shim: Failed to dlsym addErrorCallback: %s", dlerror());
            dlclose(handle);
            return;
        }

    }
    addErrorCallback(cb);
}

