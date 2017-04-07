## Scala's Hierarchy

### Vocabulary

Now that you've seen the details of class inheritance in the previous chapter, it is a good time to take a step back and look at Scala's class hierarchy as a whole. In Scala, every class inherits from a common superclass named Any. Because every class is a subclass of Any, the methods defined in Any are "universal" methods: they may be invoked on any object. Scala also defines some interesting classes at the bottom of the hierarchy, Null and Nothing, which essentially act as common subclasses. For example, just as Any is a superclass of every other class, Nothing is a subclass of every other class. In this chapter, we'll give you a tour of Scala's class hierarchy.

+ Scala每个类都是继承自Any，在Any中定以了几个全局化的方法，可以在任何对象中调用。在下面图中底部也定以了几个有趣的类Nothing和Null，Nothing是所有类的子类。

### 11.1 Scala's class hierarchy

Figure 11.1 shows an outline of Scala's class hierarchy. At the top of the hierarchy is class Any, which defines methods that include the following:

+ Any中定以的全局化方法。

```
  final def ==(that: Any): Boolean
  final def !=(that: Any): Boolean
  def equals(that: Any): Boolean
  def hashCode: Int
  def toString: String
```

Because every class inherits from Any, every object in a Scala program can be compared using ==, !=, or equals; hashed using hashCode; and formatted using toString. The equality and inequality methods, == and !=, are declared final in class Any, so they cannot be overridden in subclasses. In fact, == is always the same as equals and != is always the negation of equals. So individual classes can tailor what == or != means by overriding the equals method. We'll show an example later in this chapter.

+ 每个类都继承自Any，每个对象都可以用`==, !=, or equals`来比较，还有hashCode和toString方法。`==, !=`这两个方法在Any中定以为final的，所以不能在子类中改写。个别类可以改写equals方法来改写`==, !=`的意思。

![Figure11.1](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure11.1.jpg)

Class hierarchy of Scala.

The root class Any has two subclasses: AnyVal and AnyRef. AnyVal is the parent class of every built-in value class in Scala. There are nine such value classes: Byte, Short, Char, Int, Long, Float, Double, Boolean, and Unit. The first eight of these correspond to Java's primitive types, and their values are represented at run time as Java's primitive values. The instances of these classes are all written as literals in Scala. For example, 42 is an instance of Int, 'x' is an instance of Char, and false an instance of Boolean. You cannot create instances of these classes using new. This is enforced by the "trick" that value classes are all defined to be both abstract and final. So if you were to write:

+ Any有两个子类AnyVal和AnyRef。AnyVal是所以Scala基本数据的父类。有9个`Byte, Short, Char, Int, Long, Float, Double, Boolean, and Unit`，前8个和Java数据类型相同，`42`就是Int的实例，不能用new来实例化。

```
  scala> new Int
you would get:
  <console>:5: error: class Int is abstract; cannot be 
  instantiated
         new Int
         ^
```

The other value class, Unit, corresponds roughly to Java's void type; it is used as the result type of a method that does not otherwise return an interesting result. Unit has a single instance value, which is written (), as discussed in Section 7.2.

+ Unit是相当于Java的void。Unit是单实例值写成`()`。

As explained in Chapter 5, the value classes support the usual arithmetic and boolean operators as methods. For instance, Int has methods named + and *, and Boolean has methods named || and &&. Value classes also inherit all methods from class Any. You can test this in the interpreter:

+ 基础数据类也是继承自Any，所以那些全局方法也是被继承的，如下。

```
  scala> 42.toString
  res1: java.lang.String = 42
  
  scala> 42.hashCode
  res2: Int = 42
  
  scala> 42 equals 42
  res3: Boolean = true
```

Note that the value class space is flat; all value classes are subtypes of scala.AnyVal, but they do not subclass each other. Instead there are implicit conversions between different value class types. For example, an instance of class scala.Int is automatically widened (by an implicit conversion) to an instance of class scala.Long when required.

+ 记住基础数据类型空间是平的，他们都是AnyVal的子类，但不是互相的子类。他们之间可以隐式转化。

As mentioned in Section 5.9, implicit conversions are also used to add more functionality to value types. For instance, the type Int supports all of the operations below:

+ 通过隐式转化implicit conversions，可以变成更加函数化的数据类型，可以有如下操作。

```
  scala> 42 max 43
  res4: Int = 43
  
  scala> 42 min 43
  res5: Int = 42
  
  scala> 1 until 5
  res6: Range = Range(1, 2, 3, 4)
  
  scala> 1 to 5
  res7: Range.Inclusive = Range(1, 2, 3, 4, 5)
  
  scala> 3.abs
  res8: Int = 3
  
  scala> (-3).abs
  res9: Int = 3
```

Here's how this works: The methods min, max, until, to, and abs are all defined in a class scala.runtime.RichInt, and there is an implicit conversion from class Int to RichInt. The conversion is applied whenever a method is invoked on an Int that is undefined in Int but defined in RichInt. Similar "booster classes" and implicit conversions exist for the other value classes. Implicit conversions will be discussed in detail in Chapter 21.

+ 这些功能函数都是定义在scala.runtime.RichInt中，所以有从Int到RichInt的隐式转化。转化会发生在Int上调用但并未在Int中定义而是在RichInt中定义的函数时。会在Chapter21中介绍。

The other subclass of the root class Any is class AnyRef. This is the base class of all reference classes in Scala. As mentioned previously, on the Java platform AnyRef is in fact just an alias for class java.lang.Object. So classes written in Java as well as classes written in Scala all inherit from AnyRef.[1] One way to think of java.lang.Object, therefore, is as the way AnyRef is implemented on the Java platform. Thus, although you can use Object and AnyRef interchangeably in Scala programs on the Java platform, the recommended style is to use AnyRef everywhere.

+ 另一个Any的子类AnyRef。这是所有引用类的基类。像Java中的java.lang.Object类。可以在Java平台上用AnyRef来Scala的编程。

Scala classes are different from Java classes in that they also inherit from a special marker trait called ScalaObject. The idea is that the ScalaObject contains methods that the Scala compiler defines and implements in order to make execution of Scala programs more efficient. Right now, Scala object contains a single method, named $tag, which is used internally to speed up pattern matching.

+ 不同于Java类，scala也继承自一个特殊的制造者接口ScalaObject。ScalaObject的定义和实现是为了执行Scala程序更有效。`$tag`是为了来加速pattern matching的。

### 11.2 How primitives are implemented

How is all this implemented? In fact, Scala stores integers in the same way as Java: as 32-bit words. This is important for efficiency on the JVM and also for interoperability with Java libraries. Standard operations like addition or multiplication are implemented as primitive operations. However, Scala uses the "backup" class java.lang.Integer whenever an integer needs to be seen as a (Java) object. This happens for instance when invoking the toString method on an integer number or when assigning an integer to a variable of type Any. Integers of type Int are converted transparently to "boxed integers" of type java.lang.Integer whenever necessary.

+ Scala也是存储一个Int 32个字节。这是为了有效地在JVM和用Java库编译。Scala也可以用java.lang.Integer来做备份当需要用作Java对象。

All this sounds a lot like auto-boxing in Java 5 and it is indeed quite similar. There's one crucial difference, though, in that boxing in Scala is much less visible than boxing in Java. Try the following in Java:

+ auto-boxing在Scala中不是那么明显。

```java
  // This is Java
  boolean isEqual(int x, int y) {
    return x == y;
  }
  System.out.println(isEqual(421, 421));
```

You will surely get true. Now, change the argument types of isEqual to java.lang.Integer (or Object, the result will be the same):

```java
  // This is Java
  boolean isEqual(Integer x, Integer y) {
    return x == y;
  }
  System.out.println(isEqual(421, 421));
```

You will find that you get false! What happens is that the number 421 gets boxed twice, so that the arguments for x and y are two different objects. Because == means reference equality on reference types, and Integer is a reference type, the result is false. This is one aspect where it shows that Java is not a pure object-oriented language. There is a difference between primitive types and reference types that can be clearly observed.
Now try the same experiment in Scala:

+ 这里是false，421被包装了两次，以致于x和y是两个对象。因为`==`是用来引用类型比较引用是否相同，Integer是引用类型。所以Java不是pure object-oriented，因为还有基本数据类型和引用类型。下面是Scala

```
  scala> def isEqual(x: Int, y: Int) = x == y
  isEqual: (Int,Int)Boolean
  
  scala> isEqual(421, 421)
  res10: Boolean = true
  
  scala> def isEqual(x: Any, y: Any) = x == y
  isEqual: (Any,Any)Boolean
  
  scala> isEqual(421, 421)
  res11: Boolean = true
```

In fact, the equality operation == in Scala is designed to be transparent with respect to the type's representation. For value types, it is the natural (numeric or boolean) equality. For reference types, == is treated as an alias of the equals method inherited from Object. That method is originally defined as reference equality, but is overridden by many subclasses to implement their natural notion of equality. This also means that in Scala you never fall into Java's well-known trap concerning string comparisons. In Scala, string comparison works as it should:

+ 事实上，`==`在数据类型中，作为自然比较。在引用类型，作为equals继承自Object的别名方法。那个方法原先是作为引用比较的，但是被子类重写实现了自然相等的概念。

```
  scala> val x = "abcd".substring(2)
  x: java.lang.String = cd
  
  scala> val y = "abcd".substring(2)
  y: java.lang.String = cd
  
  scala> x == y
  res12: Boolean = true
```

In Java, the result of comparing x with y would be false. The programmer should have used equals in this case, but it is easy to forget.

+ 在Java中x和y比较是false。

However, there are situations where you need reference equality instead of user-defined equality. For example, in some situations where efficiency is paramount, you would like to hash cons with some classes and compare their instances with reference equality.[2] For these cases, class AnyRef defines an additional eq method, which cannot be overridden and is implemented as reference equality (i.e., it behaves like == in Java for reference types). There's also the negation of eq, which is called ne. For example:

+ 当然有时也是需要来比较引用的。有时会用比较hash来引用比较实例。AnyRef中定义了附加方法eq和ne是不能被重写的，有点像Java中`==`比较的引用。

```
  scala> val x = new String("abc")
  x: java.lang.String = abc
  
  scala> val y = new String("abc")
  y: java.lang.String = abc
  
  scala> x == y
  res13: Boolean = true
  
  scala> x eq y
  res14: Boolean = false
  
  scala> x ne y
  res15: Boolean = true
```

Equality in Scala is discussed further in Chapter 28.

### 11.3 Bottom types

At the bottom of the type hierarchy in Figure 11.1 you see the two classes scala.Null and scala.Nothing. These are special types that handle some "corner cases" of Scala's object-oriented type system in a uniform way.

+ scala.Null and scala.Nothing

Class Null is the type of the null reference; it is a subclass of every reference class (i.e., every class that itself inherits from AnyRef). Null is not compatible with value types. You cannot, for example, assign a null value to an integer variable:

+ Null是null的引用，是所有引用类型的子类。Null不能用作数据类型。如下。

```
  scala> val i: Int = null
  <console>:4: error: type mismatch;
   found   : Null(null)
   required: Int
```

Type Nothing is at the very bottom of Scala's class hierarchy; it is a subtype of every other type. However, there exist no values of this type whatsoever. Why does it make sense to have a type without values? As discussed in Section 7.4, one use of Nothing is that it signals abnormal termination. For instance there's the error method in the Predef object of Scala's standard library, which is defined like this:

+ Nothing是Scala所有类的子类，就是没有值的意思。如下。

```scala
  def error(message: String): Nothing =
    throw new RuntimeException(message)
```

The return type of error is Nothing, which tells users that the method will not return normally (it throws an exception instead). Because Nothing is a subtype of every other type, you can use methods like error in very flexible ways. For instance:

+ Nothing是Int的子类，会用Exception来代替。

```scala
  def divide(x: Int, y: Int): Int = 
    if (y != 0) x / y 
    else error("can't divide by zero")
```

The "then" branch of the conditional, x / y, has type Int, whereas the else branch, the call to error, has type Nothing. Because Nothing is a subtype of Int, the type of the whole conditional is Int, as required.

### 11.4 Conclusion

In this chapter we showed you the classes at the top and bottom of Scala's class hierarchy. Now that you've gotten a good foundation on class inheritance in Scala, you're ready to understand mixin composition. In the next chapter, you'll learn about traits.

### Footnotes for Chapter 11:

[1] The reason the AnyRef alias exists, instead of just using the name java.lang.Object, is because Scala was designed to work on both the Java and .NET platforms. On .NET, AnyRef is an alias for System.Object.

[2] You hash cons instances of a class by caching all instances you have created in a weak collection. Then, any time you want a new instance of the class, you first check the cache. If the cache already has an element equal to the one you are about to create, you can reuse the existing instance. As a result of this arrangement, any two instances that are equal with equals() are also equal with reference equality.

