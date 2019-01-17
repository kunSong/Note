## Control Abstraction

### Vocabulary
+ sloppy
+ immense
+ loan

In Chapter 7, we pointed out that Scala doesn't have many built-in control abstractions, because it gives you the ability to create your own. In the previous chapter, you learned about function values. In this chapter, we'll show you how to apply function values to create new control abstractions. Along the way, you'll also learn about currying and by-name parameters.

+ 这章主要是讲如何利用function value来创建新的control abstractions，同时会学到柯林化currying和by-name parameters。

### 9.1 Reducing code duplication

All functions are separated into common parts, which are the same in every invocation of the function, and non-common parts, which may vary from one function invocation to the next. The common parts are in the body of the function, while the non-common parts must be supplied via arguments. When you use a function value as an argument, the non-common part of the algorithm is itself some other algorithm! At each invocation of such a function, you can pass in a different function value as an argument, and the invoked function will, at times of its choosing, invoke the passed function value. These higher-order functions—functions that take functions as parameters—give you extra opportunities to condense and simplify code.

+ 所有函数都会被分割成共通和非共通部分。共通部分每次调用都是相同的，也就是函数体。非共通部分可以用函数以入参的方式得到。可以每次传入不同的函数值function value作为参数。这种higher-order functions将函数作为入参的形式可以给你更多机会来压缩和简化代码。

One benefit of higher-order functions is they enable you to create control abstractions that allow you to reduce code duplication. For example, suppose you are writing a file browser, and you want to provide an API that allows users to search for files matching some criterion. First, you add a facility to search for files whose names end in a particular string. This would enable your users to find, for example, all files with a ".scala" extension. You could provide such an API by defining a public filesEnding method inside a singleton object like this:

+ higher-order函数有个好处能帮助你创建control abstractions来允许你减少代码复制。假设你要写一个文件浏览器，你需要提供一些API让用户按一定规则来搜索文件。首先你会增加一些工具来寻找文件，例如在singleton object中增加了filesEnding方法如下注意是endsWith。

```scala
  object FileMatcher {
    private def filesHere = (new java.io.File(".")).listFiles
  
    def filesEnding(query: String) =
      for (file <- filesHere; if file.getName.endsWith(query))
        yield file
  }
```

The filesEnding method obtains the list of all files in the current directory using the private helper method filesHere, then filters them based on whether each file name ends with the user-specified query. Given filesHere is private, the filesEnding method is the only accessible method defined in FilesMatcher, the API you provide to your users.

+ 通过private方法filesHere所得到现在文件夹中的文件列表，filesEnding方法可以过滤出所需要的文件，filesEnding是用户唯一可以访问的方法。

So far so good, and there is no repeated code yet. Later on, though, you decide to let people search based on any part of the file name. This is good for when your users cannot remember if they named a file phb-important.doc, stupid-phb-report.doc, may2003salesdoc.phb, or something entirely different, but they think that "phb" appears in the name somewhere. You go back to work and add this function to your FileMatcher API:

+ 到现在为止还不错，还没有重复的代码。但是后来用户想查一些文件他们也记得不是很完全，只是记得包含"phb"。所以你增加了一个filesContaining方法注意这里是contains。

```scala
  def filesContaining(query: String) =
    for (file <- filesHere; if file.getName.contains(query))
      yield file
```

This function works just like filesEnding. It searches filesHere, checks the name, and returns the file if the name matches. The only difference is that this function uses contains instead of endsWith.

The months go by, and the program becomes more successful. Eventually, you give in to the requests of a few power users who want to search based on regular expressions. These sloppy guys have immense directories with thousands of files, and they would like to do things like find all "pdf" files that have "oopsla" in the title somewhere. To support them, you write this function:

+ 时间过得很快，有些有权利的人想增加需求，想查找文件通过正则表达式。这些懒散的人想要在海量的文件夹和文件中找到类型是pdf标题中包含"oopsla"的文件。你又写了一个filesRegex的方法注意这里是matchs。

```scala
  def filesRegex(query: String) =
    for (file <- filesHere; if file.getName.matches(query))
      yield file
```

Experienced programmers will notice all of this repetition and wonder if it can be factored into a common helper function. Doing it the obvious way does not work, however. You would like to be able to do the following:

+ 有经验的程序员会注意到这些重复的代码，思考如何可以重构出一个共通的帮助函数。你可能会如下这样写注意这里是method。

```scala
  def filesMatching(query: String, method) =
    for (file <- filesHere; if file.getName.method(query))
      yield file
```

This approach would work in some dynamic languages, but Scala does not allow pasting together code at runtime like this. So what do you do?

+ 上述方案可能在动态语言中试用但是scala不能允许在运行时把他们粘在一起。所以我们要怎么做呢？

Function values provide an answer. While you cannot pass around a method name as a value, you can get the same effect by passing around a function value that calls the method for you. In this case, you could add a matcher parameter to the method whose sole purpose is to check a file name against a query:

+ 函数值function values提供了答案。你不能通过传入名字来作为值，你可以传入函数值function value来实现同样的效果。这里matcher入参类型是一个方法，传入文件名和需要过滤的东西，返回Boolean。函数是`(String, String) => Boolean`。

```scala
  def filesMatching(query: String,
      matcher: (String, String) => Boolean) = {
  
    for (file <- filesHere; if matcher(file.getName, query))
      yield file
  }
```

In this version of the method, the if clause now uses matcher to check the file name against the query. Precisely what this check does depends on what is specified as the matcher. Take a look, now, at the type of matcher itself. It is a function, and thus has a => in the type. This function takes two string arguments—the file name and the query—and returns a boolean, so the type of this function is (String, String) => Boolean.

Given this new filesMatching helper method, you can simplify the three searching methods by having them call the helper method, passing in an appropriate function:

+ 通过新的filesMatching帮助方法，你可以简化之前的寻找方法，如下。

```scala
  def filesEnding(query: String) =
    filesMatching(query, _.endsWith(_))
  
  def filesContaining(query: String) =
    filesMatching(query, _.contains(_))
  
  def filesRegex(query: String) =
    filesMatching(query, _.matches(_))
```

The function literals shown in this example use the placeholder syntax, introduced in the previous chapter, which may not as yet feel very natural to you. Thus, here's a clarification of how placeholders are used in this example. The function literal _.endsWith(_), used in the filesEnding method, means the same thing as:

+ `_.endsWith(_)`用到了placeholder`_`，等价于下面。

```
  (fileName: String, query: String) => fileName.endsWith(query)
```

Because filesMatching takes a function that requires two String arguments, however, you need not specify the types of the arguments. Thus you could also write (fileName, query) => fileName.endsWith(query). Since the parameters are each used only once in the body of the function, and since the first parameter, fileName, is used first in the body, and the second parameter, query, is used second, you can use the placeholder syntax: _.endsWith(_). The first underscore is a placeholder for the first parameter, the file name, and the second underscore a placeholder for the second parameter, the query string.

+ 上面funciton values需要两个String入参，但是你不需要指明他们的类型。当然也可以像上面那种方式写。但是这里`_.endsWith(_)`入参只使用一次，而且按顺序第一个`_`指第一个入参，第二个指第二个。

This code is already simplified, but it can actually be even shorter. Notice that the query gets passed to filesMatching, but filesMatching does nothing with the query except to pass it back to the passed matcher function. This passing back and forth is unnecessary, because the caller already knew the query to begin with! You might as well simply remove the query parameter from filesMatching and matcher, thus simplifying the code as shown in Listing 9.1.

+ 代码已经相当简化了，但是还可以更加短。这里的query可以直接传入无需再传入一遍，所以简化如下。

```scala
    object FileMatcher {
      private def filesHere = (new java.io.File(".")).listFiles
  
      private def filesMatching(matcher: String => Boolean) =
        for (file <- filesHere; if matcher(file.getName))
          yield file
  
      def filesEnding(query: String) =
        filesMatching(_.endsWith(query))
  
      def filesContaining(query: String) =
        filesMatching(_.contains(query))
  
      def filesRegex(query: String) =
        filesMatching(_.matches(query))
    }
```

Listing 9.1 - Using closures to reduce code duplication.

This example demonstrates the way in which first-class functions can help you eliminate code duplication where it would be very difficult to do so without them. In Java, for example, you could create an interface containing a method that takes one String and returns a Boolean, then create and pass anonymous inner class instances that implement this interface to filesMatching. Although this approach would remove the code duplication you are trying to eliminate, it would at the same time add as much or more new code. Thus the benefit is not worth the cost, and you may as well live with the duplication.

+ 一级函数first-class functions会给你带来消除代码重复的效果。在Java中你可以定义接口来实现这个效果但是还会增加其他的新代码和损耗。

Moreover, this example demonstrates how closures can help you reduce code duplication. The function literals used in the previous example, such as _.endsWith(_) and _.contains(_), are instantiated at runtime into function values that are not closures, because they don't capture any free variables. Both variables used in the expression, _.endsWith(_), for example, are represented by underscores, which means they are taken from arguments to the function. Thus, _.endsWith(_) uses two bound variables, and no free variables. By contrast, the function literal _.endsWith(query), used in the most recent example, contains one bound variable, the argument represented by the underscore, and one free variable named query. It is only because Scala supports closures that you were able to remove the query parameter from filesMatching in the most recent example, thereby simplifying the code even further.

+ 而且，这个例子还证明了closure是如何帮助你减少代码重复的。`_.endsWith(_)`这种形式是有两个入参的，没有去捕捉free变量所以不是closure。相反后来例子中用到了`_.endsWith(query)`有一个free variable叫做query，这样就形成了closure，实现了代码简化。

### 9.2 Simplifying client code

The previous example demonstrated that higher-order functions can help reduce code duplication as you implement an API. Another important use of higher-order functions is to put them in an API itself to make client code more concise. A good example is provided by the special-purpose looping methods of Scala's collection types.[1] Many of these are listed in Table 3.1 in Chapter 3, but take a look at just one example for now to see why these methods are so useful.

+ 之前那个例子中higher-order functions能减少代码重复性当你实现的API时。另一个好处就是放在API中使客户端代码简洁。好的例子就Scala的容器类型，很多在Chapter3 Table3.1中。

Consider exists, a method that determines whether a passed value is contained in a collection. You could of course search for an element by having a var initialized to false, looping through the collection checking each item, and setting the var to true if you find what you are looking for. Here's a method that uses this approach to determine whether a passed List contains a negative number:

+ 考虑是否在容器中存在某个值或对象，需要遍历这个容器，使用var来设true or false。下面是找到容器中是否有负数。

```scala
  def containsNeg(nums: List[Int]): Boolean = {
    var exists = false
    for (num <- nums)
      if (num < 0)
        exists = true
    exists
  }
```

If you define this method in the interpreter, you can call it like this:

```
  scala> containsNeg(List(1, 2, 3, 4))
  res0: Boolean = false
  
  scala> containsNeg(List(1, 2, -3, 4))
  res1: Boolean = true
```

A more concise way to define the method, though, is by calling the higher-order function exists on the passed List, like this:

+ 更简洁的方法是使用higher-order function。

```scala
  def containsNeg(nums: List[Int]) = nums.exists(_ < 0)
```

This version of containsNeg yields the same results as the previous:

+ 可以产生同样的效果。

```
  scala> containsNeg(Nil)
  res2: Boolean = false
  
  scala> containsNeg(List(0, -1, -2))
  res3: Boolean = true
```

The exists method represents a control abstraction. It is a special-purpose looping construct provided by the Scala library rather than being built into the Scala language like while or for. In the previous section, the higher-order function, filesMatching, reduces code duplication in the implementation of the object FileMatcher. The exists method provides a similar benefit, but because exists is public in Scala's collections API, the code duplication it reduces is client code of that API. If exists didn't exist, and you wanted to write a containsOdd method, to test whether a list contains odd numbers, you might write it like this:

+ exist方法用control abstraction来代表了。这是Scala library提供特殊目的的循环结构，不是像while or for那样内建在Scala语言中的。如果没有exist方法，那就要如下写containOdd方法。

```scala
  def containsOdd(nums: List[Int]): Boolean = {
    var exists = false
    for (num <- nums)
      if (num % 2 == 1)
        exists = true
    exists
  }
```

If you compare the body of containsNeg with that of containsOdd, you'll find that everything is repeated except the test condition of an if expression. Using exists, you could write this instead:

+ 比较containNeg，还是可以用exist如下写。

```scala
  def containsOdd(nums: List[Int]) = nums.exists(_ % 2 == 1)
```

The body of the code in this version is again identical to the body of the corresponding containsNeg method (the version that uses exists), except the condition for which to search is different. Yet the amount of code duplication is much smaller because all of the looping infrastructure is factored out into the exists method itself.

There are many other looping methods in Scala's standard library. As with exists, they can often shorten your code if you recognize opportunities to use them.

+ 还有其他类似的方法像exist一样。

### 9.3 Currying

In Chapter 1, we said that Scala allows you to create new control abstractions that "feel like native language support." Although the examples you've seen so far are indeed control abstractions, it is unlikely anyone would mistake them for native language support. To understand how to make control abstractions that feel more like language extensions, you first need to understand the functional programming technique called currying.

+ 理解如何用control abstractions感觉更像语言拓展，你要确保理解函数变成的技术叫做柯林化currying。

A curried function is applied to multiple argument lists, instead of just one. Listing 9.2 shows a regular, non-curried function, which adds two Int parameters, x and y.

+ 这里是一个普通的没有currying的函数，目的是两数相加。

```
    scala> def plainOldSum(x: Int, y: Int) = x + y
    plainOldSum: (Int,Int)Int
  
    scala> plainOldSum(1, 2)
    res4: Int = 3
```

Listing 9.2 - Defining and invoking a "plain old" function.

By contrast, Listing 9.3 shows a similar function that's curried. Instead of one list of two Int parameters, you apply this function to two lists of one Int parameter each.

+ 相反的，类似的功能函数使用了currying，入参是两个分开的整数。

```
    scala> def curriedSum(x: Int)(y: Int) = x + y
    curriedSum: (Int)(Int)Int
  
    scala> curriedSum(1)(2)
    res5: Int = 3
```

Listing 9.3 - Defining and invoking a curried function.

What's happening here is that when you invoke curriedSum, you actually get two traditional function invocations back to back. The first function invocation takes a single Int parameter named x, and returns a function value for the second function. This second function takes the Int parameter y. Here's a function named first that does in spirit what the first traditional function invocation of curriedSum would do:

+ 这里调用curriedSum相当于连续调用两个传统的函数，第一次入参为x，返回一个函数值function value给第二个函数，第二个函数入参为y。如下是第一个函数的分解。

```
  scala> def first(x: Int) = (y: Int) => x + y
  first: (Int)(Int) => Int
```

Applying 1 to the first function—in other words, invoking the first function and passing in 1—yields the second function:

```
  scala> val second = first(1)
  second: (Int) => Int = <function>
```

Applying 2 to the second function yields the result:

```
  scala> second(2)
  res6: Int = 3
```

These first and second functions are just an illustration of the currying process. They are not directly connected to the curriedSum function. Nevertheless, there is a way to get an actual reference to curriedSum's "second" function. You can use the placeholder notation to use curriedSum in a partially applied function expression, like this:

+ 前面两个函数只是描绘了currying过程。你可以用placeholder概念来使用curriedSum部分应用。underscore的部分是第二个参数列表。

```
  scala> val onePlus = curriedSum(1)_
  onePlus: (Int) => Int = <function>
```

The underscore in curriedSum(1)_ is a placeholder for the second parameter list.[2] The result is a reference to a function that, when invoked, adds one to its sole Int argument and returns the result:

```
  scala> onePlus(2)
  res7: Int = 3
```

And here's how you'd get a function that adds two to its sole Int argument:

```
  scala> val twoPlus = curriedSum(2)_
  twoPlus: (Int) => Int = <function>
  
  scala> twoPlus(2)
  res8: Int = 4
```

### 9.4 Writing new control structures

In languages with first-class functions, you can effectively make new control structures even though the syntax of the language is fixed. All you need to do is create methods that take functions as arguments.

+ 一级函数都可以创建新的控制结构甚至语法是固定的。你所要做的是创建方法用函数作为入参。

For example, here is the "twice" control structure, which repeats an operation two times and returns the result:

```
  scala> def twice(op: Double => Double, x: Double) = op(op(x))
  twice: ((Double) => Double,Double)Double
  
  scala> twice(_ + 1, 5)
  res9: Double = 7.0
```

The type of op in this example is Double => Double, which means it is a function that takes one Double as an argument and returns another Double.

+ 这里重复两次操作并返回结果，op`Double => Double`是入参为Double返回值是另一个Double。这里`_ + 1`等价于`Double => Double + 1`。

Any time you find a control pattern repeated in multiple parts of your code, you should think about implementing it as a new control structure. Earlier in the chapter you saw filesMatching, a very specialized control pattern. Consider now a more widely used coding pattern: open a resource, operate on it, and then close the resource. You can capture this in a control abstraction using a method like the following:

+ 任何时候你发现代码中有多个部分有重复的控制形式，你可以考虑用新的控制结构来实现。现在有个功能结构，打开资源，操作他，关闭资源。如下使用了control abstraction。

```scala
  def withPrintWriter(file: File, op: PrintWriter => Unit) {
    val writer = new PrintWriter(file)
    try {
      op(writer)
    } finally {
      writer.close()
    }
  }
```

Given such a method, you can use it like this:

```scala
  withPrintWriter(
    new File("date.txt"),
    writer => writer.println(new java.util.Date)
  )
```

The advantage of using this method is that it's withPrintWriter, not user code, that assures the file is closed at the end. So it's impossible to forget to close the file. This technique is called the loan pattern, because a control-abstraction function, such as withPrintWriter, opens a resource and "loans" it to a function. For instance, withPrintWriter in the previous example loans a PrintWriter to the function, op. When the function completes, it signals that it no longer needs the "borrowed" resource. The resource is then closed in a finally block, to ensure it is indeed closed, regardless of whether the function completes by returning normally or throwing an exception.

+ 好处是保证最后资源的关闭。这种技术叫借贷样式。因为withPrintWriter是个control-abstraction。最后在finally中关闭资源不管是有没有函数完成返回或者抛出异常。

One way in which you can make the client code look a bit more like a built-in control structure is to use curly braces instead of parentheses to surround the argument list. In any method invocation in Scala in which you're passing in exactly one argument, you can opt to use curly braces to surround the argument instead of parentheses.

+ 另一个方法是你可以将调用者的代码看起来更像内建控制结构built-in control structure，使用大括号来代替括号在入参列表。在Scala方法调用中，如果你只传一个入参，你可以用大括号来代替括号。如下。

For example, instead of:

```
  scala> println("Hello, world!")
  Hello, world!
```

You could write:

```
  scala> println { "Hello, world!" }
  Hello, world!
```

In the second example, you used curly braces instead of parentheses to surround the arguments to println. This curly braces technique will work, however, only if you're passing in one argument. Here's an attempt at violating that rule:

```
  scala> val g = "Hello, world!"
  g: java.lang.String = Hello, world!
  
  scala> g.substring { 7, 9 }
  <console>:1: error: ';' expected but ',' found.
         g.substring { 7, 9 }
                        ^
```

Because you are attempting to pass in two arguments to substring, you get an error when you try to surround those arguments with curly braces. Instead, you'll need to use parentheses:

+ 这里违背了只传一个参数的规则，这里试图传两个参数7和9。就还会有错误所以不能用大括号了。

```
  scala> g.substring(7, 9)
  res12: java.lang.String = wo
```

The purpose of this ability to substitute curly braces for parentheses for passing in one argument is to enable client programmers to write function literals between curly braces. This can make a method call feel more like a control abstraction. Take the withPrintWriter method defined previously as an example. In its most recent form, withPrintWriter takes two arguments, so you can't use curly braces. Nevertheless, because the function passed to withPrintWriter is the last argument in the list, you can use currying to pull the first argument, the File, into a separate argument list. This will leave the function as the lone parameter of the second argument list. Listing 9.4 shows how you'd need to redefine withPrintWriter.

+ 如果把调用者代码写在大括号内，感觉更像是control abstraction。因为之前的withPrintWriter方法调用了两个入参所以不能用大括号。你可以使用currying来分开入参列表，如下。

```scala
    def withPrintWriter(file: File)(op: PrintWriter => Unit) {
      val writer = new PrintWriter(file)
      try {
        op(writer)
      } finally {
        writer.close()
      }
    }
```

Listing 9.4 - Using the loan pattern to write to a file.

The new version differs from the old one only in that there are now two parameter lists with one parameter each instead of one parameter list with two parameters. Look between the two parameters. In the previous version of withPrintWriter, shown here, you see ...File, op.... But in this version, you see ...File)(op.... Given the above definition, you can call the method with a more pleasing syntax:

```scala
  val file = new File("date.txt")
  
  withPrintWriter(file) {
    writer => writer.println(new java.util.Date)
  }
```

In this example, the first argument list, which contains one File argument, is written surrounded by parentheses. The second argument list, which contains one function argument, is surrounded by curly braces.

### 9.5 By-name parameters

The withPrintWriter method shown in the previous section differs from built-in control structures of the language, such as if and while, in that the code between the curly braces takes an argument. The withPrintWriter method requires one argument of type PrintWriter. This argument shows up as the "writer =>" in:

```scala
  withPrintWriter(file) {
    writer => writer.println(new java.util.Date)
  }
```

What if you want to implement something more like if or while, however, where there is no value to pass into the code between the curly braces? To help with such situations, Scala provides by-name parameters.

+ 如果你想把上面在大括号中不像build-in control such as if or while的结构更像if or while，没有值传到大括号中。Scala提供了一种叫by-name parameters。

As a concrete example, suppose you want to implement an assertion construct called myAssert.[3] The myAssert function will take a function value as input and consult a flag to decide what to do. If the flag is set, myAssert will invoke the passed function and verify that it returns true. If the flag is turned off, myAssert will quietly do nothing at all.

+ 你想构建一个断言结构叫myAssert。通过一个flag来控制传入的function value来做还是不做，例如下面if语句中的短路效果。

Without using by-name parameters, you could write myAssert like this:

```scala
  var assertionsEnabled = true
  
  def myAssert(predicate: () => Boolean) =
    if (assertionsEnabled && !predicate())
      throw new AssertionError
```

The definition is fine, but using it is a little bit awkward:

```
  myAssert(() => 5 > 3)
```

You would really prefer to leave out the empty parameter list and => symbol in the function literal and write the code like this:

+ 想省略`()=>`但是这样是不工作的。

```
  myAssert(5 > 3) // Won't work, because missing () => 
```

By-name parameters exist precisely so that you can do this. To make a by-name parameter, you give the parameter a type starting with => instead of () =>. For example, you could change myAssert's predicate parameter into a by-name parameter by changing its type, "() => Boolean", into "=> Boolean". Listing 9.5 shows how that would look:

+ by-name parameters能帮助你省略上面所说的`()`。通过入参类型用`=> Boolean`代替`() => Boolean`。

```scala
    def byNameAssert(predicate: => Boolean) =
      if (assertionsEnabled && !predicate)
        throw new AssertionError
```

Listing 9.5 - Using a by-name parameter.

Now you can leave out the empty parameter in the property you want to assert. The result is that using byNameAssert looks exactly like using a built-in control structure:

+ 现在你可以省略`() =>`，看起来更像是build-in control结构。

```
  byNameAssert(5 > 3)
```

A by-name type, in which the empty parameter list, (), is left out, is only allowed for parameters. There is no such thing as a by-name variable or a by-name field.

+ by-name type只能用在空的入参列表中，可以省略`()`。没有by-name变量之类的。

Now, you may be wondering why you couldn't simply write myAssert using a plain old Boolean for the type of its parameter, like this:

+ 那为何不直接传一个boolean类型呢？

```scala
  def boolAssert(predicate: Boolean) =
    if (assertionsEnabled && !predicate)
      throw new AssertionError
```

This formulation is also legal, of course, and the code using this version of boolAssert would still look exactly as before:

+ 当然这样也是可以的。而且调用还是和之前一样。

```
  boolAssert(5 > 3)
```

Nevertheless, one difference exists between these two approaches that is important to note. Because the type of boolAssert's parameter is Boolean, the expression inside the parentheses in boolAssert(5 > 3) is evaluated before the call to boolAssert. The expression 5 > 3 yields true, which is passed to boolAssert. By contrast, because the type of byNameAssert's predicate parameter is => Boolean, the expression inside the parentheses in byNameAssert(5 > 3) is not evaluated before the call to byNameAssert. Instead a function value will be created whose apply method will evaluate 5 > 3, and this function value will be passed to byNameAssert.

+ 但是这两种方法还是有不同点的，如果参数是Boolean类型，调用时是用`5 > 3`，那`5 > 3`会在boolAssert之前产生一个true来传给他。然而类型是`=> Boolean`是，那会把`5 > 3`表达式传过去给byNameAssert。

The difference between the two approaches, therefore, is that if assertions are disabled, you'll see any side effects that the expression inside the parentheses may have in boolAssert, but not in byNameAssert. For example, if assertions are disabled, attempting to assert on "x / 0 == 0" will yield an exception in boolAssert's case:

+ 把assertionsEnabled设置为false，那上述的if语句中的&&会被短路。如果使用类型为Boolean的入参形式，`x /0 == 0`因为会被优先于调用前执行就会有些副作用，会抛出异常。但是如果使用的是`=> Boolean`就不会，因为短路后面传入的表达式不会被执行。

```
  scala> var assertionsEnabled = false
  assertionsEnabled: Boolean = false
  
  scala> boolAssert(x / 0 == 0)
  java.lang.ArithmeticException: / by zero
           at .<init>(<console>:8)
          at .<clinit>(<console>)
          at RequestResult$.<init>(<console>:3)
          at RequestResult$.<clinit>(<console>)...
```

But attempting to assert on the same code in byNameAssert's case will not yield an exception:

```
  scala> byNameAssert(x / 0 == 0)
```

### 9.6 Conclusion

This chapter has shown you how to build on Scala's rich function support to build control abstractions. You can use functions within your code to factor out common control patterns, and you can take advantage of higher-order functions in the Scala library to reuse control patterns that are common across all programmers' code. This chapter has also shown how to use currying and by-name parameters so that your own higher-order functions can be used with a concise syntax.

In the previous chapter and this one, you have seen quite a lot of information about functions. The next few chapters will go back to discussing more object-oriented features of the language.

### Footnotes for Chapter 9:

[1] These special-purpose looping methods are defined in trait Iterable, which is extended by List, Set, Array, and Map. See Chapter 17 for a discussion.

[2] In the previous chapter, when the placeholder notation was used on traditional methods, like println _, you had to leave a space between the name and the underscore. In this case you don't, because whereas println_ is a legal identifier in Scala, curriedSum(1)_ is not.

[3] You'll call this myAssert, not assert, because Scala provides an assert of its own, which will be described in Section 14.1.

