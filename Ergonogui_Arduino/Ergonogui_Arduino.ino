const char HEADER = 'H';
int value = 0;

void setup() {
  // start serial
  Serial.begin(9600);

}

void loop() {

  Serial.print(HEADER);

  for(int i=0; i<4; i++) {
    // map values from 1023 to 255
    // 255/1023 = 0.24..  

    value = map(analogRead(i), 0, 1023, 0, 255); 

    sendBinary(value);
  }  
  Serial.println();

  delay(150);

}

void sendBinary( int value) {
  /* From Arduino Cookbook, Michael Margolis, O'Reilly, p.110 */
  Serial.write(lowByte(value)); // send the low byte
  Serial.write(highByte(value)); // send the high byte
}

/* Hÿûðç
 */

