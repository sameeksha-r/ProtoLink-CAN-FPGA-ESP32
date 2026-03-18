#  ProtoLink-CAN: FPGA–Microcontroller Custom CAN Framework

A custom CAN-like communication framework built using **Basys 3 FPGA** and **ESP32 microcontrollers**. The FPGA generates CAN-like frames with identifier, data, and error handling logic, while ESP32 nodes handle real-world data transmission, UART logging, and PWM motor control.

---

## 📌 Features

- FPGA-based CAN-like frame generator with ID, data, and checksum logic
- Error injection mechanism for testing frame integrity
- 7-segment display for real-time ID, data, and error status
- ESP32 UART communication for ADC data transfer
- PWM-based DC motor speed control using potentiometer input
- LCD display for live data monitoring on receiver node
- Modular architecture separating FPGA protocol logic and embedded CAN communication

---

## 🛠️ Hardware Requirements

| Component | Description |
|---|---|
| Basys 3 FPGA | CAN frame generation and protocol logic |
| ESP32 (x2) | Transmitter and Receiver nodes |
| Potentiometer | Analog input for ADC data |
| DC Motor | Controlled via PWM from receiver ESP32 |
| LCD Display (I2C) | Shows received data on receiver node |
| CAN Transceivers | External transceivers for ESP32 CAN nodes |

---

## 💻 Software Requirements

- Xilinx Vivado (for FPGA synthesis and simulation)
- Arduino IDE (for ESP32 programming)
- Libraries:
  - `LiquidCrystal_I2C` — LCD display control
  - `Wire.h` — I2C communication

---

## 📁 Project Structure

```
ProtoLink-CAN/
├── fpga/
│   ├── sh.v                  # Main CAN frame transmitter module
│   ├── tb_sh.v               # Testbench for simulation
│   └── constraints.xdc       # Basys 3 pin mapping constraints
├── esp32/
│   ├── esp32_transmitter.ino # Reads potentiometer, sends via UART
│   └── esp32_receiver.ino    # Receives data, controls motor + LCD
└── README.md
```

---

## ⚙️ How It Works

### FPGA Side
1. Switches set the **ID (3-bit)** and **Data (2-bit)** values
2. FPGA generates a **7-bit CAN-like frame**: Start bit + ID + Data + Checksum
3. Frame is transmitted bit by bit via `can_out` pin
4. Error injection switch corrupts the checksum to test error handling
5. 7-segment display shows ID, data, and error status in real time

### ESP32 Side
1. **Transmitter ESP32** reads potentiometer value (0–4095) and converts to voltage
2. Sends data via UART in format: `POT:value,voltage`
3. **Receiver ESP32** parses incoming data
4. Maps potentiometer value to motor speed (0–255) using PWM
5. Displays live pot value and voltage on LCD screen

---

## 🚀 How to Run

### FPGA
1. Open Xilinx Vivado
2. Add `sh.v` and `constraints.xdc` to your project
3. Run synthesis and implementation
4. Program the Basys 3 board
5. Use switches to set ID and data values

### ESP32
1. Open Arduino IDE
2. Flash `esp32_transmitter.ino` to Transmitter ESP32
3. Flash `esp32_receiver.ino` to Receiver ESP32
4. Connect UART pins (TX→RX, RX→TX) between the two ESP32s
5. Rotate potentiometer to control motor speed

---

## 📊 Results

- Successfully transmitted CAN-like frames via FPGA
- Real-time error detection and display on 7-segment
- Smooth PWM motor control based on UART data
- Live voltage and pot value display on LCD
