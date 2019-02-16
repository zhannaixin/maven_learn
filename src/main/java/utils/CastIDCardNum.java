package utils;

import java.text.SimpleDateFormat;

import static java.lang.System.out;

/**
 * 用于将15位身份证号转换为18位身份证号
 *
 * 如果输入15位，自动按20世纪和21世纪各计算一次
 *
 * 接受17位输入，直接计算最后一位校验码
 */
public class CastIDCardNum {

    /**用于日期校验的格式化字符串*/
    private static final SimpleDateFormat SDF =
            new SimpleDateFormat("YYYYMMDD");

    /**计算校验码时，每一位的权重*/
    private static final int[] WEIGHT =
            {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5 , 8, 4, 2};

    /**所有校验码*/
    private static final char[] LAST =
            {'1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2'};

    /**默认计算的输入号码*/
    private static final String ID_NUM = "";

    /**
     * 检查生日字段是否是有效日期
     * @param dt 生日/日期字符串
     * @return 如果是有效日期，返回true，否则返回false
     */
    private static boolean checkDate(String dt){
        try{
            return (SDF.format(SDF.parse(dt)).equals(dt));
        }catch(Exception e){
            out.println("输入号码生日不正确！");
            System.exit(-1);
        }
        return false;
    }

    /**
     * 计算17位号码的验证码
     *
     * @param id17 身份证号码前17位
     * @return 18位身份证号码
     */
    private static String cacl(String id17){
        checkDate(id17.substring(6, 14));
        char[] chars = id17.toCharArray();
        int N = 0;
        for(int idx = 0; idx < 17; idx++){
            N += (chars[idx] - 48) * WEIGHT[idx];
        }
        return id17 + LAST[N % 11];
    }

    /**
     * 处理各种输入情况
     *
     * @param args 命令行输入参数
     */
    public static void convertId(String[] args){
        String idin = null;

        if (args.length != 1) {
            idin = ID_NUM;
        }

        if(idin.matches("[0-9]{15}")){

            out.println("20世纪18位身份证号码：" +
                    cacl(idin.substring(0, 6) + "19" + idin.substring(6)));

            out.println("21世纪18位身份证号码：" +
                    cacl(idin.substring(0, 6) + "20" + idin.substring(6)));

        }else if(idin.matches("[0-9]{17}")){
            out.println("18位身份证号码：" + cacl(idin));

        }else {
            out.println("请输入15位或17位身份证号码！");
            System.exit(-1);
        }
    }

    /**
     * 程序入口
     *
     * @param args
     */
    public static void main(String[] args) {
        convertId(args);
    }
}
