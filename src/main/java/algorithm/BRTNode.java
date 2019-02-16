package algorithm;

import java.util.Objects;

public class BRTNode {
    private int value;

    private BRTNode parent;
    private BRTNode left;
    private BRTNode right;
    private boolean isBlack;

    public BRTNode(){
        super();
    }

    BRTNode(int v){
        this();
        value = v;
    }

    int getValue() {
        return value;
    }

    void setValue(int value) {
        this.value = value;
    }

    BRTNode getParent() {
        return parent;
    }

    void setParent(BRTNode parent) {
        this.parent = parent;
    }

    BRTNode getLeft() {
        return left;
    }

    void setLeft(BRTNode left) {
        this.left = left;
    }

    BRTNode getRight() {
        return right;
    }

    void setRight(BRTNode right) {
        this.right = right;
    }

    boolean isBlack() {
        return isBlack;
    }

    void setBlack(boolean black) {
        isBlack = black;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        BRTNode brtNode = (BRTNode) o;
        return value == brtNode.value &&
                isBlack == brtNode.isBlack &&
                Objects.equals(parent, brtNode.parent) &&
                Objects.equals(left, brtNode.left) &&
                Objects.equals(right, brtNode.right);
    }

    @Override
    public int hashCode() {
        return Objects.hash(value, parent, left, right, isBlack);
    }

    @Override
    public String toString() {
        return "{" + value + (isBlack ? "B" : "R") + "}";
    }
}
