
const int ecgPin = 17;
const int lop = 5;
const int lom = 18;
int potValue = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(17, INPUT);
  pinMode(5, INPUT);
  pinMode(18, INPUT);
}

void loop() {
  delayMicroseconds(104);
  if(digitalRead(lop) || digitalRead(lom)){
    Serial.println('!');
  }
  else{
    potValue = analogRead(ecgPin);
    Serial.println(potValue);
  }
     
}
