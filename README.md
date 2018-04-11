# BLE-iOS-demo

BLE communication with ESP32 device. You can enable blinking LED via app or via button on the device.

## UUIDs

* service `9a8ca9ef-e43f-4157-9fee-c37a3d7dc12d`
  * blink characteristic (1 byte, bool) `e94f85c8-7f57-4dbd-b8d3-2b56e107ed60`
  * debug characteristing (utf8 string) `326a9006-85cb-9195-d9dd-464cfbbae75a`

## Device

* ESP32 on Goouuu-ESP32 board
* button wired to GPIO0
* LED wired to serial TX pin (blinks when transmitting)
* Using [ESP32 core for Arduino](https://github.com/espressif/arduino-esp32)
* Using [TaskScheduler library](https://github.com/arkhipenko/TaskScheduler)
