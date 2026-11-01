# MSM8974 Bring-up Change Log

## 2026-10-20 — S-U bring-up properties

- **File:** `system_prop.mk`, under the `# S-U Bringup` section.
- **Scope:** shared `msm8974-common` product properties; every device product inheriting this common tree receives them.
- **Requested property set:**

  ```make
  ro.kernel.ebpf.supported=false
  debug.renderengine.backend=gles
  persist.sys.binary_xml=false
  ro.soc.manufacturer=QTI
  ro.soc.model=MSM8974
  ro.urandom.bypass_entropy_check=true
  ```

- **Purpose recorded:** S-U bring-up compatibility settings for the legacy MSM8974 platform, as requested by the device maintainer.
- **Incident:** the maintainer reported an infinite Mi-logo/reboot loop after adding this set. The phone was not enumerating over USB during diagnosis, so no live boot or crash log was available.
- **Source finding:** Android 14's `packages/modules/Connectivity/netd/NetdUpdatable.cpp` used `property_present || value_is_false` to decide whether eBPF is supported. Therefore setting this tree's explicit `ro.kernel.ebpf.supported=false` actually enabled eBPF initialization. Virgo's legacy kernel makes this a credible boot/network-service failure trigger.
- **Fix recorded:** the source patch `device/xiaomi/virgo/patches/packages/modules/Connectivity/0001-fix-false-ebpf-property-semantics.patch` now parses the property as a boolean and defaults to unsupported.
- **Validation status:** source-level cause is confirmed; the fix still needs a build and a device boot test before the reboot loop can be considered resolved.

## 2026-10-20 — Early-boot log capture proposal

- **Reported location:** `rootdir/etc/init.target.rc` in the shared MSM8974 tree.
- **Reported behavior:** start a root `logcat -b all -D -f /cache/boot_log.txt` service at `post-fs-data`, clear the prior file first, then stop the logger when `sys.boot_completed=1`.
- **Purpose:** preserve logd buffers across an Android boot loop so they can be pulled from recovery.
- **Working-tree check:** the desktop path `/root/桌面/挂载设备/tank/los21` resolves to this checkout, but the current `rootdir/etc/init.target.rc` does not contain the reported service block yet. It is not included in the current source image.
- **SELinux check:** in ENG/userdebug, `init` transitions `/system/bin/logcat` to the `logpersist` domain. Current platform policy grants that domain writes to `misc_logd_file` under `/data/misc/logd`, not `/cache/boot_log.txt`; verify or add a narrowly scoped policy rule before relying on this path. In this AOSP logcat, `-D` enables log-buffer dividers.

