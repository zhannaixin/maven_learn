package com.spring.jdbc;

import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.BeanPropertySqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;

import javax.sql.DataSource;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SpringJdbcTest {
    ApplicationContext ctx = new ClassPathXmlApplicationContext("applicationContext.xml");
    JdbcTemplate jdbcTemplate = ctx.getBean("jdbcTemplate", JdbcTemplate.class);
    NamedParameterJdbcTemplate namedParameterJdbcTemplate = ctx.getBean("namedParameterJdbcTemplate", NamedParameterJdbcTemplate.class);

    @Test
    public void testAnnotation() {

    }

    @Test
    public void testDataSource() throws SQLException {
        DataSource dataSource = ctx.getBean("dataSourceMariaDB", DataSource.class);
        System.out.println(dataSource.getConnection());
    }

    @Test
    public void testUpdate() {
        String sql = "UPDATE employee SET EMAIL = ? WHERE ID = ?";
        jdbcTemplate.update(sql, "sohu@126.com", "1");

    }

    @Test
    public void testBatchUpdate() {
        String sql = "INSERT INTO employee(LAST_NAME,EMAIL,DEPT_ID) VALUES(?,?,?)";
        List<Object[]> batchArgs = new ArrayList<>();
        batchArgs.add(new Object[]{"赵六一", "google@sohu.com", "2"});
        batchArgs.add(new Object[]{"王八一", "microsoft@goole.com", "1"});

        jdbcTemplate.batchUpdate(sql, batchArgs);
    }

    @Test
    public void testQueryObject() {
        String sql = "SELECT ID, LAST_NAME, EMAIL, DEPT_ID FROM employee where id = ?";
        RowMapper<Employee> rowMapper = new BeanPropertyRowMapper<>(Employee.class);
        Employee employee = jdbcTemplate.queryForObject(sql, rowMapper, 1);
        System.out.println(employee);
    }

    @Test
    public void testQueryList() {
        String sql = "SELECT ID, LAST_NAME, EMAIL, DEPT_ID FROM employee where id > ?";
        RowMapper<Employee> rowMapper = new BeanPropertyRowMapper<>(Employee.class);
        List<Employee> employeeList = jdbcTemplate.query(sql, rowMapper, 5);
        System.out.println(employeeList);
    }

    @Test
    public void testQueryColumn() {
        String sql = "SELECT count(1) FROM employee where id > ?";
        long l = jdbcTemplate.queryForObject(sql, Long.class, 5);
        System.out.println(l);
    }

    @Test
    public void testGetByPK() {
        String sql = "SELECT ID, LAST_NAME, EMAIL, DEPT_ID FROM employee where id = ?";
        RowMapper<Employee> rowMapper = new BeanPropertyRowMapper<>(Employee.class);
        System.out.println(jdbcTemplate.queryForObject(sql, rowMapper, 1));
    }

    @Test
    public void testNamedParameterJdbcTemplate(){
        String sql = "INSERT INTO employee(LAST_NAME,EMAIL,DEPT_ID) VALUES(:lastName,:email,:deptId)";
        Map<String, Object> map = new HashMap<>();
        map.put("lastName", "骁芃");
        map.put("email", "xiaopeng@google.com");
        map.put("deptId", 1);
        namedParameterJdbcTemplate.update(sql, map);
    }
    @Test
    public void testNamedParameterJdbcTemplate2(){
        String sql = "INSERT INTO employee(LAST_NAME,EMAIL,DEPT_ID) VALUES(:lastName,:email,:deptId)";
        Employee employee = new Employee();
        employee.setLastName("王五八");
        employee.setEmail("wangwu@sina.com.cn");
        employee.setDeptId(1);
        SqlParameterSource sqlParameterSource = new BeanPropertySqlParameterSource(employee);
        namedParameterJdbcTemplate.update(sql, sqlParameterSource);
    }

    @Test
    public void testBookShopService(){
        BookShopService bookShopService = ctx.getBean("bookShopService", BookShopService.class);
        bookShopService.purchase("AA", "1001");
    }

    @Test
    public void testCashier(){
        Cashier cashier = ctx.getBean("cashier", Cashier.class);
        cashier.checkout("AA", "1001", "1002");
    }

    @Test
    public void testBookShopDao(){
        BookShopDao bookShopDao = ctx.getBean("bookShopDao", BookShopDao.class);
//        Assert.assertEquals(bookShopDao.findBookPriceByIsbn("1001"), new BigDecimal("100.00"));
        bookShopDao.updateBookStock("1002");
        bookShopDao.updateUserAccount("AA", new BigDecimal("21.03"));
    }

    @Test
    public void testBookShopServiceXml(){
        BookShopService bookShopService = ctx.getBean("bookShopServiceXml", BookShopService.class);
        bookShopService.purchase("AA", "1001");
    }

    @Test
    public void testCashierXml(){
        Cashier cashier = ctx.getBean("cashierXml", Cashier.class);
        cashier.checkout("AA", "1001", "1002");
    }

}
