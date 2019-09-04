# Queue

### 开篇问题

+ 线程池大小和处理任务速度不是线性相关，反而过多线程导致CPU频繁切换更，容易导致处理器性能下降。

### 队列操作特性

+ 先进先出，入队enqueue()，出队dequeue()，操作受限的线性表数据结构

### 队列应用

+ 循环队列
+ 阻塞队列
+ 并发队列
+ 循环并发队列
    + 高性能队列 Disruptor
    + Linux 环形缓存
+ 公平锁
    + ArrayBlockingQueue

### 顺序队列和链式队列

+ 以数组的顺序队列, 当队列满了，集中触发数据搬移
+ 入队，出队只涉及一个元素最优复杂为O(1)，当队列满时最差复杂度为O(n)，平均复杂度为O(n)，集中触发一次数据搬移则均摊复杂度为O(1)
+ 队空条件： head == tail
+ 队满条件： tail == n

```java
public class ArrayQueue {
    private int[] array;
    private int head;
    private int tail;
    private int cap;

    public ArrayQueue(int capacity) {
        array = new int[capacity];
        cap = capacity;
    }

    public boolean enqueue(int val) {
        if (head >= cap && tail == 0) {
            return false;
        }
        if (head >= cap && tail != 0) {
            for(int i = 0;i < cap - tail;i++) {
                array[i] = array[tail + i];
            }
            head = head - tail;
            tail = 0;

        }
        array[head] = val;
        head++;
        return true;
    }

    public int dequeue() {
        if (head > 0 && tail < head) {
            int ret = array[tail];
            tail++;
            return ret;
        }
        return -1;
    }

    public int[] getArray() {
        return array;
    }
}
```

+ 链式队列

```java
public class LinkedQueue {
    private Node head;
    private Node tail;
    private int cap;
    private Node temp;
    public int count;

    public LinkedQueue(int capacity) {
        cap = capacity;
    }

    public boolean enqueue(int val) {
        if (count > cap - 1) {
            return false;
        }
        if (head == null) {
           head = new Node(val, null);
           tail = head;
           count++;
           return true;
        }
        Node newNode = new Node(val, null);
        tail.setNext(newNode);
        tail = newNode;
        count++;
        return true;
    }

    public Node dequeue() {
        if (head == null) {
            return null;
        }
        temp = head;
        head = head.getNext();
        temp.setNext(null);
        count--;
        return temp;
    }

    public Node getHead() {
        return head;
    }
}
```

+ 栈式队列
    + 栈的顺序为后进先出，而队列的顺序为先进先出。使用两个栈实现队列，一个元素需要经过两个栈才能出队列，在经过第一个栈时元素顺序被反转，经过第二个栈时再次被反转，此时就是先进先出顺序。

```java
public class StackQueue {
    private int capacity;
    private LinkedStack stack1;
    private LinkedStack stack2;
    private int count;

    public StackQueue(int capacity) {
        this.capacity = capacity;
        stack1 = new LinkedStack();
        stack2 = new LinkedStack();
    }

    public boolean enqueue(int val) {
        if (count > capacity) {
            return false;
        }
        stack1.push(val);
        count++;
        return true;
    }

    public int dequeue() {
        if (stack2.isEmpty()) {
            while(!stack1.isEmpty()) {
                stack2.push(stack1.pop().getVal());
            }
        }
        Node node = stack2.pop();
        int ret = -1;
        if (node != null) {
            count--;
            ret = node.getVal();
        }
        return ret;
    }
}
```

### 循环队列

+ 如图所示，增加一个元素后tail会向后+1
+ 队空判断条件：head == tail
+ 队满判断条件：(tail + 1)%n == head

![09_1](https://github.com/kunSong/Note/blob/master/ARTS/Algorithms/res/09_1.jpg)

```java
public class CircleQueue {
    private int capacity;
    private int[] array;
    private int head;
    private int tail;

    public CircleQueue(int capacity) {
        this.capacity = capacity;
        array = new int[capacity];
    }

    public boolean enqueue(int val) {
        if ((tail + 1)%capacity == head) {
            return false;
        }
        array[tail] = val;
        tail = (tail + 1)%capacity;
        return true;
    }

    public int dequeue() {
        if (head == tail) {
            return -1;
        }
        int ret = array[head];
        tail = (tail + 1)%capacity;
        return ret;
    }
}
```

### 阻塞队列

+ 生产者消费者模型
    + volatile isRunning
        + cpu 高速缓存 主存
        + 原子性： 不支持 synchronized Lock AtomInteger 能保证原子性
        + 可见性： 使缓存行失效，去读取主存中的最新值，synchronized Lock 也可以保证可见性
        + 有序性： 带有volatile关键字，在汇编中会有个lock，会有个内存屏障，保证之前语句和后续语句顺序有序
    + wait / notify : lq.wait() / lq.notify()
    + 使用线程池 produce / consume 分别继承 Thread

+ Java一般队列方法，推荐使用 offer / poll / peek
    + add(E e):将元素e插入到队列末尾，如果插入成功，则返回true；如果插入失败（即队列已满），则会抛出异常
    + remove()：移除队首元素，若移除成功，则返回true；如果移除失败（队列为空），则会抛出异常
    + offer(E e)：将元素e插入到队列末尾，如果插入成功，则返回true；如果插入失败（即队列已满），则返回false
    + poll()：移除并获取队首元素，若成功，则返回队首元素；否则返回null
    + peek()：获取队首元素，若成功，则返回队首元素；否则返回null

+ Java阻塞队列
    + ArrayBlockingQueue / LinkedBlockingQueue
    + PriorityBlockingQueue 元素排优先级，然后再从头取，从尾插
    + DelayQueue：基于PriorityQueue，一种延时阻塞队列，DelayQueue中的元素只有当其指定的延迟时间到了，才能够从队列中获取到该元素。DelayQueue也是一个无界队列，因此往队列中插入数据的操作（生产者）永远不会被阻塞，而只有获取数据的操作（消费者）才会被阻塞。
    + put方法用来向队尾存入元素，如果队列满，则等待
    + take方法用来从队首取元素，如果队列为空，则等待
    + offer方法用来向队尾存入元素，如果队列满，则等待一定的时间，当时间期限达到时，如果还没有插入成功，则返回false；否则返回true；
    + poll方法用来从队首取元素，如果队列空，则等待一定的时间，当时间期限达到时，如果取到，则返回null；否则返回取得的元素；
    

[Java并发编程：volatile关键字解析](https://www.cnblogs.com/dolphin0520/p/3932906.html)

[我没有三颗心脏](https://www.cnblogs.com/wmyskxz/p/9538177.html)

[一篇文章，让你彻底弄懂生产者--消费者问题](https://www.jianshu.com/p/e29632593057)

### 并发队列

+ 基于数组的循环队列，利用CAS原子操作，可以实现非常高效地并发队列（循环队列比链式队列应用广泛的原因）

+ 线程安全的队列我们叫作并发队列。最简单直接的实现方式是直接在 enqueue()、dequeue() 方法上加锁，但是锁粒度大并发度会比较低，同一时刻仅允许一个存或者取操作。实际上，基于数组的循环队列，利用 CAS 原子操作，可以实现非常高效的并发队列。这也是循环队列比链式队列应用更加广泛的原因。在实战篇讲 Disruptor 的时候，我会再详细讲并发队列的应用

### 开篇问题解答

+ 第一种是非阻塞的处理方式，直接拒绝任务请求
+ 另一种是阻塞的处理方式，将请求排队，等到有空闲线程时，取出排队的请求继续处理
    + 链式实现队列：可以实现一个支持无限排队的无界队列，但是可能会导致过多请求排队等待，请求处理响应时间过长。针对响应时间敏感的系统，不合适
    + 数组实现队列：队列大小有限，超过队列大小，会被拒绝，响应速度会更快，适合敏感系统，但是设置队列大小对利用系统资源和性能有很大讲究
