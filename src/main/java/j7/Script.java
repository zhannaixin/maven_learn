package j7;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;

public class Script{

  public static void main(String[] args) throws Throwable{

    script();

  }

  public static void script() throws ScriptException{
    ScriptEngineManager sem = new ScriptEngineManager();
    ScriptEngine engine = sem.getEngineByName("JavaScript");
    if(engine == null){
      throw new RuntimeException("No JavaScript avaliable!");
    }
    engine.eval("println('Hello world!');");
  }


}