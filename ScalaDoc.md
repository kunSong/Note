## Introduction

Scala is a modern multi-paradigm programming language designed to express common programming patterns in a concise, elegant, and type-safe way. It smoothly integrates features of object-oriented and functional languages.

Scala is object-oriented
Scala is a pure object-oriented language in the sense that every value is an object. Types and behavior of objects are described by classes and traits. Classes are extended by subclassing and a flexible mixin-based composition mechanism as a clean replacement for multiple inheritance.

Scala is functional
Scala is also a functional language in the sense that every function is a value. Scala provides a lightweight syntax for defining anonymous functions, it supports higher-order functions, it allows functions to be nested, and supports currying. Scala’s case classes and its built-in support for pattern matching model algebraic types used in many functional programming languages. Singleton objects provide a convenient way to group functions that aren’t members of a class.

Furthermore, Scala’s notion of pattern matching naturally extends to the processing of XML data with the help of right-ignoring sequence patterns, by way of general extension via extractor objects. In this context, sequence comprehensions are useful for formulating queries. These features make Scala ideal for developing applications like web services.

Scala is statically typed
Scala is equipped with an expressive type system that enforces statically that abstractions are used in a safe and coherent manner. In particular, the type system supports:

generic classes
variance annotations
upper and lower type bounds
inner classes and abstract types as object members
compound types
explicitly typed self references
implicit parameters and conversions
polymorphic methods
A local type inference mechanism takes care that the user is not required to annotate the program with redundant type information. In combination, these features provide a powerful basis for the safe reuse of programming abstractions and for the type-safe extension of software.

Scala is extensible
In practice, the development of domain-specific applications often requires domain-specific language extensions. Scala provides a unique combination of language mechanisms that make it easy to smoothly add new language constructs in form of libraries:

any method may be used as an infix or postfix operator
closures are constructed automatically depending on the expected type (target typing).
A joint use of both features facilitates the definition of new statements without extending the syntax and without using macro-like meta-programming facilities.

Scala is designed to interoperate well with the popular Java 2 Runtime Environment (JRE). In particular, the interaction with the mainstream object-oriented Java programming language is as smooth as possible. Newer Java features like annotations and Java generics have direct analogues in Scala. Those Scala features without Java analogues, such as default and named parameters, compile as close to Java as they can reasonably come. Scala has the same compilation model (separate compilation, dynamic class loading) like Java and allows access to thousands of existing high-quality libraries.

Please continue to the next page to read more.
