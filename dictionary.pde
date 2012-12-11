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
    
  void refreshIndexes(){
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

  int[] getRandomList(){
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
  
  JSONObject getVerb(int index){    
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
  JSONObject getStartingVerb(){
    JSONObject verbNode = getVerb(0);
    return verbNode;
  }     
 
  String getInfinitiv(JSONObject tmpVerbnode){
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
  Map getConiugations(String selected_verb, JSONObject verb_node){
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

  void setNewContent(Box[] irregularverbs, int tmpVerbindex){
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
