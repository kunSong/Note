## Chapter 2 First Steps in Scala

### Vocabulary
  + vetern: a person who has had long experience in a particular field.
  + fire house
  + interpreter
  + interactive
  + prompt
  + colon
  + striking
  + inference
  + literal
  + grouchy
  + comma-separated
  + curly braces
  + recursive
  + concatenated
  + imperative
  + mutate
  + conciseness
  + trusty
  + be accustomed to
  + glimpse

### Step 1. Learn to use the Scala interpreter
  + `scala> 1 + 2`: `res0: Int = 3`
  + res0 means result0
  + scala.Int corresponding to Java's int
  + complie Scala code to Java bytecodes, using Java's primitive types for the performance benefits of the primitive types
  + `scala> res0 * 3`: `res1: Int = 9` 
  + println similar System.out.println

### Step 2. Define some variables
  + A val is similar to a final variable in Java. Once initialized, a val can never be reassigned.
  + A var is similar to a non-final variable in Java. A var can be reassigned throughout its lifetime.
  + Scala strings are implemented by Java's String class
  + type inference
  + An explicit type annotation
  + multiple lines respond with a vertical bar
  + input something wrong, escape by pressing enter twice

  ```Scala
  scala> val msg = "Hello,world!"
  msg: String = Hello,world!

  scala> val msg2: java.lang.String = "Hello again,world!"
  msg2: String = Hello again,world!

  scala> val msg3: String = "Hello yet again,world!"
  msg3: String = Hello yet again,world!

  scala> println(msg)
  Hello,world!

  scala> msg="Goodbye cruel world!"
  <console>:12: error: reassignment to val
         msg="Goodbye cruel world!"
            ^

  scala> var greeting = "Hello,world!"
  greeting: String = Hello,world!

  scala> greeting = "Leave me alone,world!"
  greeting: String = Leave me alone,world!

  scala> val multiLine =
       | "This is the next line."
  multiLine: String = This is the next line.

  scala> val oops =
       | 
       | 
  You typed two blank lines.  Starting a new command.
  ```

### Step 3. Define some functions
  + Scala compiler does not infer function parameter types
  + `if(x > y) x else y` similar to `(x > y)? x : y`
  + the funciton is recursive, explicityly specify the function's result. In the case of max, you can leave the result type off and the compiler will infer it.
  + a function consists of just one statement, you can optionally leave off the curly braces
  + A result type of Unit indicates the function returns no interesting value. Similar to Java's void.
  + `:quit` or `:q`: quit

  ![Figure2.1](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure2.1.jpg)

  ```scala
  scala> def max(x: Int, y: Int):Int = {
       | if(x > y) x
       | else y
       | }
  max: (x: Int, y: Int)Int

  scala> def max2(x: Int, y: Int) = if(x > y) x else y
  max2: (x: Int, y: Int)Int

  scala> max(3,5)
  res4: Int = 5

  scala> def greet() = println("Hello,world")
  greet: ()Unit
  ```

### Step 4. Write some Scala scripts
  + `scala hello.scala`

### Step 5. Loop with while;decide with if
  + Do not demostrate the bast Scala style

  ```scala
  var i = 0
  while(i < args.length) {
    if(i != 0)
      print(" ")
    print(args(i))
    i += 1
  }
  println()
  ```

### Step 6. Iterate with foreach and for
  + Passing in a function literal that takes one parameter named arg

  ```scala
  args.foreach(arg => println(arg))
  ```

  + a function literal consists of one statement that takes a single argument, need not explicitly name and specify the argument.

  ```scala
  args.foreach(println)
  ```

  + function literal

  ![Figure2.2](https://github.com/kunSong/Note/blob/master/ProgrammingInScala/res/drawable/Figure2.2.jpg)

  + a new arg val will be created and initialized to the element value, not a var. (ahead to Section 7.3 Chapter 7)

  ```scala
  for(arg <- args)
    println(arg)
  ```