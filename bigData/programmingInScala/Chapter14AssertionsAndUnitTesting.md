## Assertions and Unit Testing

### Vocabulary

Two important ways to check that the behavior of the software you write is as you expect are assertions and unit tests. In this chapter, we'll show you several options you have in Scala to write and run them.

### 14.1 Assertions

Assertions in Scala are written as calls of a predefined method assert.[1] The expression assert(condition) throws an AssertionError if condition does not hold. There's also a two-argument version of assert. The expression assert(condition, explanation) tests condition, and, if it does not hold, throws an AssertionError that contains the given explanation. The type of explanation is Any, so you can pass any object as the explanation. The assert method will call toString on it to get a string explanation to place inside the AssertionError.

+ Scala里，断言被写为对预定义方法 assert 的调用。表达式`assert(condition)`将在condition条件不成立的时候抛出AssertionError。
assert还有带两个参数的版本。表达式`assert(condition, explanation)` 会测试condition，并且如果条件不成立，会抛出含有指定explanation作为说明的AssertionError。explanation的类型是Any，因此你可以把任何对象当作说明参数。assert方法会对传入的参数调用toString，一获得可以放在AssertionError中的字符串说明。

For example, in the method named "above" of class Element, shown in Listing 10.13 here, you might place an assert after the calls to widen to make sure that the widened elements have equal widths. This is shown in Listing 14.1.

```scala
    def above(that: Element): Element = { 
      val this1 = this widen that.width 
      val that1 = that widen this.width 
      assert(this1.width == that1.width)
      elem(this1.contents ++ that1.contents) 
    }
```

Listing 14.1 - Using an assertion.

Another way you might choose to do this is to check the widths at the end of the widen method, right before you return the value. You can accomplish this by storing the result in a val, performing an assertion on the result, then mentioning the val last so the result is returned if the assertion succeeds. You can do this more concisely, however, with a convenience method in Predef named ensuring, as shown in Listing 14.2.

+ 另一种使用断言的方式是在widen方法的结束处，在返回结果值之前，检查一下宽度是否正确。首先把结果存在val里，然后对这个结果执行断言，并且如果断言成功，则返回val值。不过，也可以使用`Predef`里的名为`ensuring`的方法来简化这些操作。

```scala
    private def widen(w: Int): Element =
      if (w <= width) 
        this 
      else { 
        val left = elem(' ', (w - width) / 2, height) 
        var right = elem(' ', w - width - left.width, height) 
        left beside this beside right 
      } ensuring (w <= _.width)
```

Listing 14.2 - Using ensuring to assert a function's result.

The ensuring method can be used with any result type because of an implicit conversion. Although it looks in this code as if we're invoking ensuring on widen's result, which is type Element, we're actually invoking ensuring on a type to which Element is implicitly converted. The ensuring method takes one argument, a predicate function that takes a result type and returns Boolean. ensuring will pass the result to the predicate. If the predicate returns true, ensuring will return the result. Otherwise, ensuring will throw an AssertionError.

+ 由于存在隐式转换，因此ensuring方法能被用在任何结果类型上。尽管这段代码看上去好像是对widen的结果类型Element调用ensuring，但实际上是对Element隐式转换成的类型调用了ensuring。ensuring方法带一个函数做参数，该函数是接受一个结果类型对象并返回Boolean类型的论断函数predicate function。ensuring会把结果传给这个函数。如果函数返回true，ensuring将返回结果，否则，ensuring将抛出AssertionError。

```
// 对Element隐式转换成的类型调用了ensuring
ensuring(cond: (Element) => Boolea)
```

In this example, the predicate is "w <= _.width". The underscore is a placeholder for the one argument passed to the predicate, the Element result of the widen method. If the width passed as w to widen is less than or equal to the width of the result Element, the predicate will result in true, and ensuring will result in the Element on which it was invoked. Because this is the last expression of the widen method, widen itself will then result in the Element.

+ 例子中，论断函数是`w <= _.width`。下划线是传递给论断参数的占位符，即widen方法的结果Element。如果传参w与widen的宽度小于或等于结果Element的width，预期函数将返回true，于是ensuring将返回被调用的 Element作为结果。因为这是widen方法的最后一个表达式，所以 widen本身将返回Element作为结果。

Assertions (and ensuring checks) can be enabled and disabled using the JVM's -ea and -da command-line flags. When enabled, each assertion serves as a little test that uses the actual data encountered as the software runs. In the remainder of this chapter, we'll focus on the writing of external unit tests, which provide their own test data and run independently from the application.

+ 断言(以及ensuring检查)可以使用JVM的-ea和-da命令行标志开放和禁止。开放的时候，每个断言 被当做对使用软件运行时产生的实际数据进行的小测试。

### 14.2 Unit testing in Scala

You have many options for unit testing in Scala, from established Java tools, such as JUnit and TestNG, to new tools written in Scala, such as ScalaTest, specs, and ScalaCheck. In the remainder of this chapter, we'll give you a quick tour of these tools. We'll start with ScalaTest.

+ Scala的单元测试可以有许多选择，从Java实现的工具，如JUnit和TestNG，到Scala编写的新工具，如ScalaTest，specs还有ScalaCheck。

ScalaTest provides several ways to write tests, the simplest of which is to create classes that extend org.scalatest.Suite and define test methods in those classes. A Suite represents a suite of tests. Test methods start with "test". Listing 14.3 shows an example:

+ ScalaTest提供了若干编写测试的方法，最简单的就是创建类来继承org.scalatest.Suite的类并在这些类中定义测试方法。Suite代表一个测试集。测试方法名以"test"开头。

```scala
    import org.scalatest.Suite
    import Element.elem
  
    class ElementSuite extends Suite {
  
      def testUniformElement() {
        val ele = elem('x', 2, 3)
        assert(ele.width == 2)
      }
    }
```

Listing 14.3 - Writing a test method with Suite.

Although ScalaTest includes a Runner application, you can also run a Suite directly from the Scala interpreter by invoking execute on it. Trait Suite's execute method uses reflection to discover its test methods and invokes them. Here's an example:

+ 尽管ScalaTest包含了Runner应用，你也还是可以直接在Scala解释器中通过调用execute方法运行Suite。Trait Suite的execute方法使用反射发现测试方法并调用它们。如下。

```
  scala> (new ElementSuite).execute()
  Test Starting - ElementSuite.testUniformElement
  Test Succeeded - ElementSuite.testUniformElement
```

ScalaTest facilitates different styles of testing, because execute can be overridden in Suite subtypes. For example, ScalaTest offers a trait called FunSuite, which overrides execute so that you can define tests as function values rather than methods. Listing 14.4 shows an example:

+ ScalaTest为不同风格的测试提供了便利，因为execute可以在Suite子类型中重写。比方说，ScalaTest提供了名为trait FunSuite，重写了execute，从而可以让你以函数值function value的方式而不是方法定义测试。

```scala
    import org.scalatest.FunSuite
    import Element.elem
  
    class ElementSuite extends FunSuite {
  
      test("elem result should have passed width") {
        val ele = elem('x', 2, 3)
        assert(ele.width == 2)
      }
    }
```

Listing 14.4 - Writing a test function with FunSuite.

The "Fun" in FunSuite stands for function. "test" is a method defined in FunSuite, which will be invoked by the primary constructor of ElementSuite. You specify the name of the test as a string between the parentheses, and the test code itself between curly braces. The test code is a function passed as a by-name parameter to test, which registers it for later execution. One benefit of FunSuite is you need not name all your tests starting with "test". In addition, you can more easily give long names to your tests, because you need not encode them in camel case, as you must do with test methods.[2]

+ FunSuite里的"Fun"表示函数。"test"是定义在FunSuite中的方法，将被ElementSuite的主构造器调用。圆括号里的字串指定了测试的名称，大括号之间的是测试代码。测试代码是被作为传名参数by-name parameter传递给test的函数，并由test函数登记在册以备之后的运行。FunSuite的一个好处是你不用给你所有的测试以"test"开头起名。而且，你可以更容易地给你的测试起很长的名称，因为你不需要把它们编码为驼峰形式，而对于测试方法你就必须这么做了。

### 14.3 Informative failure reports

The tests in the previous two examples attempt to create an element of width 2 and assert that the width of the resulting element is indeed 2. Were this assertion to fail, you would see a message that indicated an assertion failed. You'd be given a line number, but wouldn't know the two values that were unequal. You could find out by placing a string message in the assertion that includes both values, but a more concise approach is to use the triple-equals operator, which ScalaTest provides for this purpose:

+ 像上面断言宽度是否为2，如果这个断言失败了，你会看到一条指明断言失败的消息。你会得到行号，但是无法知道不相等的两个值。Scala中有一种更清晰的方式，就是使用三等号操作符 (===)，这是 ScalaTest 为了这个目的专门提供的：

```
  assert(ele.width === 2)
```

Were this assertion to fail, you would see a message such as "3 did not equal 2" in the failure report. This would tell you that ele.width wrongly returned 3. The triple-equals operator does not differentiate between the actual and expected result. It just indicates that the left operand did not equal the right operand. If you wish to emphasize this distinction, you could alternatively use ScalaTest's expect method, like this:

+ 如果断言失败了，你会在失败报告中看到"3 did not equal 2"这样的信息。它能告诉你ele.width错误地返回了3。三等号操作符不能区分实际结果和希望结果。它只是说明左侧的操作数不等于右侧的操作数。如果你希望强调这种区分，你可以改用ScalaTest的except方法。

```
  expect(2) {
    ele.width
  }
```

With this expression you indicate that you expect the code between the curly braces to result in 2. Were the code between the braces to result in 3, you'd see the message, "Expected 2, but got 3" in the test failure report.

+ 这个表达式可以说明你希望在大括号之间的代码返回的结果是2。如果返回的结果是3，你会在测
试失败报告中看到"Expected 2, but got 3"的消息。

If you want to check that a method throws an expected exception, you can use ScalaTest's intercept method, like this:

+ 如果你想要检查方法是否抛出了期待的异常，可以使用ScalaTest的intercept方法。

```
  intercept[IllegalArgumentException] {
   elem('x', -2, 3)
  }
```

If the code between the curly braces completes abruptly with an instance of the passed exception class, intercept will return the caught exception, in case you want to inspect it further. Most often, you'll probably only care that the expected exception was thrown, and ignore the result of intercept, as is done in this example. On the other hand, if the code does not throw an exception, or throws a different exception, the intercept method will throw a TestFailedException, and you'll get a helpful error message in the failure report, such as:

+ 如果大括号之间的代码被一个参数指定的异常类的实例突然中断，intercept将返回捕获的异常，以便于你在之后进行检查。另一方面，如果代码没有抛出异常，或抛出了不同的异常，intercept将抛出TestFailedException(AssertionError)，并且你将在失败报告中得到有帮助的错误消息，如。 

```
  Expected IllegalArgumentException to be thrown,
    but NegativeArraySizeException was thrown.
```

The goal of ScalaTest's === operator and its expect and intercept methods is to help you write assertion-based tests that are clear and concise. In the next section, we'll show you how to use this syntax in JUnit and TestNG tests written in Scala.

+ ScalaTest的===符号和它的expect以及 intercept方法的目的是帮助你编写清晰的简明的基于断言的测试。

### 14.4 Using JUnit and TestNG

The most popular unit testing framework on the Java platform is JUnit, an open source tool written by Kent Beck and Erich Gamma. You can write JUnit tests in Scala quite easily. Here's an example using JUnit 3.8.1:

+ Scala里编写JUnit测试非常容易。

```scala
  import junit.framework.TestCase
  import junit.framework.Assert.assertEquals
  import junit.framework.Assert.fail
  import Element.elem
  
  class ElementTestCase extends TestCase {
  
    def testUniformElement() {
      val ele = elem('x', 2, 3)
      assertEquals(2, ele.width)
      assertEquals(3, ele.height)
      try {
        elem('x', -2, 3)
        fail()
      }
      catch {
        case e: IllegalArgumentException => // expected
      }
    }
  }
```

Once you compile this class, JUnit will run it like any other TestCase. JUnit doesn't care that it was written in Scala. If you wish to use ScalaTest's assertion syntax in your JUnit 3 test, however, you can instead subclass JUnit3Suite, as shown Listing 14.5.

+ 一旦你完成了这个类的编译，JUnit就会像运行其它任何 TestCase那样运行它。JUnit不会在意它是用Scala写的。不过，如果你希望在JUnit3测试中使用ScalaTest的断言语法，你可以换成JUnit3Suite的子类，JUnit3Suite，如。

```scala
    import org.scalatest.junit.JUnit3Suite
    import Element.elem
  
    class ElementSuite extends JUnit3Suite {
  
      def testUniformElement() {
        val ele = elem('x', 2, 3)
        assert(ele.width === 2)
        expect(3) { ele.height }
        intercept[IllegalArgumentException] {
          elem('x', -2, 3)
        }
      }
    }
```

Listing 14.5 - Writing a JUnit test with JUnit3Suite.

Trait JUnit3Suite extends TestCase, so once you compile this class, JUnit will run it just fine, even though it uses ScalaTest's more concise assertion syntax. Moreover, because JUnit3Suite mixes in ScalaTest's trait Suite, you can alternatively run this test class with ScalaTest's runner. The goal is to provide a gentle migration path to enable JUnit users to start writing JUnit tests in Scala that take advantage of the conciseness afforded by Scala. ScalaTest also has a JUnitWrapperSuite, which enables you to run existing JUnit tests written in Java with ScalaTest's runner.

+ trait JUnit3Suite继承了TestCase，因此一旦你完成了这个类的编译之后，即使它使用了ScalaTest的更简洁的断言语法，JUnit 也能很好地运行它。不只如此，因为JUnit3Suite混入mix-in ScalaTest的特质Suite，你还能使用ScalaTest的运行器运行这个测试。目的是能让JUnit使用者利用Scala简洁的特性来写JUnit tests在Scala中。ScalaTest同样具有JUnit3WrapperSuite，能让你使用ScalaTest的运行器运行用Java编写的现存JUnit测试。

ScalaTest offers similar integration classes for JUnit 4 and TestNG, both of which make heavy use of annotations. We'll show an example using TestNG, an open source framework written by Cedric Beust and Alexandru Popescu. As with JUnit, you can simply write TestNG tests in Scala, compile them, and run them with TestNG's runner. Here's an example:

+ TestNG与使用JUnit一样， 用Scala编写TestNG测试非常容易，编译，然后使用TestNG的运行器运行它们。

```scala
  import org.testng.annotations.Test
  import org.testng.Assert.assertEquals
  import Element.elem
  
  class ElementTests {
    @Test def verifyUniformElement() {
      val ele = elem('x', 2, 3)
      assertEquals(ele.width, 2)
      assertEquals(ele.height, 3)
    }
    @Test {
      val expectedExceptions =
        Array(classOf[IllegalArgumentException])
    }
    def elemShouldThrowIAE() { elem('x', -2, 3) }
  }
```

If you prefer to use ScalaTest's assertion syntax in your TestNG tests, however, you can extend trait TestNGSuite, as shown in Listing 14.6:

+ 如果你偏好在TestNG测试中使用ScalaTest的断言语法，可以继承TestNGSuite特质。

```scala
    import org.scalatest.testng.TestNGSuite
    import org.testng.annotations.Test
    import Element.elem
  
    class ElementSuite extends TestNGSuite {
  
      @Test def verifyUniformElement() {
        val ele = elem('x', 2, 3)
        assert(ele.width === 2)
        expect(3) { ele.height }
        intercept[IllegalArgumentException] {
          elem('x', -2, 3)
        }
      }
    }
```

Listing 14.6 - Writing a TestNG test with TestNGSuite.

As with JUnit3Suite, you can run a TestNGSuite with either TestNG or ScalaTest, and ScalaTest also provides a TestNGWrapperSuite that enables you to run existing TestNG tests written in Java with ScalaTest. To see an example of JUnit 4 tests written in Scala, see Section 29.2.

+ 和JUnit3Suit一样，你可以运行TestNGSuit在TestNG和ScalaTest。ScalaTest也同样提供了TestNGWrapperSuite以便你能够用ScalaTest运行用Java写的现存TestNG测试。

### 14.5 Tests as specifications

In the behavior-driven development (BDD) testing style, the emphasis is on writing human-readable specifications of the expected behavior of code, and accompanying tests that verify the code has the specified behavior. ScalaTest includes a trait, Spec, which facilitates this style of testing. An example is shown in Listing 14.7.

+ 行为驱动开发behavior-driven development，BDD测试风格中，重点放在了编写人类可读的预期代码行为的规格说明，并辅以验证代码具有规定行为的测试。ScalaTest包含了trait，Spec，以便于这种风格的测试。

```scala
    import org.scalatest.Spec
  
    class ElementSpec extends Spec {
  
      describe("A UniformElement") {
  
        it("should have a width equal to the passed value") {
          val ele = elem('x', 2, 3)
          assert(ele.width === 2)
        }
  
        it("should have a height equal to the passed value") {
          val ele = elem('x', 2, 3)
          assert(ele.height === 3)
        }
  
        it("should throw an IAE if passed a negative width") {
          intercept[IllegalArgumentException] {
            elem('x', -2, 3)
          }
        }
      }
    }
```

Listing 14.7 - Specifying and testing behavior with a ScalaTest Spec.

A Spec contains "describers" and "specifiers." A describer, written as describe followed by a string in parentheses and then a block, describes the "subject" being specified and tested. A specifier, written as it followed by a string in parentheses and a block, specifies a small bit of behavior of that subject (in the string) and provides code that verifies that behavior (in the block). When a Spec is executed, it will run each specifier as a ScalaTest test. A Spec can generate output when it is executed that reads more like a specification. For example, here's what the output will look like if you run ElementSpec from Listing 14.7 in the interpreter:

+ Spec包含了描述部分和规格部分。
  - 描述部分：describe跟着在括号里的字符串和大括号中的代码块，描述了要被规格化和测试的目标。
  - 规格部分：it跟着括号里的字符串和大括号中的代码块，规格化了一小块目标的行为（字串中）并提供了验证这种行为的代码（代码块中）。
  - 当 Spec被执行之后，它将把规格部分当作ScalaTest的测试逐一运行。Spec在执行之后会产生输出，读起来很像规格说明。
  - 如下是输出。

```
  scala> (new ElementSpec).execute()
  A UniformElement
  - should have a width equal to the passed value
  - should have a height equal to the passed value
  - should throw an IAE if passed a negative width
```

The specs testing framework, an open source tool written in Scala by Eric Torreborre, also supports the BDD style of testing but with a different syntax. For example, you could use specs to write the test shown in Listing 14.8.

+ The specs testing framework是由Eric Torreborre用Scala写的开源工具，同样支持BDD风格测试，不过语法不同。如下。

```scala
    import org.specs._
  
    object ElementSpecification extends Specification {
      "A UniformElement" should {
        "have a width equal to the passed value" in {
          val ele = elem('x', 2, 3)
          ele.width must be_==(2)
        }
        "have a height equal to the passed value" in {
          val ele = elem('x', 2, 3)
          ele.height must be_==(3)
        }
        "throw an IAE if passed a negative width" in {
          elem('x', -2, 3) must
            throwA[IllegalArgumentException]
        }
      }
    }
```

Listing 14.8 - Specifying and testing behavior with the specs framework.

One goal of specs is to enable you to write assertions that read more like natural language and generate descriptive failure messages. Specs provides a large number of matchers for this purpose. You can also create your own matchers. You can see some examples of matchers in action in Listing 14.8 in the lines that contain "must be_==" and "must throwA". You can also use specs matchers in ScalaTest, JUnit, or TestNG tests written in Scala by mixing trait org.specs.SpecsMatchers into your test classes. You can use specs standalone, but it is also integrated with ScalaTest and JUnit, so you can run specs tests with those tools as well.[3]

+ specs的一个目标是让你能够编写读起来更像自然语言的断言并且产生详尽的失败消息。为此specs提供了大量的匹配matcher。你也可以创建自己的匹配。代码 14.8中，在包含了`must be_==`和`must throwA`的行中，你可以看到一些实际的匹配例子。你还可以通过混入mix-in trait org.specs.SpecsMatchers到你的测试类的方法在用Scala写的ScalaTest，JUnit，或TestNG测试中使用specs匹配。你可以单独使用specs，不过它也可以与ScalaTest和JUnit集成在一起，所以你也可以使用这些工具运行specs测试。 

### 14.6 Property-based testing

Another useful testing tool for Scala is ScalaCheck, an open source framework written by Rickard Nilsson. ScalaCheck enables you to specify properties that the code under test must obey. For each property, ScalaCheck will generate test data and run tests that check whether the property holds. Listing 14.9 show an example of using ScalaCheck from a ScalaTest suite.

+ Scala的另一个有用的测试工具是ScalaCheck，ScalaCheck 能让你指定待测代码须遵循的属性。对于每个属性，ScalaCheck将产生测试数据并运行测试以验证其是否正确。

```scala
    import org.scalatest.prop.FunSuite
    import org.scalacheck.Prop._
    import Element.elem
  
    class ElementSuite extends FunSuite {
  
      test("elem result should have passed width", (w: Int) =>
        w > 0 ==> (elem('x', w, 3).width == w)
      )
  
      test("elem result should have passed height", (h: Int) =>
        h > 0 ==> (elem('x', 2, h).height == h)
      )
    }
```

Listing 14.9 - Writing property-based tests with ScalaCheck.

In this example, we check two properties that the elem factory should obey. ScalaCheck properties are expressed as function values that take as parameters the required test data, which will be generated by ScalaCheck. In the first property shown in Listing 14.9, the test data is an integer named w that represents a width. Inside the body of the function, you see:

+ 14.9我们检查了elem factory应该遵循的两个属性。ScalaCheck属性被表示为带有将由ScalaCheck产生的所需的测试数据作为参数的函数值function value。

```
  w > 0 ==> (elem('x', w, 3).width == w)
```

The ==> symbol is an implication operator. It implies that whenever the left hand expression is true, the expression on the right must hold true. Thus in this case, the expression on the right of ==> must hold true whenever w is greater than 0. The right-hand expression in this case will yield true if the width passed to the elem factory is the same as the width of the Element returned by the factory.

+ `==>`符号是含义操作符implication operator。说明当左手边的表达式为真，那么右侧的表达式也必须为真。因此在这个例子中，`==>`右侧的表达式在w大于0的时候必须为真。本例中若传递给elem factory的宽度与factory返回的 Element宽度一致的话，右手侧的表达式将产生真值。

With this small amount of code, ScalaCheck will generate possibly hundreds of values for w and test each one, looking for a value for which the property doesn't hold. If the property holds true for every value ScalaCheck tries, the test will pass. Otherwise, the test will complete abruptly with an AssertionError that contains information including the value that caused the failure.

+ 有了这一小段代码，ScalaCheck将有可能产生几百个w 值并测试每一个，查看有哪个值使得属性失败。如果对于每个ScalaCheck尝试的之来说属性始终为真，那么测试通过。反之，测试就会被包含了引起失败的值的信息的 AssertionError中断掉。

In Listing 14.9, each test was composed of a single property. Sometimes, however, you may want to make multiple property checks within a single test, or perform both property checks and assertions in the same test. ScalaTest's Checkers trait makes this easy. Simply mix Checkers into your test class, and pass properties to one of several "check" methods. For example, Listing 14.10 shows a JUnit3Suite performing the same two ScalaCheck property checks shown in the previous example, but this time in a single test. As with all JUnit3Suites, this class is a JUnit TestCase and can therefore be run with either ScalaTest or JUnit.[4]

+ 14.9中每个测试由单个属性组成。有些时候，你或许希望在单个测试中检查多个属性，或者在同一个测试中即执行属性检查又包含断言。用ScalaTest的Checkers trait就简单了。只要把Checkers混入mix-in你的测试类，然后把属性传递给几个"check"方法之一即可。这里JUnit3Suit用ScalaCheck完成了上述代码的2个属性的检查，但这里是一个测试。和JUnit3Suites相同，这个类是JUnit TestCase，因此可以在ScalaTest或JUnit运行。

```scala
  import org.scalatest.junit.JUnit3Suite
  import org.scalatest.prop.Checkers
  import org.scalacheck.Prop._
  import Element.elem
  
  class ElementSuite extends JUnit3Suite with Checkers {
  
    def testUniformElement() {
      check((w: Int) => w > 0 ==> (elem('x', w, 3).width == w))
      check((h: Int) => h > 0 ==> (elem('x', 2, h).height == h))
    }
  }
```

Listing 14.10 - Checking properties from a JUnit TestCase with Checkers.

### 14.7 Organizing and running tests

Each framework mentioned in this chapter provides some mechanism for organizing and running tests. In this section, we'll give a quick overview of ScalaTest's approach. To get the full story on any of these frameworks, however, you'll need to consult their documentation.

In ScalaTest, you organize large test suites by nesting Suites inside Suites. When a Suite is executed, it will execute its nested Suites as well as its tests. The nested Suites will in turn execute their nested Suites, and so on. A large test suite, therefore, is represented as a tree of Suite objects. When you execute the root Suite in the tree, all Suites in the tree will be executed.

+ ScalaTest中，可以通过在Suite内部嵌套 Suite来管理较大的测试集。一个Suite在执行的时候，会把内嵌的Suite当做它的测试执行。以此类推，内嵌的Suite会依次执行它们的内嵌Suite。因此一个大的测试集被表达成Suite对象树。当你执行树的根节点Suite时，树上的所有Suite都将被执行。

You can nest suites manually or automatically. To nest manually, you either override the nestedSuites method on your Suites, or pass the Suites you want to nest to the constructor of class SuperSuite, which ScalaTest provides for this purpose. To nest automatically, you provide package names to ScalaTest's Runner, which will discover Suites automatically, nest them under a root Suite, and execute the root Suite.

+ 你可以手动或自动嵌套测试集。手动嵌套的话，要么在你的Suite里重载 nestedSuites方法，要么采用ScalaTest专为此提供的方案，把你想要嵌套的Suite传递给SuperSuite 类的构造器。自动嵌套的话，准备一个与ScalaTest的Runner同名的包，保存需要自动发现的Suite，把它们内嵌到根Suite下，然后执行根Suite。

You can invoke ScalaTest's Runner application from the command line or an ant task. You must specify which suites you want to run, either by naming the suites explicitly or indicating name prefixes with which you want Runner to perform automatic discovery. You can optionally specify a runpath, a list of directories and JAR files from with to load class files for the tests and the code they exercise.[5] You can also specify one or more reporters, which will determine how test results will be presented.

+ ScalaTest的Runner应用可以在命令行或ant任务中调用。不过必须指定要运行的测试集，方式包括显式说明测试集名称或者说明你想要Runner执行自动发现的测试集名称前缀。你可以选择性地指定运行路径run path，目录列表和装载测试类的JAR文件以及它们测试的代码。你也可以指定一个或多个reporters，来决定如何呈现测试结果。

![Figure14.1](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure14.1.jpg)

Figure 14.1 - ScalaTest's graphical reporter.

For example, the ScalaTest distribution includes the suites that test ScalaTest itself. You can run one of these suites, SuiteSuite,[6] with the following command:

+ 例如，ScalaTest的发布包里包含了测试ScalaTest自身的测试集。你可以使用下列命令执行其中的测试集。

```
  $ scala -cp scalatest-0.9.4.jar org.scalatest.tools.Runner
        -p "scalatest-0.9.4-tests.jar" -s org.scalatest.SuiteSuite
```

With -cp you place ScalaTest's JAR file on the class path. The next token, org.scalatest.tools.Runner, is the fully qualified name of the Runner application. Scala will run this application and pass the remaining tokens as command line arguments. The -p specifies the runpath, which in this case is a JAR file that contains the suite classes: scalatest-0.9.4-tests.jar. The -s indicates SuiteSuite is the suite to execute. Because you don't explicitly specify a reporter, you will by default get the graphical reporter. The result is shown in Figure 14.1.

+ `-cp`的目的是把ScalaTest的JAR文件放在类路径中。
+ 下一项，org.scalatest.tools.Runner，是Runner应用的全称。Scala将运行这个应用并把剩余的项当做命令行参数传递给应用。
+ `-p`指定了运行路径，这里是包含了测试集类的JAR文件scalatest-0.9.4-tests.jar。
+ `-s`说明了SuiteSuite是要执行的测试集。因为没有显示指定报表器，缺省的将采用图形报表器。

### 14.8 Conclusion

In this chapter you saw examples of mixing assertions directly in production code as well as writing them externally in unit tests. You saw that as a Scala programmer, you can take advantage of popular testing tools from the Java community, such as JUnit and TestNG, as well as newer tools designed explicitly for Scala, such as ScalaTest, ScalaCheck, and specs. Both in-code assertions and unit testing can help you achieve your software quality goals. We felt that these techniques are important enough to justify the short detour from the Scala tutorial that this chapter represented. In the next chapter, however, we'll return to the language tutorial and cover a very useful aspect of Scala: pattern matching.

### Footnotes for Chapter 14:

[1] The assert method is defined in the Predef singleton object, whose members are automatically imported into every Scala source file.

[2] You can download ScalaTest from http://www.scalatest.org/.

[3] You can download specs from http://code.google.com/p/specs/.

[4] You can download ScalaCheck from http://code.google.com/p/scalacheck/.

[5] Tests can be anywhere on the runpath or classpath, but typically you would keep your tests separate from your production code, in a separate directory hierarchy that mirrors your source tree's directory hierarchy.

[6] SuiteSuite is so-named because it is a suite of tests that test trait Suite itself.
