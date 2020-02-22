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

A wise behavior is called an "imp". (The name is a pun on "implementation"
and demon.) Each imp forms the root behavior (potentially the sole behavior) of
a corresponding data type, which is called the imp's "face". (The name is a pun on human
face and "interface".) It is common for multiple imps to represent the same face.

A tree or subtree of imps is called a "clan". A clan is a complete implementation
of its root imp's face. This face is also considered to be the clan's face.
A clan's face can be as simple as `Int32`, in which case the clan is as simple as
the number `42`. A face is described at runtime by a `MetaFace`.

## Wise Programming in Swift

Any Swift data type can be made into a face by implementing the MetaFace protocol on it.

The MetaFace protocol has the following responsibilities:
* Provide a registry of named imps of the face.
* Given a suitable `HMap` (see the `joy-data-swift` repo), construct a clan that implements the face.

# Material Not Yet Edited from `wisdom-crystal`

A clan is constructed from a "charter", which is JSON. This can be a JSON object,
array, or value. The module that
supports a given face must provide a function that takes a charter argument
and returns an instance of the face. This is called the "founder function" for
the face.

Within an imp's Crystal code, simple data types like `Int32` are
most commonly handled in the normal Crystal fashion. In this case, a 42 is just a 42.
But when a simple data type is used as a configurable parameter that adjusts the behavior
of a clan, it is handled as a face and becomes part of the wise hierarchy.
So let's go ahead and use our `Int32` example to make these ideas more concrete.

To create an `Int32` clan, we first need an appropriate charter.
We also need a founder function for `Int32`. We might write something like this:

```PureScript
module ObtainAnswer where

import Prelude
import Data.Foreign (toForeign)
import Control.Monad.Eff.Console (log)

import Morphics.Number (foundNumber)

main = do
  charter = toForeign {
    imp: "Morphics.Number.number"
    data: 42
  }
  answer :: Number
  answer = foundNumber charter
  log $ "Hello, World! The answer turns out to be " <> show answer <> "."
```

Ok, that was silly -- and yet, complete. Let's move on to a more representative use case.

Suppose we have a face that is the following PureScript data type:

```PureScript
type ItemOrder = Item -> Item -> Ordering
```

Suppose also that we want to have three implementations of `ItemOrder`:
* `orderBySize :: ItemOrder`
* `orderByWeight :: ItemOrder`
* `orderByBlend :: Number -> Number -> ItemOrder` orders by `w * weight + s * size`
Each implementation is simply a PureScript function. We will encapsulate each function
in an imp. An imp is described at runtime by a "meta-imp", which is represented
in PureScript by a value of the record type `MetaImp`.

The charter for an `ItemOrder` needs to provide two pieces of information:
* It needs to indicate which imp to use.
* In the case of `orderByBlend`, it needs to supply `w` and `s`.

Charter JSON has an "imp" property that specifies an imp by giving its label:
```PureScript
bySizeCharter = { imp: "ItemOrder.orderBySizeLabel" }
```

An imp's label is defined through the `label` field of the `MetaImp` record type.
By convention, each imp label is prefixed by the name of the
module in which instances of that imp are created. In our example, we assume that the
module is called "ItemOrder".

In our `bySizeCharter` example, we gratuitously use the word "Label" in "orderBySizeLabel"
to avoid giving the impression that the label magically refers to the function name.
Although PureScript's JavaScript runtime would make such magic possible, the morphics
implementation uses no such magic: labels are just strings that are compared at runtime.
In practice, a much more likely choice of label for the `orderBySize` imp would be
simply "ItemOrder.orderBySize".

The `orderByBlend` imp adds an interesting new twist: it has parameters `w` and `s`.
Such imp parameters are called "roles". Although in this particular example they
are simply numbers, they could have any face. They could be implemented by complex
clans of their own.

Each meta-imp declares the roles required by that imp. These are exposed through the
`roles` field of the `MetaImp` record type: `roles :: Array Role`. Just as imps have labels, roles and faces
also have labels. The role labels in our example are "w" and "s". `Role` is a simple record type:
```PureScript
type Role = { label :: String, faceLabel :: String }
```

As a founder function constructs a clan, it implements each role with a "sept" -- a subordinate clan.
It is up to the founder function how to capture the imp's septs and make them available
to the imp for its operation.

An imp is represented in charter JSON as an object with three fields:
* imp: the label of the imp
* roles (optional): an object where the keys are role labels and the values are sept charters
* data (optional): additional data for use by the imp's founder function in constructing the imp

For example, the following JSON would be a reasonable charter for our `orderByBlend` imp:
```JSON
{
  "imp": "ItemOrder.orderByBlend",
  "roles": {
    "s": { "imp": "Morphics.Number.number", "data": 0.7 },
    "w": { "imp": "Morphics.Number.number", "data": 0.3 }
  }
}
```


## Important Morphic Idioms and Operations

### Constructing a Morphic Component in Code

Invoke a constructor defined by the root value's type class.

### Constructing a Morphic Component in a UI

In the UI implementation, map classes and their `new` map keys to non-programmer-readable
labels and descriptions.

### Constructing a Morphic Component through Machine Learning

### Textual Representation of a Morphic Component

Uses Joy's textual representation of values.

### Creating a Random Morphic Component of a Given Type

### Randomly Mutating a Morphic Component

### Mating Two Morphic Components


