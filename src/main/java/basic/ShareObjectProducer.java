package basic;

public class ShareObjectProducer extends Thread{
    private int maxCounter;
    private ShareObject shareObject;

    ShareObjectProducer(ShareObject obj, int maxWrites){
        super();
        shareObject = obj;
        maxCounter = maxWrites;
    }

    public void run(){
        for(int counterValue = 1; counterValue <= maxCounter; counterValue++){
            System.out.println(" Producer - Wriing New Value: " + counterValue);
            shareObject.setShareData(counterValue);
        }
    }
}
