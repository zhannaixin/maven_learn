package basic;

public class BetterShareObject extends ShareObject {

    private Integer shareData;
    private boolean dataAvailable = false;

    BetterShareObject(int initialValue){
        super(initialValue);
        shareData = initialValue;
    }

    public synchronized void setShareData(int newData){
        if(dataAvailable){
            try{
                wait();
            }catch(InterruptedException ex){

            }
        }
        System.out.println(" Share Object - New Value Set " + newData);
        shareData = newData;
        dataAvailable = true;
        notifyAll();
    }

    public synchronized Integer getShareData(){

        if(!dataAvailable){
            try{
                wait();
            }catch(InterruptedException ex){

            }
        }
        dataAvailable = false;
        notifyAll();
        return shareData;
    }
}
