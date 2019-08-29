# Stack

### 栈结构

+ 后进者先出，先进者后出
+ 操作受限制的线性表，只有一端操作数据

### 数组实现顺序栈

```java
public class ArrayStack {
    private String[] items;
    private int count;
    private int n;

    // init string array, apply space in n size
    public ArrayStack(int n) {
        this.items = new String[n];
        this.n = n;
        this.count = 0;
    }

    // push in stack
    public boolean push(String item) {
        // if no space, return false, fail to push
        if (count == n) return false;
        // put item at n position, and count + 1 
        item[count] = item;
        ++count;
        return true;
    }

    // pop stack
    public String pop() {
        // if stack is empty, return null
        if (count == 0) return null;
        // return element in array, and count - 1
        String tmp = items[count - 1];
        --count;
        return tmp; 
    }
}
```

+ 因为存储n大小数组，空间复杂度为O(n)
+ 每次操作只涉及一个元素，时间复杂度为O(1)

### Linked Stack

```java
package org.songkun.test;
 
public class LinkedStack {
    private Node head;
    private Node temp;
 
    public LinkedStack() {
    }
 
    public Node pop() {
        if (head == null) {
            return null;
        }
        temp = head;
        head = head.getNext();
        temp.setNext(null);
        return temp;
    }
 
    public void push(int val) {
        if (head == null) {
            head = new Node(val, null);
        }
        temp = head;
        head = new Node(val, temp);
    }
}
```

+ 因为存储n大小数组，空间复杂度为O(n)
+ 每次操作只涉及一个元素，时间复杂度为O(1)

### 支持动态扩容的顺序栈

+ 平时用的不多，主要复杂度分析
+ 当栈大小不足，会分配更大的空间，然后把之前的数据搬移过来
+ 最优复杂度为O(1)，最坏复杂度为O(n)，因为扩容只是一次，并不是每次都需要遍历，所以摊还分析法，摊还复杂度为O(1)

### 栈在函数调用中的应用

+ 函数调用栈
+ 系统为每个线程分配一块独立的内存空间，组织成`栈`这种结构，用来存储函数调用时的`临时变量`，就会将临时变量作为一个`栈帧入栈`，当被调用函数执行完成，返回之后，将这个函数对应的`栈帧出栈`

```c
int main() {
    int a = 1;
    int ret = 0;
    int res = 0;
    ret = add(3, 5);
    res = a + ret;
    printf("%d", res);
    return 0;
}

int add (int x, int y) {
    int sum = 0;
    sum = x + y;
    return sum;
}
```

![08_1](https://github.com/kunSong/Note/blob/master/ARTS/Algorithms/res/08_1.jpg)

### 栈在表达式求值中的应用

+ 编译器就是通过两个栈来实现的。其中一个保存操作数的栈，另一个是保存运算符的栈。我们从左向右遍历表达式，当遇到数字，我们就直接压入操作数栈；当遇到运算符，就与运算符栈的栈顶元素进行比较。如果比运算符栈顶元素的优先级高，就将当前运算符压入栈；如果比运算符栈顶元素的优先级低或者相同，从运算符栈中取栈顶运算符，从操作数栈的栈顶取 2 个操作数，然后进行计算，再把计算完的结果压入操作数栈，继续比较

![08_2](https://github.com/kunSong/Note/blob/master/ARTS/Algorithms/res/08_2.jpg)

### 栈在括号匹配中的应用

+ 当扫描到左括号时，则将其压入栈中；当扫描到右括号时，从栈顶取出一个左括号。当所有的括号都扫描完成之后，如果栈为空，则说明字符串为合法格式；否则，说明有未匹配的左括号，为非法格式

### Chome 浏览器问题

![08_3](https://github.com/kunSong/Note/blob/master/ARTS/Algorithms/res/08_3.jpg)

### 思考

+ 我们在讲栈的应用时，讲到用函数调用栈来保存临时变量，为什么函数调用要用“栈”来保存临时变量呢？用其他数据结构不行吗？
    + 其实，我们不一定非要用栈来保存临时变量，只不过如果这个函数调用符合后进先出的特性，用栈这种数据结构来实现，是最顺理成章的选择

+ 我们都知道，JVM 内存管理中有个“堆栈”的概念。栈内存用来存储局部变量和方法调用，堆内存用来存储 Java 中的对象。那 JVM 里面的“栈”跟我们这里说的“栈”是不是一回事呢？如果不是，那它为什么又叫作“栈”呢？
    + 内存中的堆栈和数据结构堆栈不是一个概念。内存中的堆栈是真实存在的物理区，数据结构中的堆栈是抽象的数据结构。内存空间在逻辑上分为三部分：代码区、静态数据区和动态数据区。动态数据区又分为栈区和堆区。
        + 代码区：存储方法体的二进制代码。高级调度（作业调度）、中级调度（内存调度）、低级调度（进程调度）控制代码区执行代码的切换。
        + 静态数据区：存储全局变量、静态变量、常量，常量包括 final 修饰的常量和 String 常量。系统自动分配和回收。
        + 栈区：存储方法的形参、局部变量、返回值。由系统自动分配和回收。
        + 堆区：new 操作符创建的一个对象的引用地址存储在栈区，指向该对象存储在堆区中的真实数据。

+ Android Activity栈
    + Activities in the stack are never rearranged, only pushed and popped from the stack—pushed onto the stack when started by the current activity and popped off when the user leaves it using the Back button
    + Multiple tasks : Press home, and task A will turn to background. Launch appB, and task B will be created and turn to foreground. If press home again, task A will turn to foreground, B will turn to background.
    + running many background tasks at the same time, the system might begin destroying background activities in order to recover memory
    + launch attriubute can be defined in intent and manifest
    + launch mode
        + standard(default) : The activity can be instantiated multiple times, each instance can belong to different tasks, and one task can have multiple instances
        + singleTop : The activity can be instantiated multiple times, each instance can belong to different tasks, and one task can have multiple instances (but the activity when at top of stack, will be invoked onNewIntent and not will be instantiated). As such, if A-B-C-D, D is top and standard, A-B-C-D-D; if A-B-C-D, D is top and singleTop, A-B-C-D. note : can not press back return to the state before onNewIntent
        + singleTask : 如果没有则会创建一个新的task把这个activity作为根。如果在一个独立的task中已经有这个activity实例了，系统会直接调用这个实例的onNewIntent方法而不是创建新对象
        >The system creates a new task and instantiates the activity at the root of the new task. However, if an instance of the activity already exists in a separate task, the system routes the intent to the existing instance through a call to its onNewIntent() method, rather than creating a new instance. Only one instance of the activity can exist at a time.
        + singleInstance : Same as "singleTask", except that the system doesn't launch any other activities into the task holding the instance. The activity is always the single and only member of its task; any activities started by this one open in a separate task.
    + Intent flags
        + FLAG_ACTIVITY_NEW_TASK : similar to singleTask
        + FLAG_ACTIVITY_CLEAR_TOP : similar to singleTop
        + FLAG_ACTIVITY_CLEAR_TOP : 如果要启动的activity已经在现有的task中启动了，那么这个activity之前返回栈上的其他的activity都会被清空，然后把这activity通过调用onNewIntent方法重新处于onResume状态。一般要结合FLAG_ACTIVITY_NEW_TASK使用
        >If the activity being started is already running in the current task, then instead of launching a new instance of that activity, all of the other activities on top of it are destroyed and this intent is delivered to the resumed instance of the activity (now on top), through onNewIntent()).There is no value for the launchMode attribute that produces this behavior.FLAG_ACTIVITY_CLEAR_TOP is most often used in conjunction with FLAG_ACTIVITY_NEW_TASK. When used together, these flags are a way of locating an existing activity in another task and putting it in a position where it can respond to the intent.
    + Handling affinities
        + 如果有相同的affinities，activity会在同一个task中，会在同一个返回栈上。如果affinites不一样并且使用了FLAG_ACTIVITY_NEW_TASK，则会新创建一个task。比如notification manager一般都用新task来启动activity，会用上FLAG_ACTIVITY_NEW_TASK。如果你也用，确保有返回启动activity的那个back路劲，比如有launcher icon就是有LAUNCHER属性
        + allowTaskReparenting
    + Clearing the back stack
        + 过了很久没用了，除了root activity会存着状态，其他activity都会被destory掉
    + Starting a task
        + "singleTask" and "singleInstance" 如果是用这两个mode启动的activity在一个新task中，如果按了home键后，就看不到了如果没有LAUNCHER属性，就没有返回那个activity了。

[一次关于SingleTask的填坑](https://blog.csdn.net/zhp694125196/article/details/74060856)

[Activity的加载模式，以及singleTask的坑](https://www.jianshu.com/p/841cfe3fcbc6)

[Android Activity tasks-and-back-stack](https://developer.android.google.cn/guide/components/activities/tasks-and-back-stack)
