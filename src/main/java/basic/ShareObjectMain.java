package basic;

public class ShareObjectMain {

    public static void main(String[] args){
        int MAX_COUNTER = 5;
        ShareObject shareObject = new BetterShareObject(0);
        ShareObjectProducer shareObjectProducer = new ShareObjectProducer(shareObject, MAX_COUNTER);
        ShareObjectConsumer shareObjectConsumer = new ShareObjectConsumer(shareObject, MAX_COUNTER);

        shareObjectProducer.start();
        shareObjectConsumer.start();
    }
}
