package lambda;

import org.junit.Test;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class ZLastTest {

    @Test
    public void test1(){
        String queryString = "itemId=1&userId=10000&type=20&token=1111111111&key=index";
        Map<String, String> stringMap = Stream.of(queryString.split("&")).map(str -> str.split("=")).collect(Collectors.toMap(s -> s[0], s -> s[1]));
        System.out.println(stringMap);
    }

    @Test
    public void test2(){
//        (new ZLastTest.Book()).books().stream().map(Book::getId).forEach(System.out::println);
//        List<Integer> ids = (new Book()).books().stream().map(Book::getId).collect(Collectors.toList());
//        System.out.println(ids);
//        System.out.println((new Book()).books().stream().map(Book::getName).collect(Collectors.joining(",", "[", "]")));
//
//        (new Book()).books().stream().sorted((b1,b2) -> Double.compare(b1.getPrice(), b2.getPrice())).forEach(System.out::println);
//
//        Comparator<Book> cb = (b1,b2) -> Double.compare(b1.getPrice(), b2.getPrice());
//        (new Book()).books().stream().sorted(cb.thenComparing((b1,b2) -> b1.getPublishDt().isAfter(b2.getPublishDt())?-1:1)).forEach(System.out::println);
//
//        (new Book()).books().stream().sorted(Comparator.comparing(Book::getPrice).reversed().thenComparing(Book::getPublishDt).reversed()).forEach(System.out::println);
//
//        System.out.println((new Book()).books().stream().collect(Collectors.averagingDouble(Book::getPrice)));
//        System.out.println((new Book()).books().stream().collect(Collectors.maxBy(Comparator.comparing(Book::getPrice))));

//        Comparator<Book> cb = Comparator.comparing(Book::getPrice).thenComparing(Comparator.comparing(Book::getPublishDt));
//        System.out.println((new Book()).books().stream().collect(Collectors.maxBy(cb)));

        System.out.println((new Book()).books().stream().collect(Collectors.groupingBy(Book::getType, Collectors.counting())));
        System.out.println((new Book()).books().stream().collect(Collectors.groupingBy(Book::getType, Collectors.summingDouble(Book::getPrice))));
        System.out.println((new Book()).books().stream().collect(Collectors.groupingBy(Book::getType, Collectors.averagingDouble(Book::getPrice))));
        System.out.println((new Book()).books().stream().collect(Collectors.groupingBy(Book::getType, Collectors.maxBy(Comparator.comparing(Book::getPrice)))));

        (new Book()).books().stream().filter(b -> b.getPrice() >= 80).sorted(Comparator.comparing(Book::getPublishDt)).forEach(System.out::println);
    }


    class Book{
        private int id;
        private String name;
        private double price;
        private String type;
        private LocalDate publishDt;

        public Book(){}

        public Book(int id, String name, double price, String type, LocalDate publishDt) {
            this.id = id;
            this.name = name;
            this.price = price;
            this.type = type;
            this.publishDt = publishDt;
        }


        public List<Book> books(){
            List<Book> books = new ArrayList<>(16);
            books.add(new Book(1, "tomcate", /*50*/70d, "服务器", LocalDate.parse("2014-05-17")));
            books.add(new Book(2, "jetty", 60d, "服务器", LocalDate.parse("2015-12-01")));
            books.add(new Book(3, "nginx", 65d, "服务器", LocalDate.parse("2016-10-17")));
            books.add(new Book(4, "java", 66d, "编程语言", LocalDate.parse("2011-04-09")));
            books.add(new Book(5, "ruby", 80d, "编程语言", LocalDate.parse("2013-05-09")));
            books.add(new Book(6, "php", 40d, "编程语言", LocalDate.parse("2014-08-06")));
            books.add(new Book(7, "html", 44d, "编程语言", LocalDate.parse("2011-01-06")));
            books.add(new Book(8, "oracle", 150d, "数据库", LocalDate.parse("2013-08-09")));
            books.add(new Book(9, "mysql", 66d, "数据库", LocalDate.parse("2015-04-06")));
            books.add(new Book(10, "ssh", 70d, "编程语言", LocalDate.parse("2016-12-04")));
            books.add(new Book(11, "设计模式", 81d, "其他", LocalDate.parse("2017-04-06")));
            books.add(new Book(12, "重构", 62d, "其他", LocalDate.parse("2012-04-09")));
            books.add(new Book(13, "敏捷开发", 72d, "其他", LocalDate.parse("2016-09-07")));
            books.add(new Book(14, "从技术到管理", 42d, "其他", LocalDate.parse("2016-02-19")));
            books.add(new Book(15, "算法导论", /*58*/66d, "其他", LocalDate.parse("2010-05-08")));

            return books;
        }

        @Override
        public String toString() {
            return "Book{" +
                    "id=" + id +
                    ", name='" + name + '\'' +
                    ", price=" + price +
                    ", type='" + type + '\'' +
                    ", publishDt=" + publishDt +
                    '}';
        }

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public double getPrice() {
            return price;
        }

        public void setPrice(double price) {
            this.price = price;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public LocalDate getPublishDt() {
            return publishDt;
        }

        public void setPublishDt(LocalDate publishDt) {
            this.publishDt = publishDt;
        }
    }

}