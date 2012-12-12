package processing.test.jairre;

import processing.core.*; 
import processing.data.*; 
import processing.opengl.*; 

import org.json.*; 
import controlP5.*; 
import apwidgets.*; 

import android.view.MotionEvent; 
import android.view.KeyEvent; 
import android.graphics.Bitmap; 
import java.io.*; 
import java.util.*; 

public class jairre extends PApplet {



//AUDIO

APMediaPlayer player;

ControlP5 controlP5;
Box decision;
Box[] irregularverbs;
Score score;
Dictionary dictionary;

//general
int screenBg;
int fontsize;
PFont myFont;

//cursor
PVector cursorLocation;
PVector cursorVelocity;
int cursorColor;
int cursorWrong;
int fingerSpace;

//score
int Scorefontsize;
int scoreBgColor;
int scoreColor;
float levelOfDifficulty;
float scaleDifficulty;
int maxErrors;
int verbIndex;

//irregular verbs possibilietes
int irregularsColor;
float[] screenPosition = { 0.25f, 0.75f };

public void setup(){
  Scorefontsize = 18;
  scoreBgColor = 0xff5453db;
  scoreColor = 0xfffabaf8;
  levelOfDifficulty = 3.8f;
  scaleDifficulty = 0.3f;
  maxErrors = 3;
  verbIndex = 0;  
  
  screenBg = 0xff3c30c4;
  fontsize = 22;
  myFont = loadFont("Amstrad-CPC-correct.vlw");
  textFont(myFont, fontsize);  
  //only for java mode 
  //size(500, 500);
  cursorColor = 0xffffff80;
  cursorWrong = 0xffff0080;
  fingerSpace = 100;  
  
  score = new Score(levelOfDifficulty, scaleDifficulty, maxErrors, scoreBgColor, scoreColor, Scorefontsize);
  dictionary = new Dictionary("de_DE");
    
  //possibilieties
  irregularsColor = 0xff00ff89; 
  PVector blockVelocity = new PVector(0, score.difficulty);
  irregularverbs  = new Box[2];
  for (int i = 0; i < 2; i++) {
    PVector blockLocation = new PVector((width * screenPosition[i]), 0);
    irregularverbs[i] = new Box(blockLocation, blockVelocity, 0, fontsize, "", irregularsColor, false);
  }
  dictionary.setNewContent(irregularverbs, verbIndex);   
  PVector cursorLocation = new PVector((width/2), (height - PApplet.parseInt(fingerSpace))); 
  PVector cursorVelocity = new PVector(0,0);
  decision = new Box(cursorLocation, cursorVelocity, fingerSpace, fontsize, dictionary.currentInfinitive, cursorColor, true); 

  //AUDIO
  initializeAudio(); 
  
  playAgainButton(); 
}

public void draw(){
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

public void displayPossibilities(){
  for (int i = 0; i < 2; i++) {
    irregularverbs[i].fall();
    irregularverbs[i].display();
  }
}

public void updateVelocity(){
    irregularverbs[0].velocity.y = score.difficulty;
    irregularverbs[1].velocity.y = score.difficulty;  
}

public void playAgainButton(){
  controlP5 = new ControlP5(this);
  int wbutton = Math.round(height*0.25f);
  int xbutton = (Math.round(width/2)- (63));
  int ybutton = Math.round(height*0.4f);
  ControlFont bf = new ControlFont(myFont,30);
  Button b = controlP5.addButton("play",1,xbutton, ybutton,wbutton,20);
  b.setColorBackground(scoreColor);
  b.setColorActive(scoreBgColor);
  b.setSize(126,46);
  b.setColorForeground(irregularsColor);
  b.captionLabel().setControlFont(bf);   
  b.hide();
}

public void controlEvent(ControlEvent theEvent) {  
  if(theEvent.isController()) {         
    if(theEvent.controller().name()=="play") {
      restoreInitialValue(levelOfDifficulty);
      //AUDIO
      player.start();
    }    
  }  
} 

public void restoreInitialValue(float tmpDifficulty){
    score.reset(tmpDifficulty);
    decision.c = cursorColor;
    dictionary.refreshIndexes();
    verbIndex = 0;
    controlP5.controller("play").hide(); 
}

//AUDIO
public void initializeAudio(){
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

public void onPause() {
  super.onPause();
  if(player != null) {
    player.release();
    player = null;
  }  
}
class Box {
  int c;
  int fontsize;
  PVector location, velocity;  
  float twidth; //text width
  boolean correct;
  boolean attack;
  int fingerHeight;
  String textContent;
  float marginRight;
  float marginLeft;
  
  Box(PVector tmpLocation, PVector tmpVelocity, int tmpFingerheight, int tmpFontsize, String tmpTextcontent, int tmpColor, boolean tmpCorrect){
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
 
  public void display(){
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
  
  public void defense(){
    decision.attack = false; 
    decision.location.y = (height-fingerHeight);
  }    

  public void drive(){
    if (mousePressed == true) {
      move();
    }else{
      showTouchpoint();
    }
  }
    
  public void showTouchpoint(){
    if(!attack){
      fill(c);
      ellipse(location.x,(height - 50), 50, 50);
    }
  }  
  
  public void move(){ 
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
  
  public void fall(){
    location.add(velocity);
  }
  
  public void getNewcontent(String tmpTextcontent, boolean tmpCorrect){
    correct = tmpCorrect;
    textContent = tmpTextcontent;
    twidth = textWidth(tmpTextcontent); 
    marginLeft = (location.x - (twidth/2));
    marginRight = (location.x + (twidth/2));     
  } 

  public void blink(int tmpColor, int tmpColorWrong){
     if(correct){
       background(tmpColor);
       c = tmpColor;
     }else{
       c = tmpColorWrong;       
     } 
        
  }  
  
  //use it only for the cursor
  public void editText(String content){
    getNewcontent(content, true);
  }
  
  public Boolean isRight(Box fallingFirst, Box fallingSecond){
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
class Dictionary{
  Box[] irregularverbs; 
  String lang;
  String loadedFile;
  JSONObject verbList, currentVerb;
  String currentInfinitive;
  int[] shuffledIndexes;
  int totVerbs;
  Map coniugations;  

  Dictionary(String tmpLang){
      lang = tmpLang;
      verbList = getDictionary();
      shuffledIndexes = getRandomList();
      currentVerb = getStartingVerb();
  }
    
  public void refreshIndexes(){
    shuffledIndexes = getRandomList();
  }  
    
  public JSONObject getDictionary(){
    JSONObject verbList = null;  
    try {
      String loadedFile = loadStrings(lang+".json")[0];
      verbList = new JSONObject( loadedFile );
    } catch (Exception e) {
      e.printStackTrace();
    }    
    return verbList;
  }

  public int[] getRandomList(){
    int maximum = verbList.length();
    totVerbs = maximum;
    Random rnd = new Random();
    int[] indexes = new int[maximum];

    for (int i=0; i < maximum; i++) {         
      indexes[i] = i ;
    }
    
    for (int i = 0; i < maximum; i++) {
      int position = i + rnd.nextInt(maximum - i);
      int temp = indexes[i];
      indexes[i] = indexes[position];
      indexes[position] = temp;        
    }
    return indexes;
  }
  
  public JSONObject getVerb(int index){    
    JSONObject verbNode = null;       
    try {
      int shuflled_key = shuffledIndexes[index];
      String key_string = Integer.toString(shuflled_key);
      verbNode = verbList.getJSONObject(key_string);
      currentInfinitive = getInfinitiv(verbNode);
      coniugations = getConiugations(currentInfinitive, verbNode);
    } catch (Exception e) {
      e.printStackTrace();
    }    
    return verbNode;    
  }
 
  // Overload get_verb method, used for the starting point
  public JSONObject getStartingVerb(){
    JSONObject verbNode = getVerb(0);
    return verbNode;
  }     
 
  public String getInfinitiv(JSONObject tmpVerbnode){
    JSONArray names = tmpVerbnode.names();
    String selectedVerb = null;
    try{
      selectedVerb = names.get(0).toString();
    } catch (Exception e) {
      e.printStackTrace();
    }  
    return selectedVerb;
  } 
 
  //it returns a map with the current the 2 available possibilieties for each verb 
  public Map getConiugations(String selected_verb, JSONObject verb_node){
    JSONObject coniugation_availables = null;
    try{
      coniugation_availables = verb_node.getJSONObject(selected_verb);
    } catch (Exception e) {
      e.printStackTrace();
    }     
    
    //JSONObject coniugation_availables = verb_node.getJSONObject(selected_verb);
    Map<String,Boolean> map = new HashMap<String,Boolean>();
    Iterator iter = coniugation_availables.keys();
    
    while(iter.hasNext()){
        String key = (String)iter.next();
        Boolean value = (Boolean) coniugation_availables.optBoolean(key);
        map.put(key,value);      
    }
    //println(map);
    return map;
  }

  public void setNewContent(Box[] irregularverbs, int tmpVerbindex){
      getVerb(tmpVerbindex);
      //mixing position, because in the json file the right box is the correct one
      Random rand = new Random();
      int i = rand.nextInt(2);
      //print(i);
      for (Object key : coniugations.keySet()) {
          boolean di = (Boolean) coniugations.get(key);
          irregularverbs[i].getNewcontent(key.toString(), di);
          //irregular verbs are falling from the top
          irregularverbs[i].location.y = 0;
          if(i == 0){
            i =1;
          }else{
            i = 0;
          }
      }     
  }  
  
}
class Score{
  int level;
  int fontsize;
  float difficulty;
  float improveDifficulty;
  int points;
  int attempts;
  int bg_color;
  int textColor;
  int errors;
  int maxErrors;
  boolean youLoose;
  
  Score(float tmpDifficulty, float tmpImprovedifficulty, int tmpMaxerrors, int tmpBgcolor, int tmpColor, int tmpFontsize){
    difficulty = tmpDifficulty;
    attempts = 0; 
    bg_color = tmpBgcolor;
    textColor = tmpColor;
    fontsize = tmpFontsize;
    youLoose = false;
    improveDifficulty = tmpImprovedifficulty;
    level = 1;
    points = 0;
    maxErrors = tmpMaxerrors;
    errors = 0;     
  }
  
  public void display(){     
    noStroke();
    fill(bg_color);
    rect(0, 0, width, height*0.05f);   
    textAlign(LEFT, CENTER); 
    fill(textColor);
    textSize(fontsize);
    text("Lev:"+level+" Err:"+errors+" score:"+points, width*0.05f, height*0.025f);    
  }
  
  public void update(boolean goodOne){
    attempts++;
    if(goodOne){
      points = points+1;
      if((points % 10) == 0 && (points!=0)){
        level++;
        difficulty = difficulty + improveDifficulty;
        //print(difficulty);
      }      
    }else{
      errors++;
      if(errors == maxErrors){
        youLoose = true;
      }
    }
  }  
  
  public void gameOver(){
    textAlign(CENTER, CENTER); 
    fill(textColor);
    textSize(fontsize+5);
    text("GAME OVER", width/2, height*0.3f); 
    textSize(fontsize);
    text("Lev:"+level+" Err:"+errors+" Score:"+points, width/2, height*0.55f);  
  }
  
  public void reset(float settedDifficulty){
    difficulty = settedDifficulty;
    attempts = 0; 
    youLoose = false;
    level = 1;
    points = 0;
    errors = 0;           
  }
  
}

}
