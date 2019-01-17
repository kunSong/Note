## Collections
+ compactly
+ tedium

### Vocabulary

Scala has a rich collections library. You've already seen the most commonly used collection types in previous chapters—arrays, lists, sets, and maps—but there is more to the story. In this chapter, we'll start by giving an overview of how these types relate to each other in the collections inheritance hierarchy. We'll also briefly describe these and various other collection types that you may occasionally want to use, including discussing their tradeoffs of speed, space, and requirements on input data.

### 17.1 Overview of the library

The Scala collections library involves many classes and traits. As a result, it can be challenging to get a big picture of the library by browsing the Scaladoc documentation. In Figure 17.1, we show just the traits you need to know about to understand the big picture.

+ scala的collections库涉及到很多类和traits。结果如下图17.1。

The main trait is Iterable, which is the supertrait of both mutable and immutable variations of sequences (Seqs), sets, and maps. Sequences are ordered collections, such as arrays and lists. Sets contain at most one of each object, as determined by the == method. Maps contain a collection of keys mapped to values.

+ 主要的trait是Iterable，他是mutable和immutable的sequences，sets和maps的父trait。Sequences是有序集合，类似的有arrays和lists。Sets中每个对象只有一个，通过`==`来判断。Maps每次添加一个键值对。

Iterable is so named because it represents collection objects that can produce an Iterator via a method named elements:

+ Iterable通过调用elements方法返回一个Iterator对象来展现collection对象。

```
  def elements: Iterator[A]
```

The A in this example is the type parameter to Iterator, which indicates the type of element objects contained in the collection. The Iterator returned by elements is parameterized by the same type. An Iterable[Int]'s elements method, for example, will produce an Iterator[Int].

+ A代表的是Iterator的类型参数，他是表示集合中元素对象的类型的。返回一个Iterator[A]，例如Iterator[Int]。

Iterable provides dozens of useful concrete methods, all implemented in terms of the Iterator returned by elements, which is the sole abstract method in trait Iterable. Among the methods defined in Iterable are many higher-order methods, most of which you've already seen in previous chapters. Some examples are map, flatMap, filter, exists, and find. These higher-order methods provide concise ways to iterate through collections for specific purposes, such as to transform each element and produce a new collection (the map method) or find the first occurrence of an element given a predicate (the find method).

+ Iterable提供了很多有用的具体的方法，以element返回的Iterator形式实现的，他们每个都是在trait Iterable中的抽象方法。这些方法中许多都是high-order方法，比如map，flatMap，filter，exists和find。这些方法都是为了特殊目的简洁的遍历了整个集合，比如map方法改造元素产生新的集合，find方法通过提供的预判找到第一个符合要求的元素。

![Figure17.1](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure17.1.jpg)

Figure 17.1 - Class hierarchy for Scala collections.

An Iterator has many of the same methods as Iterable, including the higher-order ones, but does not belong to the same hierarchy. As shown in Figure 17.2, trait Iterator extends AnyRef. The difference between Iterable and Iterator is that trait Iterable represents types that can be iterated over (i.e., collection types), whereas trait Iterator is the mechanism used to perform an iteration. Although an Iterable can be iterated over multiple times, an Iterator can be used just once. Once you've iterated through a collection with an Iterator, you can't reuse it. If you need to iterate through the same collection again, you'll need to call elements on that collection to obtain a new Iterator.

+ Iterator许多和Iterable一样的方法，包括high-order方法，但不属于相同的继承关系。trait Iterator是继承自AnyRef。Iterable和Iterator的不同之处在于，Iterable是用来表示可以被迭代的类型，比如集合。而trait Iterator是一种机制用来完成这个迭代。虽然Iterable(maps)可以被迭代多次，但是Iterator只能被用一次。你用Iterator来遍历整个集合，你就不能重用他了。如果你想再迭代一遍集合就需要重新调用elements方法来获得新的Iterator。

The many concrete methods provided by Iterator are implemented in terms of two abstract methods, next and hasNext:

+ Iterator提供的许多具体的现都是根据这两个抽象方法hasNext和next。

```
  def hasNext: Boolean
  def next: A
```

The hasNext method indicates whether any elements remain in the iteration. The next method returns the next element.

+ hasNext表示有没有下一个，next表示先一个迭代项。

Although most of the Iterable implementations you are likely to encounter will represent collections of a finite size, Iterable can also be used to represent infinite collections. The Iterator returned from an infinite collection could, for example, calculate and return the next digit of π each time its next method was invoked.

![Figure17.2](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure17.2.jpg)

Figure 17.2 - Class hierarchy for Iterator.

### 17.2 Sequences

Sequences, classes that inherit from trait Seq, let you work with groups of data lined up in order. Because the elements are ordered, you can ask for the first element, second element, 103rd element, and so on. In this section, we'll give you a quick tour of the most important sequences.

+ Sequences，序列是继承自trait Seq，是一串有序连续的成线的序列。因为元素是有序的，你可以访问第一个，第二个，第103个元素。这节会快速看下几个重要的sequences。

**Lists**

Perhaps the most important sequence type to know about is class List, the immutable linked-list described in detail in the previous chapter. Lists support fast addition and removal of items to the beginning of the list, but they do not provide fast access to arbitrary indexes because the implementation must iterate through the list linearly.

+ 上一章讲了具体的linked-list。Lists支持在list开头快速插入和删除，但是不能在任意位置进行访问因为他的实现就是要线性遍历整个list。

This combination of features might sound odd, but they hit a sweet spot that works well for many algorithms. The fast addition and removal of initial elements means that pattern matching works well, as described in Chapter 15. The immutability of lists helps you develop correct, efficient algorithms because you never need to make copies of a list. Here's a short example showing how to initialize a list and access its head and tail:

+ 由于初始化元素的快速添加和删除能使pattern matching工作出色。immutability能帮助开发准确，高效的算法，因为我们不需要去做这些list的拷贝。

```
  scala> val colors = List("red", "blue", "green")
  colors: List[java.lang.String] = List(red, blue, green)
  
  scala> colors.head
  res0: java.lang.String = red
  
  scala> colors.tail
  res1: List[java.lang.String] = List(blue, green)
```

For an introduction to lists see Step 8 in Chapter 3, and for the details on using lists, see Chapter 16. Lists will also be discussed in Chapter 22, which provides insight into how lists are implemented in Scala.

**Arrays**

Arrays allow you to hold a sequence of elements and efficiently access an element at an arbitrary position, both to get or update the element, with a zero-based index. Here's how you create an array whose size you know, but for which you don't yet know the element values:

+ Arrays允许你持有一系列的元素并且可以在任意位置高效地访问元素，包括得到和更新元素，是以0开头的index。下面创建一个知道大小的Array。

```
  scala> val fiveInts = new Array[Int](5)
  fiveInts: Array[Int] = Array(0, 0, 0, 0, 0)
```

Here's how you initialize an array when you do know the element values:

```
  scala> val fiveToOne = Array(5, 4, 3, 2, 1)
  fiveToOne: Array[Int] = Array(5, 4, 3, 2, 1)
```

As mentioned previously, arrays are accessed in Scala by placing an index in parentheses, not square brackets as in Java. Here's an example of both accessing and updating an array element:

+ 之前提到scala通过小括号里放index来访问元素，而不是Java的方括号。

```
  scala> fiveInts(0) = fiveToOne(4)
  
  scala> fiveInts
  res1: Array[Int] = Array(1, 0, 0, 0, 0)
```

Scala arrays are represented in the same way as Java arrays. So, you can seamlessly use existing Java methods that return arrays.[1]

+ scala和java表达arrays是相同的。

You have seen arrays in action many times in previous chapters. The basics are in Step 7 in Chapter 3. Several examples of iterating through the elements of an array with a for expression are shown in Section 7.3. Arrays also figure prominently in the two-dimensional layout library of Chapter 10.

**List buffers**

Class List provides fast access to the head of the list, but not the end. Thus, when you need to build a list by appending to the end, you should consider building the list backwards by prepending elements to the front, then when you're done, calling reverse to get the elements in the order you need.

+ list可以快速的在头部添加元素，但是如果你想要在尾部append元素，那你会创建一个从后往前的list并在开头添加元素，完成后调用reverse来得到你想要的序列顺序。

Another alternative, which avoids the reverse operation, is to use a ListBuffer. A ListBuffer is a mutable object (contained in package scala.collection.mutable), which can help you build lists more efficiently when you need to append. ListBuffer provides constant time append and prepend operations. You append elements with the += operator, and prepend them with the +: operator. When you're done building, you can obtain a List by invoking toList on the ListBuffer. Here's an example:

+ 另一种方法是使用ListBuffer来避免reverse操作。ListBuffer是mutable对象，可以高效地帮助你来创建append的list。通过`+=`来完元素append，`+:`完成在开头添加，而且是恒定的。最后用toList生成List对象。

```
  scala> import scala.collection.mutable.ListBuffer
  import scala.collection.mutable.ListBuffer
  
  scala> val buf = new ListBuffer[Int]             
  buf: scala.collection.mutable.ListBuffer[Int] = ListBuffer()
  
  scala> buf += 1                                  
  
  scala> buf += 2                                  
  
  scala> buf     
  res11: scala.collection.mutable.ListBuffer[Int]
    = ListBuffer(1, 2)
  
  scala> 3 +: buf                                  
  res12: scala.collection.mutable.Buffer[Int]
    = ListBuffer(3, 1, 2)
  
  scala> buf.toList
  res13: List[Int] = List(3, 1, 2)
```

Another reason to use ListBuffer instead of List is to prevent the potential for stack overflow. If you can build a list in the desired order by prepending, but the recursive algorithm that would be required is not tail recursive, you can use a for expression or while loop and a ListBuffer instead. You'll see ListBuffer being used in this way in Section 22.2.

+ 另一个考虑用ListBuffer是为了防止栈溢出。如果你通过前面加元素来创建一个有序的序列，但是递归算法调用并不需要尾部递归，你就可以用while或for和ListBuffer来代替。

**Array buffers**

An ArrayBuffer is like an array, except that you can additionally add and remove elements from the beginning and end of the sequence. All Array operations are available, though they are a little slower due to a layer of wrapping in the implementation. The new addition and removal operations are constant time on average, but occasionally require linear time due to the implementation needing to allocate a new array to hold the buffer's contents.

+ ArrayBuffer像Array一样，除此之外，还可以在开头和结尾添加删除元素。所有的Array操作都是可以用的，尽管因为实现被包装了几层显得有些慢。新的增加和删除功能平均来说是恒定的，但是由于实现需要分配array空间和持有buffer内容会花费线性的时间。

To use an ArrayBuffer, you must first import it from the mutable collections package:

+ 使用ArrayBuffer需要导入包。

```
  scala> import scala.collection.mutable.ArrayBuffer
  import scala.collection.mutable.ArrayBuffer
```

When you create an ArrayBuffer, you must specify a type parameter, but need not specify a length. The ArrayBuffer will adjust the allocated space automatically as needed:

+ 当你创建ArrayBuffer需要有类型参数，但你不需要指定ArrayBufer大小，因为ArrayBuffer会自动分配大小。

```
  scala> val buf = new ArrayBuffer[Int]()
  buf: scala.collection.mutable.ArrayBuffer[Int] = 
    ArrayBuffer()
```

You can append to an ArrayBuffer using the += method:

+ 你可以用`+=`方法来append。

```
  scala> buf += 12
  
  scala> buf += 15
  
  scala> buf
  res16: scala.collection.mutable.ArrayBuffer[Int] = 
    ArrayBuffer(12, 15)
```

All the normal array methods are available. For example, you can ask an ArrayBuffer its length, or you can retrieve an element by its index:

+ 同样你也可以用Array的方法来获得length和小括号index来访问元素。

```
  scala> buf.length
  res17: Int = 2
  
  scala> buf(0)
  res18: Int = 12
```

**Queues**

If you need a first-in-first-out sequence, you can use a Queue. Scala's collection library provides both mutable and immutable variants of Queue. Here's how you can create an empty immutable queue:

+ 如果你想要一个先进先出的集合，那你可以使用Queue。Scala的库提供了mutable和immutable的Queue。下面是创建immutable Queue。

```
  scala> import scala.collection.immutable.Queue
  import scala.collection.immutable.Queue
  
  scala> val empty = new Queue[Int]    // 报错 protected constructor       
  empty: scala.collection.immutable.Queue[Int] = Queue()

  scala> val empty = Queue[Int]()
  empty: scala.collection.immutable.Queue[Int] = Queue()
```

You can append an element to an immutable queue with enqueue:

+ 通过enqueue方法来append元素。

```
  scala> val has1 = empty.enqueue(1)
  has1: scala.collection.immutable.Queue[Int] = Queue(1)
```

To append multiple elements to a queue, call enqueue with a collection as its argument:

+ 需要append多个元素，可以调用enqueue方法有集合作为入参的重载方法。

```
  scala> val has123 = has1.enqueue(List(2, 3))
  has123: scala.collection.immutable.Queue[Int] = Queue(1,2,3)
```

To remove an element from the head of the queue, you use dequeue:

+ 通过dequeue来从头部删除元素。

```
  scala> val (element, has23) = has123.dequeue
  element: Int = 1
  has23: scala.collection.immutable.Queue[Int] = Queue(2,3)
```

On immutable queues, the dequeue method returns a pair (a Tuple2) consisting of the element at the head of the queue, and the rest of the queue with the head element removed.

+ 在immutable Queue上，dequeue会返回一个Tuple2，第一个元素是Queue的头部元素，第二个元素是Queue中剩下的元素组成的Queue。

You use a mutable queue similarly to how you use an immutable one, but instead of enqueue, you use the += and ++= operators to append. Also, on a mutable queue, the dequeue method will just remove the head element from the queue and return it. Here's an example:

+ 使用mutable和immutable是类似的，但是用`+=`和`++=`来代替enqueue方法来append元素，`++=`是用来append包含多个元素的集合，同样dequeue来删除头部元素并返回单个元素。

```
  scala> import scala.collection.mutable.Queue                
  import scala.collection.mutable.Queue
  
  scala> val queue = new Queue[String]
  queue: scala.collection.mutable.Queue[String] = Queue()
  
  scala> queue += "a"
  
  scala> queue ++= List("b", "c")
  
  scala> queue
  res21: scala.collection.mutable.Queue[String] = Queue(a, b, c)
  
  scala> queue.dequeue
  res22: String = a
  
  scala> queue
  res23: scala.collection.mutable.Queue[String] = Queue(b, c)
```

**Stacks**

If you need a last-in-first-out sequence, you can use a Stack, which also comes in both mutable and immutable versions in the Scala collections library. You push an element onto a stack with push, pop an element with pop, and peek at the top of the stack without removing it with top. Here's an example of a mutable stack:

+ 如果你想要一个先进后出的集合可以St用acks。同样也有mutable和immutable两种在Scala库中。使用push来加到集合中，拿出元素用pop，得到最后层元素并不删除用top。

```
  scala> import scala.collection.mutable.Stack
  import scala.collection.mutable.Stack
  
  scala> val stack = new Stack[Int]           
  stack: scala.collection.mutable.Stack[Int] = Stack()
  
  scala> stack.push(1)
  
  scala> stack
  res1: scala.collection.mutable.Stack[Int] = Stack(1)
  
  scala> stack.push(2)
  
  scala> stack
  res3: scala.collection.mutable.Stack[Int] = Stack(1, 2)
  
  scala> stack.top
  res8: Int = 2
  
  scala> stack
  res9: scala.collection.mutable.Stack[Int] = Stack(1, 2)
  
  scala> stack.pop    
  res10: Int = 2
  
  scala> stack    
  res11: scala.collection.mutable.Stack[Int] = Stack(1)
```

**Strings (via RichString)**

One other sequence to be aware of is RichString, which is a Seq[Char]. Because Predef has an implicit conversion from String to RichString, you can treat any string as a Seq[Char]. Here's an example:

+ 两一个sequence是RichString，类型为Seq[Char]，因为Predef中有一个隐式转换从String到RichString。你可以把任何一个string当做Seq[Char]。

```
  scala> def hasUpperCase(s: String) = s.exists(_.isUpperCase)
  hasUpperCase: (String)Boolean
  
  scala> hasUpperCase("Robert Frost")
  res14: Boolean = true
  
  scala> hasUpperCase("e e cummings")
  res15: Boolean = false
```

In this example, the exists method is invoked on the string named s in the hasUpperCase method body. Because no method named "exists" is declared in class String itself, the Scala compiler will implicitly convert s to RichString, which has the method. The exists method treats the string as a Seq[Char], and will return true if any of the characters are upper case.[2]

+ 因为exists方法在string中是没有定义的，隐式转换为RichString，exists方法把string看做事Seq[Char]。

### 17.3 Sets and maps

You have already seen the basics of sets and maps in previous chapters, starting with Step 10 in Chapter 3. In this section, we'll give more insight into their use and show you a few more examples.

As mentioned previously, the Scala collections library offers both mutable and immutable versions of sets and maps. The hierarchy for sets is shown in Figure 3.2 here, and the hierarchy for maps is shown in Figure 3.3 here. As these diagrams show, the simple names Set and Map are used by three traits each, residing in different packages.

+ 同样Maps和Sets有mutable和immutable。

By default when you write "Set" or "Map" you get an immutable object. If you want the mutable variant, you need to do an explicit import. Scala gives you easier access to the immutable variants, as a gentle encouragement to prefer them over their mutable counterparts. The easy access is provided via the Predef object, which is implicitly imported into every Scala source file. Listing 17.1 shows the relevant definitions.

+ 默认的Set和Map是immutable的，如果你想访问mutable的集合对象那就需要导包。immutable包因为在Predef中已经显示定义了，而且还默认导入了所有的scala文件。

```
    object Predef {
      type Set[T] = scala.collection.immutable.Set[T]
      type Map[K, V] = scala.collection.immutable.Map[K, V]
      val Set = scala.collection.immutable.Set
      val Map = scala.collection.immutable.Map
      // ...
    }
```

Listing 17.1 - Default map and set definitions in Predef.

The "type" keyword is used in Predef to define Set and Map as aliases for the longer fully qualified names of the immutable set and map traits.[3] The vals named Set and Map are initialized to refer to the singleton objects for the immutable Set and Map. So Map is the same as Predef.Map, which is defined to be the same as scala.collection.immutable.Map. This holds both for the Map type and Map object.

+ type关键字是traits immutable Sets和Maps的包名加类名的别名。val Set和Map是指向immutable Set和Map的单例对象的。所以Map就是Predef.Map，Predef.Map也是被定义为scala.collection.immutable.Map。这是同时持有Map type和Map Object的。

If you want to use both mutable and immutable sets or maps in the same source file, one approach is to import the name of the package that contains the mutable variants:

+ 如果你想同时使用immutable和mutable的set或map，就要导入scala.collection.mutable。

```
  scala> import scala.collection.mutable
  import scala.collection.mutable
```

You can continue to refer to the immutable set as Set, as before, but can now refer to the mutable set as mutable.Set. Here's an example:

+ 你可以继续使用Set作为immutable Set。用mutable.Set作为mutable的。

```
  scala> val mutaSet = mutable.Set(1, 2, 3)          
  mutaSet: scala.collection.mutable.Set[Int] = Set(3, 1, 2)
```

**Using sets**

The key characteristic of sets is that they will ensure that at most one of each object, as determined by ==, will be contained in the set at any one time. As an example, we'll use a set to count the number of different words in a string.

+ Set最主要的特性就是其中每个对象保证只有一个，用`==`来决定。

The split method on String can separate a string into words, if you specify spaces and punctuation as word separators. The regular expression "[ !,.]+" will suffice: it indicates the string should be split at each place that one or more space and/or punctuation characters exist:

+ String的split方法能分割字符串，通过上述正则表达式可以在特定的地方进行分割。

```
  scala> val text = "See Spot run. Run, Spot. Run!"
  text: java.lang.String = See Spot run. Run, Spot. Run!
  
  scala> val wordsArray = text.split("[ !,.]+")    
  wordsArray: Array[java.lang.String] =
     Array(See, Spot, run, Run, Spot, Run)
```

To count the distinct words, you can convert them to the same case and then add them to a set. Because sets exclude duplicates, each distinct word will appear exactly one time in the set. First, you can create an empty set using the empty method provided on the Set companion objects:

+ 因为Set中不能有重复的元素，可以将上述分割后的字符串变成小写，加入到set中，set会自动排除相同项。通过伴随对象empty方法来创建一个空的set。

```
  scala>  val words = mutable.Set.empty[String]
  words: scala.collection.mutable.Set[String] = Set()
```

Then, just iterate through the words with a for expression, convert each word to lower case, and add it to the mutable set with the += operator:

+ 通过for表达式来迭代字符串，并变成小写，通过`+=`方法加入set。

```
  scala> for (word <- wordsArray)
           words += word.toLowerCase
  
  scala> words
  res25: scala.collection.mutable.Set[String] =
    Set(spot, run, see)
```

Thus, the text contained exactly three distinct words: spot, run, and see. The most commonly used methods on both mutable and immutable sets are shown in Table 17.1.

**Using maps**

Maps let you associate a value with each element of the collection. Using a map looks similar to using an array, except that instead of indexing with integers counting from 0, you can use any kind of key. If you import the scala.collection.mutable package, you can create an empty mutable map like this:

+ 你可以结合一个值到集合中的每个元素。使用map有点像使用array，用key找对应的元素来代替使用index。如果你导入了scala.collection.mutable，你可以用如下的empty方法来创建一个空的mutable map。

```
  scala> val map = mutable.Map.empty[String, Int]
  map: scala.collection.mutable.Map[String,Int] = Map()
```

**Common operations for sets**

What it is                       |  What it does
---------------------------------|-----------------------------------------------------------------
val nums = Set(1, 2, 3)          |  Creates an immutable set (nums.toString returns Set(1, 2, 3))
nums + 5                         |  Adds an element (returns Set(1, 2, 3, 5))
nums - 3                         |  Removes an element (returns Set(1, 2))
nums ++ List(5, 6)               |  Adds multiple elements (returns Set(1, 2, 3, 5, 6))
nums -- List(1, 2)               |  Removes multiple elements (returns Set(3))
nums ** Set(1, 3, 5, 7)          |  Takes the intersection of two sets (returns Set(1, 3))
nums.size                        |  Returns the size of the set (returns 3)
nums.contains(3)                 |  Checks for inclusion (returns true)
import scala.collection.mutable  |  Makes the mutable collections easy to access
val words =                      | 
mutable.Set.empty[String]        |  Creates an empty, mutable set (words.toString returns Set())
words += "the"                   |  Adds an element (words.toString returns Set(the))
words -= "the"                   |  Removes an element, if it exists (words.toString returns Set())
words ++= List("do", "re", "mi") |  Adds multiple elements (words.toString returns Set(do, re, mi))
words --= List("do", "re")       |  Removes multiple elements (words.toString returns Set(mi))
words.clear                      |  Removes all elements (words.toString returns Set())

Note that when you create a map, you must specify two types. The first type is for the keys of the map, the second for the values. In this case, the keys are strings and the values are integers.

+ 当你创建map是需要指key和value的类型。

Setting entries in a map looks similar to setting entries in an array:

+ map设值是和读取值，是和array类似的。

```
  scala> map("hello") = 1
  
  scala> map("there") = 2
  
  scala> map
  res28: scala.collection.mutable.Map[String,Int] =
    Map(hello -> 1, there -> 2)
```

Likewise, reading a map is similar to reading an array:

```
  scala> map("hello")
  res29: Int = 1
```

Putting it all together, here is a method that counts the number of times each word occurs in a string:

```
  scala> def countWords(text: String) = {
           val counts = mutable.Map.empty[String, Int]
           for (rawWord <- text.split("[ ,!.]+")) {
             val word = rawWord.toLowerCase
             val oldCount = 
               if (counts.contains(word)) counts(word)
               else 0
             counts += (word -> (oldCount + 1))
           }
           counts
         }
  countWords: (String)scala.collection.mutable.Map[String,Int]
  
  
  scala> countWords("See Spot run! Run, Spot. Run!")
  res30: scala.collection.mutable.Map[String,Int] =
    Map(see -> 1, run -> 3, spot -> 2)
```

Given these counts, you can see that this text talks a lot about running, but not so much about seeing.

The way this code works is that a mutable map, named counts, maps each word to the number of times it occurs in the text. For each word in the text, the word's old count is looked up, that count is incremented by one, and the new count is saved back into counts. Note the use of contains to check whether a word has been seen yet or not. If counts.contains(word) is not true, then the word has not yet been seen and zero is used for the count.

+ 解释上述代码。

Many of the most commonly used methods on both mutable and immutable maps are shown in Table 17.2.

+ 许多普通的mutable和immutable map操作如下表。

**Common operations for maps**

What it is                          |What it does
------------------------------------|-------------------------------------------------------------------------------------
val nums = Map("i" -> 1, "ii" -> 2) |Creates an immutable map (nums.toString returns Map(i -> 1, ii -> 2))
nums + ("vi" -> 6)                  |Adds an entry (returns Map(i -> 1, ii -> 2, vi -> 6))
nums - "ii"                         |Removes an entry (returns Map(i -> 1))
nums ++ List("iii" -> 3, "v" -> 5)  |Adds multiple entries (returns Map(i -> 1, ii -> 2, iii -> 3, v -> 5))
nums -- List("i", "ii")             |Removes multiple entries (returns Map())
nums.size                           |Returns the size of the map (returns 2)
nums.contains("ii")                 |Checks for inclusion (returns true)
nums("ii")                          |Retrieves the value at a specified key (returns 2)
nums.keys                           |Returns the keys (returns an Iterator over the strings "i" and "ii")
nums.keySet                         |Returns the keys as a set (returns Set(i, ii))
nums.values                         |Returns the values (returns an Iterator over the integers 1 and 2)
nums.isEmpty                        |Indicates whether the map is empty (returns false)
import scala.collection.mutable     |Makes the mutable collections easy to access
val words =                         |
mutable.Map.empty[Stri|ng, Int]     |Creates an empty, mutable map
words += ("one" -> 1)               |Adds a map entry from "one" to 1 (words.toString returns Map(one -> 1))
words -= "one"                      |Removes a map entry, if it exists (words.toString returns Map())
words ++= List("one" -> 1,          |
"two" -> 2, "three" -> 3)           |Adds multiple map entries (words.toString returns Map(one -> 1, two -> 2, three -> 3))
words --= List("one", "two")        |Removes multiple objects (words.toString returns Map(three -> 3))

**Default sets and maps**

For most uses, the implementations of mutable and immutable sets and maps provided by the Set(), scala.collection.mutable.Map(), etc., factories will likely be sufficient. The implementations provided by these factories use a fast lookup algorithm, usually involving a hashtable, so they can quickly decide whether or not an object is in the collection.

+ 快速的查找算法，设计Hashtable，所以可以快速判断对象是否在集合中。

The scala.collection.mutable.Set() factory method, for example, returns a scala.collection.mutable.HashSet, which uses a hashtable internally. Similarly, the scala.collection.mutable.Map() factory returns a scala.collection.mutable.HashMap.

+ mutable中的Set和Map，他们的工厂方法返回的都是HashSet和HashMap。

The story for immutable sets and maps is a bit more involved. The class returned by the scala.collection.immutable.Set() factory method, for example, depends on how many elements you pass to it, as shown in Table 17.3. For sets with fewer than five elements, a special class devoted exclusively to sets of each particular size is used, to maximize performance. Once you request a set that has five or more elements in it, however, the factory method will return immutable HashSet.

+ immutable Set的工厂方法取决于你构造时的入参个数，如下表，5个或以上会返回HashSet。

Table 17.3 - Default immutable set implementations

Number of elements  | Implementation
--------------------|-------------------------------------
0                   | scala.collection.immutable.EmptySet
1                   | scala.collection.immutable.Set1
2                   | scala.collection.immutable.Set2
3                   | scala.collection.immutable.Set3
4                   | scala.collection.immutable.Set4
5 or more           | scala.collection.immutable.HashSet

Similarly, the scala.collection.immutable.Map() factory method will return a different class depending on how many key-value pairs you pass to it, as shown in Table 17.4. As with sets, for immutable maps with fewer than five elements, a special class devoted exclusively to maps of each particular size is used, to maximize performance. Once a map has five or more key-value pairs in it, however, an immutable HashMap is used.

+ 同样的immutable Map会取决于构造时入参的键值对个数，如下表，5个或以上会返回HashMap。

Table 17.4 - Default immutable map implementations

Number of elements  | Implementation
--------------------|-------------------------------------
0                   | scala.collection.immutable.EmptyMap
1                   | scala.collection.immutable.Map1
2                   | scala.collection.immutable.Map2
3                   | scala.collection.immutable.Map3
4                   | scala.collection.immutable.Map4
5 or more           | scala.collection.immutable.HashMap

The default immutable implementation classes shown in Tables 17.3 and 17.4 work together to give you maximum performance. For example, if you add an element to an EmptySet, it will return a Set1. If you add an element to that Set1, it will return a Set2. If you then remove an element from the Set2, you'll get another Set1.

+ 默认immutable实现给你最大性能。比如你加一个元素到emptySet，会返回你新的Set1。加一个元素到Set1，会返回新的Set2。从Set2删掉一个元素，会返回你新的Set1。

**Sorted sets and maps**

On occasion you may need a set or map whose iterator returns elements in a particular order. For this purpose, the Scala collections library provides traits SortedSet and SortedMap. These traits are implemented by classes TreeSet and TreeMap, which use a red-black tree to keep elements (in the case of TreeSet) or keys (in the case of TreeMap) in order. The order is determined by the Ordered trait, which the element type of the set, or key type of the map, must either mix in or be implicitly convertable to. These classes only come in immutable variants. Here are some TreeSet examples:

+ 偶尔我们会需要用到有序的Set和Map。TreeSet和TreeMap是trait SortedSet和SortedMap的实现，通过红黑树进行对Set的元素和Map的key进行排序。trait Ordered来维护顺序。

```
  scala> import scala.collection.immutable.TreeSet
  import scala.collection.immutable.TreeSet
  
  scala> val ts = TreeSet(9, 3, 1, 8, 0, 2, 7, 4, 6, 5)
  ts: scala.collection.immutable.SortedSet[Int] =
    Set(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
  
  scala> val cs = TreeSet('f', 'u', 'n')
  cs: scala.collection.immutable.SortedSet[Char] = Set(f, n, u)
```

And here are a few TreeMap examples:

```
  scala> import scala.collection.immutable.TreeMap
  import scala.collection.immutable.TreeMap
  
  scala> var tm = TreeMap(3 -> 'x', 1 -> 'x', 4 -> 'x')
  tm: scala.collection.immutable.SortedMap[Int,Char] =
    Map(1 -> x, 3 -> x, 4 -> x)
  
  scala> tm += (2 -> 'x')
  
  scala> tm
  res38: scala.collection.immutable.SortedMap[Int,Char] =
    Map(1 -> x, 2 -> x, 3 -> x, 4 -> x)
```

**Synchronized sets and maps**

In Section 1.1, we mentioned that if you needed a thread-safe map, you could mix the SynchronizedMap trait into whatever particular map implementation you desired. For example, you could mix SynchronizedMap into HashMap, as shown in Listing 17.2. This example begins with an import of two traits, Map and SynchronizedMap, and one class, HashMap, from package scala.collection.mutable. The rest of the example is the definition of singleton object MapMaker, which declares one method, makeMap. The makeMap method declares its result type to be a mutable map of string keys to string values.

+ 如果想要个线程安全的map，可以mix in trait SynchroizedMap在实现的Map上。下面的例子Object定义了一个方法makeMap，返回HashMap mix in trait SynchronizedMap。

```
    import scala.collection.mutable.{Map,
        SynchronizedMap, HashMap}
  
    object MapMaker {
  
      def makeMap: Map[String, String] = {
  
          new HashMap[String, String] with
              SynchronizedMap[String, String] {
  
            override def default(key: String) =
              "Why do you want to know?"
          }
      }
    }
```

Listing 17.2 - Mixing in the SynchronizedMap trait.

The first statement inside the body of makeMap constructs a new mutable HashMap that mixes in the SynchronizedMap trait:

```
  new HashMap[String, String] with
    SynchronizedMap[String, String]
```

Given this code, the Scala compiler will generate a synthetic subclass of HashMap that mixes in SynchronizedMap, and create (and return) an instance of it. This synthetic class will also override a method named default, because of this code:

```
  override def default(key: String) =
    "Why do you want to know?"
```

If you ask a map to give you the value for a particular key, but it doesn't have a mapping for that key, you'll by default get a NoSuchElementException. If you define a new map class and override the default method, however, your new map will return the value returned by default when queried with a non-existent key. Thus, the synthetic HashMap subclass generated by the compiler from the code in Listing 17.2 will return the somewhat curt response string, "Why do you want to know?", when queried with a non-existent key.

+ 如果你想要找某个特定的key，如果没有找到这个特定的key。就会从override的default返回自定义的话。

Because the mutable map returned by the makeMap method mixes in the SynchronizedMap trait, it can be used by multiple threads at once. Each access to the map will be synchronized. Here's an example of the map being used, by one thread, in the interpreter:

+ 可以多线程访问。

```
  scala> val capital = MapMaker.makeMap  
  capital: scala.collection.mutable.Map[String,String] = Map()
  
  scala> capital ++ List("US" -> "Washington",
              "Paris" -> "France", "Japan" -> "Tokyo")
  res0: scala.collection.mutable.Map[String,String] =
    Map(Paris -> France, US -> Washington, Japan -> Tokyo)
  
  scala> capital("Japan")
  res1: String = Tokyo
  
  scala> capital("New Zealand")
  res2: String = Why do you want to know?
  
  scala> capital += ("New Zealand" -> "Wellington")
  
  scala> capital("New Zealand")                    
  res3: String = Wellington
```

You can create synchronized sets similarly to the way you create synchronized maps. For example, you could create a synchronized HashSet by mixing in the SynchronizedSet trait, like this:

+ 同map一样可以创建SynchronizedSet。

```
  import scala.collection.mutable
  
  val synchroSet =
    new mutable.HashSet[Int] with
        mutable.SynchronizedSet[Int]
```

Finally, if you are thinking of using synchronized collections, you may also wish to consider the concurrent collections of java.util.concurrent instead. Alternatively, you may prefer to use unsynchronized collections with Scala actors. Actors will be covered in detail in Chapter 30.

### 17.4 Selecting mutable versus immutable collections

+ 17.4 选择mutable还是immutable集合

For some problems, mutable collections work better, and for others, immutable collections work better. When in doubt, it is better to start with an immutable collection and change it later if you need to, because immutable collections can be easier to reason about than mutable ones.

+ 有些是mutable好，有些是immutable好。如果有疑问，那就先以immutable集合开始，如果后面需要可以改变他。因为immutable集合更容易推导。

It can also sometimes be worthwhile to go the opposite way. If you find some code that uses mutable collections becoming complicated and hard to reason about, consider whether it would help to change some of the collections to immutable alternatives. In particular, if you find yourself worrying about making copies of mutable collections in just the right places, or thinking a lot about who "owns" or "contains" a mutable collection, consider switching some of the collections to their immutable counterparts.

+ 有时你觉得用mutable很难推导，那就换immutable。如果有时自己会担心会做了mutable集合的拷贝，考虑谁有或包含mutable集合。考虑换immutable集合。

Besides being potentially easier to reason about, immutable collections can usually be stored more compactly than mutable ones if the number of elements stored in the collection is small. For instance an empty mutable map in its default representation of HashMap takes up about 80 bytes and about 16 more are added for each entry that's added to it. An empty immutable Map is a single object that's shared between all references, so referring to it essentially costs just a single pointer field. What's more, the Scala collections library currently stores immutable maps and sets with up to four entries in a single object, which typically takes up between 16 and 40 bytes, depending on the number of entries stored in the collection.[4] So for small maps and sets, the immutable versions are much more compact than the mutable ones. Given that many collections are small, switching them to be immutable can give important space savings and performance advantages.

+ 除了immutable更容易推导，如果immutable集合中的元素较少会比mutable集合存储更加简洁。为什么immutable比mutable存储简洁可以看下上述段落中的例子。immutable可以更节省空间和性能优势。

To make it easier to switch from immutable to mutable collections, and vice versa, Scala provides some syntactic sugar. Even though immutable sets and maps do not support a true += method, Scala gives a useful alternate interpretation to +=. Whenever you write a += b, and a does not support a method named +=, Scala will try interpreting it as a = a + b. For example, immutable sets do not support a += operator:

+ 为了让immutable和mutable互转简单，scala有办法，但是`+=`在immutable是不可以行的如下。scala会想办法把其变成`a = a + b`。

```
  scala> val people = Set("Nancy", "Jane")
  people: scala.collection.immutable.Set[java.lang.String] =
    Set(Nancy, Jane)
  
  scala> people += "Bob"
  <console>:6: error: reassignment to val
         people += "Bob"
                ^
```

If you declare people as a var, instead of a val, however, then the collection can be "updated" with a += operation, even though it is immutable. First, a new collection will be created, and then people will be reassigned to refer to the new collection:

+ 如果用var代替val定义，尽管是immutable的集合，`+=`操作会创建一个新的集合，会赋值给people。

```
  scala> var people = Set("Nancy", "Jane")
  people: scala.collection.immutable.Set[java.lang.String] = 
    Set(Nancy, Jane)
  
  scala> people += "Bob"
  
  scala> people
  res42: scala.collection.immutable.Set[java.lang.String] = 
    Set(Nancy, Jane, Bob)
```

After this series of statements, the people variable refers to a new immutable set, which contains the added string, "Bob". The same idea applies to any method ending in =, not just the += method. Here's the same syntax used with the -= operator, which removes an element from a set, and the ++= operator, which adds a collection of elements to a set:

+ 这个不仅限于`+=`操作，以=结尾的都适用如下。

```
  scala> people -= "Jane"
  
  scala> people ++= List("Tom", "Harry")
  
  scala> people
  res45: scala.collection.immutable.Set[java.lang.String] = 
    Set(Nancy, Bob, Tom, Harry)
```

To see how this is useful, consider again the following Map example from Section 1.1:

```
  var capital = Map("US" -> "Washington", "France" -> "Paris")
  capital += ("Japan" -> "Tokyo")
  println(capital("France")) 
```

This code uses immutable collections. If you want to try using mutable collections instead, all that is necessary is to import the mutable version of Map, thus overriding the default import of the immutable Map:

+ 上述代码使用的是immutable Map，如果你想要用mutable Map，直接导包import scala.collection.mutable.Map来override默认的immutable Map。

```
  import scala.collection.mutable.Map  // only change needed!
  var capital = Map("US" -> "Washington", "France" -> "Paris")
  capital += ("Japan" -> "Tokyo")
  println(capital("France")) 
```

Not all examples are quite that easy to convert, but the special treatment of methods ending in an equals sign will often reduce the amount of code that needs changing.

+ 但并不是所有的转换都是那么简单的，但是var这种=好的处理可以减少很多代码。

By the way, this syntactic treatment works on any kind of value, not just collections. For example, here it is being used on floating-point numbers:

+ var这种转换适用于各种值，不仅仅是集合。

```
  scala> var roughlyPi = 3.0
  roughlyPi: Double = 3.0
  
  scala> roughlyPi += 0.1
  
  scala> roughlyPi += 0.04
  
  scala> roughlyPi
  res48: Double = 3.14
```

The effect of this expansion is similar to Java's assignment operators +=, -=, *=, etc., but it is more general because every operator ending in = can be converted.

+ 只有以=结尾的可以被转换可变与不可变。

### 17.5 Initializing collections

As you've seen previously, the most common way to create and initialize a collection is to pass the initial elements to a factory method on the companion object of your chosen collection. You just place the elements in parentheses after the companion object name, and the Scala compiler will transform that to an invocation of an apply method on that companion object:

+ 通常我们创建集合通过伴随对象加入参的方式，编译器会调用伴随对象的apply方法。

```
  scala> List(1, 2, 3)
  res0: List[Int] = List(1, 2, 3)
  
  scala> Set('a', 'b', 'c')
  res1: scala.collection.immutable.Set[Char] = Set(a, b, c)
  
  scala> import scala.collection.mutable
  import scala.collection.mutable
  
  scala> mutable.Map("hi" -> 2, "there" -> 5)
  res2: scala.collection.mutable.Map[java.lang.String,Int] =
    Map(hi -> 2, there -> 5)
  
  scala> Array(1.0, 2.0, 3.0)
  res3: Array[Double] = Array(1.0, 2.0, 3.0)
```

Although most often you can let the Scala compiler infer the element type of a collection from the elements passed to its factory method, sometimes you may want to create a collection but specify a different type from the one the compiler would choose. This is especially an issue with mutable collections. Here's an example:

+ 虽然编译器会从我们的入参推断出集合元素的类型，但是我们经常会想创建一个集合指明与编译器选择不同的类型，这问题经常发生在mutable上。

```
  scala> import scala.collection.mutable
  import scala.collection.mutable
  
  scala> val stuff = mutable.Set(42)
  stuff: scala.collection.mutable.Set[Int] = Set(42)
  
  scala> stuff += "abracadabra"
  <console>:7: error: type mismatch;
   found   : java.lang.String("abracadabra")
   required: Int
         stuff += "abracadabra"
                  ^
```

The problem here is that stuff was given an element type of Int. If you want it to have an element type of Any, you need to say so explicitly by putting the element type in square brackets, like this:

+ 因为入参是Int，你想要加入任意的类型，需要在初始化时指明。

```
  scala> val stuff = mutable.Set[Any](42)
  stuff: scala.collection.mutable.Set[Any] = Set(42)
```

Another special situation is if you want to initialize a collection with another collection. For example, imagine you have a list, but you want a TreeSet containing the elements in the list. Here's the list:

+ 另外一个特殊情况是，你想用另一个集合来初始化一个新的集合。

```
  scala> val colors = List("blue", "yellow", "red", "green")
  colors: List[java.lang.String] =
    List(blue, yellow, red, green)
```

You cannot pass the colors list to the factory method for TreeSet:

+ 你不能直接传给TreeSet，因为没有隐式入参来匹配。

```
  scala> import scala.collection.immutable.TreeSet
  import scala.collection.immutable.TreeSet
  
  scala> val treeSet = TreeSet(colors)                 
  <console>:6: error: no implicit argument matching
    parameter type (List[java.lang.String]) =>
      Ordered[List[java.lang.String]] was found.
         val treeSet = TreeSet(colors)
                       ^
```

Instead, you'll need to create an empty TreeSet[String] and add to it the elements of the list with the TreeSet's ++ operator:

+ 你可以先创建一个空的TreeSet集合，然后用`++`操作来吧List集合加入。

```
  scala> val treeSet = TreeSet[String]() ++ colors
  treeSet: scala.collection.immutable.SortedSet[String] =
     Set(blue, green, red, yellow)
```

**Converting to array or list**

If you need to initialize a list or array with another collection, on the other hand, it is quite straightforward. As you've seen previously, to initialize a new list with another collection, simply invoke toList on that collection:

+ 如果你想通过一个集合来创建Array或List，很简单，直接了当的调用toList或toArray方法。

```
  scala> treeSet.toList
  res54: List[String] = List(blue, green, red, yellow)
```

Or, if you need an array, invoke toArray:

```
  scala> treeSet.toArray
  res55: Array[String] = Array(blue, green, red, yellow)
```

Note that although the original colors list was not sorted, the elements in the list produced by invoking toList on the TreeSet are in alphabetical order. When you invoke toList or toArray on a collection, the order of the elements in the resulting list or array will be the same as the order of elements produced by an iterator obtained by invoking elements on that collection. Because a TreeSet[String]'s iterator will produce strings in alphabetical order, those strings will appear in alphabetical order in the list resulting from invoking toList on that TreeSet.

+ 记住虽然List最初是没有顺序的，但是TreeSet是排序的，他调用toList拷贝给新的List还是会用相同的排序顺序。

Keep in mind, however, that conversion to lists or arrays usually requires copying all of the elements of the collection, and thus may be slow for large collections. Sometimes you need to do it, though, due to an existing API. Further, many collections only have a few elements anyway, in which case there is only a small speed penalty.

+ 记住这种转化需要从一个集合把元素拷贝到另外一个，所以如果大的集合会很慢。

**Converting between mutable and immutable sets and maps**

Another situation that may arise occasionally is the need to convert a mutable set or map to an immutable one, or vice versa. To accomplish this, you can use the technique shown previously to initialize a TreeSet with the elements of a list. If you have a mutable collection, and want to convert it to a immutable one, for example, create an empty immutable collection and add the elements of the mutable one via the ++ operator. Here's how you'd convert the immutable TreeSet from the previous example to a mutable set, and back again to an immutable one:

+ 另外一种情形是将immutable Set和Map转为mutable的。也可以通过上述方式来完成。比如创建一个新的空的immutable集合，然后通过`++`操作把mutable的元素加到immutable空的集合中。

```
  scala> import scala.collection.mutable
  import scala.collection.mutable
  
  scala> treeSet
  res5: scala.collection.immutable.SortedSet[String] =
    Set(blue, green, red, yellow)
  
  scala> val mutaSet = mutable.Set.empty ++ treeSet
  mutaSet: scala.collection.mutable.Set[String] =
    Set(yellow, blue, red, green)
  
  scala> val immutaSet = Set.empty ++ mutaSet
  immutaSet: scala.collection.immutable.Set[String] =
    Set(yellow, blue, red, green)
```

You can use the same technique to convert between mutable and immutable maps:

```
  scala> val muta = mutable.Map("i" -> 1, "ii" -> 2)
  muta: scala.collection.mutable.Map[java.lang.String,Int] =
     Map(ii -> 2, i -> 1)
  
  scala> val immu = Map.empty ++ muta
  immu: scala.collection.immutable.Map[java.lang.String,Int] =
     Map(ii -> 2, i -> 1)
```

### 17.6 Tuples

As described in Step 9 in Chapter 3, a tuple combines a fixed number of items together so that they can be passed around as a whole. Unlike an array or list, a tuple can hold objects with different types. Here is an example of a tuple holding an integer, a string, and the console:

+ 不像Array和List，Tuple可以持有不同类型的元素。

```
  (1, "hello", Console)
```

Tuples save you the tedium of defining simplistic data-heavy classes. Even though defining a class is already easy, it does require a certain minimum effort, which sometimes serves no purpose. Tuples save you the effort of choosing a name for the class, choosing a scope to define the class in, and choosing names for the members of the class. If your class simply holds an integer and a string, there is no clarity added by defining a class named AnIntegerAndAString.

+ 用Tuple来代替一个只是持有一些字段的类可以节省很多工作。

Because tuples can combine objects of different types, tuples do not inherit from Iterable. If you find yourself wanting to group exactly one integer and exactly one string, then you want a tuple, not a List or Array.

+ Tuple可以整合不同的数据类型，他不是继承自Iterable。如果你发现你只需要一个Int和一个String，那你会用Tuple而不是Array和List。

A common application of tuples is returning multiple values from a method. For example, here is a method that finds the longest word in a collection and also returns its index:

+ 一个通用的Tuple的应用是方法返回多个值。

```
  def longestWord(words: Array[String]) = {
    var word = words(0)
    var idx = 0
    for (i <- 1 until words.length)
      if (words(i).length > word.length) {
        word = words(i)
        idx = i
      }
    (word, idx)
  }
```

Here is an example use of the method:

```
  scala> val longest = 
           longestWord("The quick brown fox".split(" "))
  longest: (String, Int) = (quick,1)
```

The longestWord function here computes two items: word, the longest word in the array, and idx, the index of that word. To keep things simple, the function assumes there is at least one word in the list, and it breaks ties by choosing the word that comes earlier in the list. Once the function has chosen which word and index to return, it returns both of them together using the tuple syntax (word, idx).

+ 解释上述代码。

To access elements of a tuple, you can use method _1 to access the first element, _2 to access the second, and so on:

+ 要访问Tuple的元素，使用`_1`来访问第一个元素，`_2`第二个，以此类推。

```
  scala> longest._1
  res56: String = quick
  
  scala> longest._2
  res57: Int = 1
```

Additionally, you can assign each element of the tuple to its own variable,[5] like this:

+ 同时，也可以用Tuple来被赋值变量。

```
  scala> val (word, idx) = longest
  word: String = quick
  idx: Int = 1
  
  scala> word
  res58: String = quick
```

By the way, if you leave off the parentheses you get a different result:

+ 顺便说一句，如果你把括号删掉，那会得到不同的结果。如下。

```
  scala> val word, idx = longest
  word: (String, Int) = (quick,1)
  idx: (String, Int) = (quick,1)
```

This syntax gives multiple definitions of the same expression. Each variable is initialized with its own evaluation of the expression on the right-hand side. That the expression evaluates to a tuple in this case does not matter. Both variables are initialized to the tuple in its entirety. See Chapter 18 for some examples where multiple definitions are convenient.

+ 每个变量都被右边的内容进行了初始化。

As a note of warning, tuples are almost too easy to use. Tuples are great when you combine data that has no meaning beyond "an A and a B." However, whenever the combination has some meaning, or you want to add some methods to the combination, it is better to go ahead and create a class. For example, do not use a 3-tuple for the combination of a month, a day, and a year. Make a Date class. It makes your intentions explicit, which both clears up the code for human readers and gives the compiler and language opportunities to help you catch mistakes.

+ 警告记住，元组几乎太容易使用。元组是伟大的，你可以结合没有意义的两个数据A or B，但是，每当组合有一些意义，或者你想添加一些方法的组合，最好是去创建一个类。例如，不要用一个三元组去结合日，月，年。写个Date类，意图明确，提高代码可读性，并提供编译器帮助您捕捉错误。

### 17.7 Conclusion

This chapter has given an overview of the Scala collections library and the most important classes and traits in it. With this foundation you should be able to work effectively with Scala collections, and know where to look in Scaladoc when you need more information. In the next chapter, we'll turn our attention from the Scala library back to the language, and discuss Scala's support for mutable objects.

### Footnotes for Chapter 17:

[1] The difference in variance of Scala and Java's arrays—i.e., whether Array[String] is a subtype of Array[AnyRef]—will be discussed in Section 19.3.

[2] The code given here of Chapter 1 presents a similar example.

[3] The type keyword will be explained in more detail in Section 20.6.

[4] The "single object" is an instance of Set1 through Set4, or Map1 through Map4, as shown in Tables 17.3 and 17.4.

[5] This syntax is actually a special case of pattern matching, as described in detail in Section 15.7.
