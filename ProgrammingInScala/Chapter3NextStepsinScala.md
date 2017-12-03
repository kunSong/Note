## Next Steps in Scala

### Vocabulary
  + side effect
    - changing something somewhere
    - Accessing a volatile object, modifying an object, modifying a file, or calling a function that does any of those operations are all side effects，which are changes in the state of the execution environment.
    - A side effect is generally defined as mutating state somewhere external to the method or performing an I/O action.
  + semantically
  + incur
  + concise
  + mutate
  + concatenation
  + prepend
  + operand
  + amiss
  + associativity
  + notation
  + whereas
  + imperative styles
  + inherently
  + akin
  + blasphemy
  + ultimately
  + error-prone
  + telltale
  + reveal
  + bear in mind that

### Step 7. Parameterize arrays with types

In Scala, you can instantiate objects, or class instances, using new. When you instantiate an object in Scala, you can parameterize it with values and types. Parameterization means "configuring" an instance when you create it. You parameterize an instance with values by passing objects to a constructor in parentheses. For example, the following Scala code instantiates a new java.math.BigInteger and parameterizes it with the value "12345":
  
  + 使用new来实例化对象和类实例，可以在括号中传入构造方法的参数。
  
  ```scala
  val big = new java.math.BigInteger("12345")
  ```

You parameterize an instance with types by specifying one or more types in square brackets. An example is shown in Listing 3.1. In this example, greetStrings is a value of type `Array[String](an "array of string")` that is initialized to length 3 by parameterizing it with the value 3 in the first line of code. If you run the code in Listing 3.1 as a script, you'll see yet another Hello, world! greeting. Note that when you parameterize an instance with both a type and a value, the type comes first in its square brackets, followed by the value in parentheses.

  + greetStrings中在方括号中指明一个或多个类型，圆括号中是array长度。

  ```scala
  val greetStrings = new Array[String](3)
  
  greetStrings(0) = "Hello"
  greetStrings(1) = ", "
  greetStrings(2) = "world!\n"
  
  for (i <- 0 to 2)
    print(greetStrings(i))
  ```

Listing 3.1 - Parameterizing an array with a type.

Although the code in Listing 3.1 demonstrates important concepts, it does not show the recommended way to create and initialize an array in Scala. You'll see a better way in Listing 3.2 here.
  
  + 在Scala中，3.1并不是推荐的创建和初始化array，请看3.2。

  ```scala
  val numNames = Array("zero", "one", "two")
  ```

Listing 3.2 - Creating and initializing an array.

Had you been in a more explicit mood, you could have specified the type of greetStrings explicitly like this:

  ```scala
  val greetStrings: Array[String] = new Array[String](3)
  ```

Given Scala's type inference, this line of code is semantically equivalent to the actual first line of Listing 3.1. But this form demonstrates that while the type parameterization portion (the type names in square brackets) forms part of the type of the instance, the value parameterization part (the values in parentheses) does not. The type of greetStrings is Array[String], not `Array[String](3)`.

  + Scala类型猜测，显示指定对象类型和3.1中是相同的，是`Array[String]`。

The next three lines of code in Listing 3.1 initialize each element of the greetStrings array:

  ```scala
  greetStrings(0) = "Hello"
  greetStrings(1) = ", "
  greetStrings(2) = "world!\n"
  ```

As mentioned previously, arrays in Scala are accessed by placing the index inside parentheses, not square brackets as in Java. Thus the zeroth element of the array is greetStrings(0), not greetStrings[0].

  + Java数组索引是用[0]，而Scala是用(0)来索引并且是从0开始。

These three lines of code illustrate an important concept to understand about Scala concerning the meaning of val. When you define a variable with val, the variable can't be reassigned, but the object to which it refers could potentially still be changed. So in this case, you couldn't reassign greetStrings to a different array; greetStrings will always point to the same Array[String] instance with which it was initialized. But you can change the elements of that Array[String] over time, so the array itself is mutable.

  + 重要概念，当你定义了一个val对象，对象是不能被重新指定的，但是其元素是可以被改变的所以数组本身是可变的。

The final two lines in Listing 3.1 contain a for expression that prints out each greetStrings array element in turn:

  ```scala
  for (i <- 0 to 2)
    print(greetStrings(i))
  ```

The first line of code in this for expression illustrates another general rule of Scala: if a method takes only one parameter, you can call it without a dot or parentheses. The to in this example is actually a method that takes one Int argument. The code 0 to 2 is transformed into the method call (0).to(2).[1] Note that this syntax only works if you explicitly specify the receiver of the method call. You cannot write "println 10", but you can write "Console println 10".

  + Scala重要规则，当一个方法只用一个参数，可以调用它不需要点和括号。`0 to 2`等于(0).to(2)，但是记住一定要有方法调用的接收者即谁调用的。

Scala doesn't technically have operator overloading, because it doesn't actually have operators in the traditional sense. Instead, characters such as +, -, *, and / can be used in method names. Thus, when you typed 1 + 2 into the Scala interpreter in Step 1, you were actually invoking a method named + on the Int object 1, passing in 2 as a parameter. As illustrated in Figure 3.1, you could alternatively have written 1 + 2 using traditional method invocation syntax, (1).+(2).

  + Scala是没有操作符重载的，+, -, *, and /都是方法名，`1 + 2`的传统方法是`(1).+(2)`。

  ![Figure 3.1 - All operations are method calls in Scala.](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure3.1.jpg)

Another important idea illustrated by this example will give you insight into why arrays are accessed with parentheses in Scala. Scala has fewer special cases than Java. Arrays are simply instances of classes like any other class in Scala. When you apply parentheses surrounding one or more values to a variable, Scala will transform the code into an invocation of a method named apply on that variable. So greetStrings(i) gets transformed into greetStrings.apply(i). Thus accessing an element of an array in Scala is simply a method call like any other. This principle is not restricted to arrays: any application of an object to some arguments in parentheses will be transformed to an apply method call. Of course this will compile only if that type of object actually defines an apply method. So it's not a special case; it's a general rule.

  + Scala比Java少一些特殊情况，有个大众的规则，`greetStrings(i)`等于`greetStrings.apply(i)`，它是一种方法调用这不仅限于Array，括号中有入参的都会转换成apply方法，当然对象需要实际定义了apply方法。

Similarly, when an assignment is made to a variable to which parentheses and one or more arguments have been applied, the compiler will transform that into an invocation of an update method that takes the arguments in parentheses as well as the object to the right of the equals sign. For example:

  + 相同地，会把等号左边的Hello作为入参和前面的0入参一起变成update方法。

  ```scala
  greetStrings(0) = "Hello" 

  // will be transformed into:

  greetStrings.update(0, "Hello")

  // Thus, the following is semantically equivalent to the code in Listing 3.1:

  val greetStrings = new Array[String](3)
  
  greetStrings.update(0, "Hello")
  greetStrings.update(1, ", ")
  greetStrings.update(2, "world!\n")
  
  for (i <- 0.to(2))
    print(greetStrings.apply(i))
  ```

Scala achieves a conceptual simplicity by treating everything, from arrays to expressions, as objects with methods. You don't have to remember special cases, such as the differences in Java between primitive and their corresponding wrapper types, or between arrays and regular objects. Moreover, this uniformity does not incur a significant performance cost. The Scala compiler uses Java arrays, primitive types, and native arithmetic where possible in the compiled code.

  + Scala对待所有的东西为有方法的对象，而且不会造成性能损耗，Scala编译器可能会在编译好的代码中是使用Java数组、基本数据类型和本地算法。

Although the examples you've seen so far in this step compile and run just fine, Scala provides a more concise way to create and initialize arrays that you would normally use. It looks as shown in Listing 3.2. This code creates a new array of length three, initialized to the passed strings, "zero", "one", and "two". The compiler infers the type of the array to be Array[String], because you passed strings to it.

  + Scala给出了更加简明地创建和初始化Array的方法，3.2中创建了一个3个string组成的Array，类型推测为Array[String]。

    ```scala
    val numNames = Array("zero", "one", "two")
    ```

Listing 3.2 - Creating and initializing an array.

What you're actually doing in Listing 3.2 is calling a factory method, named apply, which creates and returns the new array. This apply method takes a variable number of arguments[2] and is defined on the Array companion object. You'll learn more about companion objects in Section 4.3. If you're a Java programmer, you can think of this as calling a static method named apply on class Array. A more verbose way to call the same apply method is:

  + 3.2中调用了一个工厂方法叫做apply方法，它是定义在Array的伴随对象中的，类似于Java中在Array类中的静态方法。

  ```scala
  val numNames2 = Array.apply("zero", "one", "two")
  ```

### Step 8. Use lists

One of the big ideas of the functional style of programming is that methods should not have side effects. A method's only act should be to compute and return a value. Some benefits gained when you take this approach are that methods become less entangled, and therefore more reliable and reusable. Another benefit (in a statically typed language) is that everything that goes into and out of a method is checked by a type checker, so logic errors are more likely to manifest themselves as type errors. Applying this functional philosophy to the world of objects means making objects immutable.

  + 函数式编程中方法不应该有赋值，方法应该计算和返回一个值。
    - 好处一：方法会解偶，可靠和被重用。
    - 好处二：每个东西进和出方法都会被类型检测，逻辑错误更像是类型错误。
    - 将函数的心理应用到对象世界就是使对象不可变。

As you've seen, a Scala array is a mutable sequence of objects that all share the same type. An Array[String] contains only strings, for example. Although you can't change the length of an array after it is instantiated, you can change its element values. Thus, arrays are mutable objects.

  + Scala Array[String]是一个只含有相同类型strings元素的可变对象，初始化后是不能改变长度，但是可以改变元素值的。

For an immutable sequence of objects that share the same type you can use Scala's List class. As with arrays, a List[String] contains only strings. Scala's List, scala.List, differs from Java's java.util.List type in that Scala Lists are always immutable (whereas Java Lists can be mutable). More generally, Scala's List is designed to enable a functional style of programming. Creating a list is easy. Listing 3.3 shows how:

  + Scala scala.List[String]是不可变的区别于Java中的Lists，scala List是为了能函数式编程而设计的。

    ```scala
    val oneTwoThree = List(1, 2, 3)
    ```

Listing 3.3 - Creating and initializing a list.

The code in Listing 3.3 establishes a new val named oneTwoThree, initialized with a new List[Int] with the integer elements 1, 2, and 3.[3] Because Lists are immutable, they behave a bit like Java strings: when you call a method on a list that might seem by its name to imply the list will mutate, it instead creates and returns a new list with the new value. For example, List has a method named `:::' for list concatenation. Here's how you use it:

  + 3.3创建new了一个val以元素1,2,3的List[Int]对象，是不可变的有点像Java的strings。`:::`方法是将两了List连接起来创建并返回一个新的List作为值。

  ```scala
  val oneTwo = List(1, 2)
  val threeFour = List(3, 4)
  val oneTwoThreeFour = oneTwo ::: threeFour
  println(""+ oneTwo +" and "+ threeFour +" were not mutated.")
  println("Thus, "+ oneTwoThreeFour +" is a new list.")

  // If you run this script, you'll see:
  /* output:
  List(1, 2) and List(3, 4) were not mutated.
  Thus, List(1, 2, 3, 4) is a new list.
  */
  ```

Perhaps the most common operator you'll use with lists is `::', which is pronounced "cons." Cons prepends a new element to the beginning of an existing list, and returns the resulting list. For example, if you run this script:

  + `::`发音是"cons"，将新元素放在已经存在的List的开始，并返回一个结果List。

  ```scala
  val twoThree = List(2, 3)
  val oneTwoThree = 1 :: twoThree
  println(oneTwoThree)

  /* You'll see:
  List(1, 2, 3)
  */
  ```

In the expression "1 :: twoThree", :: is a method of its right operand, the list, twoThree. You might suspect there's something amiss with the associativity of the :: method, but it is actually a simple rule to remember: If a method is used in operator notation, such as a * b, the method is invoked on the left operand, as in a.*(b)—unless the method name ends in a colon. If the method name ends in a colon, the method is invoked on the right operand. Therefore, in 1 :: twoThree, the :: method is invoked on twoThree, passing in 1, like this: twoThree.::(1). Operator associativity will be described in more detail in Section 5.8.

  + `a * b`等于`a.*(b)是左操作符，如果是以冒号结束的就是右操作符。`1 :: twoThree`等于`twoThree.::(1)`

Given that a shorthand way to specify an empty list is Nil, one way to initialize new lists is to string together elements with the cons operator, with Nil as the last element.[4] For example, the following script will produce the same output as the previous one, "List(1, 2, 3)":

  + Nil表示一个空的List，通过下面的式子可以创建一个"List(1, 2, 3)"。

  ```scala
  val oneTwoThree = 1 :: 2 :: 3 :: Nil
  println(oneTwoThree)
  ```

Scala's List is packed with useful methods, many of which are shown in Table 3.1. The full power of lists will be revealed in Chapter 16.

Why not append to lists?

Class List does not offer an append operation, because the time it takes to append to a list grows linearly with the size of the list, whereas prepending with :: takes constant time. Your options if you want to build a list by appending elements is to prepend them, then when you're done call reverse; or use a ListBuffer, a mutable list that does offer an append operation, and when you're done call toList. ListBuffer will be described in Section 22.2.

  + List不用append方法而是用`::`，是因为append到一个List的时间会随着List的增大而线性增长，相反`::`只是恒定的。如果你想append可以先加到头部然后是用反转方法或者使用可变ListBuffer完成后调用toList方法。

  + List is packed with useful methods
    - List() or Nil: The empty List
    - List("Cool", "tools", "rule"): Creates a new List[String] with the three values "Cool", "tools", and "rule"
    - val thrill = "Will" :: "fill" :: "until" :: Nil: Creates a new List[String] with the three values "Will", "fill", and "until"
    - List("a", "b") ::: List("c", "d"): Concatenates two lists (returns a new List[String] with values "a", "b", "c", and "d")
    - thrill(2): Returns the element at index 2 (zero based) of the thrill list (returns "until")
    - thrill.count(s => s.length == 4): Counts the number of string elements in thrill that have length 4 (returns 2)
    - thrill.drop(2): Returns the thrill list without its first 2 elements (returns List("until"))
    - thrill.dropRight(2): Returns the thrill list without its rightmost 2 elements (returns List("Will"))
    - thrill.exists(s => s == "until"): Determines whether a string element exists in thrill that has the value "until" (returns true)
    - thrill.filter(s => s.length == 4): Returns a list of all elements, in order, of the thrill list that have length 4 (returns List("Will", "fill"))
    - thrill.forall(s => s.endsWith("l")): Indicates whether all elements in the thrill list end with the letter "l" (returns true)
    - thrill.foreach(s => print(s)): Executes the print statement on each of the strings in the thrill list (prints "Willfilluntil")
    - thrill.foreach(print): Same as the previous, but more concise (also prints "Willfilluntil")
    - thrill.head: Returns the first element in the thrill list (returns "Will")
    - thrill.init: Returns a list of all but the last element in the thrill list (returns List("Will", "fill"))
    - thrill.isEmpty: Indicates whether the thrill list is empty (returns false)
    - thrill.last: Returns the last element in the thrill list (returns "until")
    - thrill.length: Returns the number of elements in the thrill list (returns 3)
    - thrill.map(s => s + "y"): Returns a list resulting from adding a "y" to each string element in the thrill list (returns List("Willy", "filly", "untily"))
    - thrill.mkString(", "): Makes a string with the elements of the list (returns "Will, fill, until")
    - thrill.remove(s => s.length == 4): Returns a list of all elements, in order, of the thrill list except those that have length 4 (returns List("until"))
    - thrill.reverse: Returns a list containing all elements of the thrill list in reverse order (returns List("until", "fill", "Will"))
    - thrill.sort((s, t) => s.charAt(0).toLowerCase < t.charAt(0).toLowerCase): Returns a list containing all elements of the thrill list in alphabetical order of the first character lowercased (returns List("fill", "until", "Will"))
    - thrill.tail: Returns the thrill list minus its first element (returns List("fill", "until"))

### Step 9. Use tuples

Another useful container object is the tuple. Like lists, tuples are immutable, but unlike lists, tuples can contain different types of elements. Whereas a list might be a List[Int] or a List[String], a tuple could contain both an integer and a string at the same time. Tuples are very useful, for example, if you need to return multiple objects from a method. Whereas in Java you would often create a JavaBean-like class to hold the multiple return values, in Scala you can simply return a tuple. And it is simple: to instantiate a new tuple that holds some objects, just place the objects in parentheses, separated by commas. Once you have a tuple instantiated, you can access its elements individually with a dot, underscore, and the one-based index of the element. An example is shown in Listing 3.4:

  + 另一个容器是tuple，像List一样是不可变的，但不像List的是可以允许含有不同元素类型。如果你想从方法返回多个对象，Java会创建一个类持有几种类型来完成，Scala会简单地返回一个tuple。创建一个tuple只需要将对象放在括号中，用逗号隔开，访问元素使用`._`的方式。记住它是从1开始的。

    ```scala
    val pair = (99, "Luftballons")
    println(pair._1)
    println(pair._2)
    ```

Listing 3.4 - Creating and using a tuple.

In the first line of Listing 3.4, you create a new tuple that contains the integer 99, as its first element, and the string, "Luftballons", as its second element. Scala infers the type of the tuple to be Tuple2[Int, String], and gives that type to the variable pair as well. In the second line, you access the _1 field, which will produce the first element, 99. The "." in the second line is the same dot you'd use to access a field or invoke a method. In this case you are accessing a field named _1. If you run this script, you'll see:

  ```
  // output：
  99
  Luftballons
  ```
The actual type of a tuple depends on the number of elements it contains and the types of those elements. Thus, the type of (99, "Luftballons") is Tuple2[Int, String]. The type of ('u', 'r', "the", 1, 4, "me") is Tuple6[Char, Char, String, Int, Int, String].[5]

Accessing the elements of a tuple

You may be wondering why you can't access the elements of a tuple like the elements of a list, for example, with "pair(0)". The reason is that a list's apply method always returns the same type, but each element of a tuple may be a different type: _1 can have one result type, _2 another, and so on. These _N numbers are one-based, instead of zero-based, because starting with 1 is a tradition set by other languages with statically typed tuples, such as Haskell and ML.

  + 3.4中Scala通过传入参数类型推测为`Tuple2[Int, String]`，tuple的类型取决于入参元素个数和类型，`('u', 'r', "the", 1, 4, "me")`等于`Tuple6[Char, Char, String, Int, Int, String]`。因为tuple返回的每个元素类型不同所以不能像List方式得到元素，同时选择1为起始元素是为了适配其他语言比如Haskell和ML。

### Step 10. Use sets and maps

Because Scala aims to help you take advantage of both functional and imperative styles, its collections libraries make a point to differentiate between mutable and immutable collection classes. For example, arrays are always mutable, whereas lists are always immutable. When it comes to sets and maps, Scala also provides mutable and immutable alternatives, but in a different way. For sets and maps, Scala models mutability in the class hierarchy.

  + Scala目标是帮助你利用函数式和命令式编程，它的集合库区别于可变和不可变类。Scala set和map都有可变和不可变可选，都是从类继承而来的可变性。

For example, the Scala API contains a base trait for sets, where a trait is similar to a Java interface. (You'll find out more about traits in Chapter 12.) Scala then provides two subtraits, one for mutable sets and another for immutable sets. As you can see in Figure 3.2, these three traits all share the same simple name, Set. Their fully qualified names differ, however, because each resides in a different package. Concrete set classes in the Scala API, such as the HashSet classes shown in Figure 3.2, extend either the mutable or immutable Set trait. (Although in Java you "implement" interfaces, in Scala you "extend" or "mix in" traits.) Thus, if you want to use a HashSet, you can choose between mutable and immutable varieties depending upon your needs. The default way to create a set is shown in Listing 3.5:
  
  + Scala API中有个set的基类接口（类似于Java接口），子接口中一个是可变一个是不可变，图3.2中它们都是相同的接口名，它们的包名是不同的。HashSet类都有继承自可变和不可变接口的，你可以根据自己的需求来使用。Java是用implement，Scala用extend或者mix in。

    ```scala
    var jetSet = Set("Boeing", "Airbus")
    jetSet += "Lear"
    println(jetSet.contains("Cessna"))
    ```
Listing 3.5 - Creating, initializing, and using an immutable set.

  ![Figure 3.2 - Class hierarchy for Scala sets.](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure3.2.jpg)

In the first line of code in Listing 3.5, you define a new var named jetSet, and initialize it with an immutable set containing the two strings, "Boeing" and "Airbus". As this example shows, you can create sets in Scala similarly to how you create lists and arrays: by invoking a factory method named apply on a Set companion object. In Listing 3.5, you invoke apply on the companion object for scala.collection.immutable.Set, which returns an instance of a default, immutable Set. The Scala compiler infers jetSet's type to be the immutable Set[String].

  + 3.2中定义了一个Set由两个string元素组成，初始化为一个不可变的Set, 类型推测为scala.collection.immutable.Set[String]，类似于List和Array是调用工厂方法apply在Set的伴随对象中。

To add a new element to a set, you call + on the set, passing in the new element. Both mutable and immutable sets offer a + method, but their behavior differs. Whereas a mutable set will add the element to itself, an immutable set will create and return a new set with the element added. In Listing 3.5, you're working with an immutable set, thus the + invocation will yield a brand new set. Although mutable sets offer an actual += method, immutable sets do not. In this case, the second line of code, "jetSet += "Lear"", is essentially a shorthand for:

  + 添加元素通过`+`方法，可变和不可变Set都有`+`方法，但是它们是不同的。
    - 可变Set是将元素加到自己里面，通过方法`+=`。
    - 不可变Set是创建并返回一个包含新元素的Set，它没有`+=`方法，只是一个简洁写法。

  ```scala
  jetSet = jetSet + "Lear"
  ```

Thus, in the second line of Listing 3.5, you reassign the jetSet var with a new set containing "Boeing", "Airbus", and "Lear". Finally, the last line of Listing 3.5 prints out whether or not the set contains the string "Cessna". (As you'd expect, it prints false.)

If you want a mutable set, you'll need to use an import, as shown in Listing 3.6:
    
```scala
    import scala.collection.mutable.Set
  
    val movieSet = Set("Hitch", "Poltergeist")
    movieSet += "Shrek"
    println(movieSet) 
```

Listing 3.6 - Creating, initializing, and using a mutable set.

In the first line of Listing 3.6 you import the mutable Set. As with Java, an import statement allows you to use a simple name, such as Set, instead of the longer, fully qualified name. As a result, when you say Set on the third line, the compiler knows you mean scala.collection.mutable.Set. On that line, you initialize movieSet with a new mutable set that contains the strings "Hitch" and "Poltergeist". The subsequent line adds "Shrek" to the mutable set by calling the += method on the set, passing in the string "Shrek". As mentioned previously, += is an actual method defined on mutable sets. Had you wanted to, instead of writing movieSet += "Shrek", therefore, you could have written movieSet.+=("Shrek").[6]

  + 导入可变Set的包`import scala.collection.mutable.Set`，创建并初始化了可变Set，并且通过`+=`方法添加元素，`movieSet += "Shrek"`等于`movieSet.+=("Shrek")`

Although the default set implementations produced by the mutable and immutable Set factory methods shown thus far will likely be sufficient for most situations, occasionally you may want an explicit set class. Fortunately, the syntax is similar. Simply import that class you need, and use the factory method on its companion object. For example, if you need an immutable HashSet, you could do this:

  + 导入HashSet包`import scala.collection.immutable.HashSet`

  ```scala
  import scala.collection.immutable.HashSet
  
  val hashSet = HashSet("Tomatoes", "Chilies")
  println(hashSet + "Coriander")
  ```

Another useful collection class in Scala is Map. As with sets, Scala provides mutable and immutable versions of Map, using a class hierarchy. As you can see in Figure 3.3, the class hierarchy for maps looks a lot like the one for sets. There's a base Map trait in package scala.collection, and two subtrait Maps: a mutable Map in scala.collection.mutable and an immutable one in scala.collection.immutable.

  + 另一个有用的集合是Map，像Set一样有个基类接口然后有两个可变和不可变接口组成，如图3.3继承关系。

  ![Figure 3.3 - Class hierarchy for Scala maps.](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure3.3.jpg)

Implementations of Map, such as the HashMaps shown in the class hierarchy in Figure 3.3, extend either the mutable or immutable trait. You can create and initialize maps using factory methods similar to those used for arrays, lists, and sets. For example, Listing 3.7 shows a mutable map in action:

  + 类似Array，List，Set，Map也是通过工厂方法初始化，下面是可变Map。

    ```scala
    import scala.collection.mutable.Map
  
    val treasureMap = Map[Int, String]()
    treasureMap += (1 -> "Go to island.")
    treasureMap += (2 -> "Find big X on ground.")
    treasureMap += (3 -> "Dig.")
    println(treasureMap(2))
    ```

Listing 3.7 - Creating, initializing, and using a mutable map.

On the first line of Listing 3.7, you import the mutable Map. You then define a val named treasureMap and initialize it with an empty mutable Map that has integer keys and string values. The map is empty because you pass nothing to the factory method (the parentheses in `"Map[Int, String]()"` are empty).[7] On the next three lines you add key/value pairs to the map using the -> and += methods. As illustrated previously, the Scala compiler transforms a binary operation expression like 1 -> "Go to island." into (1).->("Go to island."). Thus, when you say 1 -> "Go to island.", you are actually calling a method named -> on an integer with the value 1, passing in a string with the value "Go to island." This -> method, which you can invoke on any object in a Scala program, returns a two-element tuple containing the key and value.[8] You then pass this tuple to the += method of the map object to which treasureMap refers. Finally, the last line prints the value that corresponds to the key 2 in the treasureMap. If you run this code, it will print:

  + 3.7中创建了一个类型为Map[Int, String]的可变空Map，`1 -> "Go to island."`等于`(1).->("Go to island.")`返回一个两元素的tuple包含key和value。调用`+=`方法添加到Map中。

  ```
  // output:
  Find big X on ground.
  ```

If you prefer an immutable map, no import is necessary, as immutable is the default map. An example is shown in Listing 3.8:

  + 默认是不可变Map，不需要导包

    ```scala
    val romanNumeral = Map(
      1 -> "I", 2 -> "II", 3 -> "III", 4 -> "IV", 5 -> "V"
    )
    println(romanNumeral(4))
    ```

Listing 3.8 - Creating, initializing, and using an immutable map.

Given there are no imports, when you say Map in the first line of Listing 3.8, you'll get the default: a scala.collection.immutable.Map. You pass five key/value tuples to the map's factory method, which returns an immutable Map containing the passed key/value pairs. If you run the code in Listing 3.8 it will print "IV".

### Step 11. Learn to recognize the functional style

As mentioned in Chapter 1, Scala allows you to program in an imperative style, but encourages you to adopt a more functional style. If you are coming to Scala from an imperative background—for example, if you are a Java programmer—one of the main challenges you may face when learning Scala is figuring out how to program in the functional style. We realize this style might be unfamiliar at first, and in this book we try hard to guide you through the transition. It will require some work on your part, and we encourage you to make the effort. If you come from an imperative background, we believe that learning to program in a functional style will not only make you a better Scala programmer, it will expand your horizons and make you a better programmer in general.

  + 从命令式编程（Java programmer）向函数式编程转变

The first step is to recognize the difference between the two styles in code. One telltale sign is that if code contains any vars, it is probably in an imperative style. If the code contains no vars at all—i.e., it contains only vals—it is probably in a functional style. One way to move towards a functional style, therefore, is to try to program without vars.

  + 函数式与命令式形式的区别在于没有vars，只有vals。

If you're coming from an imperative background, such as Java, C++, or C#, you may think of var as a regular variable and val as a special kind of variable. On the other hand, if you're coming from a functional background, such as Haskell, OCaml, or Erlang, you might think of val as a regular variable and var as akin to blasphemy. The Scala perspective, however, is that val and var are just two different tools in your toolbox, both useful, neither inherently evil. Scala encourages you to lean towards vals, but ultimately reach for the best tool given the job at hand. Even if you agree with this balanced philosophy, however, you may still find it challenging at first to figure out how to get rid of vars in your code.

Consider the following while loop example, adapted from Chapter 2, which uses a var and is therefore in the imperative style:

  + 对于命令式（Java，C++，C#）vars是通常的，vals是特殊的，相反于函数式。Scala兼顾两者，但更倾向于vals，从你的代码中消除vars可能是个挑战。

  ```scala
  def printArgs(args: Array[String]): Unit = {
    var i = 0
    while (i < args.length) {
      println(args(i))
      i += 1
    }
  }

  // You can transform this bit of code into a more functional style by getting rid of the var,
  // for example, like this:

  def printArgs(args: Array[String]): Unit = {
    for (arg <- args)
      println(arg)
  }

  // or this:

  def printArgs(args: Array[String]): Unit = {
    args.foreach(println)
  }
  ```

This example illustrates one benefit of programming with fewer vars. The refactored (more functional) code is clearer, more concise, and less error-prone than the original (more imperative) code. The reason Scala encourages a functional style, in fact, is that the functional style can help you write more understandable, less error-prone code.

  + 上述代码重构变得更函数化从原来的命令式中，简洁，更好理解，少错误的代码，这就是函数式的好处。

You can go even further, though. The refactored printArgs method is not purely functional, because it has side effects—in this case, its side effect is printing to the standard output stream. The telltale sign of a function with side effects is that its result type is Unit. If a function isn't returning any interesting value, which is what a result type of Unit means, the only way that function can make a difference in the world is through some kind of side effect. A more functional approach would be to define a method that formats the passed args for printing, but just returns the formatted string, as shown in Listing 3.9.

  + 上述printArgs还不够函数化，仍然有赋值给返回值，其返回值为Unit空，更函数式的方法是定义一个方法来将传入的args返回一个string。

    ```scala
    def formatArgs(args: Array[String]) = args.mkString("\n")
    ```

Listing 3.9 - A function without side effects or vars.

Now you're really functional: no side effects or vars in sight. The mkString method, which you can call on any iterable collection (including arrays, lists, sets, and maps), returns a string consisting of the result of calling toString on each element, separated by the passed string. Thus if args contains three elements "zero", "one", and "two", formatArgs will return "zero\none\ntwo". Of course, this function doesn't actually print anything out like the printArgs methods did, but you can easily pass its result to println to accomplish that:

  + 现在已经函数化了，没有赋值和vars，`mkString`是每个可遍历的集合都可以调用的(arrays, lists, sets, and maps)，是返回一个string由传入的string来进行对元素的遍历，toString和分割后组成。最后由println来完成打印。

  ```scala
  println(formatArgs(args))
  ```

Every useful program is likely to have side effects of some form, because otherwise it wouldn't be able to provide value to the outside world. Preferring methods without side effects encourages you to design programs where side-effecting code is minimized. One benefit of this approach is that it can help make your programs easier to test. For example, to test any of the three printArgs methods shown earlier in this section, you'd need to redefine println, capture the output passed to it, and make sure it is what you expect. By contrast, you could test formatArgs simply by checking its result:

  + 有用的程序在某些样式上可能会有赋值，可能没有办法将数据提供到外部，就像上述的printArgs。更好的没有赋值的方法可以带来很多好处，例如很方便地来判断你的程序结果如下，不用去改造println，不用去抓却输出值。`assert`方法来判断true or false，if false会抛出AssertionError，true会安静地返回。

  ```scala
  val res = formatArgs(Array("zero", "one", "two"))
  assert(res == "zero\none\ntwo")
  ```

Scala's assert method checks the passed Boolean and if it is false, throws AssertionError. If the passed Boolean is true, assert just returns quietly. You'll learn more about assertions and testing in Chapter 14.

That said, bear in mind that neither vars nor side effects are inherently evil. Scala is not a pure functional language that forces you to program everything in the functional style. Scala is a hybrid imperative/functional language. You may find that in some situations an imperative style is a better fit for the problem at hand, and in such cases you should not hesitate to use it. To help you learn how to program without vars, however, we'll show you many specific examples of code with vars and how to transform those vars to vals in Chapter 7.
A balanced attitude for Scala programmers

Prefer vals, immutable objects, and methods without side effects. Reach for them first. Use vars, mutable objects, and methods with side effects when you have a specific need and justification for them.

  + Scala是个基于函数和命令式的语言，如果命令式更好地处理问题，那无需犹豫。更倾向于使用vals，immutable object， and methods without side effects。

### Step 12. Read lines from a file

Scripts that perform small, everyday tasks often need to process lines in files. In this section, you'll build a script that reads lines from a file, and prints them out prepended with the number of characters in each line. The first version is shown in Listing 3.10:

  + 从文件中读取内容，并返回前面包含此行字数的内容

    ```scala
    import scala.io.Source
  
    if (args.length > 0) {
  
      for (line <- Source.fromFile(args(0)).getLines)
        print(line.length +" "+ line)
    }
    else
      Console.err.println("Please enter filename")
    ```

Listing 3.10 - Reading lines from a file.

This script starts with an import of a class named Source from package scala.io. It then checks to see if at least one argument was specified on the command line. If so, the first argument is interpreted as a filename to open and process. The expression Source.fromFile(args(0)) attempts to open the specified file and returns a Source object, on which you call getLines. The getLines method returns an Iterator[String], which provides one line on each iteration, including the end-of-line character. The for expression iterates through these lines and prints for each the length of the line, a space, and the line itself. If there were no arguments supplied on the command line, the final else clause will print a message to the standard error stream. If you place this code in a file named countchars1.scala, and run it on itself with:

  + `scala.io.Source`包名`Source.fromFile(args(0))`可以打开文件并返回一个Source对象，Source对象的`getLines`方法返回一个`Iterator[String]`对象，它会遍历每一行包括空格和行结束符。

  ```
  $ scala countchars1.scala countchars1.scala

  // You should see:

  23 import scala.io.Source
  1 
  23 if (args.length > 0) {
  1 
  50   for (line <- Source.fromFile(args(0)).getLines)
  36     print(line.length +" "+ line)
  2 }
  5 else
  47   Console.err.println("Please enter filename")

  // Although the script in its current form prints out the needed information, 
  // you may wish to line up the numbers, right adjusted, and add a pipe character, 
  // so that the output looks instead like:

  23 | import scala.io.Source
   1 | 
  23 | if (args.length > 0) {
   1 | 
  50 |   for (line <- Source.fromFile(args(0)).getLines)
  34 |     print(line.length +" "+ line)
   2 | }
   5 | else
  47 |   Console.err.println("Please enter filename")
  ```

To accomplish this, you can iterate through the lines twice. The first time through you'll determine the maximum width required by any line's character count. The second time through you'll print the output, using the maximum width calculated previously. Because you'll be iterating through the lines twice, you may as well assign them to a variable:

  + 打印出上诉结果，数字右对齐加上管道符。需要每行遍历两次。第一次来确定字数的最大宽度。第二遍是输出内容使用到前面计算的最大宽度。

  ```scala
  val lines = Source.fromFile(args(0)).getLines.toList
  ```

The final toList is required because the getLines method returns an iterator. Once you've iterated through an iterator, it is spent. By transforming it into a list via the toList call, you gain the ability to iterate as many times as you wish, at the cost of storing all lines from the file in memory at once. The lines variable, therefore, references a list of strings that contains the contents of the file specified on the command line.

  + `toList`方法将Soure对象返回的iterator转化成一个List放在内存中。List一个元素为一行。

Next, because you'll be calculating the width of each line's character count twice, once per iteration, you might factor that expression out into a small function, which calculates the character width of the passed string's length:

  + 计算每一行的长度的宽度，抽成一个方法，配合for循环可以知道最大宽度。

  ```scala
  def widthOfLength(s: String) = s.length.toString.length
  
  // With this function, you could calculate the maximum width like this:

  var maxWidth = 0
  for (line <- lines)
    maxWidth = maxWidth.max(widthOfLength(line))
  ```

Here you iterate through each line with a for expression, calculate the character width of that line's length, and, if it is larger than the current maximum, assign it to maxWidth, a var that was initialized to 0. (The max method, which you can invoke on any Int, returns the greater of the value on which it was invoked and the value passed to it.) Alternatively, if you prefer to find the maximum without vars, you could first find the longest line like this:

  + 调用max方法找到最大值，当然最好是通过下面的找到最大行不用vars

  ```scala
  val longestLine = lines.reduceLeft(
    (a, b) => if (a.length > b.length) a else b 
  ) 
  ```

The reduceLeft method applies the passed function to the first two elements in lines, then applies it to the result of the first application and the next element in lines, and so on, all the way through the list. On each such application, the result will be the longest line encountered so far, because the passed function, (a, b) => if (a.length > b.length) a else b, returns the longest of the two passed strings. "reduceLeft" will return the result of the last application of the function, which in this case will be the longest string element contained in lines.

  + `def reduceLeft[B >: A](op: (B, A) ⇒ B): B`方法是从左到右对所有元素进行传入方法的操作。先比较前两个元素，接着应用到第一次比较结果和下一个元素上，从左到右遍历整个List，最后返回最后一次的比较结果。

Given this result, you can calculate the maximum width by passing the longest line to widthOfLength:

  val maxWidth = widthOfLength(longestLine)

All that remains is to print out the lines with proper formatting. You can do that like this:

  for (line <- lines) {
    val numSpaces = maxWidth - widthOfLength(line)
    val padding = " " * numSpaces
    print(padding + line.length +" | "+ line)
  }

In this for expression, you once again iterate through the lines. For each line, you first calculate the number of spaces required before the line length and assign it to numSpaces. Then you create a string containing numSpaces spaces with the expression " " * numSpaces. Finally, you print out the information with the desired formatting. The entire script looks as shown in Listing 3.11:
    
  + 找到最大行字数宽度和每行字数宽度得到需要空个数，加管道符，加行内容。

    ```scala
    import scala.io.Source
  
    def widthOfLength(s: String) = s.length.toString.length
  
    if (args.length > 0) {
  
      val lines = Source.fromFile(args(0)).getLines.toList
  
      val longestLine = lines.reduceLeft(
        (a, b) => if (a.length > b.length) a else b 
      ) 
      val maxWidth = widthOfLength(longestLine)
  
      for (line <- lines) {
        val numSpaces = maxWidth - widthOfLength(line)
        val padding = " " * numSpaces
        print(padding + line.length +" | "+ line)
      }
    }
    else
      Console.err.println("Please enter filename")
    ```

Listing 3.11 - Printing formatted character counts for the lines of a file.

### Conclusion

With the knowledge you've gained in this chapter, you should already be able to get started using Scala for small tasks, especially scripts. In future chapters, we will dive into more detail in these topics, and introduce other topics that weren't even hinted at here.

### Footnotes for Chapter 3:

[1] This to method actually returns not an array but a different kind of sequence, containing the values 0, 1, and 2, which the for expression iterates over. Sequences and other collections will be described in Chapter 17.

[2] Variable-length argument lists, or repeated parameters, are described in Section 8.8.

[3] You don't need to say new List because "List.apply()" is defined as a factory method on the scala.List companion object. You'll read more on companion objects in Section 4.3.

[4] The reason you need Nil at the end is that :: is defined on class List. If you try to just say 1 :: 2 :: 3, it won't compile because 3 is an Int, which doesn't have a :: method.

[5] Although conceptually you could create tuples of any length, currently the Scala library only defines them up to Tuple22.

[6] Because the set in Listing 3.6 is mutable, there is no need to reassign movieSet, which is why it can be a val. By contrast, using += with the immutable set in Listing 3.5 required reassigning jetSet, which is why it must be a var.

[7] The explicit type parameterization, "[Int, String]", is required in Listing 3.7 because without any values passed to the factory method, the compiler is unable to infer the map's type parameters. By contrast, the compiler can infer the type parameters from the values passed to the map factory shown in Listing 3.8, thus no explicit type parameters are needed.

[8] The Scala mechanism that allows you to invoke -> on any object, implicit conversion, will be covered in Chapter 21.
