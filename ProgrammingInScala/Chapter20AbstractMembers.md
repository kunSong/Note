## Abstract Members

### Vocabulary
+ resembles
+ subtle
+ analogous
+ analogy
+ exemplifies

A member of a class or trait is abstract if the member does not have a complete definition in the class. Abstract members are intended to be implemented in subclasses of the class in which they are declared. This idea is found in many object-oriented languages. For instance, Java lets you declare abstract methods. Scala also lets you declare such methods, as you saw in Section 10.2. But Scala goes beyond that and implements the idea in its full generality: besides methods, you can also declare abstract fields and even abstract types as members of classes and traits.

+  抽象class或者trait的成员没有完成实现定义，抽象成员可以在子类中实现。Scala中除了抽象方法，还有抽象字段和抽象类型作为class或trait的成员

In this chapter we'll describe all four kinds of abstract member: vals, vars, methods, and types. Along the way we'll discuss pre-initialized fields, lazy vals, path-dependent types, and enumerations.

+ 讨论内容看下。

### 20.1 A quick tour of abstract members

The following trait declares one of each kind of abstract member: an abstract type (T), method (transform), val (initial), and var (current):

+ 如下定义了抽象成员。

```
  trait Abstract {
    type T
    def transform(x: T): T
    val initial: T
    var current: T
  }
```

A concrete implementation of Abstract needs to fill in definitions for each of its abstract members. Here is an example implementation that provides these definitions:

+ 具体抽象类的实现。

```
  class Concrete extends Abstract {
    type T = String
    def transform(x: String) = x + x
    val initial = "hi"
    var current = initial
  }
```

The implementation gives a concrete meaning to the type name T by defining it as an alias of type String. The transform operation concatenates a given string with itself, and the initial and current values are both set to "hi".

+ type T定义为type String的别名。其他的进行了实现和初始化。

This example gives you a rough first idea of what kinds of abstract members exist in Scala. The remainder of the chapter will present the details and explain what the new forms of abstract members, as well as type members in general, are good for.

+ null

### 20.2 Type members

As you can see from the example in the previous section, the term abstract type in Scala means a type declared (with the "type" keyword) to be a member of a class or trait, without specifying a definition. Classes themselves may be abstract, and traits are by definition abstract, but neither of these are what are referred to as abstract types in Scala. An abstract type in Scala is always a member of some class or trait, such as type T in trait Abstract.

+ 一个抽象类型abstract type永远是一个class或trait的成员。

You can think of a non-abstract (or, "concrete") type member, such as type T in class Concrete, as a way to define a new name, or alias, for a type. In class Concrete, for example, the type String is given the alias T. As a result, anywhere T appears in the definition of class Concrete, it means String. This includes the parameter and result types of transform, initial, and current, which mention T when they are declared in supertrait Abstract. Thus, when class Concrete implements these methods, those Ts are interpreted to mean String.

+ 定义非抽象的type成员，可以给类型起新的名字或别名。例如，在定义的类中出现T，那就是代表String类型。

One reason to use a type member is to define a short, descriptive alias for a type whose real name is more verbose, or less obvious in meaning, than the alias. Such type members can help clarify the code of a class or trait. The other main use of type members is to declare abstract types that must be defined in subclasses. This use, which was demonstrated in the previous section, will be described in detail later in this chapter.

+ 第一个目的是为了简洁，更容易检查代码。第二个目的是父类定义抽象type，子类可以来继承实现。

### 20.3 Abstract vals

An abstract val declaration has a form like:

+ 抽象val的定义如下。

```
  val initial: String
```

It gives a name and type for a val, but not its value. This value has to be provided by a concrete val definition in a subclass. For instance, class Concrete implemented the val using:

+ 提供了名字和类型，但没有值。值是在子类中实现的。

```
  val initial = "hi"
```

You use an abstract val declaration in a class when you do not know the correct value in the class, but you do know that the variable will have an unchangeable value in each instance of the class.

+ 你可以来使用这个抽象的val当你不知道准确值的时候，但是你要知道这是一个不可改变的变量在每个实例类中。

An abstract val declaration resembles an abstract parameterless method declaration such as:

+ 抽象val定义类似于一个没有括号的的抽象方法定义，如下。

```
  def initial: String
```

Client code would refer to both the val and the method in exactly the same way, i.e., obj.initial. However, if initial is an abstract val, the client is guaranteed that obj.initial will yield the same value every time it is referenced. If initial were an abstract method, that guarantee would not hold, because in that case initial could be implemented by a concrete method that returns a different value every time it's called.

+ 调用者可以通过`obj.initial`来调用val和method。如果initial是abstract val，那保证调用者每次得到的引用值是相同的。而如果是abstract method，那具体子类实现的方法，得到的值会不同。

In other words, an abstract val constrains its legal implementation: any implementation must be a val definition; it may not be a var or a def. Abstract method declarations, on the other hand, may be implemented by both concrete method definitions and concrete val definitions. Given the abstract class Fruit shown in Listing 20.1, class Apple would be a legal subclass implementation, but class BadApple would not.

+ abstract method可以被子类用method和val override，但是abstract val只能是val。

```
  abstract class Fruit {
    val v: String // `v' for value
    def m: String // `m' for method
  }
  
  abstract class Apple extends Fruit {
    val v: String
    val m: String // OK to override a `def' with a `val'
  }
  
  abstract class BadApple extends Fruit {
    def v: String // ERROR: cannot override a `val' with a `def'
    def m: String
  }
```

Listing 20.1 - Overriding abstract vals and parameterless methods.

### 20.4 Abstract vars

Like an abstract val, an abstract var declares just a name and a type, but not an initial value. For instance, Listing 20.2 shows a trait AbstractTime, which declares two abstract variables named hour and minute:

+ 像abstract val一样，var也定义了名字和类型。

```
    trait AbstractTime {
      var hour: Int
      var minute: Int
    }
```

Listing 20.2 - Declaring abstract vars.

What is the meaning of abstract vars like hour and minute? You saw in Section 18.2 that vars declared as members of classes come equipped with getter and setter methods. This holds for abstract vars as well. If you declare an abstract var named hour, for example, you implicitly declare an abstract getter method, hour, and an abstract setter method, hour_=. There's no reassignable field to be defined—that will come in subclasses that define the concrete implementation of the abstract var. For instance, the definition of AbstractTime shown in Listing 20.2 is exactly equivalent to the definition shown in Listing 20.3.

+ 在18.2节你看到定以vars会配备getter和setter。同理定以abstract vars也会隐式定以abstract getter和abstract setter方法。如下。这里不会有可赋值字段定义会在子类中具体实现abstract var。

```
    trait AbstractTime {
      def hour: Int          // getter for `hour'
      def hour_=(x: Int)     // setter for `hour'
      def minute: Int        // getter for `minute'
      def minute_=(x: Int)   // setter for `minute'
    }
```

Listing 20.3 - How abstract vars are expanded into getters and setters.

### 20.5 Initializing abstract vals

Abstract vals sometimes play a role analogous to superclass parameters: they let you provide details in a subclass that are missing in a superclass. This is particularly important for traits, because traits don't have a constructor to which you could pass parameters. So the usual notion of parameterizing a trait works via abstract vals that are implemented in subclasses. As an example, consider a reformulation of class Rational from Chapter 6, as shown in Listing 6.5 here, as a trait:

+ abstract vals有时扮演了一个类似父类构造参数，父类中没有的在子类中提供具体的。特别重要的是traits，因为trait没有构造方法你可以传构造参数给他。所以可以用abstract val来在子类中实现。下面是Chapter 6的重新构造的Rational。

```
  trait RationalTrait { 
    val numerArg: Int 
    val denomArg: Int 
  } 
```

The Rational class from Chapter 6 had two parameters: n for the numerator of the rational number, and d for the denominator. The RationalTrait trait given here defines instead two abstract vals: numerArg and denomArg. To instantiate a concrete instance of that trait, you need to implement the abstract val definitions. Here's an example:

+ Chapter 6的Rational类有两个参数一个是分子一个是分母。RationalTrait用两个abstract val来定义。如果要实例化一个trait实例，需要实现absract val的定义。

```
  new RationalTrait {
    val numerArg = 1
    val denomArg = 2
  }
```

Here the keyword new appears in front of a trait name, RationalTrait, which is followed by a class body in curly braces. This expression yields an instance of an anonymous class that mixes in the trait and is defined by the body. This particular anonymous class instantiation has an effect analogous to the instance creation new Rational(1, 2). The analogy is not perfect, however. There's a subtle difference concerning the order in which expressions are initialized. When you write:

+ new关键字来实例化一个RationalTrait，后面大括号中是类体，这个实例化了一个匿名类mix-in了一个trait。类似于`new Rational(1, 2)`，但是这样类比不是很好，考虑到如果写成如下表达式就会有微妙的不同在初始化的先后顺序。

```
  new Rational(expr1, expr2)
```

the two expressions, expr1 and expr2, are evaluated before class Rational is initialized, so the values of expr1 and expr2 are available for the initialization of class Rational. For traits, however, the situation is the opposite. When you write:

+ expr1和expr2在类Rational初始化前就已经被评估了，所以他们是Rational初始化时可以访问的。但是对于trait来说就是相反的。

```
  new RationalTrait {
    val numerArg = expr1
    val denomArg = expr2
  }
```

the expressions, expr1 and expr2, are evaluated as part of the initialization of the anonymous class, but the anonymous class is initialized after the RationalTrait. So the values of numerArg and denomArg are not available during the initialization of RationalTrait (more precisely, a selection of either value would yield the default value for type Int, 0). For the definition of RationalTrait given previously, this is not a problem, because the trait's initialization does not make use of values numerArg or denomArg. However, it does become a problem in the variant of RationalTrait shown in Listing 20.4, which defines normalized numerators and denominators:

+ expr1和expr2的评估是匿名类初始化的一部分，而匿名类初始化是在RationalTrait初始化之后。所以这两个abstract val在RationalTrait初始化的时候是访问不到的，如果是Int型会给一个默认的0。因为上面代码这两个值没有用到，所以没关系。但是看下面的代码这两个值被用到了，就会有问题。当new的时候会报错。

```
    trait RationalTrait { 
      val numerArg: Int 
      val denomArg: Int 
      require(denomArg != 0)
      private val g = gcd(numerArg, denomArg)
      val numer = numerArg / g
      val denom = denomArg / g
      private def gcd(a: Int, b: Int): Int = 
        if (b == 0) a else gcd(b, a % b)
      override def toString = numer +"/"+ denom
    }
```

Listing 20.4 - A trait that uses its abstract vals.

If you try to instantiate this trait with some numerator and denominator expressions that are not simple literals, you'll get an exception:

+ null

```
  scala> val x = 2
  x: Int = 2
  
  scala> new RationalTrait {
           val numerArg = 1 * x
           val denomArg = 2 * x
         }
  java.lang.IllegalArgumentException: requirement failed
          at scala.Predef$.require(Predef.scala:107)
          at RationalTrait$class.$init$(<console>:7)
          at $anon$1.<init>(<console>:7)
          ....
```

The exception in this example was thrown because denomArg still had its default value of 0 when class RationalTrait was initialized, which caused the require invocation to fail.

+ 因为在RationalTrait初始化的时候始终还是0，所以报了require的错。

This example demonstrates that initialization order is not the same for class parameters and abstract fields. A class parameter argument is evaluated before it is passed to the class constructor (unless the parameter is by-name). An implementing val definition in a subclass, by contrast, is evaluated only after the superclass has been initialized.

+ 所以证明了类构造参数和abstract val的初始化顺序有区别的。前者在类构造前就初始化好了，后在是在子类中实现，需要在父类初始化后在被评估的。

Now that you understand why abstract vals behave differently from parameters, it would be good to know what can be done about this. Is it possible to define a RationalTrait that can be initialized robustly, without fearing errors due to uninitialized fields? In fact, Scala offers two alternative solutions to this problem, pre-initialized fields and lazy vals. They are presented in the remainder of this section.

+ 那解决这个问题，scala提供了两种方法，pre-initialized和lazy vals。

**Pre-initialized fields**

The first solution, pre-initialized fields, lets you initialize a field of a subclass before the superclass is called. To do this, simply place the field definition in braces before the superclass constructor call. As an example, Listing 20.5 shows another attempt to create an instance of RationalTrait. As you see from this example, the initialization section comes before the mention of the supertrait RationalTrait. Both are separated by a with.

+ 在父类调用前就初始化子类字段。如下。

```
    scala> new { 
             val numerArg = 1 * x
             val denomArg = 2 * x 
           } with RationalTrait
    res15: java.lang.Object with RationalTrait = 1/2
```

Listing 20.5 - Pre-initialized fields in an anonymous class expression.

```
    object twoThirds extends {
      val numerArg = 2
      val denomArg = 3
    } with RationalTrait
```

Listing 20.6 - Pre-initialized fields in an object definition.

Pre-initialized fields are not restricted to anonymous classes; they can also be used in objects or named subclasses. Two examples are shown in Listings 20.6 and 20.7. As you can see from these examples, the pre-initialization section comes in each case after the extends keyword of the defined object or class. Class RationalClass, shown in Listing 20.7, exemplifies a general schema of how class parameters can be made available for the initialization of a supertrait.

+ Pre-initialized fields不仅限于匿名类。还可以用在对象或命名的子类中。在20.6和20.7中你可以看到Pre-initialized的部分是在extends关键字后的。20.7中的RationalClass类展现了一个通用的模式，类参数如何可以被父trait初始化时访问到的。

Because pre-initialized fields are initialized before the superclass constructor is called, their initializers cannot refer to the object that's being constructed. Consequently, if such an initializer refers to this, the reference goes to the object containing the class or object that's being constructed, not the constructed object itself. Here's an example:

+ 因为Pre-initialized是在父类构造方法调用前初始化的，他们的初始化者是不能引用到要被构建的对象的。如下this.numerArg。

```
  scala> new {
         val numerArg = 1
         val denomArg = this.numerArg * 2
       } with RationalTrait
  <console>:8: error: value numerArg is not a
       member of object $iw
           val denomArg = this.numerArg * 2
                               ^

    class RationalClass(n: Int, d: Int) extends {
      val numerArg = n
      val denomArg = d
    } with RationalTrait {
      def + (that: RationalClass) = new RationalClass(
        numer * that.denom + that.numer * denom,
        denom * that.denom
      )
    }
```

Listing 20.7 - Pre-initialized fields in a class definition.

The example did not compile because the reference this.numerArg was looking for a numerArg field in the object containing the new (which in this case was the synthetic object named $iw, into which the interpreter puts user input lines). Once more, pre-initialized fields behave in this respect like class constructor arguments.

+ null

**Lazy vals**

You can use pre-initialized fields to simulate precisely the initialization behavior of class constructor arguments. Sometimes, however, you might prefer to let the system itself sort out how things should be initialized. This can be achieved by making your val definitions lazy. If you prefix a val definition with a lazy modifier, the initializing expression on the right-hand side will only be evaluated the first time the val is used.

+ 除了前面介绍的预先初始化成员值外，你还是让系统自行决定何时初始化成员的初始值，这是通过在val定义前面添加 lazy，也是说直到你第一次需要引用该成员时，系统才会去初始化，否则该成员就不初始化。

For an example, define an object Demo with a val as follows:

```
  scala> object Demo {
           val x = { println("initializing x"); "done" }
         }
  defined module Demo
```

Now, first refer to Demo, then to Demo.x:

```
  scala> Demo
  initializing x
  res19: Demo.type = Demo$@97d1ff
  
  scala> Demo.x
  res20: java.lang.String = done
```

As you can see, the moment you use Demo, its x field becomes initialized. The initialization of x forms part of the initialization of Demo. The situation changes, however, if you define the x field to be lazy:

+ 正如你所看到的，当引用Demo对象时，它的成员x也会初始化，初始化x伴随着初始化Demo的过程。然后，如果我们在val x前添加lazy，情况就有所不同了。

```
  scala> object Demo {
           lazy val x = { println("initializing x"); "done" }
         }
  defined module Demo
  
  scala> Demo
  res21: Demo.type = Demo$@d81341
  
  scala> Demo.x
  initializing x
  res22: java.lang.String = done
```

Now, initializing Demo does not involve initializing x. The initialization of x will be deferred until the first time x is used.

+ 在使用lazy之后，初始化Demo时，不会初始化x，只有在引用到Demo.x该初始化代码才会执行。

```
    trait LazyRationalTrait { 
      val numerArg: Int 
      val denomArg: Int 
      lazy val numer = numerArg / g
      lazy val denom = denomArg / g
      override def toString = numer +"/"+ denom
      private lazy val g = {
        require(denomArg != 0)
        gcd(numerArg, denomArg)
      }
      private def gcd(a: Int, b: Int): Int = 
        if (b == 0) a else gcd(b, a % b)
    }
```

Listing 20.8 - Initializing a trait with lazy vals.

This is similar to the situation where x is defined as a parameterless method, using a def. However, unlike a def a lazy val is never evaluated more than once. In fact, after the first evaluation of a lazy val the result of the evaluation is stored, to be reused when the same val is used subsequently.

+ 这有点类似定义了一个无参数的方法，但和def不同的是，lazy变量初始化代码只会执行一次。事实上，第一次评估后，lazy变量的值就被存储了，等后续同样的val被调用的时再使用。

Looking at this example, it seems that objects like Demo themselves behave like lazy vals, in that they are also initialized on demand, the first time they are used. This is correct. In fact an object definition can be seen as a shorthand for the definition of a lazy val with an anonymous class that describes the object's contents.

+ 可以看到例如Demo的对象本身也像一个lazy变量，也是在第一次引用时才会初始化。实际上一个object定义可以看成是使用了lazy val定义一个匿名类实例的简化方式。

Using lazy vals, you could reformulate RationalTrait as shown in Listing 20.8. In the new trait definition, all concrete fields are defined lazy. Another change with respect to the previous definition of RationalTrait, shown in Listing 20.4, is that the require clause was moved from the body of the trait to the initializer of the private field, g, which computes the greatest common divisor of numerArg and denomArg. With these changes, there's nothing that remains to be done when LazyRationalTrait is initialized; all initialization code is now part of the right-hand side of a lazy val. Therefore, it is safe to initialize the abstract fields of LazyRationalTrait after the class is defined. Here's an example:

+ 使用lazy val，修改之前的RationalTrait，在这个新的Trait定义中，所有的类成员变量的实现(非抽象成员)都使用lazy来修饰。同时把require移动到g里面，这样所有的lazy val初始化代码都移动到val定义的右边。我们不再需要预先初始化成员变量。

```
  scala> val x = 2
  x: Int = 2
  
  scala> new LazyRationalTrait {
           val numerArg = 1 * x
           val denomArg = 2 * x
         }
  res1: java.lang.Object with LazyRationalTrait = 1/2
```

No pre-initialization is needed. It's instructive to trace the sequence of initializations that lead to the string 1/2 to be printed in the code above:

First, a fresh instance of LazyRationalTrait gets created, and the initialization code of LazyRationalTrait is run. This initialization code is empty—none of the fields of LazyRationalTrait is as yet initialized.

Next, the primary constructor of the anonymous subclass defined by the new expression is executed. This involves the initialization of numerArg with 2 and denomArg with 4.

Next, the toString method is invoked on the constructed object by the interpreter, so that the resulting value can be printed.

Next, the numer field is accessed for the first time by the toString method in trait LazyRationalTrait, so its initializer is evaluated.

The initializer of numer accesses the private field, g, so g is evaluated next. This evaluation accesses numerArg and denomArg, which were defined in Step 2.

Next, the toString method accesses the value of denom, which causes denom's evaluation. The evaluation of denom accesses the values of denomArg and g. The initializer of the g field is not re-evaluated, because it was already evaluated in Step 5.

Finally, the result string "1/2" is constructed and printed.

+ 分析一下这段代码中命令行的执行顺序。
  - 首先，创建了一个新的LazyRationalTrait的实例，执行LazyRationalTrait的初始化代码，这部分代码为空，LazyRationalTrait所有成员变量都没有初始化。
  - 其次，该Trait的匿名子类的主构造函数被执行，这部分初始化numberArg和denomArg 为2和4.
  - 接下来，命令行需要调用该实例的toString方法来显示该实例的值。
  - 接下来，toString需要访问成员number这是第一次访问该成员，因此lazy val 初始化代码被执行。初始化代码调用私有成员g，因此需要计算g的值，用到之前定义过的numberArg和denomArg。
  - 接下来toString需要访问成员denom这是第一次访问该成员，因此lazy val初始化代码被执行。初始化代码调用私有成员g，因此需要计算g的值，因为g已经计算过，无需再计算。
  - 最后，toString的结果1/2构造出来并显示。

Note that the definition of g comes textually after the definitions of numer and denom in class LazyRationalTrait. Nevertheless, because all three values are lazy, g gets initialized before the initialization of numer and denom is completed. This shows an important property of lazy vals: the textual order of their definitions does not matter, because values get initialized on demand. Therefore, lazy vals can free you as a programmer from having to think hard how to arrange val definitions to ensure that everything is defined when it is needed.

+ 在这个例子中，我们在写代码时，g定义在number和denom的后面，然而，由于这三个变量都是使用lazy来定义的，因此它们在代码中出现的顺序并不重要，因为值会按需求初始化。

However, this advantage holds only as long as the initialization of lazy vals neither produces side effects nor depends on them. In the presence of side effects, initialization order starts to matter. And then it can be quite difficult to trace in what order initialization code is run, as the previous example has demonstrated. So lazy vals are an ideal complement to functional objects, where the order of initializations does not matter, as long as everything gets initialized eventually. They are less well suited for code that's predominantly imperative.

+ null

**Lazy functional languages**

Scala is by no means the first language to have exploited the perfect match of lazy definitions and functional code. In fact, there is a category of "lazy functional programming languages" in which every value and parameter is initialized lazily. The best known member of this class of languages is Haskell haskell98.

+ null

### 20.6 Abstract types

In the beginning of this chapter, you saw, "type T", an abstract type declaration. The rest of this chapter discusses what such an abstract type declaration means and what it's good for. Like all other abstract declarations, an abstract type declaration is a placeholder for something that will be defined concretely in subclasses. In this case, it is a type that will be defined further down the class hierarchy. So T above refers to a type that is at yet unknown at the point where it is declared. Different subclasses can provide different realizations of T.

+ Type T的用法，这是声明一个抽象类型，本篇介绍这种声明的意义和用途。和其它类型的抽象类型一样，抽象类型定义也是定义了一个占位符类型，其具体定义由其子类声明。不同的子类可以定义不同T的具体类型。 

Here is a well-known example where abstract types show up naturally. Suppose you are given the task of modeling the eating habits of animals. You might start with a class Food and a class Animal with an eat method:

+ 一个例子，假定你需要为动物的饮食习性建模， 你可能会定义如下的数据结构。

```
  class Food
  abstract class Animal {
    def eat(food: Food)
  }
```

You might then attempt to specialize these two classes to a class of Cows that eat Grass:

+ 怎么会出错呢，这是因为类Cow中的eat不能重载其父类，这是因为参数类型不一致，Animal中food类型为Food，而Cow中类型为Grass。

```
  class Grass extends Food
  class Cow extends Animal {
    override def eat(food: Grass) {} // This won't compile
  }
```

However, if you tried to compile the new classes, you'd get the following compilation errors:

```
  BuggyAnimals.scala:7: error: class Cow needs to be
  abstract, since method eat in class Animal of type
      (Food)Unit is not defined
  class Cow extends Animal {
        ^
  BuggyAnimals.scala:8: error: method eat overrides nothing
    override def eat(food: Grass) {}
                 ^
```

What happened is that the eat method in class Cow does not override the eat method in class Animal, because its parameter type is different—it's Grass in class Cow vs. Food in class Animal.

Some people have argued that the type system is unnecessarily strict in refusing these classes. They have said that it should be OK to specialize a parameter of a method in a subclass. However, if the classes were allowed as written, you could get yourself in unsafe situations very quickly. For instance, the following script would pass the type checker:

+ 仅管有人会说Grass是Food的子类，编译器没有必要这么严格。但是如果编译器允许这种情况存在，那么很快就出现新问题了。假定前面的编译没有问题，我们在定义一个Fish类。

```
  class Food
  abstract class Animal {
    def eat(food: Food)
  }
  class Grass extends Food
  class Cow extends Animal {
    override def eat(food: Grass) {} // This won't compile,
  }                                  // but if it did,...
  class Fish extends Food
  val bessy: Animal = new Cow
  bessy eat (new Fish)     // ...you could feed fish to cows.
```

The program would compile if the restriction were eased, because Cows are Animals and Animals do have an eat method that accepts any kind of Food, including Fish. But surely it would do a cow no good to eat a fish!

+ 问题来了，我们给牛喂了鱼。如果前面的Cow可以编译通过的话，这段代码也是合法的，但结果却显然不对，因此编译器编译不通过Cow是有道理的。

What you need to do instead is apply some more precise modeling. Animals do eat Food, but what kind of Food each Animal eats depends on the Animal. This can be neatly expressed with an abstract type, as shown in Listing 20.9:

+ 对于这个问题，我们可以通过抽象类型来解决，哪种动物吃哪种食物由动物决定。

```
    class Food
    abstract class Animal {
      type SuitableFood <: Food
      def eat(food: SuitableFood)
    }
```

Listing 20.9 - Modeling suitable food with an abstract type.

With the new class definition, an Animal can eat only food that's suitable. What food is suitable cannot be determined at the level of the Animal class. That's why SuitableFood is modeled as an abstract type. The type has an upper bound, Food, which is expressed by the "<: Food" clause. This means that any concrete instantiation of SuitableFood (in a subclass of Animal) must be a subclass of Food. For example, you would not be able to instantiate SuitableFood with class IOException.

+ 当定义新的Animal子类时，动物只能吃合适的食物，而Animal类本身不能决定那种食物合适，因此我们使用抽象类型定义。但这个抽象类型有类型上界限制，表示Animal子类中使用的SuitableFood必须是Food的子类。我们重新定义Cow如下。

```
    class Grass extends Food
    class Cow extends Animal {
      type SuitableFood = Grass
      override def eat(food: Grass) {}
    }
```

Listing 20.10 - Implementing an abstract type in a subclass.

With Animal defined, you can now progress to cows, as shown in Listing 20.10. Class Cow fixes its SuitableFood to be Grass and also defines a concrete eat method for this kind of food. These new class definitions compile without errors. If you tried to run the "cows-that-eat-fish" counterexample with the new class definitions, you would get the following compiler error:

+ 如果再给牛喂鱼会得到类型不match错误。

```
  scala> class Fish extends Food
  defined class Fish
  
  scala> val bessy: Animal = new Cow
  bessy: Animal = Cow@674bf6
  
  scala> bessy eat (new Fish)
  <console>:10: error: type mismatch;
   found   : Fish
   required: bessy.SuitableFood
         bessy eat (new Fish)
                    ^
```

### 20.7 Path-dependent types

Have a look at the last error message: What's interesting about it is the type required by the eat method: bessy.SuitableFood. This type consists of an object reference, bessy, which is followed by a type field, SuitableFood, of the object. So this shows that objects in Scala can have types as members. The meaning of bessy.SuitableFood is "the type SuitableFood that is a member of the object referenced from bessy," or alternatively, the type of food that's suitable for bessy. A type like bessy.SuitableFood is called a path-dependent type. The word "path" here means a reference to an object. It could be a single name, such as bessy, or a longer access path, such as farm.barn.bessy.SuitableFood, where each of farm, barn, and bessy are variables (or singleton object names) that refer to objects.

+ `bessy.SuitableFood`包含一个的对象引用bessy和一个类型字段SuitableFood。Scala把一个type作为成员。`bessy.SuitableFood`叫path-dependent类型。path意思是一个对象的引用，是一个变量名引用到对象。

As the term "path-dependent type" says, the type depends on the path: in general, different paths give rise to different types. For instance, say you defined classes DogFood and Dog, like this:

+ path-dependent是依赖于路径。通常，不同的路径会得到不同的类型。如下

```
  class DogFood extends Food
  class Dog extends Animal {
    type SuitableFood = DogFood
    override def eat(food: DogFood) {}
  }
```

If you attempted to feed a dog with food fit for a cow, your code would not compile:

+ 如果你给狗喂牛的食物就不会编译通过。

```
  scala> val bessy = new Cow
  bessy: Cow = Cow@10cd6d
  
  scala> val lassie = new Dog
  bootsie: Dog = Dog@d11fa6
  
  scala> lassie eat (new bessy.SuitableFood)
  <console>:13: error: type mismatch;
   found   : Grass
   required: DogFood
         lassie eat (new bessy.SuitableFood)
                     ^
```

The problem here is that the type of the SuitableFood object passed to the eat method, bessy.SuitableFood, is incompatible with the parameter type of eat, lassie.SuitableFood. The case would be different for two Dogs however. Because Dog's SuitableFood type is defined to be an alias for class DogFood, the SuitableFood types of two Dogs are in fact the same. As a result, the Dog instance named lassie could actually eat the suitable food of a different Dog instance (which we'll name bootsie):

+ 这里的问题是给狗的SuitableFood是bessy.SuitableFood是Gress，所以类型不匹配。lassie.SuitableFood是DogFood，如下变量名字换换仍然是适合的food。

```
  scala> val bootsie = new Dog
  bootsie: Dog = Dog@54ca71
  
  scala> lassie eat (new bootsie.SuitableFood)
```

A path-dependent type resembles the syntax for an inner class type in Java, but there is a crucial difference: a path-dependent type names an outer object, whereas an inner class type names an outer class. Java-style inner class types can also be expressed in Scala, but they are written differently. Consider these two classes, Outer and Inner:

+ path-dependent类型语法类似Java的内部类。但是有很大区别，path-dependent是以outer对象命名，反之内部类是以outer类命名。Java样式的内部类也可以在Scala中表达，但是他们写法不同。

```
  class Outer {
    class Inner
  }
```

In Scala, the inner class is addressed using the expression Outer#Inner instead of Java's Outer.Inner. The `.' syntax is reserved for objects. For example, imagine you instantiate two objects of type Outer, like this:

+ 在Scala中，用`Outer#Innter`来代替Java的`Outer.Inner`作为类型。`.`是保留给对象用的。

```
  val o1 = new Outer
  val o2 = new Outer
```

Here o1.Inner and o2.Inner are two path-dependent types (and they are different types). Both of these types conform to (are subtypes of) the more general type Outer#Inner, which represents the Inner class with an arbitrary outer object of type Outer. By contrast, type o1.Inner refers to the Inner class with a specific outer object (the one referenced from o1). Likewise, type o2.Inner refers to the Inner class with a different, specific outer object (the one referenced from o2).

+ 这里o1.Innter和o2.Inner是两个不同的path-dependent的类型。但是他们都是Outer#Inner的子类型，这个是用来表达任意Outer类型outer对象的Inner class。o1和o2都是用来指出特定outer对象的Inner class。

In Scala, as in Java, inner class instances hold a reference to an enclosing outer class instance. This allows an inner class, for example, to access members of its outer class. Thus you can't instantiate an inner class without in some way specifying an outer class instance. One way to do this is to instantiate the inner class inside the body of the outer class. In this case, the current outer class instance (referenced from this) will be used. Another way is to use a path-dependent type. For example, because the type, o1.Inner, names a specific outer object, you can instantiate it:

+ 在Scala，像Java，inner class的实例有一个引用到它自己外部的outer class实例。允许inner clsas可以访问其外部outer class的成员。你不能实例化一个inner class没有指定外部类实例。你可以在外部类实例中进行实例化inner类，也可以使用path-dependent来实例化inner class。

```
  scala> new o1.Inner
  res1: o1.Inner = Outer$Inner@13727f
```

The resulting inner object will contain a reference to its outer object, the object referenced from o1. By contrast, because the type Outer#Inner does not name any specific instance of Outer, you can't create an instance of it:

+ inner对象会包含其外部对象引用中。你不能使用Outer#Inner来实例化，因为没有特别指定Outer实例。

```
  scala> new Outer#Inner
  <console>:6: error: Outer is not a legal prefix for
    a constructor
         new Outer#Inner
                   ^
```

### 20.8 Enumerations

An interesting application of path-dependent types is found in Scala's support for enumerations. Some other languages, including Java and C#, have enumerations as a built-in language construct to define new types. Scala does not need special syntax for enumerations. Instead, there's a class in its standard library, scala.Enumeration. To create a new enumeration, you define an object that extends this class, as in the following example, which defines a new enumeration of Colors:

+ path-dependent类型应用是Scala的enumerations，你可以继承自scala.Enumeration来创建一个新类。

```
  object Color extends Enumeration {
    val Red = Value
    val Green = Value
    val Blue = Value
  }
```

Scala lets you also shorten several successive val or var definitions with the same right-hand side. Equivalently to the above you could write:

+ Scala简化定义。

```
  object Color extends Enumeration {
    val Red, Green, Blue = Value
  }
```

This object definition provides three values: Color.Red, Color.Green, and Color.Blue. You could also import everything in Color with:

+ 通过导包直接使用Red，Green，and Blue。Enumeration定义了一个内部类叫Value，通过一个同样名字的无参方法返回这个类的实例。Color.Red相当于Color.Value。

```
  import Color._
```

and then just use Red, Green, and Blue. But what is the type of these values? Enumeration defines an inner class named Value, and the same-named parameterless Value method returns a fresh instance of that class. This means that a value such as Color.Red is of type Color.Value. Color.Value is the type of all enumeration values defined in object Color. It's a path-dependent type, with Color being the path and Value being the dependent type. What's significant about this is that it is a completely new type, different from all other types. In particular, if you would define another enumeration, such as:

+ Direction.Value和Color.Value不同，因为path不一样。

```
  object Direction extends Enumeration {
    val North, East, South, West = Value
  }
```

then Direction.Value would be different from Color.Value because the path parts of the two types differ.

+ Scala的Enumeration提供了很多功能，你可以关联values用不同的重载变量的Value方法。

Scala's Enumeration class also offers many other features found in the enumeration designs of other languages. You can associate names with enumeration values by using a different overloaded variant of the Value method:

+ 可以用foreach表达式来迭代enumeration。

```
  object Direction extends Enumeration {
    val North = Value("North")
    val East = Value("East")
    val South = Value("South")
    val West = Value("West")
  }
```

You can step through all values of an enumeration with foreach, or use for expressions with map, flatMap and filter:

+ enumeration是从0开始的，你可以通过方法读到某个value的index。

```
  scala> for (d <- Direction) print(d +" ")
  North East South West 
```

Values of an enumeration are numbered from 0, and you can find out the number of an enumeration value by its id method:

+ 通过如下类名加小括号index方法来得到某个元素。

```
  scala> Direction.East.id
  res5: Int = 1
```

It's also possible to go the other way, from a non-negative integer number to the value that has this number as id in an enumeration:

+ null

```
  scala> Direction(1)
  res6: Direction.Value = East
```

This should be enough to get you started with enumerations. You can find more information in the Scaladoc comments of class scala.Enumeration.

### 20.9 Case study: Currencies

The rest of this chapter presents a case study that explains how abstract types can be used in Scala. The task is to design a class Currency. A typical instance of Currency would represent an amount of money in dollars, euros, yen, or some other currency. It should be possible to do some arithmetic on currencies. For instance, you should be able to add two amounts of the same currency. Or you should be able to multiply a currency amount by a factor representing an interest rate.

+ 剩下的部分为货币的例子来展现abstract types。

These thoughts lead to the following first design for a currency class:

+ 第一个是个错误的设计。

```
  // A first (faulty) design of the Currency class
  abstract class Currency {
    val amount: Long
    def designation: String 
    override def toString = amount +" "+ designation
    def + (that: Currency): Currency = ...
    def * (x: Double): Currency = ...
  }
```

The amount of a currency is the number of currency units it represents. This is a field of type Long so that very large amounts of money such as the market capitalization of Google or Microsoft can be represented. It's left abstract here, waiting to be defined when a subclass talks about concrete amounts of money. The designation of a currency is a string that identifies it. The toString method of class Currency indicates an amount and a designation. It would yield results such as:

+ val amount的类型是Long，后面会在具体的子类中定义。designation方法返回Stirng，是指货币的种类。

```
  79 USD
  11000 Yen
  99 Euro
```

Finally, there are methods +, for adding currencies, and *, for multiplying a currency with a floating-point number. You can create a concrete currency value by supplying concrete amount and designation values, like this:

+ `+`用来货币加，`*`用来乘一个浮点型数字。

```
  new Currency {
    val amount = 79L
    def designation = "USD"
  }
```

This design would be OK if all we wanted to model was a single currency such as only dollars or only euros. But it fails once we need to deal with several currencies. Assume you model dollars and euros as two subclasses of class currency:

+ 这个设计如果只是针对一种货币比如美元，欧元是可以的。但是如果处理多种货币。假设你构建美元和欧元作为货币的子类。如下。

```
  abstract class Dollar extends Currency {
    def designation = "USD"
  }
  abstract class Euro extends Currency {
    def designation = "Euro"
  }
```

At first glance this looks reasonable. But it would let you add dollars to euros. The result of such an addition would be of type Currency. But it would be a funny currency that was made up of a mix of euros and dollars. What you want instead is a more specialized version of the + method: when implemented in class Dollar, it should take Dollar arguments and yield a Dollar result; when implemented in class Euro, it should take Euro arguments and yield a Euro result. So the type of the addition method would change depending on which class you are in. Nonetheless, you would like to write the addition method just once, not each time a new currency is defined.

+ 如果让把美元加到欧元上，结果类型是Currency，但是这个结果是混着美元和欧元的。有没有更特别的`+`方法，就是当美元作为入参，产生美元结果，当欧元入参，产生欧元结果。结果的产生取决于你在哪种类中。否则只能加一次，并不能每次产生新的货币定义。

In Scala, there's a simple technique to deal with situations like this: if something is not known at the point where a class is defined, make it abstract in the class. This applies to both values and types. In the case of currencies, the exact argument and result type of the addition method are not known, so it is a good candidate for an abstract type. This would lead to the following sketch of class AbstractCurrency:

+ 在Scala中有个办法就是如果某些东西在类定义的时候不知道，那就把他弄成abstract的。可以应用在valus和types上。在货币这个例子里，加这个方法的确切入参和返回结果类型不是很清楚，所以它是成为abstract type的好的候选者。第二个不是太完美的设计如下。

```
  // A second (still imperfect) design of the Currency class
  abstract class AbstractCurrency {
    type Currency <: AbstractCurrency
    val amount: Long
    def designation: String 
    override def toString = amount +" "+ designation
    def + (that: Currency): Currency = ...
    def * (x: Double): Currency = ...
  }
```

The only differences from the previous situation are that the class is now called AbstractCurrency, and that it contains an abstract type Currency, which represents the real currency in question. Each concrete subclass of AbstractCurrency would need to fix the Currency type to refer to the concrete subclass itself, thereby "tying the knot."

+ 这一版叫AbstractCurrency，同时包含了一个叫abstract type Currency。每个具体的子类会把Currency类型引用到子类自己上。

For instance, here is a new version of class Dollar, which now extends class AbstractCurrency:

```
  abstract class Dollar extends AbstractCurrency {
    type Currency = Dollar
    def designation = "USD"
  }
```

This design is workable, but it is still not perfect. One problem is hidden by the ellipses that indicate the missing method definitions of + and * in class AbstractCurrency. In particular, how should addition be implemented in this class? It's easy enough to calculate the correct amount of the new currency as this.amount + that.amount, but how would you convert the amount into a currency of the right type? You might try something like:

+ 这个设计工作了，但是有一个问题加和乘的方法在AbstractCurrency中没有定义。加法的实现很简单就是`this.amount + that.amount`，但是你如何将amount转换成合适的类型呢？如下是不会编译通过的。

```
  def + (that: Currency): Currency = new Currency {
    val amount = this.amount + that.amount
  }
```

However, this would not compile:

```
  error: class type required
    def + (that: Currency): Currency = new Currency {
                                           ^
```

One of the restrictions of Scala's treatment of abstract types is that you can neither create an instance of an abstract type, nor have an abstract type as a supertype of another class.[1] So the compiler would refuse the example code above that attempted to instantiate Currency.

+ scala对待abstract type有个规则，不用创建abstract type实例，也不用把abstract type作为其他类的子类型。

However, you can work around this restriction using a factory method. Instead of creating an instance of an abstract type directly, declare an abstract method that does it. Then, wherever the abstract type is fixed to be some concrete type, you also need to give a concrete implementation of the factory method. For class AbstractCurrency, this would look as follows:

+ 你可以用factory method来使这条规则起效。

```
  abstract class AbstractCurrency {
    type Currency <: AbstractCurrency // abstract type
    def make(amount: Long): Currency  // factory method
    ...                               // rest of class
  }
```

A design like this could be made to work, but it looks rather suspicious. Why place the factory method inside class AbstractCurrency? This looks dubious, for at least two reasons. First, if you have some amount of currency (say, one dollar), you also hold in your hand the ability to make more of the same currency, using code such as:

+ 为何要将factory method放在AbstractCurrency类中。至少有两个原因，第一如果你有一些钱，你可以有能力去拿更多的钱。

```
  myDollar.make(100)  // here are a hundred more!
```

In the age of color copying this might be a tempting scenario, but hopefully not one which you would be able to do for very long without being caught. The second problem with this code is that you can make more Currency objects if you already have a reference to a Currency object, but how do you get the first object of a given Currency? You'd need another creation method, which does essentially the same job as make. So you have a case of code duplication, which is a sure sign of a code smell.

+ 第二个问题是如果你已经有了货币对象的引用还能创建更多的货币引用，但是你不知道第一个货币的对象的引用，你需要另外一个创建的方法，和make做同样的事，就涉及到代码复制的问题。

The solution, of course, is to move the abstract type and the factory method outside class AbstractCurrency. You need to create another class that contains the AbstractCurrency class, the Currency type, and the make factory method. We'll call this a CurrencyZone:

+ 解决办法就是将工厂方法移到外部类AbstractCurrency中。需要创建一个新的外部类CurrencyZone类来包含AbstractCurrency。

```
  abstract class CurrencyZone {
    type Currency <: AbstractCurrency
    def make(x: Long): Currency
    abstract class AbstractCurrency {
      val amount: Long
      def designation: String 
      override def toString = amount +" "+ designation
      def + (that: Currency): Currency = 
        make(this.amount + that.amount)
      def * (x: Double): Currency = 
        make((this.amount * x).toLong)
    }
  }
```

An example of a concrete CurrencyZone is the US. You could define this as follows:

```
  object US extends CurrencyZone {
    abstract class Dollar extends AbstractCurrency {
      def designation = "USD"
    }
    type Currency = Dollar
    def make(x: Long) = new Dollar { val amount = x }
  }
```

Here, US is an object that extends CurrencyZone. It defines a class Dollar, which is a subclass of AbstractCurrency. So the type of money in this zone is US.Dollar. The US object also fixes the type Currency to be an alias for Dollar, and it gives an implementation of the make factory method to return a dollar amount.

+ 解释上述代码。

This is a workable design. There are only a few refinements to be added. The first refinement concerns subunits. So far, every currency was measured in a single unit: dollars, euros, or yen. However, most currencies have subunits: for instance, in the US, it's dollars and cents. The most straightforward way to model cents is to have the amount field in US.Currency represent cents instead of dollars. To convert back to dollars, it's useful to introduce a field CurrencyUnit into class CurrencyZone, which contains the amount of one standard unit in that currency:

+ 还有个问题就是子单位。例如美元有美分。所以需要有一个字段CurrencyUnit在类CurrencyZone中来将美分转化为美元。

```
  class CurrencyZone { 
    ... 
    val CurrencyUnit: Currency 
  } 
```

The US object could define the quantities Cent, Dollar, and CurrencyUnit as shown in Listing 20.11.

```
    object US extends CurrencyZone {
      abstract class Dollar extends AbstractCurrency {
        def designation = "USD"
      }
      type Currency = Dollar
      def make(cents: Long) = new Dollar {
        val amount = cents
      }
      val Cent = make(1)
      val Dollar = make(100)
      val CurrencyUnit = Dollar
    }
```

Listing 20.11 - The US currency zone.

This definition is just like the previous definition of the US object, except that it adds three new fields. The field Cent represents an amount of 1 US.Currency. It's an object analogous to a one-cent coin. The field Dollar represents an amount of 100 US.Currency. So the US object now defines the name Dollar in two ways. The type Dollar (defined by the abstract inner class named Dollar) represents the generic name of the Currency valid in the US currency zone. By contrast, the value Dollar (referenced from the val field named Dollar) represents a single US dollar, analogous to a one-dollar bill. The third field definition of CurrencyUnit specifies that the standard currency unit in the US zone is the Dollar (i.e., the value Dollar, referenced from the field, not the type Dollar).

+ 这个版本的定义中，还增加了3个新的字段。Cent字段代表1个US.Currency(USD)，Dollar字段代表100个USD。类型Dollar是被抽象内部类Dollar定义的。

The toString method in class Currency also needs to be adapted to take subunits into account. For instance, the sum of ten dollars and twenty three cents should print as a decimal number: 10.23 USD. To achieve this, you could implement Currency's toString method as follows:

+ toString需要表达适合的货币格式。比如，10.23USD，下面的formatted方法就是可以实现这个格式并返回string。

```
  override def toString = 
    ((amount.toDouble / CurrencyUnit.amount.toDouble)
     formatted ("%."+ decimals(CurrencyUnit.amount) +"f")
     +" "+ designation)
```

Here, formatted is a method that Scala makes available on several classes, including Double.[2] The formatted method returns the string that results from formatting the original string on which formatted was invoked according to a format string passed as the formatted method's right-hand operand. The syntax of format strings passed to formatted is the same as that of Java's String.format method. For instance, the format string %.2f formats a number with two decimal digits. The format string used in the toString shown previously is assembled by calling the decimals method on CurrencyUnit.amount. This method returns the number of decimal digits of a decimal power minus one. For instance, decimals(10) is 1, decimals(100) is 2, and so on. The decimals method is implemented by a simple recursion:

+ `%.2f`是保留小数点后两位有效数字。decimals方法是返回10的几次方。

```
  private def decimals(n: Long): Int = 
    if (n == 1) 0 else 1 + decimals(n / 10)
```

Listing 20.12 shows some other currency zones:

```
    object Europe extends CurrencyZone {
      abstract class Euro extends AbstractCurrency {
        def designation = "EUR"
      }
      type Currency = Euro
      def make(cents: Long) = new Euro {
        val amount = cents
      }
      val Cent = make(1)
      val Euro = make(100)
      val CurrencyUnit = Euro
    }
  
    object Japan extends CurrencyZone {
      abstract class Yen extends AbstractCurrency {
        def designation = "JPY"
      }
      type Currency = Yen
      def make(yen: Long) = new Yen {
        val amount = yen
      }
      val Yen = make(1)
      val CurrencyUnit = Yen
    }
```

Listing 20.12 - Currency zones for Europe and Japan.

As another refinement you can add a currency conversion feature to the model. As a first step, you could write a Converter object that contains applicable exchange rates between currencies, as shown in Listing 20.13.

+ 可以做一个货币汇率兑换的map。

```
    object Converter {
      var exchangeRate = Map(
        "USD" -> Map("USD" -> 1.0   , "EUR" -> 0.7596, 
                     "JPY" -> 1.211 , "CHF" -> 1.223),
        "EUR" -> Map("USD" -> 1.316 , "EUR" -> 1.0   , 
                     "JPY" -> 1.594 , "CHF" -> 1.623),
        "JPY" -> Map("USD" -> 0.8257, "EUR" -> 0.6272, 
                     "JPY" -> 1.0   , "CHF" -> 1.018),
        "CHF" -> Map("USD" -> 0.8108, "EUR" -> 0.6160, 
                     "JPY" -> 0.982 , "CHF" -> 1.0  )
      )
    }
```

Listing 20.13 - A converter object with an exchange rates map.

Then, you could add a conversion method, from, to class Currency, which converts from a given source currency into the current Currency object:

+ 可以有一个转换方法。

```
  def from(other: CurrencyZone#AbstractCurrency): Currency = 
    make(Math.round(
      other.amount.toDouble * Converter.exchangeRate
        (other.designation)(this.designation)))
```

The from method takes an arbitrary currency as argument. This is expressed by its formal parameter type, CurrencyZone#AbstractCurrency, which indicates that the argument passed as other must be an AbstractCurrency type in some arbitrary and unknown CurrencyZone. It produces its result by multiplying the amount of the other currency with the exchange rate between the other and the current currency.[3]

+ from方法可以用任意货币作为如参。正规的参数类型为`CurrencyZone#AbstractCurrency`，这暗示了传入需要是一个AbstractCurrency类型在任意的不知道的CurrencyZone中。返回货币是乘以汇率的的货币

The final version of the CurrencyZone class is shown in Listing 20.14.

```
  abstract class CurrencyZone {
  
    type Currency <: AbstractCurrency
    def make(x: Long): Currency
  
    abstract class AbstractCurrency {
  
      val amount: Long
      def designation: String 
  
      def + (that: Currency): Currency = 
        make(this.amount + that.amount)
      def * (x: Double): Currency = 
        make((this.amount * x).toLong)
      def - (that: Currency): Currency = 
        make(this.amount - that.amount)
      def / (that: Double) = 
        make((this.amount / that).toLong)
      def / (that: Currency) = 
        this.amount.toDouble / that.amount
  
      def from(other: CurrencyZone#AbstractCurrency): Currency = 
        make(Math.round(
          other.amount.toDouble * Converter.exchangeRate
            (other.designation)(this.designation)))
  
      private def decimals(n: Long): Int = 
        if (n == 1) 0 else 1 + decimals(n / 10)
  
      override def toString = 
        ((amount.toDouble / CurrencyUnit.amount.toDouble)
         formatted ("%."+ decimals(CurrencyUnit.amount) +"f")
         +" "+ designation)
    }
  
    val CurrencyUnit: Currency
  }
```

Listing 20.14 - The full code of class CurrencyZone.

You can test the class in the Scala command shell. We'll assume that the CurrencyZone class and all concrete CurrencyZone objects are defined in a package org.stairwaybook.currencies. The first step is to import everything in this package into the command shell:

```
  scala> import org.stairwaybook.currencies._
```

You can then do some currency conversions:

```
  scala> Japan.Yen from US.Dollar * 100
  res16: Japan.Currency = 12110 JPY
  
  scala> Europe.Euro from res16
  res17: Europe.Currency = 75.95 EUR
  
  scala> US.Dollar from res17
  res18: US.Currency = 99.95 USD
```

The fact that we obtain almost the same amount after three conversions implies that these are some pretty good exchange rates!

You can also add up values of the same currency:

```
  scala> US.Dollar * 100 + res18
  res19: currencies.US.Currency = 199.95
```

On the other hand, you cannot add amounts of different currencies:

+ 你不能把两个不同货币相加。

```
  scala> US.Dollar + Europe.Euro
  <console>:7: error: type mismatch;
   found   : currencies.Europe.Euro
   required: currencies.US.Currency
         US.Dollar + Europe.Euro
                            ^
```

By preventing the addition of two values with different units (in this case, currencies), the type abstraction has done its job. It prevents us from performing calculations that are unsound. Failures to convert correctly between different units may seem like trivial bugs, but they have caused many serious systems faults. An example is the crash of the Mars Climate Orbiter spacecraft on September 23, 1999, which was caused because one engineering team used metric units while another used English units. If units had been coded in the same way as currencies are coded in this chapter, this error would have been detected by a simple compilation run. Instead, it caused the crash of the orbiter after a near ten-month voyage.

+ 为了避免两个不同的单位数据进行相加，抽象类型完成了这一工作。

### 20.10 Conclusion

Scala offers systematic and very general support for object-oriented abstraction. It enables you to not only abstract over methods, but also over values, variables, and types. This chapter has shown how to take advantage of abstract members. They support a simple yet effective principle for systems structuring: when designing a class, make everything that is not yet known into an abstract member. The type system will then drive the development of your model, just as you saw with the currency case study. It does not matter whether the unknown is a type, method, variable or value. In Scala, all of these can be declared abstract.

### Footnotes for Chapter 20:

[1] There's some promising recent research on virtual classes, which would allow this, but virtual classes are not currently supported in Scala.

[2] Scala uses rich wrappers, described in Section 5.9, to make formatted available.

[3] By the way, in case you think you're getting a bad deal on Japanese yen, the exchange rates convert currencies based on their CurrencyZone amounts. Thus, 1.211 is the exchange rate between US cents to Japanese yen.
