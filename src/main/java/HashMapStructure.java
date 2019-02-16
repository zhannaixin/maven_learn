import java.util.HashMap;
import java.util.Iterator;

/**
 * Created by Administrator on 2014/4/18.
 */
public class HashMapStructure {

    public static void main(String[] args) {

        Country india = new Country("India", 1000);
        Country japan = new Country("Japan", 10000);

        Country france = new Country("France", 2000);
        Country russia = new Country("Russia", 20000);

        HashMap<Country, String> countryCapitalMap = new HashMap<Country, String>(8);
        countryCapitalMap.put(india, "Delhi");
        countryCapitalMap.put(japan, "Tokyo");
        countryCapitalMap.put(france, "Paris");
        countryCapitalMap.put(russia, "Moscow");

        Iterator<Country> countryCapitalIter = countryCapitalMap.keySet().iterator();//put debug point at this line
        while (countryCapitalIter.hasNext()) {
            Country countryObj = countryCapitalIter.next();
            String capital = countryCapitalMap.get(countryObj);
            System.out.println(countryObj.getName() + "----" + capital);
        }
        System.out.println(hash(india.hashCode()));
        System.out.println(hash(india.hashCode())&8-1);
        System.out.println(countryCapitalMap.put(india, "Moscow"));
        System.out.println(countryCapitalMap.put(india, "Tokyo"));
        System.out.println(countryCapitalMap.get(india));
        System.out.println(countryCapitalMap.put(null, "Moscow"));
        System.out.println(countryCapitalMap.put(null, "Tokyo"));
        System.out.println(countryCapitalMap.get(null));

        for(int j=0; j<5; ++j)
            System.out.println(j + "\t");
    }

    static int hash(int paramInt) {
        paramInt ^= paramInt >>> 20 ^ paramInt >>> 12;
        return (paramInt ^ paramInt >>> 7 ^ paramInt >>> 4);
    }
}
