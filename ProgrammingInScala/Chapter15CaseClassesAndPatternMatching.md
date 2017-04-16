## Case Classes and Pattern Matching

### Vocabulary
+ delving
+ nuances
+ syntactic
+ intuitive
+ derived

This chapter introduces case classes and pattern matching, twin constructs that support you when writing regular, non-encapsulated data structures. These two constructs are particularly helpful for tree-like recursive data.

+ 样本类case class和模式匹配pattern matching，这两种在编写规范的，无封装数据结构时会用到的构造。它们尤其对于树型递归数据显得格外有用。

If you have programmed in a functional language before, then you will probably recognize pattern matching. Case classes will be new to you, though. Case classes are Scala's way to allow pattern matching on objects without requiring a large amount of boilerplate. In the common case, all you need to do is add a single case keyword to each class that you want to be pattern matchable.

This chapter starts with a simple example of case classes and pattern matching. It then goes through all of the kinds of patterns that are supported, talks about the role of sealed classes, discusses the Option type, and shows some non-obvious places in the language where pattern matching is used. Finally, a larger, more realistic example of pattern matching is shown.

+ the role of sealed classes, discusses the Option type, and shows some non-obvious places in the language

### 15.1 A simple example

Before delving into all the rules and nuances of pattern matching, it is worth looking at a simple example to get the general idea. Let's say you need to write a library that manipulates arithmetic expressions, perhaps as part of a domain-specific language you are designing.

A first step to tackle this problem is the definition of the input data. To keep things simple, we'll concentrate on arithmetic expressions consisting of variables, numbers, and unary and binary operations. This is expressed by the hierarchy of Scala classes shown in Listing 15.1.

+ 第一步处理问题就是定义输入。为了保证简单，我们关注算法表达式由变量，数字和一元二进制操作。

```scala
    abstract class Expr
    case class Var(name: String) extends Expr
    case class Number(num: Double) extends Expr
    case class UnOp(operator: String, arg: Expr) extends Expr
    case class BinOp(operator: String, 
        left: Expr, right: Expr) extends Expr
```

Listing 15.1 - Defining case classes.

The hierarchy includes an abstract base class Expr with four subclasses, one for each kind of expression being considered.[1] The bodies of all five classes are empty. As mentioned previously, in Scala you can leave out the braces around an empty class body if you wish, so class C is the same as class C {}.

+ 层级包括一个抽象基类Expr和四个子类，每个代表一种表达式。所有的五个类都没有类方法体。就像之前提到的，Scala里可以去掉围绕空类方法体的大括号，因此`class C`与`class C {}`相同。

**Case classes**

The other noteworthy thing about the declarations of Listing 15.1 is that each subclass has a case modifier. Classes with such a modifier are called case classes. Using the modifier makes the Scala compiler add some syntactic conveniences to your class.

+ 在15.1中每个子类都有case修饰符，用case修饰符可以使Scala编译器给你的类提供些便捷的句法。

First, it adds a factory method with the name of the class. This means you can write say, Var("x") to construct a Var object instead of the slightly longer new Var("x"):

+ 第一，他会增加一个以类命名的工厂方法，意味着你可以用`Var("x")`来构建Var对象代替使用`new Var("x")`。

```
  scala> val v = Var("x")
  v: Var = Var(x)
```

The factory methods are particularly nice when you nest them. Because there are no noisy new keywords sprinkled throughout the code, you can take in the expression's structure at a glance:

+ 尤其在你把工厂方法嵌套在一起的时候，这种方式显得极为有用。

```
  scala> val op = BinOp("+", Number(1), v)
  op: BinOp = BinOp(+,Number(1.0),Var(x))
```

The second syntactic convenience is that all arguments in the parameter list of a case class implicitly get a val prefix, so they are maintained as fields:

+ 第二个句法便捷是样本类参数列表中的所有参数隐式获得了 val前缀，因此被当作字段保留。

```
  scala> v.name
  res0: String = x
  
  scala> op.left
  res1: Expr = Number(1.0)
```

Third, the compiler adds "natural" implementations of methods toString, hashCode, and equals to your class. They will print, hash, and compare a whole tree consisting of the class and (recursively) all its arguments. Since == in Scala always forwards to equals, this means in particular that elements of case classes are always compared structurally:

+ 第三个，是编译器为你的类添加了方法toString，hashCode和equals的"自然"实现。它们能够（递归地）打印，哈希和比较包含类的整棵树及所有的参数。因为Scala里的==始终直接转到equals，这也就特别意味着样本类的元素一直是全结构地比较的。

```
  scala> println(op)
  BinOp(+,Number(1.0),Var(x))
  
  scala> op.right == Var("x")
  res3: Boolean = true
```

All these conventions add a lot of convenience, at a small price. The price is that you have to write the case modifier and that your classes and objects become a bit larger. They are larger because additional methods are generated and an implicit field is added for each constructor parameter. However, the biggest advantage of case classes is that they support pattern matching.

**Pattern matching**

Say you want to simplify arithmetic expressions of the kinds just presented. There is a multitude of possible simplification rules. The following three rules just serve as an illustration:

+ 如果想简化这里的数学表达式，那有很多种简化规则。

```
  UnOp("-", UnOp("-", e))  => e   // Double negation
  BinOp("+", e, Number(0)) => e   // Adding zero
  BinOp("*", e, Number(1)) => e   // Multiplying by one
```

Using pattern matching, these rules can be taken almost as they are to form the core of a simplification function in Scala, as shown in Listing 15.2. The function, simplifyTop, can be used like this:

+ simplifyTop函数，使用了模式匹配。使用这些规则可以实现简化的核心。函数simplifyTop可以如下方式使用。

```
  scala> simplifyTop(UnOp("-", UnOp("-", Var("x"))))
  res4: Expr = Var(x)

    def simplifyTop(expr: Expr): Expr = expr match {
      case UnOp("-", UnOp("-", e))  => e   // Double negation
      case BinOp("+", e, Number(0)) => e   // Adding zero
      case BinOp("*", e, Number(1)) => e   // Multiplying by one
      case _ => expr
    }
```

Listing 15.2 - The simplifyTop function, which does a pattern match.

The right-hand side of simplifyTop consists of a match expression. match corresponds to switch in Java, but it's written after the selector expression. I.e., it's:

+ simplifyTop右侧的部分组成了match表达式。下面的match表达式代替了 对应于Java里的switch表达式。 

```
  selector match { alternatives }
```

instead of:

```
  switch (selector) { alternatives }
```

A pattern match includes a sequence of alternatives, each starting with the keyword case. Each alternative includes a pattern and one or more expressions, which will be evaluated if the pattern matches. An arrow symbol => separates the pattern from the expressions.

+ 一个模式匹配包含了一系列可选项alternative，每个都开始于关键字case。每个可选项都包含了一个模式pattern以及一到多个表达式，将在模式匹配过程中被评估。箭头符号`=>`把模式和表达式隔开。

A match expression is evaluated by trying each of the patterns in the order they are written. The first pattern that matches is selected, and the part following the arrow is selected and executed.

+ 尝试匹配每个模式的时候，match表达式以代码先后顺序被评估。第一个匹配的模式被选中，跟在箭头后的部分于是被选中并被执行。

A constant pattern like "+" or 1 matches values that are equal to the constant with respect to ==. A variable pattern like e matches every value. The variable then refers to that value in the right hand side of the case clause. In this example, note that the first three examples evaluate to e, a variable that is bound within the associated pattern. The wildcard pattern (_) also matches every value, but it does not introduce a variable name to refer to that value. In Listing 15.2, notice how the match ends with a default case that does nothing to the expression. Instead, it just results in expr, the expression matched upon.

+ 常量模式pattern像`+ or 1`匹配值matches value就相当于常量的相等`==`。变量模式pattern像e这种匹配matches每个值。这个变量是指向case右手边的值。15.2例子中，前三个例子是被评估为变量e是绑定相关的pattern的。wildcard pattern `_`也是匹配所有值，但是他不会引入一个变量去指向那个值。注意如何以default case结束匹配match，用结果expr来表示。

A constructor pattern looks like UnOp("-", e). This pattern matches all values of type UnOp whose first argument matches "-" and whose second argument matches e. Note that the arguments to the constructor are themselves patterns. This allows you to write deep patterns using a concise notation. Here's an example:

+ 一个构造器模式pattern看起来像这个`UnOp("-", e)`。这个模式可以匹配类型为UnOp的所有值，他的第一个入参是`_`，第二个是参数是匹配e。记住构造器入参就是pattern本身(the arguments to the constructor are themselves patterns)。允许你写的更深的patterns用简洁的概念。

```
  UnOp("-", UnOp("-", e))
```

Imagine trying to implement this same functionality using the visitor design pattern![2] Almost as awkward, imagine implementing it as a long sequence of if statements, type tests, and type casts.

**match compared to switch**

Match expressions can be seen as a generalization of Java-style switches. A Java-style switch can be naturally expressed as a match expression where each pattern is a constant and the last pattern may be a wildcard (which represents the default case of the switch). There are three differences to keep in mind, however. First, match is an expression in Scala, i.e., it always results in a value. Second, Scala's alternative expressions never "fall through" into the next case. Third, if none of the patterns match, an exception named MatchError is thrown. This means you always have to make sure that all cases are covered, even if it means adding a default case where there's nothing to do. Listing 15.3 shows an example:

+ 匹配表达式可以被看作Java风格switch的泛化。当每个模式都是常量并且最后一个模式可以是通配wildcard（表示为switch的default情况）的时候，Java风格的switch可以被自然地表达为match表达式。有三点不同要牢记在心。
  - 首先，match是Scala的表达式，也就是说，它始终以值作为结果。
  - 第二，Scala 的可选项表达式永远不会穿透下一个的情况。
  - 第三，如果没有模式匹配，名为MatchError的异常会被抛出。这意味着你必须始终确信所有的情况都照顾到，更进一步意味着可以添加一个缺省情况什么事都不做。

```scala
    expr match {
      case BinOp(op, left, right) =>
        println(expr +" is a binary operation")
      case _ =>
    }
```

Listing 15.3 - A pattern match with an empty "default" case.

The second case is necessary in Listing 15.3, because otherwise the match expression would throw a MatchError for every expr argument that is not a BinOp. In this example, no code is specified for that second case, so if that case runs it does nothing. The result of either case is the unit value `()', which is also, therefore, the result of the entire match expression.

### 15.2 Kinds of patterns

The previous example showed several kinds of patterns in quick succession. Now take a minute to look at each.

The syntax of patterns is easy, so do not worry about that too much. All patterns look exactly like the corresponding expression. For instance, given the hierarchy of Listing 15.1, the pattern Var(x) matches any variable expression, binding x to the name of the variable. Used as an expression, Var(x)—exactly the same syntax—recreates an equivalent object, assuming x is already bound to the variable's name. Since the syntax of patterns is so transparent, the main thing to pay attention to is just what kinds of patterns are possible.

**Wildcard patterns**

The wildcard pattern (_) matches any object whatsoever. You have already seen it used as a default, catch-all alternative, like this:

+ 通配模式`_`匹配任意对象。你已经看过它被用作缺省值，"捕获所有"的可选项。

```scala
  expr match {
    case BinOp(op, left, right) =>
      println(expr +"is a binary operation")
    case _ =>
  }
```

Wildcards can also be used to ignore parts of an object that you do not care about. For example, the previous example does not actually care what the elements of a binary operation are. It just checks whether it is a binary operation at all. Thus the code can just as well use the wildcard pattern for the elements of the BinOp, as shown in Listing 15.4:

+ 通配模式还可以用来忽略对象中你不关心的部分。比如说，前一个例子实际上并不关心二元操作符的元素是什么。只是检查是否为二元操作符。因此用通配符指代BinOp的元素也是可以的。

```scala
  expr match {
    case BinOp(_, _, _) => println(expr +"is a binary operation")
    case _ => println("It's something else")
  }
```

Listing 15.4 - A pattern match with wildcard patterns.

**Constant patterns**

A constant pattern matches only itself. Any literal may be used as a constant. For example, 5, true, and "hello" are all constant patterns. Also, any val or singleton object can be used as a constant. For example, Nil, a singleton object, is a pattern that matches only the empty list. Listing 15.5 shows some examples of constant patterns:

+ 常量模式仅匹配自身。任何文字都可以用作常量。另外，任何的val或者单例对象也可以被用作常量。如，单例对象Nil，是只匹配空列表的模式。

```scala
    def describe(x: Any) = x match {
      case 5 => "five"
      case true => "truth"
      case "hello" => "hi!"
      case Nil => "the empty list"
      case _ => "something else"
    }
```

Listing 15.5 - A pattern match with constant patterns.

Here is how the pattern match shown in Listing 15.5 looks in action:

```
  scala> describe(5)
  res5: java.lang.String = five
  
  scala> describe(true)
  res6: java.lang.String = truth
  
  scala> describe("hello")
  res7: java.lang.String = hi!
  
  scala> describe(Nil)
  res8: java.lang.String = the empty list
  
  scala> describe(List(1,2,3))
  res9: java.lang.String = something else
```

**Variable patterns**

A variable pattern matches any object, just like a wildcard. Unlike a wildcard, Scala binds the variable to whatever the object is. You can then use this variable to act on the object further. For example, Listing 15.6 shows a pattern match that has a special case for zero, and a default case for all other values. The default cases uses a variable pattern so that it has a name for the value, no matter what it is.

+ 变量模式匹配任意对象，类似于通配符。与通配符不同的地方在于，Scala把变量绑定在匹配的对象上。因此之后你可以使用这个变量操作对象。somethingElse就是变量模式，用来匹配expr，并可以操作。如下x也是。

```scala
    expr match {
      case 0 => "zero"
      case somethingElse => "not zero: "+ somethingElse
    }

    def fib(s:Int) = {
      def f(s:Int):List[Int] = s match {
        case x if x < 0 => Nil
        case 0 => List(0)
        case 1 => List(1,0)
        case _ => val fibs = f(s-1); (fibs.head + fibs.tail.head) :: fibs
      }
      f(s).reverse
    }
```

Listing 15.6 - A pattern match with a variable pattern.

**Variable or constant?**

Constant patterns can have symbolic names. You saw this already when we used Nil as a pattern. Here is a related example, where a pattern match involves the constants E (2.71828...) and Pi (3.14159...):

+ 常量模式有符号名。你可以看到我们使用Nil作为模式。以下例子，这里模式匹配采用了常量E（2.71828…）和 Pi（3.14159…）。

```
  scala> import Math.{E, Pi}
  import Math.{E, Pi}
  
  scala> E match {
           case Pi => "strange math? Pi = "+ Pi
           case _ => "OK"
         }
  res10: java.lang.String = OK
```

As expected, E does not match Pi, so the "strange math" case is not used.

How does the Scala compiler know that Pi is a constant imported from the java.lang.Math object, and not a variable that stands for the selector value itself? Scala uses a simple lexical rule for disambiguation: a simple name starting with a lowercase letter is taken to be a pattern variable; all other references are taken to be constants. To see the difference, create a lowercase alias for pi and try with that:

+ Scala使用了一个简单的文字规则对此加以区分，用小写字母开始的简单名被当作是变量模式，所有其它的引用被认为是常量。

```
  scala> val pi = Math.Pi
  pi: Double = 3.141592653589793
  
  scala> E match {
           case pi => "strange math? Pi = "+ pi
         }
  res11: java.lang.String = strange math? Pi = 2.7182818...
```

Here the compiler will not even let you add a default case at all. Since pi is a variable pattern, it will match all inputs, and so no cases following it can be reached:

```
  scala> E match {
           case pi => "strange math? Pi = "+ pi
           case _ => "OK"  
         }
  <console>:9: error: unreachable code
           case _ => "OK"  
                     ^
```

If you need to, you can still use a lowercase name for a pattern constant, using one of two tricks. First, if the constant is a field of some object, you can prefix it with a qualifier. For instance, pi is a variable pattern, but this.pi or obj.pi are constants even though they start with lowercase letters. If that does not work (because pi is a local variable, say), you can alternatively enclose the variable name in back ticks. For instance, `pi` would again be interpreted as a constant, not as a variable:

+ 如果有必要的话，你仍然可以通过以下两种手法之一给常量模式使用小写字母名。
  - 首先，如果常量是某个对象的字段，可以用限定符前缀在其之上。例如，pi 是变量模式，但是this.pi或obj.pi虽然都开始于小写字母但都是常量。
  - 如果这不起作用（比如说，因为pi是本地变量），还可以用反引号包住变量名，例如，**`pi`**会再次被解释为常量，而不是变量。

```
  scala> E match {
           case `pi` => "strange math? Pi = "+ pi
           case _ => "OK"
         }
  res13: java.lang.String = OK
```

As you can see, the back-tick syntax for identifiers is used for two different purposes in Scala to help you code your way out of unusual circumstances. Here you see that it can be used to treat a lowercase identifier as a constant in a pattern match. Earlier on, in Section 6.10, you saw that it can also be used to treat a keyword as an ordinary identifier, e.g., writing Thread.`yield`() treats yield as an identifier rather than a keyword.

+ 反引号有两个不同的用途在Scala中。
  - 包裹小写作为常量模式。
  - 6.10节中用反引号作为yield关键字的区分。

**Constructor patterns**

Constructors are where pattern matching becomes really powerful. A constructor pattern looks like "BinOp("+", e, Number(0))". It consists of a name (BinOp) and then a number of patterns within parentheses: "+", e, and Number(0). Assuming the name designates a case class, such a pattern means to first check that the object is a member of the named case class, and then to check that the constructor parameters of the object match the extra patterns supplied.

+ 构造器的存在使得模式匹配真正变得强大。构造器模式看上去就像`BinOp("+", e, Number(0))`。它由名称BinOp及若干括号之内的模式`"+", e, Number(0)`构成。假如这个名称指定了一个样本类，那么这个模式就是表示首先检查对象是该命名样本类的成员，然后检查对象的构造器参数符合额外提供的模式

These extra patterns mean that Scala patterns support deep matches. Such patterns not only check the top-level object supplied, but also check the contents of the object against further patterns. Since the extra patterns can themselves be constructor patterns, you can use them to check arbitrarily deep into an object. For example, the pattern shown in Listing 15.7 checks that the top-level object is a BinOp, that its third constructor parameter is a Number, and that the value field of that number is 0. This pattern is one line long yet checks three levels deep.

+ 这些额外的模式意味着Scala模式支持深度匹配deep match。这种模式不只检查顶层对象是否一致，还会检查对象的内容是否匹配内层的模式。由于额外的模式自身可以形成构造器模式，因此可以使用它们检查到对象内部的任意深度。这个模式仅有一行但却能检查三层深度。

```scala
    expr match {
      case BinOp("+", e, Number(0)) => println("a deep match")
      case _ =>
    }
```

Listing 15.7 - A pattern match with a constructor pattern.

**Sequence patterns**

You can match against sequence types like List or Array just like you match against case classes. Use the same syntax, but now you can specify any number of elements within the pattern. For example, Listing 15.8 shows a pattern that checks for a three-element list starting with zero:

+ 同样你也可以像匹配样本类那样匹配如List或Array这样的序列类型。同样的语法，不过现在你可以指定模式内任意数量的元素。

```scala
    expr match {
      case List(0, _, _) => println("found it")
      case _ =>
    }
```

Listing 15.8 - A sequence pattern with a fixed length.

If you want to match against a sequence without specifying how long it can be, you can specify _* as the last element of the pattern. This funny-looking pattern matches any number of elements within a sequence, including zero elements. Listing 15.9 shows an example that matches any list that starts with zero, regardless of how long the list is.

+ 如果你想匹配一个没有特定长度的序列，可以指定`_*`作为模式的最后元素。这种滑稽的模式能匹配序列中零到任意数量的元素。

```scala
    expr match {
      case List(0, _*) => println("found it")
      case _ =>
    }
```

Listing 15.9 - A sequence pattern with an arbitrary length.

**Tuple patterns**

You can match against tuples, too. A pattern like (a, b, c) matches an arbitrary 3-tuple. An example is shown in Listing 15.10:

+ 你还可以匹配元组。类似`(a, b, c)`这样的模式可以匹配任意的3个元素的元组。

```scala
    def tupleDemo(expr: Any) =
      expr match {
        case (a, b, c)  =>  println("matched "+ a + b + c)
        case _ =>
      }
```

Listing 15.10 - A pattern match with a tuple pattern.

If you load the tupleDemo method shown in Listing 15.10 into the interpreter, and pass to it a tuple with three elements, you'll see:

```
  scala> tupleDemo(("a ", 3, "-tuple"))
  matched a 3-tuple
```

**Typed patterns**

You can use a typed pattern as a convenient replacement for type tests and type casts. Listing 15.11 shows an example:

+ 你可以把类型模式typed pattern当做类型测试和类型转换的便捷替代。

```scala
    def generalSize(x: Any) = x match {
      case s: String => s.length
      case m: Map[_, _] => m.size
      case _ => -1
    }
```

Listing 15.11 - A pattern match with typed patterns.

Here are a few examples of using the generalSize method in the interpreter:

```
  scala> generalSize("abc")
  res14: Int = 3
  
  scala> generalSize(Map(1 -> 'a', 2 -> 'b'))
  res15: Int = 2
  
  scala> generalSize(Math.Pi)
  res16: Int = -1
```

The generalSize method returns the size or length of objects of various types. Its argument is of type Any, so it could be any value. If the argument is a String, the method returns the string's length. The pattern "s: String" is a typed pattern; it matches every (non-null) instance of String. The pattern variable s then refers to that string.

Note that, even though s and x refer to the same value, the type of x is Any, but the type of s is String. So you can write s.length in the alternative expression that corresponds to the pattern, but you could not write x.length, because the type Any does not have a length member.

+ 请注意，尽管s和x指代了同样的值，不过x是Any，而s是String。因此可以在模式对应的可选项表达式中写成s.length，但不能写成x.length，因为Any类型没有length成员。 

An equivalent but more long-winded way that achieves the effect of a match against a typed pattern employs a type test followed by a type cast. Scala uses a different syntax than Java for these. To test whether an expression expr has type String, say, you write:

+ 能够得到与类型模式匹配相同效果但更为曲折的方式需要使用类型测试和类型转换。Scala使用了与Java不同的语法。

```
  expr.isInstanceOf[String]
```

To cast the same expression to type String, you use:

```
  expr.asInstanceOf[String]
```

Using a type test and cast, you could rewrite the first case of the previous match expression as shown in Listing 15.12.

```
    if (x.isInstanceOf[String]) {
      val s = x.asInstanceOf[String]
      s.length
    } else ...
```

Listing 15.12 - Using isInstanceOf and asInstanceOf (poor style).

The operators isInstanceOf and asInstanceOf are treated as predefined methods of class Any which take a type parameter in square brackets. In fact, x.asInstanceOf[String] is a special case of a method invocation with an explicit type parameter String.

+ isInstanceOf and asInstanceOf是在Any类中预定义的，需要方括号中的type parameter。事实上是一个特殊的例子用显示type parameter String的方法调用。

As you will have noted by now, writing type tests and casts is rather verbose in Scala. That's intentional, because it is not encouraged practice. You are usually better off using a pattern match with a typed pattern. That's particularly true if you need to do both a type test and a type cast, because both operations are then rolled into a single pattern match.

+ 如果需要同时用到type test和type cast，建议使用pattern match的形式。

The second case of the previous match expression contains the type pattern "m: Map[_, _]". This pattern matches any value that is a Map of some arbitrary key and value types and lets m refer to that value. Therefore, m.size is well typed and returns the size of the map. The underscores in the type pattern are like wildcards in other patterns. You could have also used (lowercase) type variables instead.

+ 第二个case是类型模式，模式匹配任何包含两个值的Map类型。这里的下划线类似于其他模式的wildcard，你也可以用小写类型变量来代替。

**Type erasure**

+ 类型擦除

Can you also test for a map with specific element types? This would be handy, say for testing whether a given value is a map from type Int to type Int. Let's try:

+ 特定元素类型的映射能测吗？这会更有用，比如说测试给定值是否是从Int到Int的映射。

```
  scala> def isIntIntMap(x: Any) = x match {
           case m: Map[Int, Int] => true
           case _ => false
         }
  warning: there were unchecked warnings; re-run with 
     -unchecked for details
  isIntIntMap: (Any)Boolean
```

The interpreter emitted an "unchecked warning." You can find out details by starting the interpreter again with the -unchecked command-line option:

+ 解释器发出了"不能检查警告"。rerun command-line with the `--unchecked`。

```
    scala> :quit
    $ scala -unchecked
    Welcome to Scala version 2.7.2
    (Java HotSpot(TM) Client VM, Java 1.5.0_13).
    Type in expressions to have them evaluated.
    Type :help for more information.
  
  scala>  def isIntIntMap(x: Any) = x match {
           case m: Map[Int, Int] => true
           case _ => false
         }
    <console>:5: warning: non variable type-argument Int in
    type pattern is unchecked since it is eliminated by erasure
             case m: Map[Int, Int] => true
                     ^
```

Scala uses the erasure model of generics, just like Java does. This means that no information about type arguments is maintained at runtime. Consequently, there is no way to determine at runtime whether a given Map object has been created with two Int arguments, rather than with arguments of different types. All the system can do is determine that a value is a Map of some arbitrary type parameters. You can verify this behavior by applying isIntIntMap to arguments of different instances of class Map:

+ Scala使用了泛型的erasure模式，就如Java的那样。也就是说没有保留到运行时的类型参数信息。因此，运行时没有办法判断给定的Map对象创建时带了两个Int参数还是其它的什么类型。系统所能做的只是判断这个值是某种任意类型参数的Map。你可以通过对isIntIntMap调用不同的Map实例来证实这点。

```
  scala> isIntIntMap(Map(1 -> 1))
  res17: Boolean = true
  
  scala> isIntIntMap(Map("abc" -> "abc"))
  res18: Boolean = true
```

The first application returns true, which looks correct, but the second application also returns true, which might be a surprise. To alert you to the possibly non-intuitive runtime behavior, the compiler emits unchecked warnings like the one shown above.

+ 第一个应用返回true，看上去很正确，但是第二个同样返回true，就有点儿让人惊讶了。为了警告你可能存在的这种非直观的运行时行为，编译器就会如之前看到的那样发出不能检查警告。

The only exception to the erasure rule is arrays, because they are handled specially in Java as well as in Scala. The element type of an array is stored with the array value, so you can pattern match on it. Here's an example:

+ 擦除规则的唯一例外就是Array，因为在Scala里，它们正如元素类型被与数组值保存在一起，因此它可以做模式匹配。

```
  scala> def isStringArray(x: Any) = x match {
           case a: Array[String] => "yes"
           case _ => "no"
         }
  isStringArray: (Any)java.lang.String
  
  scala> val as = Array("abc")
  as: Array[java.lang.String] = Array(abc)
  
  scala> isStringArray(as)
  res19: java.lang.String = yes
  
  scala> val ai = Array(1, 2, 3)
  ai: Array[Int] = Array(1, 2, 3)
  
  scala> isStringArray(ai)
  res20: java.lang.String = no
```

**Variable binding**

In addition to the standalone variable patterns, you can also add a variable to any other pattern. You simply write the variable name, an at sign (@), and then the pattern. This gives you a variable-binding pattern. The meaning of such a pattern is to perform the pattern match as normal, and if the pattern succeeds, set the variable to the matched object just as with a simple variable pattern.

+ 除了独立的变量模式之外，你还可以对任何其它模式添加变量。只要简单地写上变量名，一个@符号，以及这个模式。这种写法创造了变量绑定模式。这种模式的意义在于它能够像通常的那样做模式匹配，并且如果匹配成功，则把变量设置成匹配的对象，就像使用简单的变量模式那样。

As an example, Listing 15.13 shows a pattern match that looks for the absolute value operation being applied twice in a row. Such an expression can be simplified to only take the absolute value one time.

+ 这个例子是一个数被操作了两次取绝对值。

```scala
    expr match {
      case UnOp("abs", e @ UnOp("abs", _)) => e
      case _ =>
    }
```

Listing 15.13 - A pattern with a variable binding (via the @ sign).

In Listing 15.13, there is a variable-binding pattern with e as the variable and UnOp("abs", _) as the pattern. If the entire pattern match succeeds, then the portion that matched the UnOp("abs", _) part is made available as variable e. As the code is written, e then gets returned as is.

### 15.3 Pattern guards

Sometimes, syntactic pattern matching is not precise enough. For instance, say you are given the task of formulating a simplification rule that replaces sum expressions with two identical operands such as e + e by multiplications of two, e.g., e * 2. In the language of Expr trees, an expression like:

+ 有些时候，语法的模式匹配还不够精确。如，假如说你被指派了一份工作去制定一个简化规则以通过乘二运算，也就是说，`e * 2`，替代两个相同操作数的相加，如`e + e`。

```
  BinOp("+", Var("x"), Var("x"))
```

would be transformed by this rule to:

```
  BinOp("*", Var("x"), Number(2))
```

You might try to define this rule as follows:

```
  scala> def simplifyAdd(e: Expr) = e match {
           case BinOp("+", x, x) => BinOp("*", x, Number(2))
           case _ => e
         }
  <console>:10: error: x is already defined as value x
           case BinOp("+", x, x) => BinOp("*", x, Number(2))
                              ^
```

This fails, because Scala restricts patterns to be linear: a pattern variable may only appear once in a pattern. However, you can re-formulate the match with a pattern guard, as shown in Listing 15.14:

+ `case BinOp("+", x, x) => BinOp("*", x, Number(2))`失败了，因为 Scala限制模式是线性的，模式变量仅允许在模式中出现一次。然而，你可以使用模式守卫pattern guard重新制定这个匹配规则。

```
    scala> def simplifyAdd(e: Expr) = e match {
             case BinOp("+", x, y) if x == y =>
               BinOp("*", x, Number(2))
             case _ => e
           }
    simplifyAdd: (Expr)Expr
```

Listing 15.14 - A match expression with a pattern guard.

A pattern guard comes after a pattern and starts with an if. The guard can be an arbitrary boolean expression, which typically refers to variables in the pattern. If a pattern guard is present, the match succeeds only if the guard evaluates to true. Hence, the first case above would only match binary operations with two equal operands.

+ 模式守卫接在模式之后，开始于if。守卫可以是任意的引用模式中变量的布尔表达式。

Some other examples of guarded patterns are:

```
  // match only positive integers
  case n: Int if 0 < n => ...  
  
  // match only strings starting with the letter `a'
  case s: String if s(0) == 'a' => ... 
```

### 15.4 Pattern overlaps

Patterns are tried in the order in which they are written. The version of simplify shown in Listing 15.15 presents an example where the order of the cases matters:

+ 模式以代码的先后次序被测试。

```scala
    def simplifyAll(expr: Expr): Expr = expr match {
      case UnOp("-", UnOp("-", e)) =>
        simplifyAll(e)   // `-' is its own inverse 自身反转
      case BinOp("+", e, Number(0)) =>
        simplifyAll(e)   // `0' is a neutral element for `+' 0对于`+`来说不改变
      case BinOp("*", e, Number(1)) =>
        simplifyAll(e)   // `1' is a neutral element for `*' 1对于`*`来说不改变
      case UnOp(op, e) => 
        UnOp(op, simplifyAll(e))
      case BinOp(op, l, r) =>
        BinOp(op, simplifyAll(l), simplifyAll(r))
      case _ => expr
    }
```

Listing 15.15 - Match expression in which case order matters.

The version of simplify shown in Listing 15.15 will apply simplification rules everywhere in an expression, not just at the top, as simplifyTop did. It can be derived from simplifyTop by adding two more cases for general unary and binary expressions (cases four and five in Listing 15.15).

+ 这版本的simplifyAll在表达式的每个地方都采用了简化规则，不只是在顶部，像上面simplifyTop做的。从simplifyTop衍生了模式四和五，增加了通用一元和二进制表达式。

The fourth case has the pattern UnOp(op, e); i.e., it matches every unary operation. The operator and operand of the unary operation can be arbitrary. They are bound to the pattern variables op and e, respectively. The alternative in this case applies simplifyAll recursively to the operand e and then rebuilds the same unary operation with the (possibly) simplified operand. The fifth case for BinOp is analogous: it is a "catch-all" case for arbitrary binary operations, which recursively applies the simplification method to its two operands.

+ 第四个样本有模式`UnOp(op, e)`，它匹配任何一元操作。操作符和操作数是任意的。它们相应地绑定为模式变量op和e。这个样本中的可选表达式对操作数e递归调用了simplifyAll方法并使用（可能是）简化了的操作数重建同样的一元操作。第五个样本对 BinOp是类似的，它是任意二元操作的"全匹配"，并且对两个操作数递归调用了简化方法。

In this example, it is important that the catch-all cases come after the more specific simplification rules. If you wrote them in the other order, then the catch-all case would be run in favor of the more specific rules. In many cases, the compiler will even complain if you try.

+ 在这个例子里，有一点很重要，就是全匹配的样本跟在更特定的简化方法之后。如果写成其它次序，那么全匹配样本将比特定规则获得更高的优先级。在许多情况下，编译器将在你如此尝试的时候发出警告。

For example, here's a match expression that won't compile because the first case will match anything that would be matched by the second case:

+ 如下面的match表达式不会编译成功，因为第一个样本匹配任何能匹配第二个样本的东西。

```
  scala> def simplifyBad(expr: Expr): Expr = expr match {
           case UnOp(op, e) => UnOp(op, simplifyBad(e))
           case UnOp("-", UnOp("-", e)) => e
         }
  <console>:17: error: unreachable code
           case UnOp("-", UnOp("-", e)) => e
                                           ^
```

### 15.5 Sealed classes

+ 封闭类

Whenever you write a pattern match, you need to make sure you have covered all of the possible cases. Sometimes you can do this by adding a default case at the end of the match, but that only applies if there is a sensible default behavior. What do you do if there is no default? How can you ever feel safe that you covered all the cases?

+ 一旦你写好了模式匹配，你就需要确信你已经照顾到了所有可能的情况。有些时候你可以通过在匹配末尾添加一个缺省例子做到这点，不过这仅仅在的确有一个合理的缺省行为的情况下有效。如果没有缺省的情况该怎么办？你怎样才能保证包括了所有的情况呢？

In fact, you can enlist the help of the Scala compiler in detecting missing combinations of patterns in a match expression. To be able to do this, the compiler needs to be able to tell which are the possible cases. In general, this is impossible in Scala, because new case classes can be defined at any time and in arbitrary compilation units. For instance, nothing would prevent you from adding a fifth case class to the Expr class hierarchy in a different compilation unit from the one where the other four cases are defined.

+ 可选方案就是封闭sealed样本类的父类。封闭类除了所在的同一个文件之外不能添加任何新的子类。这对于模式匹配来说是非常有用的，因为这意味着你仅需要关心你已经知道的子类即可。这还意味着你可以获得更好的编译器帮助。如果你使用继承自封闭类的样本类做匹配，编译器将通过警告信息标志出来缺失的模式组合。

The alternative is to make the superclass of your case classes sealed. A sealed class cannot have any new subclasses added except the ones in the same file. This is very useful for pattern matching, because it means you only need to worry about the subclasses you already know about. What's more, you get better compiler support as well. If you match against case classes that inherit from a sealed class, the compiler will flag missing combinations of patterns with a warning message.

Therefore, if you write a hierarchy of classes intended to be pattern matched, you should consider sealing them. Simply put the sealed keyword in front of the class at the top of the hierarchy. Programmers using your class hierarchy will then feel confident in pattern matching against it. The sealed keyword, therefore, is often a license to pattern match. Listing 15.16 shows an example in which Expr is turned into a sealed class.

+ 只要把关键字sealed放在最顶层类的前边即可。

```
    sealed abstract class Expr
    case class Var(name: String) extends Expr
    case class Number(num: Double) extends Expr
    case class UnOp(operator: String, arg: Expr) extends Expr
    case class BinOp(operator: String, 
        left: Expr, right: Expr) extends Expr
```

Listing 15.16 - A sealed hierarchy of case classes.

Now define a pattern match where some of the possible cases are left out:

```scala
  def describe(e: Expr): String = e match {
    case Number(_) => "a number"
    case Var(_)    => "a variable"
  }
```

You will get a compiler warning like the following:

```
  warning: match is not exhaustive!
  missing combination           UnOp
  missing combination          BinOp
```

Such a warning tells you that there's a risk your code might produce a MatchError exception because some possible patterns (UnOp, BinOp) are not handled. The warning points to a potential source of runtime faults, so it is usually a welcome help in getting your program right.

+ 这样的警告向你表明你的代码会有产生MatchError异常的风险，因为某些可能的模式UnOp，BinOp没有被处理。警告指出了潜在的运行时故障的源头，因此它通常是你在正确编程的时候受欢迎的帮助信息。

However, at times you might encounter a situation where the compiler is too picky in emitting the warning. For instance, you might know from the context that you will only ever apply the describe method above to expressions that are either Numbers or Vars. So you know that in fact no MatchError will be produced. To make the warning go away, you could add a third catch-all case to the method, like this:

+ + 然而，有些时候你或许会碰到这样的情况，编译器弹出太过挑剔的警告。要让这些警告不再发生，可以添加一个全匹配样本，但不理想。

```scala
  def describe(e: Expr): String = e match {
    case Number(_) => "a number"
    case Var(_) => "a variable"
    case _ => throw new RuntimeException // Should not happen
  }
```

That works, but it is not ideal. You will probably not be very happy that you were forced to add code that will never be executed (or so you think), just to make the compiler shut up.

A more lightweight alternative is to add an @unchecked annotation to the selector expression of the match. This is done as follows:

+ 更轻量级的替代就是给匹配的选择子表达式添加@unchecked标注。

```scala
  def describe(e: Expr): String = (e: @unchecked) match {
    case Number(_) => "a number"
    case Var(_)    => "a variable"
  }
```

Annotations are described in Chapter 25. In general, you can add an annotation to an expression in the same way you add a type: follow the expression with a colon and the name of the annotation (preceded by an at sign). For example, in this case you add an @unchecked annotation to the variable e, with "e: @unchecked". The @unchecked annotation has a special meaning for pattern matching. If a match's selector expression carries this annotation, exhaustivity checking for the patterns that follow will be suppressed.

+ 通常，你可以用添加类型的同样的方式给表达式添加标注，表达式后跟一个冒号以及标注的名称前缀@符号。比方说，本例中使用`e: @unchecked`方法为变量e添加了`@unchecked`标注。`@unchecked`标注对于模式匹配来说有特定的意思。如果match的选择子表达式带有这个标注，那么对于这个模式的详尽的检查将被抑制掉。

### 15.6 The Option type

Scala has a standard type named Option for optional values. Such a value can be of two forms. It can be of the form Some(x) where x is the actual value. Or it can be the None object, which represents a missing value.

+ Scala为可选值定义了一个名为Option的标准类型。这种值可以有两种形式。可以是`Some(x)`，这里x是实际值的形式。或者也可以是None对象，代表缺失的值。

Optional values are produced by some of the standard operations on Scala's collections. For instance, the get method of Scala's Map produces Some(value) if a value corresponding to a given key has been found, or None if the given key is not defined in the Map. Here's an example:

+ Scala的集合类的某些标准操作会产生可选值。例如，Scala的Map的get方法在发现了指定键的情况下产生Some(value)，或者在Map里没有定义指定键的时候产生None。

```
  scala> val capitals = 
           Map("France" -> "Paris", "Japan" -> "Tokyo")
  capitals: 
    scala.collection.immutable.Map[java.lang.String,
    java.lang.String] = Map(France -> Paris, Japan -> Tokyo)
  
  scala> capitals get "France"
  res21: Option[java.lang.String] = Some(Paris)
  
  scala> capitals get "North Pole"
  res22: Option[java.lang.String] = None
```

The most common way to take optional values apart is through a pattern match. For instance:

```
  scala> def show(x: Option[String]) = x match {
           case Some(s) => s
           case None => "?"
         }
  show: (Option[String])String
  
  scala> show(capitals get "Japan")
  res23: String = Tokyo
  
  scala> show(capitals get "France")
  res24: String = Paris
  
  scala> show(capitals get "North Pole")
  res25: String = ?
```

The Option type is used frequently in Scala programs. Compare this to the dominant idiom in Java of using null to indicate no value. For example, the get method of java.util.HashMap returns either a value stored in the HashMap, or null if no value was found. This approach works for Java, but is error prone, because it is difficult in practice to keep track of which variables in a program are allowed to be null. If a variable is allowed to be null, then you must remember to check it for null every time you use it. When you forget to check, you open the possibility that a NullPointerException may result at runtime. Because such exceptions may not happen very often, it can be difficult to discover the bug during testing. For Scala, the approach would not work at all, because it is possible to store value types in hash maps, and null is not a legal element for a value type. For instance, a HashMap[Int, Int] cannot return null to signify "no element".

+ Java的HashMap的get方法可能会得到null值，如果没有去检查会报NullPointException。Scala的HashMap不会返回null。

By contrast, Scala encourages the use of Option to indicate an optional value. This approach to optional values has several advantages over Java's. First, it is far more obvious to readers of code that a variable whose type is Option[String] is an optional String than a variable of type String, which may sometimes be null. But most importantly, that programming error described earlier of using a variable that may be null without first checking it for null becomes in Scala a type error. If a variable is of type Option[String] and you try to use it as a String, your Scala program will not compile.

+ Scala鼓励对Option的使用以说明可选的值。这种处理可选值的方式有若干超越Java的优点。首先，对于代码读者来说，Option[String]类型的变量是可选的String，这比String类型的变量或者可能有时是null来说要更为显然。但最重要的是，之前描述的因为使用可能为null而没有首先检查是否为null的变量产生的编程错误在Scala里变为类型错误。如果变量是Option[String]类型的，而你打算当做String使用，你的Scala程序就不会编译通过。

### 15.7 Patterns everywhere

+ 模式无处不在。

Patterns are allowed in many parts of Scala, not just in standalone match expressions. Take a look at some other places you can use patterns.

+ 模式在Scala中可以出现在很多地方，而不单单在match表达式里。

**Patterns in variable definitions**

Any time you define a val or a var, you can use a pattern instead of a simple identifier. For example, you can use this to take apart a tuple and assign each of its parts to its own variable, as shown in Listing 15.17:

+ 你在任何定义val或var的时候，都可以使用模式替代简单的标识符。如，可以使用模式拆分元组并把其中的每个值分配给变量。

```
    scala> val myTuple = (123, "abc")
    myTuple: (Int, java.lang.String) = (123,abc)
  
    scala> val (number, string) = myTuple
    number: Int = 123
    string: java.lang.String = abc
```

Listing 15.17 - Defining multiple variables with one assignment.

This construct is quite useful when working with case classes. If you know the precise case class you are working with, then you can deconstruct it with a pattern. Here's an example:

+ 当使用样本类的时候这种构造非常有用。如果你极其了解你正在用的样本类，那就可以使用模式解构它。

```
  scala> val exp = new BinOp("*", Number(5), Number(1))
  exp: BinOp = BinOp(*,Number(5.0),Number(1.0))
  
  scala> val BinOp(op, left, right) = exp
  op: String = *
  left: Expr = Number(5.0)
  right: Expr = Number(1.0)
```

**Case sequences as partial functions**

+ 用作偏函数的样本序列。

A sequence of cases (i.e., alternatives) in curly braces can be used anywhere a function literal can be used. Essentially, a case sequence is a function literal, only more general. Instead of having a single entry point and list of parameters, a case sequence has multiple entry points, each with their own list of parameters. Each case is an entry point to the function, and the parameters are specified with the pattern. The body of each entry point is the right-hand side of the case.
Here is a simple example:

+ 大括号内的样本序列就是说，可选项，可以使用在能够使用函数文本function literal的任何地方。实质上，样本序列就是函数文本function literal，而且只有更常见。代之以只有一个入口点和参数列表，样本序列可以具有多个入口点，每个都有自己的参数列表。每个样本都是函数的一个入口点，参数也被模式所特化。每个入口点的函数体都在样本的右手边。

```scala
  val withDefault: Option[Int] => Int = {
    case Some(x) => x
    case None => 0
  }
```

The body of this function has two cases. The first case matches a Some, and returns the number inside the Some. The second case matches a None, and returns a default value of zero. Here is this function in use:

```
  scala> withDefault(Some(10))
  res25: Int = 10
  
  scala> withDefault(None)
  res26: Int = 0
```

This facility is quite useful for the actors library, described in Chapter 30. Here is some typical actors code. It passes a pattern match directly to the react method:

```scala
  react {
    case (name: String, actor: Actor) => {
      actor ! getip(name)
      act()
    }
    case msg => {
      println("Unhandled message: "+ msg)
      act()
    }
  }
```

One other generalization is worth noting: a sequence of cases gives you a partial function. If you apply such a function on a value it does not support, it will generate a run-time exception. For example, here is a partial function that returns the second element of a list of integers:

+ 另外的通用化方案很值得注意，样本序列可以用作偏函数。如果你对不支持这个偏函数的值调用该方法，将会产生一个运行时异常。

```scala
  val second: List[Int] => Int = {
    case x :: y :: _ => y
  }
```

When you compile this, the compiler will correctly complain that the match is not exhaustive:

```
  <console>:17: warning: match is not exhaustive!
  missing combination            Nil
```

This function will succeed if you pass it a three-element list, but not if you pass it an empty list:

```
  scala> second(List(5,6,7))
  res24: Int = 6
  
  scala> second(List())
  scala.MatchError: List()
        at $anonfun$1.apply(<console>:17)
        at $anonfun$1.apply(<console>:17)
```

If you want to check whether a partial function is defined, you must first tell the compiler that you know you are working with partial functions. The type List[Int] => Int includes all functions from lists of integers to integers, whether or not the functions are partial. The type that only includes partial functions from lists of integers to integers is written PartialFunction[List[Int],Int]. Here is the second function again, this time written with a partial function type:

+ 如果你想要检查是否一个偏函数有定义，你必须首先告诉编译器你知道正在使用的是偏函数。类型`List[Int] => Int`包含了整数列表转整数的所有函数，而不论是否为偏函数。仅包含整数列表转整数的偏函数的，应该写成`PartialFunction[List[Int], Int]`。

```scala
  val second: PartialFunction[List[Int],Int] = {
    case x :: y :: _ => y
  }
```

Partial functions have a method isDefinedAt, which can be used to test whether the function is defined at a particular value. In this case, the function is defined for any list that has at least two elements:

+ 偏函数有一个isDefinedAt方法，可以用来测试是否函数对某个特定值有定义。

```
  scala> second.isDefinedAt(List(5,6,7))
  res27: Boolean = true
  
  scala> second.isDefinedAt(List())
  res28: Boolean = false
```

The typical example of a partial function is a pattern matching function literal like the one in the previous example. In fact, such an expression gets translated by the Scala compiler to a partial function by translating the patterns twice—once for the implementation of the real function, and once to test whether the function is defined or not. For instance, the function literal { case x :: y :: _ => y } above gets translated to the following partial function value:

+ 典性的偏函数例子是前面例子里的那种模式匹配函数文本。实际上，Scala编译器把这样的表达式转译成偏函数的时候， 会对模式执行两次翻译——其中一次是真实函数的实现，还有一次是测试函数是否对特定参数有定义的实现。例如，上面的函数文本`{ case x :: y :: _ => y }`会被翻译成下列的偏函数值。

```scala
  new PartialFunction[List[Int], Int] {
    def apply(xs: List[Int]) = xs match {
      case x :: y :: _ => y 
    }
    def isDefinedAt(xs: List[Int]) = xs match {
      case x :: y :: _ => true
      case _ => false
    }
  }
```

This translation takes effect whenever the declared type of a function literal is PartialFunction. If the declared type is just Function1, or is missing, the function literal is instead translated to a complete function.

+ 这种翻译只有在函数文本的声明类型为PartialFunction的时候才起效。

In general, you should try to work with complete functions whenever possible, because using partial functions allows for runtime errors that the compiler cannot help you with. Sometimes partial functions are really helpful, though. You might be sure that an unhandled value will never be supplied. Alternatively, you might be using a framework that expects partial functions and so will always check isDefinedAt before calling the function. An example of the latter is the react example given above, where the argument is a partially defined function, defined precisely for those messages that the caller wants to handle.

+ 通常，在可能的情况下你可以尝试使用完整函数，因为使用偏函数的话，编译器没办法帮你避免出现运行时故障。不过有些时候偏函数的确很有用。你应该确信一种未处理的值将永远不会出现。或者，你也可以使用一个需要偏函数的架构，并且它会在调用函数之前始终检查isDefinedAt。

**Patterns in for expressions**

You can also use a pattern in a for expression, as shown in Listing 15.18. This for expression retrieves all key/value pairs from the capitals map. Each pair is matched against the pattern (country, city), which defines the two variables country and city.

```
    scala> for ((country, city) <- capitals)
             println("The capital of "+ country +" is "+ city)
    The capital of France is Paris
    The capital of Japan is Tokyo
```

Listing 15.18 - A for expression with a tuple pattern.

The pair pattern shown in Listing 15.18 was special because the match against it can never fail. Indeed, capitals yields a sequence of pairs, so you can be sure that every generated pair can be matched against a pair pattern. But it is equally possible that a pattern might not match a generated value. Listing 15.19 shows an example where that is the case:

+ 这个for表达式从capitals映射中获得所有的键/值对。每一对都匹配于模式`(country, city)`，并定义了两个变量country和city。这个例子的配对模式是特殊的，因为对它的匹配不会失败。实际上，capitals 产生了一系列的配对，因此你可以确信每个产生的配对都能够匹配这个配对模式。

```
    scala> val results = List(Some("apple"), None,
               Some("orange"))
    results: List[Option[java.lang.String]] = List(Some(apple), 
        None, Some(orange))
  
    scala> for (Some(fruit) <- results) println(fruit)
    apple
    orange
```

Listing 15.19 - Picking elements of a list that match a pattern.

As you can see from this example, generated values that do not match the pattern are discarded. For instance, the second element None in the results list does not match the pattern Some(fruit); therefore it does not show up in the output.

+ 不过同样模式也可能无法匹配产生的值。如你在这个例子中所见，产生出来的不能匹配于模式的值被丢弃。

### 15.8 A larger example

After having learned the different forms of patterns, you might be interested in seeing them applied in a larger example. The proposed task is to write an expression formatter class that displays an arithmetic expression in a two-dimensional layout. Divisions such as "x / x + 1" should be printed vertically, by placing the numerator on top of the denominator, like this:

```
  x  
----- 
x + 1
```

As another example, here's the expression ((a / (b * c) + 1 / n) / 3) in two dimensional layout:

```
  a     1 
----- + - 
b * c   n 
--------- 
    3    
```

From these examples it looks like the class (we'll call it ExprFormatter) will have to do a fair bit of layout juggling, so it makes sense to use the layout library developed in Chapter 10. We'll also use the Expr family of case classes you saw previously in this chapter, and place both Chapter 10's layout library and this chapter's expression formatter into named packages. The full code for the example will be shown in Listings 15.20 and 15.21.

A useful first step is to concentrate on horizontal layout. A structured expression like:

```scala
  BinOp("+", 
        BinOp("*", 
              BinOp("+", Var("x"), Var("y")), 
              Var("z")), 
        Number(1))
```

should print (x + y) * z + 1. Note that parentheses are mandatory around x + y, but would be optional around (x + y) * z. To keep the layout as legible as possible, your goal should be to omit parentheses wherever they are redundant, while ensuring that all necessary parentheses are present.

To know where to put parentheses, the code needs to know about the relative precedence of each operator, so it's a good idea to tackle this first. You could express the relative precedence directly as a map literal of the following form:

```scala
  Map(
    "|" -> 0, "||" -> 0,
    "&" -> 1, "&&" -> 1, ...
  )
```

However, this would involve some amount of pre-computation of precedences on your part. A more convenient approach is to just define groups of operators of increasing precedence and then calculate the precedence of each operator from that. Listing 15.20 shows the code.

```scala
    package org.stairwaybook.expr
    import layout.Element.elem
  
    sealed abstract class Expr
    case class Var(name: String) extends Expr
    case class Number(num: Double) extends Expr
    case class UnOp(operator: String, arg: Expr) extends Expr
    case class BinOp(operator: String, 
        left: Expr, right: Expr) extends Expr
  
    class ExprFormatter {
  
      // Contains operators in groups of increasing precedence
      private val opGroups =
        Array(
          Set("|", "||"),
          Set("&", "&&"),
          Set("^"),
          Set("==", "!="),
          Set("<", "<=", ">", ">="),
          Set("+", "-"),
          Set("*", "%")
        )
  
      // A mapping from operators to their precedence
      private val precedence = {
        val assocs =
          for {
            i <- 0 until opGroups.length
            op <- opGroups(i)
          } yield op -> i
        Map() ++ assocs
      }
  
      private val unaryPrecedence = opGroups.length
      private val fractionPrecedence = -1
  
      // continued in Listing 15.21...
```

Listing 15.20 - The top half of the expression formatter.

```scala
    // ...continued from Listing 15.20
  
    private def format(e: Expr, enclPrec: Int): Element =
  
      e match {
  
        case Var(name) => 
          elem(name)
  
        case Number(num) => 
          def stripDot(s: String) = 
            if (s endsWith ".0") s.substring(0, s.length - 2)
            else s
          elem(stripDot(num.toString))
  
        case UnOp(op, arg) => 
          elem(op) beside format(arg, unaryPrecedence)
  
        case BinOp("/", left, right) => 
          val top = format(left, fractionPrecedence)
          val bot = format(right, fractionPrecedence)
          val line = elem('-', top.width max bot.width, 1)
          val frac = top above line above bot
          if (enclPrec != fractionPrecedence) frac
          else elem(" ") beside frac beside elem(" ")
  
        case BinOp(op, left, right) => 
          val opPrec = precedence(op)
          val l = format(left, opPrec) 
          val r = format(right, opPrec + 1)
          val oper = l beside elem(" "+ op +" ") beside r 
          if (enclPrec <= opPrec) oper
          else elem("(") beside oper beside elem(")")
      }
  
      def format(e: Expr): Element = format(e, 0)
    }
```

Listing 15.21 - The bottom half of the expression formatter.

The precedence variable is a map from operators to their precedences, which are integers starting with 0. It is calculated using a for expression with two generators. The first generator produces every index i of the opGroups array. The second generator produces every operator op in opGroups(i). For each such operator the for expression yields an association from the operator op to its index i. Hence, the relative position of an operator in the array is taken to be its precedence. Associations are written with an infix arrow, e.g., op -> i. So far you have seen associations only as part of map constructions, but they are also values in their own right. In fact, the association op -> i is nothing else but the pair (op, i).

Now that you have fixed the precedence of all binary operators except /, it makes sense to generalize this concept to also cover unary operators. The precedence of a unary operator is higher than the precedence of every binary operator. Thus we can set unaryPrecedence (shown in Listing 15.20) to the length of the opGroups array, which is one more than the precedence of the * and % operators.

The precedence of a fraction is treated differently from the other operators because fractions use vertical layout. However, it will prove convenient to assign to the division operator the special precedence value -1, so we'll initialize fractionPrecedence to -1 (shown in Listing 15.20).

After these preparations, you are ready to write the main format method. This method takes two arguments: an expression e, of type Expr, and the precedence enclPrec of the operator directly enclosing the expression e (if there's no enclosing operator, enclPrec should be zero). The method yields a layout element that represents a two-dimensional array of characters.

Listing 15.21 shows the remainder of class ExprFormatter, which includes three methods. The first method, stripDot, is a helper method.The next method, the private format method, does most of the work to format expressions. The last method, also named format, is the lone public method in the library, which takes an expression to format.
The private format method does its work by performing a pattern match on the kind of expression. The match expression has five cases. We'll discuss each case individually. The first case is:

```
  case Var(name) => 
    elem(name)
```

If the expression is a variable, the result is an element formed from the variable's name.
The second case is:

```scala
  case Number(num) => 
    def stripDot(s: String) = 
      if (s endsWith ".0") s.substring(0, s.length - 2)
      else s
    elem(stripDot(num.toString))
```

If the expression is a number, the result is an element formed from the number's value. The stripDot function cleans up the display of a floating-point number by stripping any ".0" suffix from a string.
The third case is:

```
  case UnOp(op, arg) => 
    elem(op) beside format(arg, unaryPrecedence)
```

If the expression is a unary operation UnOp(op, arg) the result is formed from the operation op and the result of formatting the argument arg with the highest-possible environment precedence.[3] This means that if arg is a binary operation (but not a fraction) it will always be displayed in parentheses.
The fourth case is:

```scala
  case BinOp("/", left, right) => 
    val top = format(left, fractionPrecedence)
    val bot = format(right, fractionPrecedence)
    val line = elem('-', top.width max bot.width, 1)
    val frac = top above line above bot
    if (enclPrec != fractionPrecedence) frac
    else elem(" ") beside frac beside elem(" ")
```

If the expression is a fraction, an intermediate result frac is formed by placing the formatted operands left and right on top of each other, separated by an horizontal line element. The width of the horizontal line is the maximum of the widths of the formatted operands. This intermediate result is also the final result unless the fraction appears itself as an argument of another fraction. In the latter case, a space is added on each side of frac. To see the reason why, consider the expression "(a / b) / c". Without the widening correction, formatting this expression would give:

```
a
-
b
-
c
```

The problem with this layout is evident—it's not clear where the top-level fractional bar is. The expression above could mean either "(a / b) / c" or "a / (b / c)". To disambiguate, a space should be added on each side to the layout of the nested fraction "a / b". Then the layout becomes unambiguous:

```
 a 
 - 
 b 
---
 c 
```

The fifth and last case is:

```scala
  case BinOp(op, left, right) => 
    val opPrec = precedence(op)
    val l = format(left, opPrec) 
    val r = format(right, opPrec + 1)
    val oper = l beside elem(" "+ op +" ") beside r 
    if (enclPrec <= opPrec) oper
    else elem("(") beside oper beside elem(")")
```

This case applies for all other binary operations. Since it comes after the case starting with:

```
  case BinOp("/", left, right) => ...
```

you know that the operator op in the pattern BinOp(op, left, right) cannot be a division. To format such a binary operation, one needs to format first its operands left and right. The precedence parameter for formatting the left operand is the precedence opPrec of the operator op, while for the right operand it is one more than that. This scheme ensures that parentheses also reflect the correct associativity. For instance, the operation:

```  
  BinOp("-", Var("a"), BinOp("-", Var("b"), Var("c")))
```

would be correctly parenthesized as "a - (b - c)". The intermediate result oper is then formed by placing the formatted left and right operands side-by-side, separated by the operator. If the precedence of the current operator is smaller than the precedence of the enclosing operator, r is placed between parentheses, otherwise it is returned as is.

This finishes the design of the private format function. The only remaining method is the public format method, which allows client programmers to format a top-level expression without passing a precedence argument. Listing 15.22 shows a demo program that exercises ExprFormatter:

```scala
    import org.stairwaybook.expr._
  
    object Express extends Application {
  
      val f = new ExprFormatter
  
      val e1 = BinOp("*", BinOp("/", Number(1), Number(2)), 
                          BinOp("+", Var("x"), Number(1)))
      val e2 = BinOp("+", BinOp("/", Var("x"), Number(2)), 
                          BinOp("/", Number(1.5), Var("x")))
      val e3 = BinOp("/", e1, e2)
  
      def show(e: Expr) = println(f.format(e)+ "\n\n")
  
      for (val e <- Array(e1, e2, e3)) show(e)
    }
```

Listing 15.22 - An application that prints formatted expressions.

Note that, even though this program does not define a main method, it is still a runnable application because it inherits from the Application trait. As mentioned in Section 4.5, trait Application simply defines an empty main method that gets inherited by the Express object. The actual work in the Express object gets done as part of the object's initialization, before the main method is run. That's why you can apply this trick only if your program does not take any command-line arguments. Once there are arguments, you need to write the main method explicitly. You can run the Express program with the command:

```
  scala Express
```

This will give the following output:

```
1          
- * (x + 1)
2          


x   1.5
- + ---
2    x 


1          
- * (x + 1)
2          
-----------
  x   1.5  
  - + ---  
  2    x   

```

### 15.9 Conclusion

In this chapter, you learned about Scala's case classes and pattern matching in detail. Using them, you can take advantage of several concise idioms not normally available in object-oriented languages. Scala's pattern matching goes further than this chapter describes, however. If you want to use pattern matching on one of your classes, but you do not want to open access to your classes the way case classes do, then you can use the extractors described in Chapter 24. In the next chapter, however, we'll turn our attention to lists.

### Footnotes for Chapter 15:

[1] Instead of an abstract class, we could have equally well chosen to model the root of that class hierarchy as a trait. Modeling it as an abstract class may be slightly more efficient.

[2] Gamma, et. al., Design Patterns gang-of-four

[3] The value of unaryPrecedence is the highest possible precedence, because it was initialized to one more than the precedence of the * and % operators.
