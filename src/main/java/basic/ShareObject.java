package basic;

public class ShareObject {
    private Integer shareData = null;

    public ShareObject(int initialValue){
        super();
        shareData = initialValue;
    }

    public  synchronized void setShareData(int newData){
        System.out.println(" Share Object - New Value Set" + newData);
        shareData = newData;
    }

    public synchronized  Integer getShareData(){
        return shareData;
    }
}
