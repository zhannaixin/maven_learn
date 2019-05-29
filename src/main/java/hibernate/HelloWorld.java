package hibernate;

import hibernate.dao.User;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;

public class HelloWorld {

    public static void main(String[] args) {
        // 1. 创建Configuration对象
//        Configuration config = new Configuration().configure();
        // 读取hibernate.cfg.xml文件，默认读取src下的hibernate.cfg.xml文件，如果同名则可以省略
        Configuration config = new Configuration().configure("config/hibernate.cfg.xml");

        // 2.读取并解析映射信息，创建会话工厂SessionFactory
        // hibernate3.x中可以调用buildSessionFactory()方法获取SessionFactory，在4.x中已过时
        // SessionFactory sf = config.buildSessionFactory();
        // hiberate4.x中通过ServiceRegistry接口来获取，目的是解耦合
//        StandardServiceRegistryBuilder ssrb = new StandardServiceRegistryBuilder().applySettings(config.getProperties());
        // ssrb.applySettings(config.getProperties());
//        StandardServiceRegistry ssr = ssrb.build();
//        SessionFactory sf = config.buildSessionFactory(ssr);
        SessionFactory sf = config.buildSessionFactory();

        //事务Transaction(增、删、改)
        Transaction tx;

        // 3. 获取会话Session
        try (Session session = sf.openSession()) {

            // 4.开启事务Transaction(增、删、改)，Hibernate默认关闭自动提交事务
            tx = session.beginTransaction();

            // 5.执行持久化操作
            session.save(new User(null, "mike", "123", 21));

            // 6.提交事务
            tx.commit();
        } catch (Exception e) {
//            if(tx != null) {
//                tx.rollback(); // 回滚事务
//            }
            e.printStackTrace();
        }
    }
}
