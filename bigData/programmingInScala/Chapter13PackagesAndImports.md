## Packages and Imports

### Vocabulary
+ coupling
  - the extent to which the various parts of the program rely on the other parts
+ seemingly
+ innocuous
+ devastating
+ overshadow

When working on a program, especially a large one, it is important to minimize coupling—the extent to which the various parts of the program rely on the other parts. Low coupling reduces the risk that a small, seemingly innocuous change in one part of the program will have devastating consequences in another part. One way to minimize coupling is to write in a modular style. You divide the program into a number of smaller modules, each of which has an inside and an outside. When working on the inside of a module—its implementation—you need only coordinate with other programmers working on that very same module. Only when you must change the outside of a module—its interface—is it necessary to coordinate with developers working on other modules.

+ 工作在大程序上，最重要的是降低耦合，所谓的耦合是指程序的各个方面依赖于其他部分。低耦合可以降低风险，就是表面上看似无害的修改程序中的一部分导致另一部分严重的后果。一个可以最小化耦合的方法是模块化写代码。你把程序分割成小部分，没部分有里面的也有外面的。当工作在模块里面的时候，即实现部分，只需要协调其他程序员在相同的模块上工作。当要修改外部模块，即接口，就需要协调开发者工作在其他的模块上。

This chapter shows several constructs that help you program in a modular style. It shows how to place things in packages, make names visible through imports, and control the visibility of definitions through access modifiers. The constructs are similar in spirit to constructs in Java, but there are some differences—usually ways that are more consistent—so it's worth reading this chapter even if you already know Java.

+ 这章会介绍介个结构是你写代码更模块化。会告诉你如何在包里放东西，通过import可以使名字可见，和通过访问修饰符来控制定义的可见性。虽然结构很像Java但是还是和Java有所不同。比如更加有组织。

### 13.1 Packages

Scala code resides in the Java platform's global hierarchy of packages. The example code you've seen so far in this book has been in the unnamed package. You can place code into named packages in Scala in two ways. First, you can place the contents of an entire file into a package by putting a package clause at the top of the file, as shown in Listing 13.1.

+ Scala代码是寄生在Java平台的全局包集合中的。你可以将代码放到包package中有两种方法。第一，你能在文件的头定义包名，这种方法就后续所有代码都放在该报中。比如。

```scala
    package bobsrockets.navigation
    class Navigator
```

Listing 13.1 - Placing the contents of an entire file into a package.

The package clause of Listing 13.1 places class Navigator into the package named bobsrockets.navigation. Presumably, this is the navigation software developed by Bob's Rockets, Inc.

**Note**

Because Scala code is part of the Java ecosystem, it is recommended to follow Java's reverse-domain-name convention for Scala packages that you release to the public. Thus, a better name for Navigator's package might be com.bobsrockets.navigation. In this chapter, however, we'll leave off the "com." to make the examples easier to understand.

+ 因为Scala是Java生态系统的一部分，所以推荐使用反向域名的形式来写Scala的packages。所以上面包名最好是com.bobsrockets.navigation。这章会将com.省略更容易理解。

The other way you can place code into packages in Scala is more like C# namespaces. You follow a package clause by a section in curly braces that contains the definitions that go into the package. Among other things, this syntax lets you put different parts of a file into different packages. For example, you might include a class's tests in the same file as the original code, but put the tests in a different package, as shown in Listing 13.2:

+ 另一个方式是将代码写在package里像C#的命名。你可以在里面放多个不同的包。

```scala
    package bobsrockets {
      package navigation {
  
        // In package bobsrockets.navigation
        class Navigator
  
        package tests {
  
          // In package bobsrockets.navigation.tests
          class NavigatorSuite
        }
      }
    }
```

Listing 13.2 - Nesting multiple packages in the same file.

The Java-like syntax shown in Listing 13.1 is actually just syntactic sugar for the more general nested syntax shown in Listing 13.2. In fact, if you do nothing with a package except nest another package inside it, you can save a level of indentation using the approach shown in Listing 13.3:

+ 比起上述的代码，归类可以减少indentation的使用。

```scala
    package bobsrockets.navigation {
  
      // In package bobsrockets.navigation
      class Navigator
  
      package tests {
  
        // In package bobsrockets.navigation.tests
        class NavigatorSuite
      }
    }
```

Listing 13.3 - Nesting packages with minimal indentation.

As this notation hints, Scala's packages truly nest. That is, package navigation is semantically inside of package bobsrockets. Java packages, despite being hierarchical, do not nest. In Java, whenever you name a package, you have to start at the root of the package hierarchy. Scala uses a more regular rule in order to simplify the language.

+ 这个概念暗示，Scala的包是可以嵌套的。Java是不能嵌套的。

Take a look at Listing 13.4. Inside the Booster class, it's not necessary to reference Navigator as bobsrockets.navigation.Navigator, its fully qualified name. Since packages nest, it can be referred to as simply as navigation.Navigator. This shorter name is possible because class Booster is contained in package bobsrockets, which has navigation as a member. Therefore, navigation can be referred to without a prefix, just like the code inside methods of a class can refer to other methods of that class without a prefix.

+ 看下面的代码中Booster类，不需要用全名bobsrockets.navigation.Navigator，因为包是嵌套的，只需要用简单的navigation.Navigator。Booster类是在bobsrockets中的，package navigation是bobsrockets的成员。

```scala
    package bobsrockets {
      package navigation {
        class Navigator
      }
      package launch {
        class Booster {
          // No need to say bobsrockets.navigation.Navigator
          val nav = new navigation.Navigator
        }
      }
    }
```

Listing 13.4 - Scala packages truly nest.

Another consequence of Scala's scoping rules is that packages in an inner scope hide packages of the same name that are defined in an outer scope. For instance, consider the code shown in Listing 13.5, which has three packages named launch. There's one launch in package bobsrockets.navigation, one in bobsrockets, and one at the top level (in a different file from the other two). Such repeated names work fine—after all they are a major reason to use packages—but they do mean you must use some care to access precisely the one you mean.

+ 另一个结果Scala的作用域规则，同样名字的package在里面和外面的作用域不同可以互补干扰。这里有三个同样名字的包launch，调用时需要准确的写访问路径。

```scala
    // In file launch.scala
    package launch {
      class Booster3
    }
  
    // In file bobsrockets.scala
    package bobsrockets {
      package navigation {
        package launch {
          class Booster1
        }
        class MissionControl {
          val booster1 = new launch.Booster1
          val booster2 = new bobsrockets.launch.Booster2
          val booster3 = new _root_.launch.Booster3
        }
      }
      package launch {
        class Booster2
      }
    }
```

Listing 13.5 - Accessing hidden package names.

To see how to choose the one you mean, take a look at MissionControl in Listing 13.5. How would you reference each of Booster1, Booster2, and Booster3? Accessing the first one is easiest. A reference to launch by itself will get you to package bobsrockets.navigation.launch, because that is the launch package defined in the closest enclosing scope. Thus, you can refer to the first booster class as simply launch.Booster1. Referring to the second one also is not tricky. You can write bobrockets.launch.Booster2 and be clear about which one you are referencing. That leaves the question of the third booster class, however. How can you access Booster3, considering that a nested launch package shadows the top-level one?

+ 看上述代码如何调用三个launch包中的class。

To help in this situation, Scala provides a package named _root_ that is outside any package a user can write. Put another way, every top-level package you can write is treated as a member of package _root_. For example, both launch and bobsrockets of Listing 13.5 are members of package _root_. As a result, _root_.launch gives you the top-level launch package, and _root_.launch.Booster3 designates the outermost booster class.

+ Scala用`_root_`来表示用户写包的最外面。换句话就是你写的最外层的包其实是包`package _root_`的成员。这里launch和bobsrockets是`_root_`包的成员。

### 13.2 Imports

In Scala, packages and their members can be imported using import clauses. Imported items can then be accessed by a simple name like File, as opposed to requiring a qualified name like java.io.File. For example, consider the code shown in Listing 13.6:

+ 使用import可以导入包这样就可以用简单的名字了。

```scala
    package bobsdelights
  
    abstract class Fruit(
      val name: String,
      val color: String
    )
  
    object Fruits {
      object Apple extends Fruit("apple", "red")
      object Orange extends Fruit("orange", "orange")
      object Pear extends Fruit("pear", "yellowish")
      val menu = List(Apple, Orange, Pear)
    }
```

Listing 13.6 - Bob's delightful fruits, ready for import.

An import clause makes members of a package or object available by their names alone without needing to prefix them by the package or object name. Here are some simple examples:

+ 导包后用简单的名字访问，不需要前缀。

```scala
  // easy access to Fruit
  import bobsdelights.Fruit
  
  // easy access to all members of bobsdelights
  import bobsdelights._
  
  // easy access to all members of Fruits
  import bobsdelights.Fruits._
```

The first of these corresponds to Java's single type import, the second to Java's on-demand import. The only difference is that Scala's on-demand imports are written with a trailing underscore (_) instead of an asterisk (*) (after all, * is a valid identifier in Scala!). The third import clause above corresponds to Java's import of static class fields.

+ 与Java不同，包里的所有用了`._`，而不是像Java的`*`，因为这是在Scala中违法的标识。

These three imports give you a taste of what imports can do, but Scala imports are actually much more general. For one, imports in Scala can appear anywhere, not just at the beginning of a compilation unit. Also, they can refer to arbitrary values. For instance, the import shown in Listing 13.7 is possible:

+ import可以放在代码任何地方，不一定要在整个单元的开头。

```scala
    def showFruit(fruit: Fruit) {
      import fruit._
      println(name +"s are "+ color)
    }
```

Listing 13.7 - Importing the members of a regular (not singleton) object.

Method showFruit imports all members of its parameter fruit, which is of type Fruit. The subsequent println statement can refer to name and color directly. These two references are equivalent to fruit.name and fruit.color. This syntax is particularly useful when you use objects as modules, which will be described in Chapter 27.

+ println可以直接打印fruit的成员，相当于fruit.name and fruit.color。

**Scala's flexible imports**

Scala's import clauses are quite a bit more flexible than Java's. There are three principal differences. In Scala, imports:

+ 相比Java，Scala更灵活一点，有三个原则不同。
  - 可以出现在文件中任何地方
  - 可以 import 对象（singleton 或者普通对象）和 package 本身
  - 支持对引入的对象重命名或者隐藏

+ may appear anywhere
+ may refer to objects (singleton or regular) in addition to packages
+ let you rename and hide some of the imported members

Another way Scala's imports are flexible is that they can import packages themselves, not just their non-package members. This is only natural if you think of nested packages being contained in their surrounding package. For example, in Listing 13.8, the package java.util.regex is imported. This makes regex usable as a simple name. To access the Pattern singleton object from the java.util.regex package, you can just say, regex.Pattern, as shown in Listing 13.8:

+ 另一比较灵活的方法导包是通过他自己导包，而非包中成员。

```scala
    import java.util.regex
  
    class AStarB {
      // Accesses java.util.regex.Pattern
      val pat = regex.Pattern.compile("a*b")
    }
```

Listing 13.8 - Importing a package name.

Imports in Scala can also rename or hide members. This is done with an import selector clause enclosed in braces, which follows the object from which members are imported. Here are some examples:

+ import可以重命名或隐藏成员。这是在大括号中导包选择器完成的
```
import Fruits.{Apple, Orange}
```

This imports just members Apple and Orange from object Fruits.

+ 这个包中只有Apple和Orange，其他的被隐藏了。

```
import Fruits.{Apple => McIntosh, Orange}
```

This imports the two members Apple and Orange from object Fruits. However, the Apple object is renamed to McIntosh. So this object can be accessed with either Fruits.Apple or McIntosh. A renaming clause is always of the form "<original-name> => <new-name>".

+ 这个包中导入Apple和Orange，Apple被重命名为McIntosh。可以被访问用Fruits.Apple or McIntosh。用"<original-name> => <new-name>"。

```
import java.sql.{Date => SDate}
```

This imports the SQL date class as SDate, so that you can simultaneously import the normal Java date class as simply Date.

```
import java.{sql => S}
```

This imports the java.sql package as S, so that you can write things like S.Date.

```
import Fruits.{_}
```

This imports all members from object Fruits. It means the same thing as import Fruits._.

```
import Fruits.{Apple => McIntosh, _}
```

This imports all members from object Fruits but renames Apple to McIntosh.

```
import Fruits.{Pear => _, _}
```

This imports all members of Fruits except Pear. A clause of the form "<original-name> => _" excludes <original-name> from the names that are imported. In a sense, renaming something to `_' means hiding it altogether. This is useful to avoid ambiguities. Say you have two packages, Fruits and Notebooks, which both define a class Apple. If you want to get just the notebook named Apple, and not the fruit, you could still use two imports on demand like this:

+ 这个是导入所有的成员除了Pear。

```
  import Notebooks._
  import Fruits.{Apple => _, _}
```

This would import all Notebooks and all Fruits except for Apple.

+ 当Notebooks和Fruits都有定义叫Apple的成员，但是只需要Notebooks的Apple成员，那就可以用上述办法。导入Notebooks所有成员，剔除Fruits的Apple成员。

These examples demonstrate the great flexibility Scala offers when it comes to importing members selectively and possibly under different names. In summary, an import selector can consist of the following:

+ A simple name x. This includes x in the set of imported names.
+ A renaming clause x => y. This makes the member named x visible under the name y.
+ A hiding clause x => _. This excludes x from the set of imported names.
+ A catch-all `_'. This imports all members except those members mentioned in a preceding clause. If a catch-all is given, it must come last in the list of import selectors.

The simpler import clauses shown at the beginning of this section can be seen as special abbreviations of import clauses with a selector clause. For example, "import p._" is equivalent to "import p.{_}" and "import p.n" is equivalent to "import p.{n}".

+ "import p._" is equivalent to "import p.{_}" and "import p.n" is equivalent to "import p.{n}"

### 13.3 Implicit imports

Scala adds some imports implicitly to every program. In essence, it is as if the following three import clauses had been added to the top of every source file with extension ".scala":

+ 在.scala文件中缺省导入下列这些包。

```
  import java.lang._ // everything in the java.lang package
  import scala._     // everything in the scala package
  import Predef._    // everything in the Predef object
```

The java.lang package contains standard Java classes. It is always implicitly imported on the JVM implementation of Scala. The .NET implementation would import package system instead, which is the .NET analogue of java.lang. Because java.lang is imported implicitly, you can write Thread instead of java.lang.Thread, for instance.

+ Java的包被默认导入的，因为Scala是在JVM平台。可以直接写Thread来代替java.lang.Thread。

As you have no doubt realized by now, the scala package contains the standard Scala library, with many common classes and objects. Because scala is imported implicitly, you can write List instead of scala.List, for instance.

+ Scala标准库，包含许多通用类和对象都有被默认导入。比如可以直接写List来代替scala.List。

The Predef object contains many definitions of types, methods, and implicit conversions that are commonly used on Scala programs. For example, because Predef is imported implicitly, you can write assert instead of Predef.assert.

+ Predef是一个对象，包含许多类，方法和隐式转换。比如直接写assert来代替Predef.assert。

The three import clauses above are treated a bit specially in that later imports overshadow earlier ones. For instance, the StringBuilder class is defined both in package scala and, from Java version 1.5 on, also in package java.lang. Because the scala import overshadows the java.lang import, the simple name StringBuilder will refer to scala.StringBuilder, not java.lang.StringBuilder.

+ 这三个默认import有些特殊的地方，后面导入的包会覆盖前面的。StringBuilder同时存在于scala和java.lang中，所以scala会覆盖java.lang，这里StringBuilder是scala.StringBuilder，而不是java.lang.StringBuilder。

### 13.4 Access modifiers

Members of packages, classes, or objects can be labeled with the access modifiers private and protected. These modifiers restrict accesses to the members to certain regions of code. Scala's treatment of access modifiers roughly follows Java's but there are some important differences which are explained in this section.

+ 包，类和对象成员都可以用private和protected修饰，访问修饰符和Java类似，但稍有不同。

**Private members**

Private members are treated similarly to Java. A member labeled private is visible only inside the class or object that contains the member definition. In Scala, this rule applies also for inner classes. This treatment is more consistent, but differs from Java. Consider the example shown in Listing 13.9:

+ 私有成员和Java类似，但是有些不同。

```scala
    class Outer {
      class Inner {
        private def f() { println("f") }
        class InnerMost {
          f() // OK
        }
      }
      (new Inner).f() // error: f is not accessible
    }
```

Listing 13.9 - How private access differs in Scala and Java.

In Scala, the access (new Inner).f() is illegal because f is declared private in Inner and the access is not from within class Inner. By contrast, the first access to f in class InnerMost is OK, because that access is contained in the body of class Inner. Java would permit both accesses because it lets an outer class access private members of its inner classes.

+ 在外部类用`(new Inner).f()`来访问内被类私有成员是非法的。在内部类中或内部类中嵌套的内部类中是可以访问其私有成员。但是Java对于这两种访问方式都是可行的。

**Protected members**

Access to protected members is also a bit more restrictive than in Java. In Scala, a protected member is only accessible from subclasses of the class in which the member is defined. In Java such accesses are also possible from other classes in the same package. In Scala, there is another way to achieve this effect, as described below, so protected is free to be left as is. The example shown in Listing 13.10 illustrates protected accesses:

+ 访问保护成员protected比Java更加受限。protected成员只能被子类访问。在Java里可以被子类访问也可以在同一个包中的成员访问。

```scala
    package p {
      class Super {
        protected def f() { println("f") }
      }
      class Sub extends Super {
        f()
      }
      class Other {
        (new Super).f()  // error: f is not accessible
      }
    }
```

Listing 13.10 - How protected access differs in Scala and Java.

In Listing 13.10, the access to f in class Sub is OK because f is declared protected in Super and Sub is a subclass of Super. By contrast the access to f in Other is not permitted, because Other does not inherit from Super. In Java, the latter access would be still permitted because Other is in the same package as Sub.

**Public members**

Every member not labeled private or protected is public. There is no explicit modifier for public members. Such members can be accessed from anywhere.

+ 如果没有被标记private和protected的，那就是public的，没有显示修饰符给public成员。可以在任何地方被访问。

```scala
    package bobsrockets {
      package navigation {
        private[bobsrockets] class Navigator { 
          protected[navigation] def useStarChart() {}
          class LegOfJourney {
            private[Navigator] val distance = 100
          }
          private[this] var speed = 200
        }
      }
      package launch {
        import navigation._
        object Vehicle { 
          private[launch] val guide = new Navigator
        }
      }
    }
```

Listing 13.11 - Flexible scope of protection with access qualifiers.

**Scope of protection**

Access modifiers in Scala can be augmented with qualifiers. A modifier of the form private[X] or protected[X] means that access is private or protected "up to" X, where X designates some enclosing package, class or singleton object.

+ 访问修饰符可以添加作用域参数。`private[X] or protected[X]`其中 x 代表某个包，类或者单例对象，表示可以访问这个 private 或的 protected 的范围直到 X。

Qualified access modifiers give you very fine-grained control over visibility. In particular they enable you to express Java's accessibility notions such as package private, package protected, or private up to outermost class, which are not directly expressible with simple modifiers in Scala. But they also let you express accessibility rules that cannot be expressed in Java. Listing 13.11 presents an example with many access qualifiers being used. In this listing, class Navigator is labeled private[bobsrockets]. This means that this class is visible in all classes and objects that are contained in package bobsrockets. In particular, the access to Navigator in object Vehicle is permitted, because Vehicle is contained in package launch, which is contained in bobsrockets. On the other hand, all code outside the package bobsrockets cannot access class Navigator.

+ 通过为访问修饰符添加作用域参数，可以非常精确的控制所定义的类型能够被其它类型访问的范围。尤其是可以支持 Java 语言支持的 package private，package protected 等效果。`private[bobsrockets] class Navigator`意思是在包bobosrockets总的类和对象都能访问到。包launch是在包bobsrocket中的，所以能访问到Navigator类，但是在bobsrocket外的代码就不能访问class Navigator了。

This technique is quite useful in large projects that span several packages. It allows you to define things that are visible in several sub-packages of your project but that remain hidden from clients external to your project. The same technique is not possible in Java. There, once a definition escapes its immediate package boundary, it is visible to the world at large.

+ 这种技巧在分散在多个 Package 的大型项目时非常有用，它允许你定义一些在多个子包中可以访问，但对使用这些 API 的外部客户代码隐藏，而这种效果在 Java 中是无法实现的。

Of course, the qualifier of a private may also be the directly enclosing package. An example is the access modifier of guide in object Vehicle in Listing 13.11. Such an access modifier is equivalent to Java's package-private access.

Table 13.1 - Effects of private qualifiers on LegOfJourney.distance

```
no access modifier    public access
private[bobsrockets]  access within outer package
private[navigation]   same as package visibility in Java
private[Navigator]    same as private in Java
private[LegOfJourney] same as private in Scala
private[this]         access only from same object
```

All qualifiers can also be applied to protected, with the same meaning as private. That is, a modifier protected[X] in a class C allows access to the labeled definition in all subclasses of C and also within the enclosing package, class, or object X. For instance, the useStarChart method in Listing 13.11 is accessible in all subclasses of Navigator and also in all code contained in the enclosing package navigation. It thus corresponds exactly to the meaning of protected in Java.

+ proctect是一样的概念，protected[x]可以被class C的子类访问，同时也可以在x的包，类和对象中访问。

The qualifiers of private can also refer to an enclosing class or object. For instance the distance variable in class LegOfJourney in Listing 13.11 is labeled private[Navigator], so it is visible from everywhere in class Navigator. This gives the same access capabilities as for private members of inner classes in Java. A private[C] where C is the outermost enclosing class is the same as just private in Java.

+ class LegOfJourney的内部类成员`private[Navigator] distence`这样写就可以在类Navigator中被访问，就和Java相同了。

Finally, Scala also has an access modifier that is even more restrictive than private. A definition labeled private[this] is accessible only from within the same object that contains the definition. Such a definition is called object-private. For instance, the definition of speed in class Navigator in Listing 13.11 is object-private. This means that any access must not only be within class Navigator, but it must also be made from the very same instance of Navigator. Thus the accesses "speed" and "this.speed" would be legal from within Navigator. The following access, though, would not be allowed, even if it appeared inside class Navigator:

+ 比private更加受限的是`private[this]`，是只有定义该类型可以访问，新new的对象是不能访问的，叫做对象私有object-pirvate。如下是编译错误的放在定义的类中。

```
  val other = new Navigator
  other.speed // this line would not compile

  def demo(other: Navigator){
    this.speed // ok
    other.speed // this line would not compile
  }
```

Marking a member private[this] is a guarantee that it will not be seen from other objects of the same class. This can be useful for documentation. It also sometimes lets you write more general variance annotations (see Section 19.7 for details).

+ 保证相同类中的其他对象不会见到，对documentation有用，具体看19.7。

To summarize, Table 13.1 here lists the effects of private qualifiers. Each line shows a qualified private modifier and what it would mean if such a modifier were attached to the distance variable declared in class LegOfJourney in Listing 13.11.

**Visibility and companion objects**

In Java, static members and instance members belong to the same class, so access modifiers apply uniformly to them. You have already seen that in Scala there are no static members; instead you can have a companion object that contains members that exist only once. For instance, in Listing 13.12 object Rocket is a companion of class Rocket:

+ In Java, static members and instance members belong to the same class, 访问修饰采用的相同的。Scala没有static对象，是用伴随对象来包含并只存在一个。

```scala
    class Rocket {
      import Rocket.fuel
      private def canGoHomeAgain = fuel > 20
    }
  
    object Rocket {
      private def fuel = 10
      def chooseStrategy(rocket: Rocket) {
        if (rocket.canGoHomeAgain)
          goHome()
        else
          pickAStar()
      }
      def goHome() {}
      def pickAStar() {}
    }
```

Listing 13.12 - Accessing private members of companion classes and objects.

Scala's access rules privilege companion objects and classes when it comes to private or protected accesses. A class shares all its access rights with its companion object and vice versa. In particular, an object can access all private members of its companion class, just as a class can access all private members of its companion object.

+ Scala给伴随对象和类关于private和protected访问一定的特权。类共享了他所有的访问权限给伴随对象，反之亦然。

For instance, the Rocket class above can access method fuel, which is declared private in object Rocket. Analogously, the Rocket object can access the private method canGetHome in class Rocket.

One exception where the similarity between Scala and Java breaks down concerns protected static members. A protected static member of a Java class C can be accessed in all subclasses of C. By contrast, a protected member in a companion object makes no sense, as singleton objects don't have any subclasses.

+ 有点不同Java类class C中protected static成员可以在C的子类中访问，但是Scala的伴随对象不行，因为singleton ojects是没有子类的。

### 13.5 Conclusion

In this chapter, you saw the basic constructs for dividing a program into packages. This gives you a simple and useful kind of modularity, so that you can work with very large bodies of code without different parts of the code trampling on each other. This system is the same in spirit as Java's packages, but there are some differences where Scala chooses to be more consistent or more general.

Looking ahead, Chapter 27 describes a more flexible module system than division into packages. In addition to letting you separate code into several namespaces, that approach allows modules to be parameterized and to inherit from each other. In the next chapter, we'll turn our attention to assertions and unit testing.
