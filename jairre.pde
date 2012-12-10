import org.json.*;
import controlP5.*;
//AUDIO
import apwidgets.*;
APMediaPlayer player;

ControlP5 controlP5;
Box decision;
Box[] irregularverbs;
Score score;
Dictionary dictionary;

//general
color screenBg = #3c30c4;
int fontsize = 22;
PFont myFont;

//cursor
PVector cursorLocation;
PVector cursorVelocity;
color cursorColor = #ffff80;
color cursorWrong = #ff0080;
int fingerSpace = 100;

//score
int Scorefontsize = 18;
color scoreBgColor = #5453db;
color scoreColor = #fabaf8;
float levelOfDifficulty = 3.8;
float scaleDifficulty = 0.3;
int maxErrors = 3;
int verbIndex = 0;

//irregular verbs possibilietes
color irregularsColor = #00ff89;
float[] screenPosition = { 0.25, 0.75 };

void setup(){
  //AUDIO
  initializeAudio();

  myFont = loadFont("Amstrad-CPC-correct.vlw");
  textFont(myFont, fontsize);  
  //leva size quando sei su android  
  //size(500, 500);
  playAgainButton();

  //SCORE
  score = new Score(levelOfDifficulty, scaleDifficulty, maxErrors, scoreBgColor, scoreColor, Scorefontsize);
  //DICTIONARY
  dictionary = new Dictionary("de_DE");
    
  //POSSIBILITIES
  PVector blockVelocity = new PVector(0, score.difficulty);
  irregularverbs  = new Box[2];

  for (int i = 0; i < 2; i++) {
    PVector blockLocation = new PVector((width * screenPosition[i]), 0);
    irregularverbs[i] = new Box(blockLocation, blockVelocity, 0, fontsize, "", irregularsColor, false);
  }
  dictionary.setNewContent(irregularverbs, verbIndex); 
  
  PVector cursorLocation = new PVector((width/2), (height - int(fingerSpace))); 
  PVector cursorVelocity = new PVector(0,0);
  decision = new Box(cursorLocation, cursorVelocity, fingerSpace, fontsize, dictionary.currentInfinitive, cursorColor, true);    
}

void draw(){
  background(screenBg); 
 
  if(score.youLoose){
      score.gameOver();
      controlP5.controller("play").show();
      //AUDIO
      player.pause();                   
  }else{  
    decision.display();
    decision.drive();
    displayPossibilities();    
        
    if(irregularverbs[0].location.y > (decision.location.y)){  
      if(decision.isRight(irregularverbs[0], irregularverbs[1])){
        decision.correct = true;
        updateVelocity();
      }else{
        decision.correct = false;                       
      }
      decision.blink(cursorColor, cursorWrong); 
      score.update(decision.correct);
     
      verbIndex++;
      if(verbIndex == (dictionary.totVerbs-1)){
        verbIndex = 0;
      }
              
      dictionary.setNewContent(irregularverbs, verbIndex);
      decision.editText(dictionary.currentInfinitive);
      decision.defense();       
          
    }         
    score.display();        
  }     
}

void displayPossibilities(){
  for (int i = 0; i < 2; i++) {
    irregularverbs[i].fall();
    irregularverbs[i].display();
  }
}

void updateVelocity(){
    irregularverbs[0].velocity.y = score.difficulty;
    irregularverbs[1].velocity.y = score.difficulty;  
}

void playAgainButton(){
  controlP5 = new ControlP5(this);
  int wbutton = Math.round(height*0.25);
  int xbutton = (Math.round(width/2)- (63));
  int ybutton = Math.round(height*0.4);
  ControlFont bf = new ControlFont(myFont,30);
  Button b = controlP5.addButton("play",1,xbutton, ybutton,wbutton,20);
  b.setColorBackground(scoreColor);
  b.setColorActive(scoreBgColor);
  b.setSize(126,46);
  b.setColorForeground(irregularsColor);
  b.captionLabel().setControlFont(bf);   
  b.hide();
}

void controlEvent(ControlEvent theEvent) {  
  if(theEvent.isController()) {         
    if(theEvent.controller().name()=="play") {
      restoreInitialValue(levelOfDifficulty);
      //AUDIO
      player.start();
    }    
  }  
} 

void restoreInitialValue(float tmpDifficulty){
    score.reset(tmpDifficulty);
    decision.c = cursorColor;
    dictionary.refreshIndexes();
    verbIndex = 0;
    controlP5.controller("play").hide(); 
}

//AUDIO

void initializeAudio(){
  player = new APMediaPlayer(this);
  player.setMediaFile("Jumpshot.mp3");
  //se qualcosa nn va, metti looping dopo start 
  player.start();
  player.setLooping(true);   
}

public void onDestroy(){
  super.onDestroy(); 
  if(player != null) { 
    player.release();
    player = null;
  }
}

public void onStop() {
  super.onStop(); 
  if(player != null) {
    player.release();
    player = null;
  }
}

public void onResume() {
  super.onResume();  
  if(player != null) {
    player.start();
  }else{
    initializeAudio();
  }
}

void onPause() {
  super.onPause();
  if(player != null) {
    player.release();
    player = null;
  }  
}
