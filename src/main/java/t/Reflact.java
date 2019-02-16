package t;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

/**
 * @author zhannaixin.zh
 * 
 */
public class Reflact {
	static class User {
		int id;

		public User() {
			id = 0;
			System.out.println("default");
		}

		@SuppressWarnings("unused")
		private User(final int id) {
			this.id = id;
			System.out.println("id=" + id);
		}

		@SuppressWarnings("unused")
		private void printId() {
			System.out.println("=====" + id + "======");
		}

		public int getId() {
			return id;
		}

		public String strHash(String str) {
			return String.valueOf(str.hashCode());
		}

		static void printName() {
			System.out.println("t.Reflact$User");
		}

		static void printName(String... strs) {
			for (String str : strs) {
				System.out.println(str);
			}
		}

		static void sum(int... nums) {
			int sum = 0;
			for (int num : nums) {
				sum += num;
			}
			System.out.println(sum);
		}
	}

	public static void main(String[] args) throws Exception {
		Class<?> clazz = Class.forName("t.Reflact$User");
		Constructor<?> constructor = clazz.getDeclaredConstructor(int.class);
		constructor.setAccessible(true);
		Object o = constructor.newInstance(15);
		Method method = clazz.getDeclaredMethod("printId");
		method.setAccessible(true);
		method.invoke(o);
		method = clazz.getDeclaredMethod("getId");
		System.out.println(method.invoke(o));
		method = clazz.getDeclaredMethod("strHash", String.class);
		System.out.println(method.invoke(o, "123"));
		System.out.println("123".hashCode());
		Field field = clazz.getDeclaredField("id");
		System.out.println(field.get(o));
		field.set(o, 25);
		System.out.println(field.get(o));
		method = clazz.getDeclaredMethod("printName", String[].class);
		method.invoke(null, new Object[]{new String[]{"123", "456"}});
		System.out.println(method.getName());
		method = clazz.getDeclaredMethod("sum", int[].class);
		method.invoke(null, new int[]{123, 456});
		System.out.println(method.getModifiers());
		System.out.println(DaEnum.values());
	}

}
