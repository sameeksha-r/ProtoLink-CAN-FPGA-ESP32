// ESP32 UART Transmitter 
// Reads potentiometer value and sends it via Serial1 (UART)

#define POT_PIN 35   // Analog pin for potentiometer (use GPIO 34, 35, 32, 33, 36, or 39)

void setup() {
  Serial.begin(115200);                         // Debug monitor
  Serial1.begin(9600, SERIAL_8N1, 16, 17);      // RX=16, TX=17
  Serial.println("ESP32 Transmitter Ready");
}

void loop() {
  int potValue = analogRead(POT_PIN);           // Read analog input (0–4095)
  float voltage = (potValue / 4095.0) * 3.3;    // Convert to voltage

  // Send potentiometer value and voltage to receiver
  Serial1.print("POT:");
  Serial1.print(potValue);
  Serial1.print(",");
  Serial1.println(voltage, 2);

  // Also print on Serial Monitor
  Serial.print("Sent -> POT Value: ");
  Serial.print(potValue);
  Serial.print(" | Voltage: ");
  Serial.println(voltage, 2);

  delay(1000);
}
