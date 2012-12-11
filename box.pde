class Box {
  color c;
  int fontsize;
  PVector location, velocity;  
  float twidth; //text width
  boolean correct;
  boolean attack;
  int fingerHeight;
  String textContent;
  float marginRight;
  float marginLeft;
  
  Box(PVector tmpLocation, PVector tmpVelocity, int tmpFingerheight, int tmpFontsize, String tmpTextcontent, color tmpColor, boolean tmpCorrect){
    attack = false;
    location = tmpLocation;
    velocity = tmpVelocity;
    fingerHeight = tmpFingerheight;
    fontsize = tmpFontsize;
    textContent = tmpTextcontent;
    correct = tmpCorrect;
    twidth = textWidth(tmpTextcontent); 
    marginLeft = (location.x - (twidth/2));
    marginRight = (location.x + (twidth/2));    
    c = tmpColor;
  }
 
  void display(){
    //resize text if too large
    if(twidth >= ((width/2)-10)){
      textSize(fontsize-2);
    }else{
      textSize(fontsize);
    }        
    fill(c);    
    textAlign(CENTER); 
    text(textContent, location.x, location.y);  
  }
  
  void defense(){
    decision.attack = false; 
    decision.location.y = (height-fingerHeight);
  }    

  void drive(){
    if (mousePressed == true) {
      move();
    }else{
      showTouchpoint();
    }
  }
    
  void showTouchpoint(){
    if(!attack){
      fill(c);
      ellipse(location.x,(height - 50), 50, 50);
    }
  }  
  
  void move(){ 
    PVector mouse = new PVector(0, 0);
    if(mouseY > (height - (fingerHeight+fontsize))){
      attack = true;
    }
    if(attack){    
      PVector attack_mouse = new PVector(mouseX, (mouseY-fingerHeight));
      mouse.set(attack_mouse);
    }else{
      PVector defensive_mouse = new PVector(mouseX, location.y);
      mouse.set(defensive_mouse);
    } 
    location.set(mouse);
  } 
  
  void fall(){
    location.add(velocity);
  }
  
  void getNewcontent(String tmpTextcontent, boolean tmpCorrect){
    correct = tmpCorrect;
    textContent = tmpTextcontent;
    twidth = textWidth(tmpTextcontent); 
    marginLeft = (location.x - (twidth/2));
    marginRight = (location.x + (twidth/2));     
  } 

  void blink(color tmpColor, color tmpColorWrong){
     if(correct){
       background(tmpColor);
       c = tmpColor;
     }else{
       c = tmpColorWrong;       
     } 
        
  }  
  
  //use it only for the cursor
  void editText(String content){
    getNewcontent(content, true);
  }
  
  Boolean isRight(Box fallingFirst, Box fallingSecond){
    if((this.location.x < fallingFirst.marginRight) && (this.location.x > fallingFirst.marginLeft)){
      return fallingFirst.correct;
    }
    if((this.location.x < fallingSecond.marginRight) && (this.location.x > fallingSecond.marginLeft)){ 
      return fallingSecond.correct;
    }
    else{
      return false;
    }    
  }

}
