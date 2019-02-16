package algorithm;

/**
 * 红黑树的几个特性：
 * (1) 每个节点或者是黑色，或者是红色。
 * (2) 根节点是黑色。
 * (3) 每个叶子节点是黑色。 [注意：这里叶子节点，是指为空的叶子节点！]
 * (4) 如果一个节点是红色的，则它的子节点必须是黑色的。
 * (5) 从一个节点到该节点的子孙节点的所有路径上包含相同数目的黑节点。
 *
 */
public class BlackRedTree {

    /**根节点*/
    private BRTNode root = null;

    /**当前节点数*/
    private int size = 0;

    /**默认构造函数*/
    public BlackRedTree(){}

    /**
     * 从r节点遍历，找到比v大的最小值
     *
     * @param r 开始遍历的节点
     * @param v 要查找的值
     * @return 比v大的最小值
     */
    private BRTNode getParent(BRTNode r, int v){
        if(r == null){
            return null;
        }

        if(v < r.getValue()){
            if(r.getLeft() == null){
                return r;
            }
            return getParent(r.getLeft(), v);
        }else{
            if(r.getRight() == null){
                return r;
            }
            return getParent(r.getRight(), v);
        }
    }

    /**
     * 左旋
     *
     * @param c 操作的节点
     */
    private void rotateLeft(BRTNode c){
        if(c == null) return;

        BRTNode r = c.getRight();
        if(r == null) return;

        BRTNode p = c.getParent();

        if(p == null){
            root = r;
        }else if(p.getLeft() == c){
            p.setLeft(r);
        }else{
            p.setRight(r);
        }

        BRTNode rl = r.getLeft();
        c.setRight(rl);
        if(rl != null){
            rl.setParent(c);
        }
        r.setLeft(c);
        r.setParent(p);

    }

    /**
     * 右旋
     *
     * @param c 操作的节点
     */
    private void rotateRight(BRTNode c){
        if(c == null) return;

        BRTNode l = c.getLeft();
        if(l == null) return;

        BRTNode p = c.getParent();

        if(p == null){
            root = l;
        }else if(p.getLeft() == c){
            p.setLeft(l);
        }else{
            p.setRight(l);
        }

        BRTNode lr = l.getRight();
        c.setLeft(lr);
        if(lr != null){
            lr.setParent(c);
        }

        l.setRight(c);
        l.setParent(p);


    }

    /**
     * 根据被插入节点的父节点的情况，可以将"当节点z被着色为红色节点，并插入二叉树"划分为三种情况来处理。
     * ① 情况说明：被插入的节点是根节点。
     *    处理方法：直接把此节点涂为黑色。
     *
     * ② 情况说明：被插入的节点的父节点是黑色。
     *    处理方法：什么也不需要做。节点被插入后，仍然是红黑树。
     *
     * ③ 情况说明：被插入的节点的父节点是红色。
     *    处理方法：那么，该情况与红黑树的“特性(5)”相冲突。
     *    这种情况下，被插入节点是一定存在非空祖父节点的；进一步的讲，被插入节点也一定存在叔叔节点(即使叔叔节点为空，我们也视之为存在，空节点本身就是黑色节点)。
     *    理解这点之后，我们依据"叔叔节点的情况"，将这种情况进一步划分为3种情况(Case)。
     *    Case 1  叔叔节点是红色。
     *      (01) 将“父节点”设为黑色。
     * 		(02) 将“叔叔节点”设为黑色。
     * 		(03) 将“祖父节点”设为“红色”。
     * 		(04) 将“祖父节点”设为“当前节点”(红色节点)；即，之后继续对“当前节点”进行操作。
     *
     *    Case 2  叔叔节点是黑色，父节点是祖父节点的左孩子，
     *      (01) 如果当前节点是其父节点的右孩子，将“父节点”作为“新的当前节点”，进行左旋。
     * 	    (01) 将当前节点父节点设为黑色。
     * 	    (02) 将当前节点祖父节点红色。
     * 	    (04) 将“祖父节点”设为“当前节点”，进行右旋操作。
     *
     *    Case 3  叔叔节点是黑色，父节点是祖父节点的右孩子
     * 		(01) 当前节点是其父节点的左孩子，将“父节点”作为“新的当前节点”，进行右旋。
     *      (02) 将当前节点父节点设为黑色。
     * 		(03) 将当前节点祖父节点设为红色。
     * 	    (04) 将“祖父节点”设为“当前节点”，进行左旋操作。
     *
     * @param c 当前需要调整节点
     */
    private void fixAfterInsert(BRTNode c){
        if(c == null){
            return;
        }

        BRTNode p = c.getParent();
        if(p == null){//情况1
            c.setBlack(true);
            root = c;
            return;
        }

        if(p.isBlack()){//情况2
            return;
        }

        BRTNode pp = p.getParent();
        BRTNode u = (p == pp.getLeft()) ? pp.getRight() : pp.getLeft();

        if(! (u == null || u.isBlack())){      //情况3-1 叔叔节点是红色。
            p.setBlack(true);   //将“父节点”设为黑色。
            u.setBlack(true);   //将“叔叔节点”设为黑色。
            pp.setBlack(false); //将“祖父节点”设为“红色”。
            fixAfterInsert(pp); //将“祖父节点”设为“当前节点”(红色节点)；即，之后继续对“当前节点”进行操作。
        }else {
            if(p == pp.getLeft()){//情况3-2 叔叔节点是黑色。
                BRTNode x = c;
                if(c == p.getRight()) {
                    rotateLeft(p);
                    x = p;
                }
                x.getParent().setBlack(true);
                pp.setBlack(false);
                rotateRight(pp);
            }else{                //情况3-3 叔叔节点是黑色。
                BRTNode x = c;
                if(c == p.getLeft()) {
                    rotateRight(p);
                    x = p;
                }
                x.getParent().setBlack(true);
                pp.setBlack(false);
                rotateLeft(pp);
            }
        }
    }

    public void insert(int v){
        BRTNode p = getParent(root, v);
        BRTNode c = new BRTNode(v);
        c.setParent(p);
        if(p != null){
            if(v > p.getValue()){
                p.setRight(c);
            }else{
                p.setLeft(c);
            }
        }
        size++;
        fixAfterInsert(c);
        root.setBlack(true);
    }

    /**
     * ① 情况说明：x是“红+黑”节点。
     *    处理方法：直接把x设为黑色，结束。此时红黑树性质全部恢复。
     * ② 情况说明：x是“黑+黑”节点，且x是根。
     *    处理方法：什么都不做，结束。此时红黑树性质全部恢复。
     * ③ 情况说明：x是“黑+黑”节点，且x不是根。
     *    处理方法：这种情况又可以划分为4种子情况。这4种子情况如下表所示：
     *    Case 1	x是"黑+黑"节点，x的兄弟节点是红色。(此时x的父节点和x的兄弟节点的子节点都是黑节点)。
     *      (01) 将x的兄弟节点设为“黑色”。
     * 		(02) 将x的父节点设为“红色”。
     * 		(03) 对x的父节点进行左旋。
     * 		(04) 左旋后，重新设置x的兄弟节点。
     *    Case 2	x是“黑+黑”节点，x的兄弟节点是黑色，x的兄弟节点的两个孩子都是黑色。
     *      (01) 将x的兄弟节点设为“红色”。
     * 		(02) 设置“x的父节点”为“新的x节点”。
     *    Case 3	x是“黑+黑”节点，x的兄弟节点是黑色；x的兄弟节点的左孩子是红色，右孩子是黑色的。
     *      (01) 将x兄弟节点的左孩子设为“黑色”。
     * 		(02) 将x兄弟节点设为“红色”。
     * 		(03) 对x的兄弟节点进行右旋。
     * 		(04) 右旋后，重新设置x的兄弟节点。
     *    Case 4	x是“黑+黑”节点，x的兄弟节点是黑色；x的兄弟节点的右孩子是红色的，x的兄弟节点的左孩子任意颜色。
     *      (01) 将x父节点颜色 赋值给 x的兄弟节点。
     * 		(02) 将x父节点设为“黑色”。
     * 		(03) 将x兄弟节点的右子节设为“黑色”。
     * 		(04) 对x的父节点进行左旋。
     * 		(05) 设置“x”为“根节点”。
     *
     * @param c 当前需要调整节点
     */
    public void fixAfterDelete(BRTNode c){}

    private String travel(BRTNode node){
        if(node == null) return "";

        return "[" + travel(node.getLeft()) + "]" + "," +
                node + "," + "[" + travel(node.getRight()) + "]";
    }


    @Override
    public String toString(){
        return "Total size = " + size + "\t[" + travel(root) + "]";
    }


















    public static void main(String[] args){
        BlackRedTree brt = new BlackRedTree();
        brt.insert(4);
        brt.insert(3);
        brt.insert(2);
        brt.insert(1);
        System.out.println(brt);
    }



}
