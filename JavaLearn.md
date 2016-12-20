## 抽象类和接口实现问题

+ 在基类中被定义了static的字段不会被复制到子类，如果是public可以以基类多态的形式访问到

```java
interface A {
   public void show();
}
//抽象类实现接口A，但可以不实现show方法，由子类再去实现 
public abstract class A implements A {
} 

interface A {
    public int sizeA();
}
public abstract class B implements A {
    public abstract int sizeB();
}
public class Main extends B {
    @Override
    public int sizeA() {
    // TODO Auto-generated method stub
        return 0;
    }
    @Override
    public int sizeB() {
    // TODO Auto-generated method stub
        return 0;
    }
}

SubMap1<String, String> extends Map<String, String>
SumMap2<String, String> extends Map<String, String> 
// 那么在声明一个Map<String, String> map，即可以进行如下操作
map=new SubMap1<String, String>();
map=new SubMap2<String, String>()；
// 而直接声明实现类则只能进行如下操作：
SubMap1<String, String> subMap1=new SubMap1<String, String>();
SumMap2<String, String> subMap2=new SumMap2<String, String>();
// 却不能有
SubMap1<String, String> subMap1=new SubMap2<String, String>();
SumMap2<String, String> subMap2=new SumMap1<String, String>();
// 如果你的子类中有额外添加的方法就要用第二种，因为父类（或接口）中没有这种方法
```

## 为什么要改写Hashcode方法？

*programmers should take note that any class that overrides the Object.equals method must also override the Object.hashCode method in order to satisfy the general contract for the Object.hashCodemethod.*
改写了equals方法的类需要同时改写hashcode方法， 否则会违反object.hashcode的通用约定。同时该类就不能与散列值相关的集合类Hashmap，Hashset，Hashtable正常地结合运行。

## hashcode方法是如何在Hashmap中工作的？

把键值对put进map中，先计算key值hashcode，然后于容量取余，得到的值就是在map中的位置。get同理，直接去到所对应的位置。

## Hashmap查找的时候不能严谨地说“时间耗费是固定的”而是“与容量与容量无关”

两个对象有相同的hashcode，或是他们的hashcode之差是容量的整数倍，他们取余值会是相同的。Hashmap会在同一个位置形成一个链表。next会指向下一个元素，如果没有则为null。这样遍历的效果仍然耗费时间。所以equals不同，也要保证hasdcode不同。

## Hashmap扩容对hashcode的影响?

...

## Eclipse short-cut

`Shift+Ctrl+T` 快速打开类
`Ctrl+O` 当前类属性和方法
`Shift+Ctrl+N` 创建类包等

## 幂函数a的b次方#

`Math.pow(a,b);`

## 在终端中编译和运行Java代码

删除package Hello;包名即可。因为终端中没有此目录结构。

## Synchronized

http://www.cnblogs.com/devinzhang/archive/2011/12/14/2287675.html Java核心卷I，P655

## 静态代码

+ 静态代码块主要用于类的初始化。它只执行一次，并在main函数之前执行。
+ 静态代码块的特点主要有：
+ 静态代码块会在类被加载时自动执行。
+ 静态代码块只能定义在类里面，不能定义在方法里面。
+ 静态代码块里的变量都是局部变量，只在块内有效。一个类中可以定义多个静态代码块，按顺序执行。
+ 静态代码块只能访问类的静态成员，而不允许访问实例成员。

```java
static {  
//静态代码块中的语句  
}
```

## String

+ String是个final类，所以String是不可改变的，Immutable
+ String str1 = "abc"; //是在编译时就确定需要现在堆中创建对象并加入常量表中也就是字符串池，里面是引用。
+ String str2 = new String("abc"); //首先有个字符串在字符串池中，然后是在堆中创建了 new char[] 来拷贝对象。

```java
public String(String original) {
        this.value = original.value;
        this.hash = original.hash;
}
```

## StringTokenize

+ 将输入字符串按规定分隔符进行分离输出。
+ 默认分隔符为`\t\n\r\f`，在构造方法中可以自定义分隔符并控制其输出与否。
+ this.hasMoreTokens() //是否还有后续字符
+ this.nextTokens() //按分隔符输出
+ this.countTokens() //统计除分隔符以外的字符

## InputStream

+ InputStream是字节流的抽象父类实现closable接口，需要实现close()方法。
+ 由于InputStream是抽象类所以不能直接使用new关键字进行实例化。
+ 实例化InputStram:
+ 系统调用URL类中的setURLStreamHandlerFactory方法来设置URLStreamHandlerFactory对象，
+ URLStreamHandlerFactory是接口类，实现createURLStreamHandler(String protocol)，
+ URLStreamHandlerFactory中根据protocol来创建URLStreamHandler对象，
+ URLStreamHandler是抽象类，改写openConnection(URL u)获取URLConnection，
+ URLConnection是抽象类，改写getInputStream()获得InputStream实例。
+ InputStream is = new URL("path").openStream();
+ public static void setURLStreamHandlerFactory(URLStreamHandlerFactory fac)每个Java虚拟机这个方法只会执行一次
+ FilterInputstream 是Buffered和DataInputStream的父类，装饰者模式
+ BufferedInputStream 带缓冲区, 请看Instapaper源码详解
+ DataInputStream 从底层数据流中读取Java数据类型

## 序列化

+ 面向实现Serializable接口的对象，可以转换成一系列字节，并可在以后恢复成原来的样子。实现“有限持久化”。
+ 实现Serializable接口会自动序列化。但是在main中需要实现以下代码。并且恢复对象不会调用任何构建器，完全是从InputStream中恢复。
+ 如果对某些敏感字段不想被序列化，可以在前面加上transient关键字。
+ 在Serializable接口中增加可以替代Externalizable接口，但是他们不是接口的一部分因为是private，

```java
private void writeObject(ObjectOutputStream stream) throws IOException{
    stream.defaultWriteObject();    //对普通字段会自动进行序列化
    stream.writeObject(b);    //对于有transient的方法需要的手动进行序列化否则不会自动操作
}
private void readObject(ObjectInputStream stream) throws IOException{
    stream.defaultReadObject();
    b = (String) stream.readObject();
}
```
+ Externalizable接口可以控制具体过程和字段。需要实现以下方法，并且需要调用构造方法和初始化字段与Serializable不同。并对每个字段进行写入和读取。这里要注意对读取的字段进行NullException的问题，因为有可能没有初始化。

```java
public void writeExternal(ObjectOutput out){
    out.writeObject(s);
    out.writeInt(i);
}
public void readExternal(ObjectInput in){
    s = (String) in.readObject();
    i = in.readInt();
}
```
+ Static字段的序列化需要实现方法

```java
serializeStaticState(ObjectOutputStream os);
deserializeStaticState(ObjectInputStream os);
```

+ 最基础的是FileOutputStream, ByteArrayOutputStream, PipedOutputStream, 通过ObjectOutputStream, DataOutputStream, BufferedOutputStream进行装饰

```java
Object obj1 = new Object();
FileOutputStream fos = new FileOutputStream("path");
ByteArrayOutputStream buf = new ByteArrayOutputStream(); //如果不写，默认使用32位的Byte[32]
ObjectOutputStream out = new ObjectOutputStream(fos);
ObjectOutputStream out = new ObjectOutputStream(buf);
out.writeObject(obj1);
FileInputStream fis = new FileInputStream("path");
ByteArrayInputStream bis = new ByteArrayInputStream(buf.toByteArray()); //需要创建一个Byte[]
ObjectInputStream in = new ObjectInputStream(fis);
ObjectInputStream in = new ObjectInputStream(bis);
Object obj2 = (Object)in.readObject();
```

## Comparable & Comparator

+ 当实现了Comparable的类时，可以实现自然排序，通过Collections.sort()和Arrays.sort()方法。
+ 需要实现compareTo(Object o)方法，最好能实现(o1.compareTo(o2) == 0) == o1.equals(o2)
+ 但是设计时可能没有考虑到类实现Comparable接口，所以可以创建新类实现Comparator接口添加所需比较的对象类型。

## StringBuffer & StringBuilder

StringBuilder 是在Java 1.5以后引用，区别在于StringBuffer多一个Synchronized关键字，导致在单线程中性能不及StringBuilder。但是StringBuilder由于没有Synchronized关键字，所以是线程不安全的。

## Order of initialization

1. static字段和static代码块会首先初始化，并且无论有多少对象创建，都只会执行一次。
2. 分配创建对象所需要的在堆上的内存。
3. 初始化字段和普通代码块，普通代码块主要用来创建内部类对象，当然可能还有其他用途。
4. 进行构造方法的执行，但是如果是从父类继承而来，需要先创建父类对象然后再执行子类构造方法。

## Concurrency

### Interface

+ Runnable: 将需要在线程中执行的任务放在run方法中。匿名内部类可以new Runnable() {};
+ Callable: 与Runnable类似，call方法可以返回具体的类型以及抛出checkedException。
+ Future: 可异步计算并可从get方法得到结果，同时可以cancellable能力的。
+ RunnableFuture: 继承自Runnable和Future。
+ Exector: 对Runnable对象的execute
+ ThreadFactory: 创建新的线程接口
+ ExecutorService: 继承自Executor，

### Class

+ FutureTask: 是RunableFuture的实现类，构造方法可以Runnable或Callable，但最终使用Callable。调用run方法进行对Callable.call()调用，然后会set()方法把结果给到outcome，最后调用done()。如果想要get获取outcome，可能会被阻塞，要等completed后才会获取。

+ Exectors: 是一个工厂和工具方法的类，主要是来创建线程池并返回ExecutorService对象，同时他也可以包装Runnable变成Callable对象。

+ AbstractExecutorService: 是ExectorService的实现类。

1. ThreadPoolExecutor
2. ScheduledThreadPoolExecutor 
3. newCachedThreadPool
4. newFixedThreadPool
5. newSingleThreadExecutor
6. setCorePoolSize
7. setMaximumPoolSize
8. BlockingQueue
9. SynchronousQueue
10. LinkedBlockingQueue
11. ArrayBlockingQueue

+ worker: 检查是否可以创建线程

+ DeamonThread
DeamonThread守护进程，就是运行在后台的服务线程，不管线程有没有关闭，程序都可以结束。
通过setDeamon来把线程设为Deamon，在start方法前设置。
通过DeamonThread创建的线程都是守护线程。

+ Coding ariations
Thread没必要使用Named inner class，只是用他的cap，所以匿名内部类就可以。

+ Creating responsive user interfaces
不要阻塞线程，将无限循环的内容放在线程run方法中。

```java
public class ResponsiveUI {
  private volatile double d = 1;
  
  public ResponsiveUI() {
    while(d > 0)
      d = d + (Math.PI + Math.E) / d;
    System.out.println("Fuck"); //Never get here
  } 
}
```
+ `Thread.UncaughtExceptionHandler`通过实现接口对线程意外结束而造成的，Runnable中run方法中的UncatchedException进行处理。

## 小技巧

```java
String[] Data = {"A", "B", "C", "D", "E"};
for(int i=0;i<100;i++){
    System.out.println(Data[i % Data.lenght]);
}
```

## ...
+ ...
...

