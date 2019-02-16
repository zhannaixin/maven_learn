package basic;

public class ShareObjectConsumer extends Thread{
    private ShareObject shareObject;
    private int numberOfReads;

    public ShareObjectConsumer(ShareObject obj, int numberOfTimesToRead){
        super();
        shareObject = obj;
        numberOfReads = numberOfTimesToRead;
    }

    private int getNumberOfReads(){
        return numberOfReads;
    }

    public void run(){
        int maxCounter = getNumberOfReads();
        for(int counter = 1; counter <= maxCounter; counter++){
            Integer intObj = shareObject.getShareData();
            System.out.println("Consumer - Getting New Value: " + intObj);
        }
    }
}
