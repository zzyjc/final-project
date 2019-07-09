//char HEADER="M";
//void setup(){
//
//  pinMode(A0,INPUT);
//  pinMode(A1,INPUT);
//  pinMode(A2,INPUT);
//  Serial.begin(9600);
//
//}
//void loop(){
//
//Serial.print("x: ");
//Serial.print(analogRead(A0));
//Serial.print("y: ");
//Serial.println(analogRead(A1));
//
//delay(1000);
//}
#define potXPin  A0
#define potYPin  A1

char HEADER = 'M';
void setup()
{
  pinMode(7,INPUT);
  Serial.begin(9600);
} 

void loop()
{
  int x = analogRead(potXPin);
  int y = analogRead(potYPin);  
 
  Serial.print(HEADER);
  Serial.print(","); 
  Serial.print(x, DEC);      
  Serial.print(",");     
  Serial.print(y, DEC);   
  Serial.print(",");
  Serial.print(digitalRead(7));   
  Serial.print(",");
  Serial.println();
  delay(5);
}
