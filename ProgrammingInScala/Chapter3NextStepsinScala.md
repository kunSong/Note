## Next Steps in Scala

### Vocabulary
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
  
### Step 7. Parameterize arrays with types
  + Using **new** to instantiate objects, or class instances.
  + Parameterize an instance with values by passing objects to a constructor in parentheses.
  
  ```scala
  val big = new java.math.BigInteger("12345")
  ```

  + Parameterize an instance with types by specifying one or more types in square brackets. greetStrings is a value of type Array[String] initialized to length 3.
  
  ```scala
  val greetStrings = new Array[String](3)
  
  greetStrings(0) = "Hello"
  greetStrings(1) = ", "
  greetStrings(2) = "world!\n"
  
  for (i <- 0 to 2)
    print(greetStrings(i))
  ```

  + Specified the type of greetStrings explicitly like this.

  ```scala
  val greetStrings: Array[String] = new Array[String](3)
  ```
  
  + The type of greetStrings is Array[String], not `Array[String](3)`

  + Scala are accessed by placing the index inside parentheses, not square brackets as in Java. Thus the zeroth element of the array is greetStrings(0), not greetStrings[0].

  + When you define a variable with val, the variable can't be reassigned, but the object to which it refers could potentially still be changed. In this case, greetStrings will always point to the same Array[String] instance with which it was initialized. But you can change the elements of that Array[String] over time, so the array itself is mutable.
  
  ```scala
  for (i <- 0 to 2)
    print(greetStrings(i))
  ```

  + Another general rule of Scala: if a method takes only one parameter, you can call that 0 to 2 is transformed into the method call (0).to(2)[1]. Note that this syntax only works if you explicitly specify the receiver of the method call. You cannot write "println 10", but you can write "Console println 10".

  + Scala doesn't technically have operator overloading, because it doesn't actually have operators in the traditional sense. Instead, characters such as +, -, *, and / can be used in method names. Thus, written 1 + 2 using traditional method invocation syntax, (1).+(2).

  ![Figure 3.1 - All operations are method calls in Scala.](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure3.1.jpg)

  + Another important idea. When you apply parentheses surrounding one or more values to a variable, Scala will transform the code into an invocation of a method named apply on that variable. So greetStrings(i) gets transformed into greetStrings.apply(i). This principle is not restricted to arrays: any application of an object to some arguments in parentheses will be transformed to an apply method call. Of course this will compile only if that type of object actually defines an apply method.
  
  + Similarly, when an assignment is made to a variable to which parentheses and one or more arguments have been applied, the compiler will transform that into an invocation of an update method that takes the arguments in parentheses as well as the object to the right of the equals sign. For example:
  
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
  
  + Scala treat everything, from arrays to expressions, as objects with methods, and does not incur a significant performance cost. The Scala compiler uses Java arrays, primitive types, and native arithmetic where possible in the compiled code.

  + A more concise way to create and initialize arrays. This code creates a new array of length three, initialized to the passed strings, "zero", "one", and "two". The compiler infers the type of the array to be Array[String], because you passed strings to it.

  ```scala
  val numNames = Array("zero", "one", "two")
  ```

  + Calling a factory method, named apply, which creates and returns the new array and is defined on the Array companion object. If you're a Java programmer, you can think of this as calling a static method named apply on class Array.

  ```scala
  // equivalent to the code
  val numNames2 = Array.apply("zero", "one", "two")
  ```

### Step 8. Use lists

  + Big idea that a method's only act should be to compute and return a value.
    - Become less entangled, and therefore more reliable and reusable.
    - everything that goes into and out of a method is checked by a type checker.
    - Applying this functional philosophy to the world of objects means making objects immutable.

  + A Scala array is a mutable sequence of objects that all share the same type. An Array[String] contains only strings, for example. Although you can't change the length of an array after it is instantiated, you can change its element values.

  + A List[String] contains only strings. Scala's List, scala.List, differs from Java's java.util.List type in that Scala Lists are always immutable (whereas Java Lists can be mutable). Scala's List is designed to enable a functional style of programming.
    
    ```scala
    val oneTwoThree = List(1, 2, 3)
    ```
    
  + Above code establishes a new val named oneTwoThree, initialized with a new List[Int] with the integer elements 1, 2, and 3.[3] 
  
  + Because Lists are immutable, they behave a bit like Java strings: when you call a method named `:::` for list concatenation on a list that might seem by its name to imply the list will mutate, it instead creates and returns a new list with the new value.

  ```scala
  val oneTwo = List(1, 2)
  val threeFour = List(3, 4)
  val oneTwoThreeFour = oneTwo ::: threeFour
  println(""+ oneTwo +" and "+ threeFour +" were not mutated.")
  println("Thus, "+ oneTwoThreeFour +" is a new list.")

  /*
  If you run this script, you'll see:

  List(1, 2) and List(3, 4) were not mutated.
  Thus, List(1, 2, 3, 4) is a new list.
  */
  ```

  + `::` in List, which is pronounced "cons." Cons prepends a new element to the beginning of an existing list, and returns the resulting list.

  ```scala
  val twoThree = List(2, 3)
  val oneTwoThree = 1 :: twoThree
  println(oneTwoThree)

  /*
  You'll see:

  List(1, 2, 3)
  */
  ```

  + Note
    - `a * b`, the method is invoked on the left operand, as in a.*(b)—unless the method name ends in a colon. 
    - If the method name ends in a colon, the method is invoked on the right operand. Therefore, in 1 :: twoThree, the :: method is invoked on twoThree, passing in 1, like this: twoThree.::(1).

  + Empty list is Nil, one way to initialize new lists is to string together elements with the cons operator, with Nil as the last element.[4]
  
  ```scala
  val oneTwoThree = 1 :: 2 :: 3 :: Nil
  println(oneTwoThree)
  // output: List(1, 2, 3)
  ```
  
  + Why not append to lists?
    - Class List does not offer an append operation, because the time it takes to append to a list grows linearly with the size of the list, whereas prepending with :: takes constant time. Your options if you want to build a list by appending elements is to prepend them, then when you're done call reverse; or use a ListBuffer, a mutable list that does offer an append operation, and when you're done call toList. ListBuffer will be described in Section 22.2.

  + List is packed with useful methods
    - List() or Nil: The empty List
    - List("Cool", "tools", "rule"): Creates a new List[String] with the three values "Cool", "tools", and "rule"
    - val thrill = "Will" :: "fill" :: "until" :: Nil: Creates a new List[String] with the three values "Will", "fill", and "until"
    - List("a", "b") ::: List("c", "d"): Concatenates two lists (returns a new List[String] with values "a", "b", "c", and "d")
    - thrill(2): Returns the element at index 2 (zero based) of the thrill list (returns "until")
    - thrill.count(s => s.length == 4): Counts the number of string elements in thrill that have length 4 (returns 2)
    - thrill.drop(2):	Returns the thrill list without its first 2 elements (returns List("until"))
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

  + Another useful container object is the tuple. 
    - Like lists, tuples are immutable.
    - Unlike lists, tuples can contain different types of elements.
    - If you need to return multiple objects from a method, in Scala you can simply return a tuple.
    - Instantiate a new tuple that holds some objects, just place the objects in parentheses, separated by commas. 
    - Once you have a tuple instantiated, you can access its elements individually with a dot, underscore, and the one-based index of the element.

    ```scala
    val pair = (99, "Luftballons")
    println(pair._1)
    println(pair._2)
    
    /* output:
    99
    Luftballons
    */
    ```

  + Scala infers the type of the tuple to be Tuple2[Int, String], and gives that type to the variable pair as well.
  
  + The actual type of a tuple depends on the number of elements it contains and the types of those elements. Thus, the type of (99, "Luftballons") is Tuple2[Int, String]. The type of ('u', 'r', "the", 1, 4, "me") is Tuple6[Char, Char, String, Int, Int, String].[5]
  
  + Accessing the elements of a tuple
    - Can't access the elements of a tuple like with "pair(0)".
    - The reason is that a list's apply method always returns the same type.
    - But each element of a tuple may be a different type: _1 can have one result type, _2 another, and so on. 
    - These _N numbers are one-based, instead of zero-based, because starting with 1 is a tradition set by other languages with statically typed tuples, such as Haskell and ML.

### Step 10. Use sets and maps

  + Scala aims to help you take advantage of both functional and imperative styles
    - Its collections libraries make a point to differentiate between mutable and immutable collection classes. 
    - arrays are always mutable, whereas lists are always immutable.
    - For sets and maps, Scala models mutability in the class hierarchy.

  + The Scala API contains a base trait for sets.(trait like Java interface)
    - Scala then provides two subtraits, one for mutable sets and another for immutable sets.
    - These three traits all share the same simple name, Set(resides in a different package).
    - Concrete set classes is HashSet classes extend either the mutable or immutable Set trait. (in Scala you "extend" or "mix in" traits.)
    
    ```scala
    // default way to create a set
    var jetSet = Set("Boeing", "Airbus")
    jetSet += "Lear"
    println(jetSet.contains("Cessna"))
    ```

  ![Figure 3.2 - Class hierarchy for Scala sets.](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure3.2.jpg)

  + Above code, you define a new var named jetSet, and initialize it with an immutable set containing the two strings, "Boeing" and "Airbus". Create sets in Scala similarly to how you create lists and arrays: by invoking a factory method named apply on a Set companion object for scala.collection.immutable.Set, which returns an instance of a default, immutable Set. The Scala compiler infers jetSet's type to be the immutable Set[String].

  + To add a new element to a set, you call + on the set, passing in the new element.
    - mutable and immutable sets offer a + method. A mutable set will add the element to itself, an immutable set will create and return a new set with the element added.
    - Although mutable sets offer an actual += method, immutable sets do not.
  
  ```scala
  // shorthand for: jetSet += "Lear"
  jetSet = jetSet + "Lear"
  ```
  
  + reassign the jetSet var with a new set containing "Boeing", "Airbus", and "Lear". Finally, set contains the string "Cessna". (false.)

  + A mutable set, need to use an import
    
    ```scala
    import scala.collection.mutable.Set
  
    val movieSet = Set("Hitch", "Poltergeist")
    movieSet += "Shrek"
    println(movieSet)
    ```

  + Had you wanted to, instead of writing movieSet += "Shrek", therefore, you could have written movieSet.+=("Shrek").[6]

  + Simply import that class you need, and use the factory method on its companion object.

  ```scala
  import scala.collection.immutable.HashSet
  
  val hashSet = HashSet("Tomatoes", "Chilies")
  println(hashSet + "Coriander")
  ```

  + Scala provides mutable and immutable versions of Map, using a class hierarchy.

  ![Figure 3.3 - Class hierarchy for Scala maps.](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure3.3.jpg)

  + You can create and initialize maps using factory methods similar to those used for arrays, lists, and sets.

    ```scala
    import scala.collection.mutable.Map
  
    val treasureMap = Map[Int, String]()
    treasureMap += (1 -> "Go to island.")
    treasureMap += (2 -> "Find big X on ground.")
    treasureMap += (3 -> "Dig.")
    println(treasureMap(2))
    
    // output: Find big X on ground.
    ```

  + Above code
    - Import the mutable Map.
    - Define a val named treasureMap and initialize it with an empty mutable Map that has integer keys and string values.
    - The map is empty because you pass nothing to the factory method (the parentheses in `Map[Int, String]()` are empty).[7]
    - Add key/value pairs to the map using the -> and += methods.
    - Transforms a binary operation expression like 1 -> "Go to island." into (1).->("Go to island.").
    - This -> method, which you can invoke on any object in a Scala program, returns a two-element tuple containing the key and value.[8]
    - You then pass this tuple to the += method of the map object to which treasureMap refers.
    - Print corresponds to the key 2 in the treasureMap.

  + If you prefer an immutable map, no import is necessary, as immutable is the default map.

    ```scala
    val romanNumeral = Map(
      1 -> "I", 2 -> "II", 3 -> "III", 4 -> "IV", 5 -> "V"
    )
    println(romanNumeral(4))
    
    // output: IV
    ```

  + Given there are no imports, a scala.collection.immutable.Map. You pass five key/value tuples to the map's factory method, which returns an immutable Map.

### Step 11. Learn to recognize the functional style

  + Scala allows you to program in an imperative style, but encourages you to adopt a more functional style.

  + The difference between the two styles in code. If code contains any vars, it is probably in an imperative style. If the code contains no vars at all—i.e., it contains only vals—it is probably in a functional style.
  
  + The Scala perspective, however, is that val and var are just two different tools in your toolbox, both useful, neither inherently evil. Scala encourages you to lean towards vals and get rid of vars in your code, but ultimately reach for the best tool given the job at hand.

  + The following code uses a var and is therefore in the imperative style:
  
  ```scala
  def printArgs(args: Array[String]): Unit = {
    var i = 0
    while (i < args.length) {
      println(args(i))
      i += 1
    }
  }
  ```

  + You can transform functional style by getting rid of the var:

  ```scala
  def printArgs(args: Array[String]): Unit = {
    for (arg <- args)
      println(arg)
  }

  // or this:

  def printArgs(args: Array[String]): Unit = {
    args.foreach(println)
  }
  ```

  + The benefit of the refactored (more functional) code with fewer vars is clearer, more concise, and less error-prone than the original (more imperative) code.

  + Side effects—in this case, its side effect is printing to the standard output stream and its result type is Unit. If a function isn't returning any interesting value, which is what a result type of Unit means. A more functional approach would be to define a method that formats the passed args for printing, but just returns the formatted string.
    
    ```scala
    def formatArgs(args: Array[String]) = args.mkString("\n")
    ```

  + Now you're really functional: no side effects or vars in sight. The mkString method, which you can call on any iterable collection (including arrays, lists, sets, and maps), returns a string consisting of the result of calling toString on each element, separated by the passed string and pass its result to println to accomplish that:

  ```scala
  println(formatArgs(args))
  ```

  + Every useful program is likely to have side effects of some form, because otherwise it wouldn't be able to provide value to the outside world. Preferring methods without side effects encourages you to design programs where side-effecting code is minimized. One benefit of this approach is that it can help make your programs easier to test. For example, to test any of the three printArgs methods shown earlier in this section, you'd need to redefine println, capture the output passed to it, and make sure it is what you expect. By contrast, you could test formatArgs simply by checking its result:

  ```scala
  val res = formatArgs(Array("zero", "one", "two"))
  assert(res == "zero\none\ntwo")
  ```

Scala's assert method checks the passed Boolean and if it is false, throws AssertionError. If the passed Boolean is true, assert just returns quietly. You'll learn more about assertions and testing in Chapter 14.

That said, bear in mind that neither vars nor side effects are inherently evil. Scala is not a pure functional language that forces you to program everything in the functional style. Scala is a hybrid imperative/functional language. You may find that in some situations an imperative style is a better fit for the problem at hand, and in such cases you should not hesitate to use it. To help you learn how to program without vars, however, we'll show you many specific examples of code with vars and how to transform those vars to vals in Chapter 7.
A balanced attitude for Scala programmers

Prefer vals, immutable objects, and methods without side effects. Reach for them first. Use vars, mutable objects, and methods with side effects when you have a specific need and justification for them.

### Step 12. Read lines from a file

Scripts that perform small, everyday tasks often need to process lines in files. In this section, you'll build a script that reads lines from a file, and prints them out prepended with the number of characters in each line. The first version is shown in Listing 3.10:

    import scala.io.Source
  
    if (args.length > 0) {
  
      for (line <- Source.fromFile(args(0)).getLines)
        print(line.length +" "+ line)
    }
    else
      Console.err.println("Please enter filename")

Listing 3.10 - Reading lines from a file.

This script starts with an import of a class named Source from package scala.io. It then checks to see if at least one argument was specified on the command line. If so, the first argument is interpreted as a filename to open and process. The expression Source.fromFile(args(0)) attempts to open the specified file and returns a Source object, on which you call getLines. The getLines method returns an Iterator[String], which provides one line on each iteration, including the end-of-line character. The for expression iterates through these lines and prints for each the length of the line, a space, and the line itself. If there were no arguments supplied on the command line, the final else clause will print a message to the standard error stream. If you place this code in a file named countchars1.scala, and run it on itself with:

  $ scala countchars1.scala countchars1.scala

You should see:

  23 import scala.io.Source
  1 
  23 if (args.length > 0) {
  1 
  50   for (line <- Source.fromFile(args(0)).getLines)
  36     print(line.length +" "+ line)
  2 }
  5 else
  47   Console.err.println("Please enter filename")

Although the script in its current form prints out the needed information, you may wish to line up the numbers, right adjusted, and add a pipe character, so that the output looks instead like:

  23 | import scala.io.Source
   1 | 
  23 | if (args.length > 0) {
   1 | 
  50 |   for (line <- Source.fromFile(args(0)).getLines)
  34 |     print(line.length +" "+ line)
   2 | }
   5 | else
  47 |   Console.err.println("Please enter filename")

To accomplish this, you can iterate through the lines twice. The first time through you'll determine the maximum width required by any line's character count. The second time through you'll print the output, using the maximum width calculated previously. Because you'll be iterating through the lines twice, you may as well assign them to a variable:

  val lines = Source.fromFile(args(0)).getLines.toList

The final toList is required because the getLines method returns an iterator. Once you've iterated through an iterator, it is spent. By transforming it into a list via the toList call, you gain the ability to iterate as many times as you wish, at the cost of storing all lines from the file in memory at once. The lines variable, therefore, references a list of strings that contains the contents of the file specified on the command line.

Next, because you'll be calculating the width of each line's character count twice, once per iteration, you might factor that expression out into a small function, which calculates the character width of the passed string's length:

  def widthOfLength(s: String) = s.length.toString.length

With this function, you could calculate the maximum width like this:

  var maxWidth = 0
  for (line <- lines)
    maxWidth = maxWidth.max(widthOfLength(line))

Here you iterate through each line with a for expression, calculate the character width of that line's length, and, if it is larger than the current maximum, assign it to maxWidth, a var that was initialized to 0. (The max method, which you can invoke on any Int, returns the greater of the value on which it was invoked and the value passed to it.) Alternatively, if you prefer to find the maximum without vars, you could first find the longest line like this:

  val longestLine = lines.reduceLeft(
    (a, b) => if (a.length > b.length) a else b 
  ) 

The reduceLeft method applies the passed function to the first two elements in lines, then applies it to the result of the first application and the next element in lines, and so on, all the way through the list. On each such application, the result will be the longest line encountered so far, because the passed function, (a, b) => if (a.length > b.length) a else b, returns the longest of the two passed strings. "reduceLeft" will return the result of the last application of the function, which in this case will be the longest string element contained in lines.

Given this result, you can calculate the maximum width by passing the longest line to widthOfLength:

  val maxWidth = widthOfLength(longestLine)

All that remains is to print out the lines with proper formatting. You can do that like this:

  for (line <- lines) {
    val numSpaces = maxWidth - widthOfLength(line)
    val padding = " " * numSpaces
    print(padding + line.length +" | "+ line)
  }

In this for expression, you once again iterate through the lines. For each line, you first calculate the number of spaces required before the line length and assign it to numSpaces. Then you create a string containing numSpaces spaces with the expression " " * numSpaces. Finally, you print out the information with the desired formatting. The entire script looks as shown in Listing 3.11:

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

Listing 3.11 - Printing formatted character counts for the lines of a file.
Conclusion

### Footnotes for Chapter 3:

[1] This to method actually returns not an array but a different kind of sequence, containing the values 0, 1, and 2, which the for expression iterates over. Sequences and other collections will be described in Chapter 17.

[2] Variable-length argument lists, or repeated parameters, are described in Section 8.8.

[3] You don't need to say new List because "List.apply()" is defined as a factory method on the scala.List companion object. You'll read more on companion objects in Section 4.3.

[4] The reason you need Nil at the end is that :: is defined on class List. If you try to just say 1 :: 2 :: 3, it won't compile because 3 is an Int, which doesn't have a :: method.

[5] Although conceptually you could create tuples of any length, currently the Scala library only defines them up to Tuple22.

[6] Because the set in Listing 3.6 is mutable, there is no need to reassign movieSet, which is why it can be a val. By contrast, using += with the immutable set in Listing 3.5 required reassigning jetSet, which is why it must be a var.

[7] The explicit type parameterization, "[Int, String]", is required in Listing 3.7 because without any values passed to the factory method, the compiler is unable to infer the map's type parameters. By contrast, the compiler can infer the type parameters from the values passed to the map factory shown in Listing 3.8, thus no explicit type parameters are needed.

[8] The Scala mechanism that allows you to invoke -> on any object, implicit conversion, will be covered in Chapter 21.

