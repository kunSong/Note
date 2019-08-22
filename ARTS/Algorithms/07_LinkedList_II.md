# Linked List


## Exercise

### 单向链表反转 （递归）

+ 方法一 三个指针遍历反转
	+ newHead指针作为新链表的头节点
	+ p指针作为保存head指针指向的下一个节点
	+ head指针指向需要反转插入新链表的节点
+ 方法二 使用递归
	+ 终止条件是head.next() == null
	+ 递归到最后一个节点，设置最后一个节点的下一个节点是上一个节点，调整上一个节点的next为null

### 检查链表中是否有环 (双指针)

+ 利用快慢指针，如果有环，则在某一个特定节点，快慢指针会相同，否则则无环，循环终止条件是两个指针不为NULL

### 两个有序链表合并 （递归）

+ 利用递归比较最后一个元素大小，如果有一个为null则返回另一个链表中的元素，依次往前被链接上

### 删除倒数第n个节点 (双指针)

+ 一个快指针从头部先移动到n的位置，然后一个慢指针从头部开始和快指针一起移动，直到快指针到末尾，那此时快指针就指向了倒数第n个节点

### 求链表的中间节点 (双指针)

+ 利用双指针，快指针一次遍历2个节点，慢指针一次遍历1个节点，那快指针到达尾部，慢指针正好在中间节点
+ 注意这里 while(fast.getNext() != null && fast.getNext().getNext() != null) 

### 链表求解回文字符串问题

+ 回文字符串就是正读，反读都是一样的。
	+ 利用数组实现，双指针，数组头指针，数组尾指针进行比较
	+ 利用链表实现，切半（寻找中间节点），后半段反转（单向链表反转），比较

### 创建单链表

```java
	public void add(int val) {
        if (head == null) {
            head = new Node(val, null);
            return;
        }
        if (tail == null) {
            tail = new Node(val, null);
            head.setNext(tail);
            return;
        }
        Node node = new Node(val, null);
        tail.setNext(node);
        tail = node;
    }
```

### 创建循环链表

```java
	public void add(int val) {
        if (head == null) {
            head = new Node(val, null);
            return;
        }
        if (tail == null) {
            tail = new Node(val, head);
            head.setNext(tail);
            return;
        }
        Node node = new Node(val, head);
        tail.setNext(node);
        tail = node;
    }
```

### 创建有序单向链表

```java
	public void add(int val) {
        if (head == null) {
            head = new Node(val, null);
            return;
        }
        temp = head;
        while(temp != null) {
            if (val < temp.getVal()) {
                if (pre == null) {
                    Node node = new Node(val, head);
                    head = node;
                    return;
                } else {
                    Node node = new Node(val, temp);
                    pre.setNext(node);
                    return;
                }
            } else {
                if (temp.getNext() == null) {
                    Node node = new Node(val, null);
                    temp.setNext(node);
                    return;
                }
            }
            pre = temp;
            temp = temp.getNext();
        }

    }
```


[cyc链表代码](https://github.com/CyC2018/CS-Notes/blob/master/notes/Leetcode%20%E9%A2%98%E8%A7%A3%20-%20%E9%93%BE%E8%A1%A8.md)