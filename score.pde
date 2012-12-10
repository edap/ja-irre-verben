class Score{
  int level;
  int fontsize;
  float difficulty;
  float improveDifficulty;
  int points;
  int attempts;
  color bg_color;
  color textColor;
  int errors;
  int maxErrors;
  boolean youLoose;
  
  Score(float tmpDifficulty, float tmpImprovedifficulty, int tmpMaxerrors, color tmpBgcolor, color tmpColor, int tmpFontsize){
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
  
  void display(){     
    noStroke();
    fill(bg_color);
    rect(0, 0, width, height*0.05);   
    textAlign(LEFT, CENTER); 
    fill(textColor);
    textSize(fontsize);
    text("Lev:"+level+" Err:"+errors+" score:"+points, width*0.05, height*0.025);    
  }
  
  void update(boolean goodOne){
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
  
  void gameOver(){
    textAlign(CENTER, CENTER); 
    fill(textColor);
    textSize(fontsize+5);
    text("GAME OVER", width/2, height*0.3); 
    textSize(fontsize);
    text("Lev:"+level+" Err:"+errors+" Score:"+points, width/2, height*0.55);  
  }
  
  void reset(float settedDifficulty){
    difficulty = settedDifficulty;
    attempts = 0; 
    youLoose = false;
    level = 1;
    points = 0;
    errors = 0;           
  }
  
}
