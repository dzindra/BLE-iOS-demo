# BLE-iOS-demo

BLE communication with ESP32 device. You can enable blinking LED via app or via button on the device.

## UUIDs

* service `9a8ca9ef-e43f-4157-9fee-c37a3d7dc12d`
  * blink on characteristic (1 byte, bool) `e94f85c8-7f57-4dbd-b8d3-2b56e107ed60`
  * blink speed characteristing (1 byte, uint8) `a8985fda-51aa-4f19-a777-71cf52abba1e`

## Device

* ESP32 on DOIT ESP32 DEVKIT board
* button wired to GPIO0
* builtin LED
* Using [ESP32 core for Arduino](https://github.com/espressif/arduino-esp32)
* Using [TaskScheduler library](https://github.com/arkhipenko/TaskScheduler)
