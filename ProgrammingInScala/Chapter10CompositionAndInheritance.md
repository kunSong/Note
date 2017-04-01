## Composition and Inheritance

### Vocabulary
+ liberal
+ vice versa
+ redundancy
+ concatenating
+ inadvertently
+ centralized
+ combo
+ advent
+ spiral

Chapter 6 introduced some basic object-oriented aspects of Scala. This chapter will pick up where Chapter 6 left off and dive with much greater detail into Scala's support for object-oriented programming. We'll compare two fundamental relationships between classes: composition and inheritance. Composition means one class holds a reference to another, using the referenced class to help it fulfill its mission. Inheritance is the superclass/subclass relationship. In addition to these topics, we'll discuss abstract classes, parameterless methods, extending classes, overriding methods and fields, parametric fields, invoking superclass constructors, polymorphism and dynamic binding, final members and classes, and factory objects and methods.

+ 这章继续讲述Scala面向对象的方面。组合和继承，组合是类中包含另一个引用类，继承是父类与子类的关系。还会加上这些话题，abstract classes, parameterless methods, extending classes, overriding methods and fields, parametric fields, invoking superclass constructors, polymorphism and dynamic binding, final members and classes, and factory objects and methods。

### 10.1 A two-dimensional layout library

As a running example in this chapter, we'll create a library for building and rendering two-dimensional layout elements. Each element will represent a rectangle filled with text. For convenience, the library will provide factory methods named "elem" that construct new elements from passed data. For example, you'll be able to create a layout element containing a string using a factory method with the following signature:

+ 我们会创建一个库来建立和实现二维的元素。每个元素会表现成用text填充的矩形。为了方便，这个库会提供工厂方法factory methods叫做"elem"，他是用来构造传入的数据变成元素的。用下面的函数签名来构造。

```
  elem(s: String): Element
```

As you can see, elements will be modeled with a type named Element. You'll be able to call above or beside on an element, passing in a second element, to get a new element that combines the two. For example, the following expression would construct a larger element consisting of two columns, each with a height of two:

+ elements会被构造出来，你还可以调用above和beside方法来构造第二个元素，合成二列。这里例子就是组成了两行两列的。

```
  val column1 = elem("hello") above elem("***")
  val column2 = elem("***") above elem("world")
  column1 beside column2
```

Printing the result of this expression would give:

```
  hello ***  
   *** world
```

Layout elements are a good example of a system in which objects can be constructed from simple parts with the aid of composing operators. In this chapter, we'll define classes that enable element objects to be constructed from arrays, lines, and rectangles—the simple parts. We'll also define composing operators above and beside. Such composing operators are also often called combinators because they combine elements of some domain into new elements.

+ 摆放元素是一个好的系统的例子，对象可以用简单的部分和构造操作的帮助来实现。我们会定义一些类来使元素可以从arrays，lines和rectangles等小部件中实现。我们也会定义组合操作符，比如above和beside，叫做整合器combinators，因为他们可以从一些领域合并元素到新元素。

Thinking in terms of combinators is generally a good way to approach library design: it pays to think about the fundamental ways to construct objects in an application domain. What are the simple objects? In what ways can more interesting objects be constructed out of simpler ones? How do combinators hang together? What are the most general combinations? Do they satisfy any interesting laws? If you have good answers to these questions, your library design is on track.

+ 就整合器而言是一个很好的方法来设计库：需要考虑基础的方法来构建对象在应用中。什么是简答对象？什么方法可以从简单的对象构建更有趣的东西呢？如何用整合器把他们弄到一起呢？什么是最通常的整合器呢？他们满足有趣的这规则吗？如果你有对这些问题好的回答，那你设计的库已经在正规上了。

### 10.2 Abstract classes

Our first task is to define type Element, which represents layout elements. Since elements are two dimensional rectangles of characters, it makes sense to include a member, contents, that refers to the contents of a layout element. The contents can be represented as an array of strings, where each string represents a line. Hence, the type of the result returned by contents will be Array[String]. Listing 10.1 shows what it will look like.

+ 第一个工作就是要定义一个类型Element，这是用来表示元素位置的。因为元素有两维的矩形字符，他是有意义的包括成员，内容，元素layout内容的引用。内容可以用Array[String]来表达，每个string表示一行。

```scala
    abstract class Element {
      def contents: Array[String]
    }
```

Listing 10.1 - Defining an abstract method and class.

In this class, contents is declared as a method that has no implementation. In other words, the method is an abstract member of class Element. A class with abstract members must itself be declared abstract, which is done by writing an abstract modifier in front of the class keyword:

+ contents方法被声明为没有实现的。换句话说这个方法是Element类的抽象成员。一个类有抽象成员，那这个类自己也要定义为抽象的，需要用一个abstract关键字在类前。

```
  abstract class Element ...
```

The abstract modifier signifies that the class may have abstract members that do not have an implementation. As a result, you cannot instantiate an abstract class. If you try to do so, you'll get a compiler error:

+ 如果抽象类成员没有被实现，那结果你不能实例化这个抽象类。会报编译错误。

```
  scala> new Element
  <console>:5: error: class Element is abstract;
      cannot be instantiated
         new Element
             ^
```

Later in this chapter you'll see how to create subclasses of class Element, which you'll be able to instantiate because they fill in the missing definition for contents.

+ 后面会看到如何创建Element的子类，你可以加入定义的内容并实例化。

Note that the contents method in class Element does not carry an abstract modifier. A method is abstract if it does not have an implementation (i.e., no equals sign or body). Unlike Java, no abstract modifier is necessary (or allowed) on method declarations. Methods that do have an implementation are called concrete.

+ 记住抽象类中的成员方法contents是没有abstract修饰符的。方法只要没有实现就是抽象的(没有等号和方法体)。不像Java，Java是需要abstract修饰符的在声明的时候。如果有实现的方法叫做具体物。

Another bit of terminology distinguishes between declarations and definitions. Class Element declares the abstract method contents, but currently defines no concrete methods. In the next section, however, we'll enhance Element by defining some concrete methods.

+ 另外的术语上的小区别是声明和定义。类Element声明了一个抽象方法，但是没有定义具体的方法。下一节，我们会定义一些具体的方法。

### 10.3 Defining parameterless methods

As a next step, we'll add methods to Element that reveal its width and height, as shown in Listing 10.2. The height method returns the number of lines in contents. The width method returns the length of the first line, or, if there are no lines in the element, zero. (This means you cannot define an element with a height of zero and a non-zero width.)

+ 第二步，我们会在Element中增加方法用来显示宽度和高度，如下。高度方法会返回内容中有多少行。宽度会返回第一行有多长，如果没有则是0。这意味着不能定义一个高度为0和宽度不为0的。

```scala
  abstract class Element {
    def contents: Array[String]
    def height: Int = contents.length
    def width: Int = if (height == 0) 0 else contents(0).length
  }
```

Listing 10.2 - Defining parameterless methods width and height.

Note that none of Element's three methods has a parameter list, not even an empty one. For example, instead of:

+ 注意这里的方法参数都是空的可以省略括号。

```
  def width(): Int
```

the method is defined without parentheses:

```
  def width: Int
```

Such parameterless methods are quite common in Scala. By contrast, methods defined with empty parentheses, such as def height(): Int, are called empty-paren methods. The recommended convention is to use a parameterless method whenever there are no parameters and the method accesses mutable state only by reading fields of the containing object (in particular, it does not change mutable state).

+ 这些省略括号的方法在Scala中很常见。有括号的那种叫empty-paren方法。推荐惯例是用午餐方法也就是后者无论何时没有参数和通过方法访问包含对象的字段变化状态。也就是不会改变变化状态。

This convention supports the uniform access principle,[1] which says that client code should not be affected by a decision to implement an attribute as a field or method. For instance, we could have chosen to implement width and height as fields instead of methods, simply by changing the def in each definition to a val:

+ 这个惯例需要支持同样的访问原则，就是调用者的代码不能被影响到，无论是用字段还是方法来实现属性。比如，我们可以用字段val来代替高度和宽度方法。

```scala
  abstract class Element {
    def contents: Array[String]
    val height = contents.length
    val width = 
      if (height == 0) 0 else contents(0).length
  }
```

The two pairs of definitions are completely equivalent from a client's point of view. The only difference is that field accesses might be slightly faster than method invocations, because the field values are pre-computed when the class is initialized, instead of being computed on each method call. On the other hand, the fields require extra memory space in each Element object. So it depends on the usage profile of a class whether an attribute is better represented as a field or method, and that usage profile might change over time. The point is that clients of the Element class should not be affected when its internal implementation changes.

+ 两者定义是完全相同的对于调用者来说。仅仅的不同是字段访问要比方法微微快点，因为类初始化的之前就已经计算好了，而不是像在调用方法是才计算。另一方面，字段需要额外的内存空间在每个元素对象中。所以取决于类的使用曲线来判断是否一个属性需要被表达成字段还是方法，使用空间也可能会改变。总之，Element类内部实现的变动不能影响调用者。

In particular, a client of class Element should not need to be rewritten if a field of that class gets changed into an access function so long as the access function is pure, i.e., it does not have any side effects and does not depend on mutable state. The client should not need to care either way.

+ 特点是调用者的代码不需要重写如果类中的字段变成了方法。比如没有赋值或取决于改变状态，调用者代码都不需要改变。

So far so good. But there's still a slight complication that has to do with the way Java handles things. The problem is that Java does not implement the uniform access principle. So it's string.length() in Java, not string.length (even though it's array.length, not array.length()). Needless to say, this is very confusing.

+ 现在已经不错了。但是还是有点和Java处理不太相同的。问题是Java没有实现统一访问原则。Java的String是`string.length()`不是`string.length`，而Java数组是`array.length`不是`array.length()`。很搞。

To bridge that gap, Scala is very liberal when it comes to mixing parameterless and empty-paren methods. In particular, you can override a parameterless method with an empty-paren method, and vice versa. You can also leave off the empty parentheses on an invocation of any function that takes no arguments. For instance, the following two lines are both legal in Scala:

+ 跨过这个鸿沟，Scala很自由的当他可以混着用parameterless`length()`和empty-paren`length`方法。特点是，你可以用empty-paren方法重写parameterless方法，反之亦然。你可以省略空括号当调用的时候没有入参。

```
  Array(1, 2, 3).toString // also Array(1, 2, 3).toString()
  "abc".length // also "abc".length()
```

In principle it's possible to leave out all empty parentheses in Scala function calls. However, it is recommended to still write the empty parentheses when the invoked method represents more than a property of its receiver object. For instance, empty parentheses are appropriate if the method performs I/O, or writes reassignable variables (vars), or reads vars other than the receiver's fields, either directly or indirectly by using mutable objects. That way, the parameter list acts as a visual clue that some interesting computation is triggered by the call. For instance:

+ 按照理论可以去掉所有空括号在Scala函数调用时。然而我们推荐还是写括号当不仅仅是用来表示一个接受对象的属性。比如，写空括号试用于方法进行IO操作，写变量，读取变量不是对象的字段，直接或间接使用可变对象。参数列表扮演了视觉线索好像一些有趣的计算被调用了。

```
  "hello".length  // no () because no side-effect
  println()       // better to not drop the ()
```

To summarize, it is encouraged style in Scala to define methods that take no parameters and have no side effects as parameterless methods, i.e., leaving off the empty parentheses. On the other hand, you should never define a method that has side-effects without parentheses, because then invocations of that method would look like a field selection. So your clients might be surprised to see the side effects. Similarly, whenever you invoke a function that has side effects, be sure to include the empty parentheses when you write the invocation. Another way to think about this is if the function you're calling performs an operation, use the parentheses, but if it merely provides access to a property, leave the parentheses off.

+ 总结，这是在Scala中鼓励的写法就是定义没有参数和没有赋值操作的parameterless方法把空括号去掉。另一方面，如果有赋值操作的，或是有一定操作的最好还是加上空括号，因为不加有点像字段选择。如果仅仅是提供访问属性，那是可以把括号去掉的。

### 10.4 Extending classes

We still need to be able to create new element objects. You have already seen that "new Element" cannot be used for this because class Element is abstract. To instantiate an element, therefore, we will need to create a subclass that extends Element and implements the abstract contents method. Listing 10.3 shows one possible way to do that:

+ 我们仍然需要创建一个新的元素对象。你已经看到"new Element"不能实现。因为Element类是抽象的。实例化一个元素，我们需要
一个子类来继承元素类，实现抽象方法contents。

```scala
    class ArrayElement(conts: Array[String]) extends Element {
      def contents: Array[String] = conts
    }
```

Listing 10.3 - Defining ArrayElement as a subclass of Element.

Class ArrayElement is defined to extend class Element. Just like in Java, you use an extends clause after the class name to express this:

+ 用extends关键词来继承自类Element。

```
  ... extends Element ...
```

Such an extends clause has two effects: it makes class ArrayElement inherit all non-private members from class Element, and it makes the type ArrayElement a subtype of the type Element. Given ArrayElement extends Element, class ArrayElement is called a subclass of class Element. Conversely, Element is a superclass of ArrayElement.

+ 这样一继承会有两个影响: 继承所有非私有成员从Element，有个新类型叫ArrayElement。ArrayElement是Element的子类，相反Element是其父类。

If you leave out an extends clause, the Scala compiler implicitly assumes your class extends from scala.AnyRef, which on the Java platform is the same as class java.lang.Object. Thus, class Element implicitly extends class AnyRef. You can see these inheritance relationships in Figure 10.1.

+ 如果不看extends，ArrayElement是默认继承自scala.AnyRef的，就像Java平台默认继承自java.lang.Object一样。Element是隐式继承自AnyRef，如图。

![Figure10.1](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure10.1.jpg)

Figure 10.1 - Class diagram for ArrayElement.

Inheritance means that all members of the superclass are also members of the subclass, with two exceptions. First, private members of the superclass are not inherited in a subclass. Second, a member of a superclass is not inherited if a member with the same name and parameters is already implemented in the subclass. In that case we say the member of the subclass overrides the member of the superclass. If the member in the subclass is concrete and the member of the superclass is abstract, we also say that the concrete member implements the abstract one.

+ 继承是所有父类成员都是子类成员，但是有两个异常。第一，父类私有成员不能在子类中继承。第二，如果父类中有相同名字和参数并在子类中已经实现的方法不能继承。这种情况叫做重写，如果父类是抽象的，子类是具体实现的叫做实现抽象方法。

For example, the contents method in ArrayElement overrides (or, alternatively: implements) abstract method contents in class Element.[2] By contrast, class ArrayElement inherits the width and height methods from class Element. For example, given an ArrayElement ae, you can query its width using ae.width, as if width were defined in class ArrayElement:

+ 比如ArrayElement实现了父类contents抽象方法，并继承了width和height从父类中。

```
  scala> val ae = new ArrayElement(Array("hello", "world"))
  ae: ArrayElement = ArrayElement@d94e60
  
  scala> ae.width
  res1: Int = 5
```

Subtyping means that a value of the subclass can be used wherever a value of the superclass is required. For example:

+ 子类型实例化val也可以种父类型。

```
  val e: Element = new ArrayElement(Array("hello"))
```

Variable e is defined to be of type Element, so its initializing value should also be an Element. In fact, the initializing value's type is ArrayElement. This is OK, because class ArrayElement extends class Element, and as a result, the type ArrayElement is compatible with the type Element.[3]

+ e被声明为Element，事实上是被实例化为类型ArrayElement。这样是可以的，因为ArrayElement继承自Element。

Figure 10.1 also shows the composition relationship that exists between ArrayElement and Array[String]. This relationship is called composition because class ArrayElement is "composed" out of class Array[String], in that the Scala compiler will place into the binary class it generates for ArrayElement a field that holds a reference to the passed conts array. We'll discuss some design considerations concerning composition and inheritance later in this chapter, in Section 10.11.

+ 图10.1中显示了ArrayElement和Array[String]的关系，这关系叫做组合composition。因为ArrayElement是通过Array[String]来组成的，编译器会通过字节码产生ArrayElement一个字段来持有这个Array[String]来引用传过来的conts array。

### 10.5 Overriding methods and fields

The uniform access principle is just one aspect where Scala treats fields and methods more uniformly than Java. Another difference is that in Scala, fields and methods belong to the same namespace. This makes it possible for a field to override a parameterless method. For instance, you could change the implementation of contents in class ArrayElement from a method to a field without having to modify the abstract method definition of contents in class Element, as shown in Listing 10.4:

+ 统一访问原则只是Scala对待字段和方法的相比Java更加统一。另一个区别在Scala中是，字段和方法是属于一个命名空间的。这样可以用字段来重写parameterless方法。比如你可以用字段改写contents方法这是一个在Element中没有用abstract来修饰的。

```scala
    class ArrayElement(conts: Array[String]) extends Element {
      val contents: Array[String] = conts
    }
```

Listing 10.4 - Overriding a parameterless method with a field.

Field contents (defined with a val) in this version of ArrayElement is a perfectly good implementation of the parameterless method contents (declared with a def) in class Element.

+ val contents要比def contents更好的实现。

On the other hand, in Scala it is forbidden to define a field and method with the same name in the same class, whereas it is allowed in Java. For example, this Java class would compile just fine:

+ 另一方面，在Scala中，定义相同名字字段和方法是不允许的。Java是可以的。

```java
  // This is Java
  class CompilesFine {
    private int f = 0;
    public int f() {
      return 1;
    }
  }
```

But the corresponding Scala class would not compile:

```scala
  class WontCompile {
    private var f = 0 // Won't compile, because a field 
    def f = 1         // and method have the same name
  }
```

Generally, Scala has just two namespaces for definitions in place of Java's four. Java's four namespaces are fields, methods, types, and packages. By contrast, Scala's two namespaces are:

+ Java有四个命名空间，分别是字段，方法，类型和包。Scala只有两个如下。

+ values (fields, methods, packages, and singleton objects)
+ types (class and trait names)

The reason Scala places fields and methods into the same namespace is precisely so you can override a parameterless method with a val, something you can't do with Java.[4]

### 10.6 Defining parametric fields

Consider again the definition of class ArrayElement shown in the previous section. It has a parameter conts whose sole purpose is to be copied into the contents field. The name conts of the parameter was chosen just so that it would look similar to the field name contents without actually clashing with it. This is a "code smell," a sign that there may be some unnecessary redundancy and repetition in your code.

+ 重新考虑类ArrayElement的定义，这里有个入参叫conts是用来做拷贝给contents字段的。"code smell"显示这里有些不必要的冗余和重复代码。

You can avoid the code smell by combining the parameter and the field in a single parametric field definition, as shown in Listing 10.5:

+ 你可以避免code smell，把字段和入参合并，如下。

```scala
    class ArrayElement(
      val contents: Array[String]
    ) extends Element
```

Listing 10.5 - Defining contents as a parametric field.

Note that now the contents parameter is prefixed by val. This is a shorthand that defines at the same time a parameter and field with the same name. Specifically, class ArrayElement now has an (unreassignable) field contents, which can be accessed from outside the class. The field is initialized with the value of the parameter. It's as if the class had been written as follows, where x123 is an arbitrary fresh name for the parameter:

+ 注意现在contents前缀有个val修饰。这是一个shorthand字段有和入参同样的名字。特别是，类ArrayElement现在有一个不可重新赋值的字段contents，可以被外部类访问。这个字段会用入参来初始化。类似于如下。

```scala
  class ArrayElement(x123: Array[String]) extends Element { 
    val contents: Array[String] = x123
  }
```

You can also prefix a class parameter with var, in which case the corresponding field would be reassignable. Finally, it is possible to add modifiers such as private, protected,[5] or override to these parametric fields, just as you can do for any other class member. Consider, for instance, the following class definitions:

+ 入参形式的字段可以用var开头，可以加修饰符private，protected，和override。

```scala
  class Cat {
    val dangerous = false
  }
  class Tiger(
    override val dangerous: Boolean,
    private var age: Int
  ) extends Cat
```

Tiger's definition is a shorthand for the following alternate class definition with an overriding member dangerous and a private member age:

+ 上面是下面这种的简写。

```scala
  class Tiger(param1: Boolean, param2: Int) extends Cat {
    override val dangerous = param1
    private var age = param2
  }
```

Both members are initialized from the corresponding parameters. We chose the names of those parameters, param1 and param2, arbitrarily. The important thing was that they not clash with any other name in scope.

### 10.7 Invoking superclass constructors

You now have a complete system consisting of two classes: an abstract class Element, which is extended by a concrete class ArrayElement. You might also envision other ways to express an element. For example, clients might want to create a layout element consisting of a single line given by a string. Object-oriented programming makes it easy to extend a system with new data-variants. You can simply add subclasses. For example, Listing 10.6 shows a LineElement class that extends ArrayElement:

+ 面向对象语言很容易的可以拓展ArrayElement，创建给定字符串的子类LineElement。

```scala
  class LineElement(s: String) extends ArrayElement(Array(s)) {
    override def width = s.length
    override def height = 1
  }
```

Listing 10.6 - Invoking a superclass constructor.

Since LineElement extends ArrayElement, and ArrayElement's constructor takes a parameter (an Array[String]), LineElement needs to pass an argument to the primary constructor of its superclass. To invoke a superclass constructor, you simply place the argument or arguments you want to pass in parentheses following the name of the superclass. For example, class LineElement passes Array(s) to ArrayElement's primary constructor by placing it in parentheses after the superclass ArrayElement's name:

+ 需要构造父类构造方法，在extends后面父类名后面括号中传入参数即可。

```
  ... extends ArrayElement(Array(s)) ...
```

With the new subclass, the inheritance hierarchy for layout elements now looks as shown in Figure 10.2.

![Figure10.2](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure10.2.jpg)

Figure 10.2 - Class diagram for LineElement.

### 10.8 Using override modifiers

Note that the definitions of width and height in LineElement carry an override modifier. In Section 6.3, you saw this modifier in the definition of a toString method. Scala requires such a modifier for all members that override a concrete member in a parent class. The modifier is optional if a member implements an abstract member with the same name. The modifier is forbidden if a member does not override or implement some other member in a base class. Since height and width in class LineElement override concrete definitions in class Element, override is required.

+ 注意override修饰符在重写父类具体化方法时都是需要的，但是如果这个方法在父类中是抽象的，那就可要可不要。这里height和width在LineElement的父类Element是具体化的方法，所以需要override修饰。

This rule provides useful information for the compiler that helps avoid some hard-to-catch errors and makes system evolution safer. For instance, if you happen to misspell the method or accidentally give it a different parameter list, the compiler will respond with an error message:

+ 如果override名字拼错了，编译器会报错。

```
  $ scalac LineElement.scala 
  .../LineElement.scala:50:
  error: method hight overrides nothing
    override def hight = 1
             ^ 
```

The override convention is even more important when it comes to system evolution. Say you defined a library of 2D drawing methods. You made it publicly available, and it is widely used. In the next version of the library you want to add to your base class Shape a new method with this signature:

```scala
  def hidden(): Boolean
```

Your new method will be used by various drawing methods to determine whether a shape needs to be drawn. This could lead to a significant speedup, but you cannot do this without the risk of breaking client code. After all, a client could have defined a subclass of Shape with a different implementation of hidden. Perhaps the client's method actually makes the receiver object disappear instead of testing whether the object is hidden. Because the two versions of hidden override each other, your drawing methods would end up making objects disappear, which is certainly not what you want! These "accidental overrides" are the most common manifestation of what is called the "fragile base class" problem. The problem is that if you add new members to base classes (which we usually call superclasses) in a class hierarchy, you risk breaking client code.

Scala cannot completely solve the fragile base class problem, but it improves on the situation compared to Java.[6] If the drawing library and its clients were written in Scala, then the client's original implementation of hidden could not have had an override modifier, because at the time there was no other method with that name. Once you add the hidden method to the second version of your shape class, a recompile of the client would give an error like the following:

```
  .../Shapes.scala:6: error: error overriding method
      hidden in class Shape of type ()Boolean;
  method hidden needs `override' modifier
  def hidden(): Boolean = 
  ^
```

That is, instead of wrong behavior your client would get a compile-time error, which is usually much preferable.

+ 在子类中定义了hidden方法，此时没有同名的方法定义的。如果要在父类中增加同签名的hidden方法，会到导致客户端代码的错乱，所以编译器在编译时会提示你需要在子类中的hidden方法前加入override修饰符。

### 10.9 Polymorphism and dynamic binding

You saw in Section 10.4 that a variable of type Element could refer to an object of type ArrayElement. The name for this phenomenon is polymorphism, which means "many shapes" or "many forms." In this case, Element objects can have many forms.[7] So far, you've seen two such forms: ArrayElement and LineElement. You can create more forms of Element by defining new Element subclasses. For example, here's how you could define a new form of Element that has a given width and height and is filled everywhere with a given character:

+ `val e: Element = new ArrayElement(Array("hello"))`这种叫做多态，意思是有很多形状或很多形式。这里Element有很多形式，比如ArrayElement和LineElement，当然也可以创建更多子类。

```scala
  class UniformElement(
    ch: Char, 
    override val width: Int,
    override val height: Int 
  ) extends Element {
    private val line = ch.toString * width
    // Using new API def contents = Array.fill(height){ line }
    def contents = Array.make(height, line)
  }
```

The inheritance hierarchy for class Element now looks as shown in Figure 10.3. As a result, Scala will accept all of the following assignments, because the assigning expression's type conforms to the type of the defined variable:

```scala
  val e1: Element = new ArrayElement(Array("hello", "world"))
  val ae: ArrayElement = new LineElement("hello")
  val e2: Element = ae
  val e3: Element = new UniformElement('x', 2, 3)
```

If you check the inheritance hierarchy, you'll find that in each of these four val definitions, the type of the expression to the right of the equals sign is below the type of the val being initialized to the left of the equals sign.

+ 等号右边的都是在继续关系下面于等号左边的。

![Figure10.3](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure10.3.jpg)

Figure 10.3 - Class hierarchy of layout elements

The other half of the story, however, is that method invocations on variables and expressions are dynamically bound. This means that the actual method implementation invoked is determined at run time based on the class of the object, not the type of the variable or expression. To demonstrate this behavior, we'll temporarily remove all existing members from our Element classes and add a method named demo to Element. We'll override demo in in ArrayElement and LineElement, but not in UniformElement:

+ 方法调用变量和表达式都是动态绑定的。意思是，被调用的实际方法实现是在运行时基于的类，不是所定义的类型。这里有个例子，去掉了所有Element中的函数，写了个demo方法。

```scala
  abstract class Element {
    def demo() {
      println("Element's implementation invoked")
    }
  }
  
  class ArrayElement extends Element {
    override def demo() {
      println("ArrayElement's implementation invoked")
    }
  }
  
  class LineElement extends ArrayElement {
    override def demo() {
      println("LineElement's implementation invoked")
    }
  }
  
  // UniformElement inherits Element's demo
  class UniformElement extends Element 
```

If you enter this code into the interpreter, you can then define this method that takes an Element and invokes demo on it:

```scala
  def invokeDemo(e: Element) {
    e.demo()
  }
```

If you pass an ArrayElement to invokeDemo, you'll see a message indicating ArrayElement's implementation of demo was invoked, even though the type of the variable, e, on which demo was invoked is Element:

+ 当你传入的是ArrayElement是，调用的是ArrayElement而不是Element中的。

```
  scala> invokeDemo(new ArrayElement)
  ArrayElement's implementation invoked
```

Similarly, if you pass a LineElement to invokeDemo, you'll see a message that indicates LineElement's demo implementation was invoked:

```
  scala> invokeDemo(new LineElement)
  LineElement's implementation invoked
```

The behavior when passing a UniformElement may at first glance look suspicious, but it is correct:

+ UniformElement没有重写demo方法。调用的是Element继承来的demo方法。

```
  scala> invokeDemo(new UniformElement)
  Element's implementation invoked
```

Because UniformElement does not override demo, it inherits the implementation of demo from its superclass, Element. Thus, Element's implementation is the correct implementation of demo to invoke when the class of the object is UniformElement.

### 10.10 Declaring final members

Sometimes when designing an inheritance hierarchy, you want to ensure that a member cannot be overridden by subclasses. In Scala, as in Java, you do this by adding a final modifier to the member. For example, you could place a final modifier on ArrayElement's demo method, as shown in Listing 10.7.

+ 有时设计继承关系，你可能想保证某个成员不想被子类重写。Scala像Java一样在成员前加上final修饰符。

```scala
    class ArrayElement extends Element {
      final override def demo() {
        println("ArrayElement's implementation invoked")
      }
    }
```

Listing 10.7 - Declaring a final method.

Given this version of ArrayElement, an attempt to override demo in its subclass, LineElement, would not compile:

+ ArrayElement的子类LineElement不能重写，会编译错误。

```
  elem.scala:18: error: error overriding method demo
     in class ArrayElement of type ()Unit;
  method demo cannot override final member
      override def demo() {
                   ^
```

You may also at times want to ensure that an entire class not be subclassed. To do this you simply declare the entire class final by adding a final modifier to the class declaration. For example, Listing 10.8 shows how you would declare ArrayElement final:

+ 你可能希望整个类都不能被继承，在class前加final。

```scala
    final class ArrayElement extends Element {
      override def demo() {
        println("ArrayElement's implementation invoked")
      }
    }
```

Listing 10.8 - Declaring a final class.

With this version of ArrayElement, any attempt at defining a subclass would fail to compile:

+ 这样LineElement就不能被继承了。

```
  elem.scala: 18: error: illegal inheritance from final class
      ArrayElement
    class LineElement extends ArrayElement {
                              ^
```

We'll now remove the final modifiers and demo methods, and go back to the earlier implementation of the Element family. We'll focus our attention in the remainder of this chapter to completing a working version of the layout library.

### 10.11 Using composition and inheritance

Composition and inheritance are two ways to define a new class in terms of another existing class. If what you're after is primarily code reuse, you should in general prefer composition to inheritance. Only inheritance suffers from the fragile base class problem, in which you can inadvertently break subclasses by changing a superclass.

+ 组合和继承是以其他以存在类再定义新类的方法。如果你追求的主要是代码复用，比起组合更喜欢继承。只有继承会受到基类易碎问题，但你可以改变父类。

One question you can ask yourself about an inheritance relationship is whether it models an is-a relationship.[8] For example, it would be reasonable to say that ArrayElement is-an Element. Another question you can ask is whether clients will want to use the subclass type as a superclass type.[9] In the case of ArrayElement, we do indeed expect clients will want to use an ArrayElement as an Element.

+ 问题一，继承关系是不是is-a的关系，ArrayElement is-an Element。问题二，调用者希望用子类类型代替父类类型，ArrayElement as an Element。

If you ask these questions about the inheritance relationships shown in Figure 10.3, do any of the relationships seem suspicious? In particular, does it seem obvious to you that a LineElement is-an ArrayElement? Do you think clients would ever need to use a LineElement as an ArrayElement? In fact, we defined LineElement as a subclass of ArrayElement primarily to reuse ArrayElement's definition of contents. Perhaps it would be better, therefore, to define LineElement as a direct subclass of Element, like this:

+ 我们定义LineElement主要是想重用ArrayElement定义的内容。那像如下直接定义LineElement作为Element的子类。

```scala
  class LineElement(s: String) extends Element {
    val contents = Array(s)
    override def width = s.length
    override def height = 1
  }
```

In the previous version, LineElement had an inheritance relationship with ArrayElement, from which it inherited contents. It now has a composition relationship with Array: it holds a reference to an array of strings from its own contents field.[10] Given this implementation of LineElement, the inheritance hierarchy for Element now looks as shown in Figure 10.4.

+ 之前LineElement继承自ArrayElement，现在他有个和Array的组合关系。他持有Array of strings的引用在自己的字段上。

![Figure10.4](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure10.4.jpg)

Figure 10.4 - Class hierarchy with revised LineElement.

### 10.12 Implementing above, beside, and toString

As a next step, we'll implement method above in class Element. Putting one element above another means concatenating the two contents values of the elements. So a first draft of method above could look like this:

+ 第二步，我们要实现above方法在Element中。把一个元素放在另一个上面意思是将两个元素的内容值连接。

```scala
  def above(that: Element): Element =
    new ArrayElement(this.contents ++ that.contents)
```

The ++ operation concatenates two arrays. Arrays in Scala are represented as Java arrays, but support many more methods. Specifically, arrays in Scala inherit from a class scala.Seq, which represents sequence-like structures and contains a number of methods for accessing and transforming sequences. Some other array methods will be explained in this chapter, and a comprehensive discussion will be given in Chapter 17.

+ `++`操作连接两个arrays并返回新的arrays。Scala.Array是继承自Scala.Seq，sequence-like结构含有许多访问和改造sequences的方法。

In fact, the code shown previously is not quite sufficient, because it does not permit you to put elements of different widths on top of each other. To keep things simple in this section, however, we'll leave this as is and only pass elements of the same length to above. In Section 10.14, we'll make an enhancement to above so that clients can use it to combine elements of different widths.

+ 不同宽度的元素我们10.14讲。

The next method to implement is beside. To put two elements beside each other, we'll create a new element in which every line results from concatenating corresponding lines of the two elements. As before, to keep things simple we'll start by assuming the two elements have the same height. This leads to the following design of method beside:

+ 下一个方法是现实beside。把两个元素放在旁边一起，我们创建一个新元素，每行都将连接两个元素成一行。保证高度都是一样的。

```scala
  def beside(that: Element): Element = {
    val contents = new Array[String](this.contents.length)
    for (i <- 0 until this.contents.length) 
      contents(i) = this.contents(i) + that.contents(i)
    new ArrayElement(contents)
  }
```

The beside method first allocates a new array, contents, and fills it with the concatenation of the corresponding array elements in this.contents and that.contents. It finally produces a new ArrayElement containing the new contents.

+ beside方法先创建了一个array，内容是用两个arrays中的元素连接来填充。最后产生一个新的ArrayElement包含这个array。

Although this implementation of beside works, it is in an imperative style, the telltale sign of which is the loop in which we index through arrays. The method could alternatively be abbreviated to one expression:

+ 上面是命令式的编写方式，使用index来循环。下面还有种写法。

```scala
  new ArrayElement(
    for (
      (line1, line2) <- this.contents zip that.contents
    ) yield line1 + line2
  )
```

Here, the two arrays this.contents and that.contents are transformed into an array of pairs (as Tuple2s are called) using the zip operator. The zip method picks corresponding elements in its two arguments and forms an array of pairs. For instance, this expression:

+ 使用zip操作符，其实是Array的一个方法，调用Tuple2来产生一个pair对，this.contents and that.contents放在一个新的Array中。如下。

```
  Array(1, 2, 3) zip Array("a", "b")
```

will evaluate to:

```
  Array((1, "a"), (2, "b"))
```

If one of the two operand arrays is longer than the other, zip will drop the remaining elements. In the expression above, the third element of the left operand, 3, does not form part of the result, because it does not have a corresponding element in the right operand.

+ 如果其中有一个数组长于另一个，那zip会丢弃剩下的元素。这上面那个表达式中，第三个元素3就被丢弃了。因为没有对应的元素在右面的array中。

The zipped array is then iterated over by a for expression. Here, the syntax "for ((line1, line2) <- ...)" allows you to name both elements of a pair in one pattern, i.e., line1 stands now for the first element of the pair, and line2 stands for the second. Scala's pattern-matching system will be described in detail in Chapter 15. For now, you can just think of this as a way to define two vals, line1 and line2, for each step of the iteration.

+ Chapter15 pattern-matching会详解。这里就是表示line1为第一个元素，line2为第二个。

The for expression has a yield part and therefore yields a result. The result is of the same kind as the expression iterated over, i.e., it is an array. Each element of the array is the result of concatenating the corresponding lines, line1 and line2. So the end result of this code is the same as in the first version of beside, but because it avoids explicit array indexing, the result is obtained in a less error-prone way.

+ yield只是产生了相当于一行line1+line2，for进行迭代并返回一个好几行的arrays。

You still need a way to display elements. As usual, this is done by defining a toString method that returns an element formatted as a string. Here is its definition:

+ 定义toString方法。

```
  override def toString = contents mkString "\n"
```

The implementation of toString makes use of mkString, which is defined for all sequences, including arrays. As you saw in Section 7.8, an expression like "arr mkString sep" returns a string consisting of all elements of the array arr. Each element is mapped to a string by calling its toString method. A separator string sep is inserted between consecutive element strings. So the expression "contents mkString "\n"" formats the contents array as a string, where each array element appears on a line by itself.

+ mkString方法是所以sequence都可以用的。通过"\n"来分割元素并形成字符串。

Note that toString does not carry an empty parameter list. This follows the recommendations for the uniform access principle, because toString is a pure method that does not take any parameters.

+ 因为toString是个纯方法没有需要任何入参，follow统一访问原则不需要后面有括号。

With the addition of these three methods, class Element now looks as shown in Listing 10.9.

```scala
    abstract class Element {
  
      def contents: Array[String]
  
      def width: Int =
        if (height == 0) 0 else contents(0).length
  
      def height: Int = contents.length
  
      def above(that: Element): Element =
        new ArrayElement(this.contents ++ that.contents)
  
      def beside(that: Element): Element =
        new ArrayElement(
          for (
            (line1, line2) <- this.contents zip that.contents
          ) yield line1 + line2
        )
  
      override def toString = contents mkString "\n"
    }
```

Listing 10.9 - Class Element with above, beside, and toString.

### 10.13 Defining a factory object

You now have a hierarchy of classes for layout elements. This hierarchy could be presented to your clients "as is." But you might also choose to hide the hierarchy behind a factory object. A factory object contains methods that construct other objects. Clients would then use these factory methods for object construction rather than constructing the objects directly with new. An advantage of this approach is that object creation can be centralized and the details of how objects are represented with classes can be hidden. This hiding will both make your library simpler for clients to understand, because less detail is exposed, and provide you with more opportunities to change your library's implementation later without breaking client code.

+ 现在的继承关系可以表达为as is了。但是我们不想把这继承关系暴露给调用者，我们就需要建立一个工厂对象用其中的方法来构建其他的对象，而不是直接new。好处是可以集中创建对象，至于类如何表达这个对象会被隐藏。这样库就能使调用者很轻易的理解，因为很少的具体实现暴露给他，同时也提供了更好的机会来修改的代码不影响调用者。

The first task in constructing a factory for layout elements is to choose where the factory methods should be located. Should they be members of a singleton object or of a class? What should the containing object or class be called? There are many possibilities. A straightforward solution is to create a companion object of class Element and make this be the factory object for layout elements. That way, you need to expose only the class/object combo of Element to your clients, and you can hide the three implementation classes ArrayElement, LineElement, and UniformElement.

+ 最直接的办法是创建一个伴随对象companion object of class Element。

```scala
    object Element {
  
      def elem(contents: Array[String]): Element = 
        new ArrayElement(contents)
  
      def elem(chr: Char, width: Int, height: Int): Element = 
        new UniformElement(chr, width, height)
  
      def elem(line: String): Element = 
        new LineElement(line)
    }
```

Listing 10.10 - A factory object with factory methods.

Listing 10.10 is a design of the Element object that follows this scheme. The Element companion object contains three overloaded variants of an elem method. Each variant constructs a different kind of layout object.

+ 上述代码创建了Element的伴随对象，并且有三个重载的方法。

With the advent of these factory methods, it makes sense to change the implementation of class Element so that it goes through the elem factory methods rather than creating new ArrayElement instances explicitly. To call the factory methods without qualifying them with Element, the name of the singleton object, we will import Element.elem at the top of the source file. In other words, instead of invoking the factory methods with Element.elem inside class Element, we'll import Element.elem so we can just call the factory methods by their simple name, elem. Listing 10.11 shows what class Element will look like after these changes.

+ 为了调用工厂对象的方法，需要将单例对象singleton object的名字用import导入。伴随对象也是写在定义class Element的文件中，但是仍然是需要导包才能访问到，已测试。如下。

```scala
    import Element.elem
  
    abstract class Element {
  
      def contents: Array[String]
  
      def width: Int =
        if (height == 0) 0 else contents(0).length
  
      def height: Int = contents.length
  
      def above(that: Element): Element =
        elem(this.contents ++ that.contents)
  
      def beside(that: Element): Element =
        elem(
          for (
            (line1, line2) <- this.contents zip that.contents
          ) yield line1 + line2
        )
  
      override def toString = contents mkString "\n"
    }
```

Listing 10.11 - Class Element refactored to use factory methods.

In addition, given the factory methods, the subclasses ArrayElement, LineElement and UniformElement could now be private, because they need no longer be accessed directly by clients. In Scala, you can define classes and singleton objects inside other classes and singleton objects. One way to make the Element subclasses private, therefore, is to place them inside the Element singleton object and declare them private there. The classes will still be accessible to the three elem factory methods, where they are needed. Listing 10.12 shows how that will look.

+ 在Scala可以定义类和对象在其他的类和对象中。ArrayElement, LineElement and UniformElement这三个子类只有通过用private来修饰并放在object Element中，这样调用者代码就不可以直接访问他们了。如果单纯的只是在class前加private，没有方法在Element的singleton object中，其他调用者还是可以访问，已测试。如下。

```scala
    object Element {
  
      private class ArrayElement(
        val contents: Array[String]
      ) extends Element
  
      private class LineElement(s: String) extends Element {
        val contents = Array(s)
        override def width = s.length
        override def height = 1
      }
  
      private class UniformElement(
        ch: Char,
        override val width: Int,
        override val height: Int
      ) extends Element {
        private val line = ch.toString * width
        def contents = Array.make(height, line)
      }
  
      def elem(contents:  Array[String]): Element =
        new ArrayElement(contents)
  
      def elem(chr: Char, width: Int, height: Int): Element =
        new UniformElement(chr, width, height)
  
      def elem(line: String): Element =
        new LineElement(line)
    }
```

Listing 10.12 - Hiding implementation with private classes.

### 10.14 Heighten and widen

We need one last enhancement. The version of Element shown in Listing 10.11 is not quite sufficient, because it does not allow clients to place elements of different widths on top of each other, or place elements of different heights beside each other. For example, evaluating the following expression would not work correctly, because the second line in the combined element is longer than the first:

+ 我们需要最后的升级，调用者不能控制变化的宽度和高度。如下就是不等长。

```scala
  new ArrayElement(Array("hello")) above 
  new ArrayElement(Array("world!"))
```

Similarly, evaluating the following expression would not work properly, because the first ArrayElement has a height of two, and the second a height of only one:

+ 如下不等高。

```scala
  new ArrayElement(Array("one", "two")) beside 
  new ArrayElement(Array("one"))
```

Listing 10.13 shows a private helper method, widen, which takes a width and returns an Element of that width. The result contains the contents of this Element, centered, padded to the left and right by any spaces needed to achieve the required width. Listing 10.13 also shows a similar method, heighten, which performs the same function in the vertical direction. The widen method is invoked by above to ensure that Elements placed above each other have the same width. Similarly, the heighten method is invoked by beside to ensure that elements placed beside each other have the same height. With these changes, the layout library is ready for use.

+ 这里增加了两个小的帮助函数widten和heighten，取width或height返回给定width的Element。例如widthen，上面长于下面返回上面，下面长于上面，就要在上面的左边和右边利用UniformElement类构造空格元素，并用beside将他们和原Element进行拼接。形成等宽。左边用`(w1 - w2) /2`，右边用`(w1 - w2 - left)`。

```scala
  import Element.elem
  
  abstract class Element {
    def contents:  Array[String]
  
    def width: Int = contents(0).length
    def height: Int = contents.length
  
    def above(that: Element): Element = {
      val this1 = this widen that.width
      val that1 = that widen this.width
      elem(this1.contents ++ that1.contents)
    }
  
    def beside(that: Element): Element = {
      val this1 = this heighten that.height
      val that1 = that heighten this.height
      elem(
        for ((line1, line2) <- this1.contents zip that1.contents) 
        yield line1 + line2)
    }
  
    def widen(w: Int): Element = 
      if (w <= width) this
      else {
        val left = elem(' ', (w - width) / 2, height) 
        var right = elem(' ', w - width - left.width, height)
        left beside this beside right
      }
  
    def heighten(h: Int): Element = 
      if (h <= height) this
      else {
        val top = elem(' ', width, (h - height) / 2)
        var bot = elem(' ', width, h - height - top.height)
        top above this above bot
      }
  
    override def toString = contents mkString "\n"
  }
```

Listing 10.13 - Element with widen and heighten methods.

### 10.15 Putting it all together

A fun way to exercise almost all elements of the layout library is to write a program that draws a spiral with a given number of edges. This Spiral program, shown in Listing 10.14, will do just that:

+ 练习画螺旋线用给定的边数。

```scala
  import Element.elem
  
  object Spiral {
  
    val space = elem(" ")
    val corner = elem("+")
  
    def spiral(nEdges: Int, direction: Int): Element = {
      if (nEdges == 1)
        elem("+")
      else {
        val sp = spiral(nEdges - 1, (direction + 3) % 4)
        def verticalBar = elem('|', 1, sp.height)
        def horizontalBar = elem('-', sp.width, 1)
        if (direction == 0)
          (corner beside horizontalBar) above (sp beside space)
        else if (direction == 1)
          (sp above space) beside (corner above verticalBar)
        else if (direction == 2)
          (space beside sp) above (horizontalBar beside corner)
        else
          (verticalBar above corner) beside (space above sp)
      }
    }
  
    def main(args: Array[String]) {
      val nSides = args(0).toInt
      println(spiral(nSides, 0))
    }
  }
```

Listing 10.14 - The Spiral application.

Because Spiral is a standalone object with a main method with the proper signature, it is a Scala application. Spiral takes one command-line argument, an integer, and draws a spiral with the specified number of edges. For example, you could draw a six-edge spiral as shown below on the left, and larger spirals as shown to the right:

```
  $ scala Spiral 6    $ scala Spiral 11    $ scala Spiral 17
  +-----              +----------          +----------------
  |                   |                    |                
  | +-+               | +------+           | +------------+ 
  | + |               | |      |           | |            | 
  |   |               | | +--+ |           | | +--------+ | 
  +---+               | | |  | |           | | |        | | 
                      | | ++ | |           | | | +----+ | | 
                      | |    | |           | | | |    | | | 
                      | +----+ |           | | | | ++ | | | 
                      |        |           | | | |  | | | | 
                      +--------+           | | | +--+ | | | 
                                           | | |      | | | 
                                           | | +------+ | | 
                                           | |          | | 
                                           | +----------+ | 
                                           |              | 
                                           +--------------+ 
```

### 10.16 Conclusion

In this section, you saw more concepts related to object-oriented programming in Scala. Among others, you encountered abstract classes, inheritance and subtyping, class hierarchies, parametric fields, and method overriding. You should have developed a feel for constructing a non-trivial class hierarchy in Scala. We'll work with the layout library again in Chapter 14.

### Footnotes for Chapter 10:

[1] Meyer, Object-Oriented Software Construction meyer:oo-soft-con

[2] One flaw with this design is that because the returned array is mutable, clients could change it. For the book we'll keep things simple, but were ArrayElement part of a real project, you might consider returning a defensive copy of the array instead. Another problem is we aren't currently ensuring that every String element of the contents array has the same length. This could be solved by checking the precondition in the primary constructor, and throwing an exception if it is violated.

[3] For more perspective on the difference between subclass and subtype, see the glossary entry for subtype.

[4] The reason that packages share the same namespace as fields and methods in Scala is to enable you to import packages in addition to just importing the names of types, and the fields and methods of singleton objects. This is also something you can't do in Java. It will be described in Section 13.2.

[5] The protected modifier, which grants access to subclasses, will be covered in detail in Chapter 13.

[6] In Java 1.5, an @Override annotation was introduced that works similarly to Scala's override modifier, but unlike Scala's override, is not required.

[7] This kind of polymorphism is called subtyping polymorphism. Another kind of polymorphism in Scala, called universal polymorphism, is discussed in Chapter 19.

[8] Meyers, Effective C++ meyers:effective-cpp

[9] Eckel, Thinking in Java eckel:thinking-in-java

[10] Class ArrayElement also has a composition relationship with Array, because its parametric contents field holds a reference to an array of strings. The code for ArrayElement is shown in Listing 10.5 here. Its composition relationship is represented in class diagrams by a diamond, as shown, for example, in Figure 10.1 here.
