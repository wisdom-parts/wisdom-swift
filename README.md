# Wisdom

Wisdom is a different approach to constructing software that makes it more malleable and more
evolvable. This version of Wisdom is implemented in [Swift](http://swift.org), which is such a comfortable
language that I expect everyone will be coding in it soon.

A wise software component is a stateless hierarchy of immutable values, with an
interface comprised of pure functions. (More precisely, it is mostly stateless, mostly immutable,
and the functions are mostly pure. We take the perspective that these are good biases, but that ultimately 
the situation on the ground has to drive the decision. In what follows, each "mostly" is presumed but unsaid.)

The interface to a wise component is defined by the interface to the top-level value of its
hierarchy of values. The functions that implement this interface pin down certain aspects of the 
component's behavior, but they commonly delegate important behavioral decisions to deeper levels 
of the hierarchy by invoking interfaces of nested values.

The difference between this approach and object-oriented programming is conceptually subtle
but makes a large practical difference. A conventional object or module implements one specific
algorithm (although possibly a complex algorithm with evolving behavior, like machine learning). 
It relies on subordinate objects or modules to handle details of that algorithm or to communicate with 
the outside world. The author of the higher-level code thinks of those subordinate objects or modules 
as being constrained by their interfaces to provide specific, well-understood behaviors. A wise software 
component instead implements a high-level strategy for solving a problem, while delegating meaningful 
decisions about the solution to lower-level components. As a matter of style rather than machinery, 
the interface to a wise subcomponent specifies mainly the goals rather than the method of achieving them.

The hierarchy of values that comprise a wise component is constructed at runtime. The
constraints that guide wise component construction are exposed at runtime in both human-readable
and machine-readable ways, so that wise components can be assembled at runtime by programmers,
non-programmers, and machine learning algorithms.

When defining the representations, invariants, and interfaces of wise values, and when
implementing the interfaces, the programmer's goal is to define a space of possible program 
behaviors rather than pinning down one specific behavior.  All of the behaviors in the defined space 
must be sane, in the sense of not causing damaging runtime behavior like infinite loops, 
excessive resource utilization, or data structure corruption. 
The programmer's goal is to make the overall space of behaviors dense in useful
solutions for a particular problem domain. This allows a future programmer, non-programmer, or
machine learning algorithm to construct a specific wise component hierarchy that solves a problem
at hand. Wisdom can be seen as a style of defining DSLs that are more declarative than most.

On average, changing values at higher levels of the hierarchy that forms a wise component 
must have more impact on the practical behavior of that component than changes deeper in the hierarchy.
When we talk here about "changing values", we mean it in the immutable sense of creating a new
component that has some different values and hence some different behavior.
The phrase "practical behavior" is chosen carefully: this goal of wise component design 
is deeply entwined with domain-specific outcomes and cannot be pursued or evaluated except in
that context. 

When done well, a set of wise values, their invariants and interfaces, and the implementations
of those interfaces form a domain-specific language in which syntactically similar programs have, 
on average, similar real-world performance. This is important both for human abstract thinking and 
for machine learning. On the human side, this means that a given wise hierarchy can be understood 
top-down, with successive refinement as one descends deeper. On the machine learning side, this means
that testing various changes to a high-performing wise component, with  bias toward changes deep
in the value hierarchy, will likely lead to higher performance. It also means that two high-performing 
wise components with similar value structure can be meaningfully combined into a new one that has a 
usefully high chance of performing better than either. 

The difference between wise and OO programming is largely a
difference in style, ecosystem, and tooling, rather than a difference in runtime machinery. Even so,
the resulting difference in capability is profound.

## Wise Programming Terminology

We use strange-sounding terminology for wise programming to support its 
fundamentally new programming style with fresh metaphors, and to give ouselves new
terms that don't already carry freight in the software domain.

Each node in a wise component's value hierarchy is called an "imp". 
(The name is a pun on "implementation" and demon.)
Each imp provides the root implementation (sometimes the entire implementation) of
a "face" data type that provides the imp's interface. ("Face" is a pun on human
face and "interface".) A given face is commonly implemented by multiple imps, which
represent different ways of carrying out the face's responsibilities.

A complete wise component is formed from a tree of imps, which is called a "clan". 
The face of the clan's root imp is also considered to be the face of the clan.
A clan's face can be as simple as `Int`, in which case the clan is as simple
as a single integer value. This single-node base case forms the leaves of a clan.

Each imp declares a set of subordinate "roles" (possible an empty set) to
which the imp delegates. The imp declares a face for each role.
To form a complete, operational clan, each role must be filled
by a subordinate clan with that face. These subordinate clans are called "septs".

A clan is constructed at runtime from a specification called a "charter".  The charter
provides information needed to construct a root imp, plus recursively a charter for
each of the root imp's roles. A charter can be a partial specification; it may leave
the imp unspecified, or specify the imp but not all of its roles.  But the charter used 
to construct a clan must be complete.

## Wise Programming in Swift

A face can be represented by any Swift data type. By convention, a polymorphic face is represented as a protocol that is usable as an existential type. (As of this writing, this means it cannot have associated types.) An imp is simply a value of the face type.

In simple cases, a charter is simply an instance of the face data type. For example, 42 is a valid charter for an `Int` face. By convention, a charter for a polymorphic face is itself polymorphic, and is also represented by a protocol that is usable as an existential type.

The code that constructs an imp must know how to instantiate it from a charter. For non-polymorphic imps, this can be hardcoded and specific to the imp and charter types. By convention, the protocol that represents the charter for a polymorphic face provides a method for constructing an imp.

These representations generally adhere to the following conventions.  `nil` represents an unspecified imp. Therefore, 
roles are represented in charters as optional values. The Wisdom framework provides machinery for converting a 
partially specified charter into a complete one. To move the burden of role optionality entirely into the framework, 
charter roles are represented by implicitly unwrapped optionals. 

# Important Wise Idioms and Operations

## Constructing a Wise Component in Code

## Constructing a Wise Component in a UI

## Constructing a Wise Component through Machine Learning

## Textual Representation of a Wise Component

## Creating a Random Wise Component of a Given Type

## Randomly Mutating a Wise Component

## Mating Two Wise Components


