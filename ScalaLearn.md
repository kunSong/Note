# Getting Started

+ build and output classes path
`scalac -d classes/ HelloWorld.scala`
+ start program in specifica path (alias -cp)
`scala -classpath classes/ HelloWorld`
+ IDE
  + Eclipse
    - `Help-->Install New Software`
    - `http://download.scala-ide.org/sdk/lithium/e44/scala211/dev/site/`
  + Intellij IDEA
    - install scala-plugin
    - tar scala sdk to /opt and attach in project structure

# API

# Overviews/Guides

# Language Specification

# Tutorials

## Introduction

Scala is a modern multi-paradigm programming language designed to express common programming patterns in a concise, elegant, and type-safe way. It smoothly integrates features of object-oriented and functional languages.

## Scala is object-oriented

Scala is a pure object-oriented language in the sense that [every value is an object](). Types and behavior of objects are described by [classes]() and [traits](). Classes are extended by subclassing and a flexible [mixin-based composition]() mechanism as a clean replacement for multiple inheritance.

## Scala is functional

Scala is also a functional language in the sense that [every function is a value](). Scala provides a [lightweight syntax]() for defining anonymous functions, it supports [higher-order functions](), it allows functions to be [nested](), and supports [currying](). Scala’s [case classes]() and its built-in support for [pattern matching]() model algebraic types used in many functional programming languages. [Singleton objects]() provide a convenient way to group functions that aren’t members of a class.

Furthermore, Scala’s notion of pattern matching naturally extends to the [processing of XML data]() with the help of [right-ignoring sequence patterns](), by way of general extension via [extractor objects](). In this context, [sequence comprehensions]() are useful for formulating queries. These features make Scala ideal for developing applications like web services.

## Scala is statically typed

Scala is equipped with an expressive type system that enforces statically that abstractions are used in a safe and coherent manner. In particular, the type system supports:

    
+ [generic classes]()
+ [variance annotations]()
+ [upper]() and [lower]() type bounds,
+ [inner classes]() and [abstract types]() as object members
+ [compound types]()
+ [explicitly typed self references]()
+ [implicit parameters]() and [conversions]()
+ [polymorphic methods]()

A [local type inference mechanism]() takes care that the user is not required to annotate the program with redundant type information. In combination, these features provide a powerful basis for the safe reuse of programming abstractions and for the type-safe extension of software.

## Scala is extensible

In practice, the development of domain-specific applications often requires domain-specific language extensions. Scala provides a unique combination of language mechanisms that make it easy to smoothly add new language constructs in the form of libraries:

+ any method may be used as an [infix or postfix operator]()
+ [closures are constructed automatically depending on the expected type]() (target typing).

A joint use of both features facilitates the definition of new statements without extending the syntax and without using macro-like meta-programming facilities.

Scala is designed to interoperate well with the popular Java 2 Runtime Environment (JRE). In particular, the interaction with the mainstream object-oriented Java programming language is as smooth as possible. Newer Java features like [annotations]() and Java generics have direct analogues in Scala. Those Scala features without Java analogues, such as [default]() and [named parameters](), compile as close to Java as they can reasonably come. Scala has the same compilation model (separate compilation, dynamic class loading) like Java and allows access to thousands of existing high-quality libraries.

## Unified Types

```scala
object UnifiedTypes extends App {
  val set = new scala.collection.mutable.LinkedHashSet[Any]
  set += "This is a string"  // add a string
  set += 732                 // add a number
  set += 'c'                 // add a character
  set += true                // add a boolean value
  set += main _              // add the main function
  val iter: Iterator[Any] = set.iterator
  while (iter.hasNext) {
    println(iter.next.toString())
  }
}
```

+ all values in Scala are objects and instances of a class.
+ scala.Any -> scala.AnyVal & scala.AnyRef
+ scala.AnyVal : Double,Float,Long,Int,Short,Byte,Unit,Boolean,Char
+ scala.AnyVal correspond to the primitive types of Java-like languages
+ scala.AnyRef extends scala.ScalaObject,Scala used in context of a Java runtime
correspond to java.lang.Object
+ scala.collection.mutable.LinkedHashSet[Any]

## Classes

```scala
class Point(var x: Int, var y: Int) {
  def move(dx: Int, dy: Int): Unit = {
    x = x + dx
    y = y + dy
  }
  override def toString: String =
    "(" + x + ", " + y + ")"
}

object Classes {
  def main(args: Array[String]) {
    val pt = new Point(1, 2)
    println(pt)
    pt.move(10, 10)
    println(pt)
  }
}
```

+ `class Point(var x: Int, var y: Int)` Classes in Scala are static templates 
and parameterized with constructor arguments visible in the whole body of the class
+ `override def toString: String = "(" + x + "," + "y" + ")"` 
String is return type,Unit corresponds to void in Java-like language
+ toString overides the pre-defined toString method,override keyword
+ it isn't necessary to say return in order to return a value
+ Note that values defined with the val construct are different from 
variables defined with the var construct that they do not allow updates;
i.e. the value is constant.

## Traits

```scala
trait Similarity {
  def isSimilar(x: Any): Boolean
  def isNotSimilar(x: Any): Boolean = !isSimilar(x)
}

class Point(xc: Int, yc: Int) extends Similarity {
  var x: Int = xc
  var y: Int = yc
  def isSimilar(obj: Any) =
    obj.isInstanceOf[Point] &&
    obj.asInstanceOf[Point].x == x
}
object TraitsTest extends App {
  val p1 = new Point(2, 3)
  val p2 = new Point(2, 4)
  val p3 = new Point(3, 3)
  println(p1.isNotSimilar(p2))
  println(p1.isNotSimilar(p3))
  println(p1.isNotSimilar(2))
}
```

+ Similar to interfaces in Java
+ Define object types by specifying the signature of the supported methods
+ `def isSimilar(x: Any): Boolean` No conerete method implemenation(abstract terminology of Java)
+ Scala allows traits to be partially implemented like Java 8
+ In contrast to classes,traits no constructor parameters
+ `class Point(xc: Int, yc: Int) extands Similarity {` 
Traits are typically integrated into a class(or other traits) with a mixin class composition
+ `obj.isInstanceOf[Point]` Test whether the dynamic type of the receiver object is Point
+ `obj.asInstanceOf[Point]` Cast the receiver object to be of type Point

## Mixin Class Composition

```scala
abstract class AbsIterator {
  type T
  def hasNext: Boolean
  def next: T
}

trait RichIterator extends AbsIterator {
  def foreach(f: T => Unit) { while (hasNext) f(next) }
}

class StringIterator(s: String) extends AbsIterator {
  type T = Char
  private var i = 0
  def hasNext = i < s.length()
  def next = { val ch = s charAt i; i += 1; ch }
}
```

+ class StringIterator extends AbsIterator
+ trait RichIterator extends AbsIterator
+ object StringIteratorTest#class Iter extends StringIterator with RichIterator

## Anonymous Function Syntax

+ `(x: Int) => x + 1` (x: Int) is in parameter ~~ `Int => Int`
+ `(x: Int, y:Int) => "(" + x + y + ")"` ~~ `(Int,Int) => String`
+ `() => { System.getProp("user.dir") }` ~~ `() => String`
+ `Function1[Int,Int] : first Int is argument, Second Int is return value
+ `Function2[Int,Int,String] : first two Int is argument, last Stirng is return value
+ `Function0[String] : String is return value
+ Function is trait need realize the abstract method apply(), the number of arguments of apply is equal to 和Function

## Higher-order Functions

```scala
class Decorator(left: String, right: String) {
  def layout[A](x: A) = left + x.toString() + right
}

object FunTest extends App {
  def apply(f: Int => String, v: Int) = f(v)
  val decorator = new Decorator("[", "]")
  println(apply(decorator.layout, 7))
}
```

+ Take other functions as parameters, or whose result is a function
+ `f: Int => String` ~~ String val = f(x: Int)
+ layout is a polymorphic method (i.e. it abstracts over some of its signature types) and 
the Scala compiler has to instantiate its method type first appropriately
+ layout[A] : the method is parameterized

## Nested Functions

```scala
object FilterTest extends App {
  def filter(xs: List[Int], threshold: Int) = {
    def process(ys: List[Int]): List[Int] =
      if (ys.isEmpty) ys
      else if (ys.head < threshold) ys.head :: process(ys.tail)
      else process(ys.tail)
    process(xs)
  }
  println(filter(List(1, 9, 2, 8, 3, 7, 4), 5))
}
```

+ `::` Adds an element at the beginning of this list(i.e. 1 :: List(2,3) = List(2,3).::(1) = List(1,2,3))

## Currying

```scala
object CurryTest extends App {
  def filter(xs: List[Int], p: Int => Boolean): List[Int] =
    if (xs.isEmpty) xs
    else if (p(xs.head)) xs.head :: filter(xs.tail, p)
    else filter(xs.tail, p)
  def modN(n: Int)(x: Int) = ((x % n) == 0)
  val nums = List(1, 2, 3, 4, 5, 6, 7, 8)
  println(filter(nums, modN(2)))
  println(filter(nums, modN(3)))
}
```
+ Methods may define multiple parameter lists. When a method is called with a fewer number of parameter lists, 
then this will yield a function taking the missing parameter lists as its arguments
+ `p: Int => Boolean` as function `def modN(n: Int): Boolean`
+ `def modN(n: Int)(x:Int): Boolean` currying `p(xs.head)`

## Case Classes

```scala
abstract class Notification
case class Email(sourceEmail: String, title: String, body: String) extends Notification
case class SMS(sourceNumber: String, message: String) extends Notification
case class VoiceRecording(contactName: String, link: String) extends Notification

val emailFromJohn = Email("john.doe@mail.com", "Greetings From John!", "Hello World!")

val title = emailFromJohn.title
println(title) // prints "Greetings From John!"

emailFromJohn.title = "Goodbye From John!" // This is a compilation error. We cannot assign another value to val fields, which all case classes fields are by default.

val editedEmail = emailFromJohn.copy(title = "I am learning Scala!", body = "It's so cool!")

println(emailFromJohn) // prints "Email(john.doe@mail.com,Greetings From John!,Hello World!)"
println(editedEmail) // prints "Email(john.doe@mail.com,I am learning Scala,It's so cool!)"

val firstSms = SMS("12345", "Hello!")
val secondSms = SMS("12345", "Hello!")

if (firstSms == secondSms) {
  println("They are equal!")
}

println("SMS is: " + firstSms)

def showNotification(notification: Notification): String = {
  notification match {
    case Email(email, title, _) =>
      "You got an email from " + email + " with title: " + title
    case SMS(number, message) =>
      "You got an SMS from " + number + "! Message: " + message
    case VoiceRecording(name, link) =>
      "you received a Voice Recording from " + name + "! Click the link to hear it: " + link
  }
}

val someSms = SMS("12345", "Are you there?")
val someVoiceRecording = VoiceRecording("Tom", "voicerecording.org/id/123")

println(showNotification(someSms))
println(showNotification(someVoiceRecording))

// prints:
// You got an SMS from 12345! Message: Are you there?
// you received a Voice Recording from Tom! Click the link to hear it: voicerecording.org/id/123

def showNotificationSpecial(notification: Notification, specialEmail: String, specialNumber: String): String = {
  notification match {
    case Email(email, _, _) if email == specialEmail =>
      "You got an email from special someone!"
    case SMS(number, _) if number == specialNumber =>
      "You got an SMS from special someone!"
    case other =>
      showNotification(other) // nothing special, delegate to our original showNotification function   
  }
}

val SPECIAL_NUMBER = "55555"
val SPECIAL_EMAIL = "jane@mail.com"
val someSms = SMS("12345", "Are you there?")
val someVoiceRecording = VoiceRecording("Tom", "voicerecording.org/id/123")
val specialEmail = Email("jane@mail.com", "Drinks tonight?", "I'm free after 5!")
val specialSms = SMS("55555", "I'm here! Where are you?")

println(showNotificationSpecial(someSms, SPECIAL_EMAIL, SPECIAL_NUMBER))
println(showNotificationSpecial(someVoiceRecording, SPECIAL_EMAIL, SPECIAL_NUMBER))
println(showNotificationSpecial(specialEmail, SPECIAL_EMAIL, SPECIAL_NUMBER))
println(showNotificationSpecial(specialSms, SPECIAL_EMAIL, SPECIAL_NUMBER))

// prints: 
// You got an SMS from 12345! Message: Are you there?
// you received a Voice Recording from Tom! Click the link to hear it: voicerecording.org/id/123
// You got an email from special someone!
// You got an SMS from special someone!
```

+ Instantiating a case class don’t need to use the new keyword
+ The constructor parameters of case classes are treated as public values and can be accessed directly.
+ With case classes, you cannot mutate their fields directly. (unless you insert var before a field, but doing so is generally discouraged).
+ Make a copy using the copy method. `emailFrom.copy(...)`
+ For every case class the Scala compiler generates an equals method which implements structural equality and a toString method
+ see cass involved example using if guards
+ `case Email(email, _, _)` 如果不是所有部件都需要, 在不需要的部件上用"_"

## Pattern Matching

```scala
object MatchTest1 extends App {
  def matchTest(x: Int): String = x match {
    case 1 => "one"
    case 2 => "two"
    case _ => "many"
  }
  println(matchTest(3))
}

object MatchTest2 extends App {
  def matchTest(x: Any): Any = x match {
    case 1 => "one"
    case "two" => 2
    case y: Int => "scala.Int"
  }
  println(matchTest("two"))
}
```

+ "_" is default value, Int 0;Doublt 0.0

## Singleton Objects

```scala

```

## XML Processing 

```scala
object XMLTest1 extends App {
  val page = 
  <html>
    <head>
      <title>Hello XHTML world</title>
    </head>
    <body>
      <h1>Hello world</h1>
      <p><a href="scala-lang.org">Scala</a> talks XHTML</p>
    </body>
  </html>;
  println(page.toString())
}

// mix Scala expressions and XML
object XMLTest2 extends App {
  import scala.xml._
  val df = java.text.DateFormat.getDateInstance()
  val dateString = df.format(new java.util.Date())
  def theDate(name: String) = 
    <dateMsg addressedTo={ name }>
      Hello, { name }! Today is { dateString }
    </dateMsg>;
  println(theDate("John Doe").toString())
}
```

+ schema2src tool


