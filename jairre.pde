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
color screenBg;
int fontsize;
PFont myFont;

//cursor
PVector cursorLocation;
PVector cursorVelocity;
color cursorColor;
color cursorWrong;
int fingerSpace;

//score
int Scorefontsize;
color scoreBgColor;
color scoreColor;
float levelOfDifficulty;
float scaleDifficulty;
int maxErrors;
int verbIndex;

//irregular verbs possibilietes
color irregularsColor;
float[] screenPosition = { 0.25, 0.75 };

void setup(){
  Scorefontsize = 18;
  scoreBgColor = #5453db;
  scoreColor = #fabaf8;
  levelOfDifficulty = 3.8;
  scaleDifficulty = 0.3;
  maxErrors = 3;
  verbIndex = 0;  
  
  screenBg = #3c30c4;
  fontsize = 22;
  myFont = loadFont("Amstrad-CPC-correct.vlw");
  textFont(myFont, fontsize);  
  //only for java mode 
  //size(500, 500);
  cursorColor = #ffff80;
  cursorWrong = #ff0080;
  fingerSpace = 100;  
  
  score = new Score(levelOfDifficulty, scaleDifficulty, maxErrors, scoreBgColor, scoreColor, Scorefontsize);
  dictionary = new Dictionary("de_DE");
    
  //possibilieties
  irregularsColor = #00ff89; 
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

  //AUDIO
  initializeAudio(); 
  
  playAgainButton(); 
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

void onDestroy(){
  super.onDestroy(); 
  if(player != null) { 
    player.release();
    player = null;
  }
}

void onStop() {
  super.onStop(); 
  if(player != null) {
    player.release();
    player = null;
  }
}

void onResume() {
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
