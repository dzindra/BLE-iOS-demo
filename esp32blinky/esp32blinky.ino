#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <TaskScheduler.h>

#define SERVICE_UUID        "9a8ca9ef-e43f-4157-9fee-c37a3d7dc12d"
#define BLINK_UUID          "e94f85c8-7f57-4dbd-b8d3-2b56e107ed60"
#define TEXT_UUID           "326a9006-85cb-9195-d9dd-464cfbbae75a"
#define DEVICE_NAME         "ESP_Blinky"

#define PIN_BUTTON 0

Scheduler scheduler;

void buttonCb();
void blinkCb();

Task taskBlink(500, TASK_FOREVER, &blinkCb, &scheduler, false);
Task taskButton(30, TASK_FOREVER, &buttonCb, &scheduler, true);

uint8_t blinkOn;

BLECharacteristic *pCharBlink;
BLECharacteristic *pCharText;



void setBlink(bool on, bool notify = false) {
  if (blinkOn == on) return;

  blinkOn = on;
  if (blinkOn) {
    Serial.println("Blink ON");
    taskBlink.restartDelayed(0);
  } else {
    Serial.println("\nBlink OFF");
    taskBlink.disable();
  }

  pCharBlink->setValue(&blinkOn, 1);
  if (notify) {
    pCharBlink->notify();
  }
}


void buttonCb() {
  uint8_t btn = digitalRead(PIN_BUTTON) != HIGH;
  if (btn) {
    setBlink(!blinkOn, true);
    taskButton.delay(1000);
  }
}

void blinkCb() {
  // LED is connected to serial TX only, so in order to blink it we need to send something
  Serial.print("....");
}



class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      Serial.println("Connected");
    };

    void onDisconnect(BLEServer* pServer) {
      Serial.println("Disconnected");
    }
};

class BlinkCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();

      if (value.length()  == 1) {
        uint8_t v = value[0];
        Serial.print("Got blink value: ");
        Serial.println(v);
        setBlink(v ? true : false);
      } else {
        Serial.println("Invalid data received");
      }
    }
};

class TextCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();

      Serial.print("Got text value: \"");
      for (int i = 0; i < value.length(); i++) {
        Serial.print(value[i]);
      }
      Serial.println("\"");
    }
};

void setup() {
  Serial.begin(9600);
  Serial.println("Starting...");

  pinMode(PIN_BUTTON, INPUT);


  BLEDevice::init(DEVICE_NAME);
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());


  BLEService *pService = pServer->createService(SERVICE_UUID);

  pCharBlink = pService->createCharacteristic(BLINK_UUID, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_WRITE);
  pCharBlink->setCallbacks(new BlinkCallbacks());
  pCharBlink->addDescriptor(new BLE2902());

  pCharText = pService->createCharacteristic(TEXT_UUID, BLECharacteristic::PROPERTY_WRITE);
  pCharText->setCallbacks(new TextCallbacks());

  pService->start();

  // ----- Advertising

  BLEAdvertising *pAdvertising = pServer->getAdvertising();

  BLEAdvertisementData adv;
  adv.setName(DEVICE_NAME);
  adv.setCompleteServices(BLEUUID(SERVICE_UUID));
  pAdvertising->setAdvertisementData(adv);

  BLEAdvertisementData adv2;
  adv2.setName(DEVICE_NAME);
  //  adv.setCompleteServices(BLEUUID(SERVICE_UUID));  // uncomment this if iOS has problems discovering the service
  pAdvertising->setScanResponseData(adv2);

  pAdvertising->start();

  Serial.println("Ready");
}

void loop() {
  scheduler.execute();
}

