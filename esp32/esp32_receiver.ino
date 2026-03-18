#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// === LCD ===
LiquidCrystal_I2C lcd(0x27, 16, 2);

// === Motor Pins ===
#define ENA 25
#define IN1 26
#define IN2 27

// === PWM ===
#define PWM_FREQ 1000
#define PWM_RES  8

String data = "";
int potValue = 0;
float voltage = 0.0;

void setup() {
  Serial.begin(115200);
  Serial1.begin(9600, SERIAL_8N1, 16, 17);

  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("UART Receiver");

  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);

  //  Correct PWM for new ESP32 core
  ledcAttach(ENA, PWM_FREQ, PWM_RES);
}

void loop() {
  if (Serial1.available()) {
    data = Serial1.readStringUntil('\n');

    if (data.startsWith("POT:")) {
      int commaIndex = data.indexOf(',');

      potValue = data.substring(4, commaIndex).toInt();
      voltage  = data.substring(commaIndex + 1).toFloat();

      int motorSpeed = map(potValue, 0, 4095, 0, 255);
      motorSpeed = constrain(motorSpeed, 0, 255);

      ledcWrite(ENA, motorSpeed);

      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Pot:");
      lcd.print(potValue);
Serial.print("potValue ");Serial.print(potValue);Serial.print("   Voltage ");Serial.println(voltage);
      lcd.setCursor(0, 1);
      lcd.print("Volt:");
      lcd.print(voltage, 2);
      lcd.print("V");
    }
  }
}