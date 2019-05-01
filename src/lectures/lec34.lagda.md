This is an introduction to [Agda][], a dependently-typed programming language.
It is also a proof assistant, and is often used in the research community to provide high-assurance proofs.
In this respect, it is similar to the more-popular [Coq][] and the less-popular [Lean][].
Agda [supports][litagda] [literate programming][litprog].
This file is available as a literate Agda source file.

If you want more information about Agda, there are multiple [tutorials][] available, including video tutorials.
For more on using Agda to study programming languages, I recommend the book [*Software Foundations in Agda*][sfagda].
This is based on the popular and much-more-in-depth book [*Software Foundations*][sf], which is based on Coq.

[agda]: https://wiki.portal.chalmers.se/agda/pmwiki.php
[coq]: https://coq.inria.fr/
[lean]: https://leanprover.github.io/
[litagda]: https://agda.readthedocs.io/en/v2.5.3/tools/literate-programming.html
[litprog]: https://en.wikipedia.org/wiki/Literate_programming
[tutorials]: https://wiki.portal.chalmers.se/agda/pmwiki.php?n=Main.Othertutorials
[sfagda]: https://plfa.github.io/
[sf]: https://softwarefoundations.cis.upenn.edu/

# Definitions, Evaluation, and Type Checking

Like any good functional programming language, Agda lets you define data types.
We can define the natural numbers using the following declaration:
(We use the prime notation here because Agda has natural numbers defined in the standard library.)
```agda
data ℕ : Set  where
  zero' : ℕ -- We use zero' because Agda's built-in Nat type defines zero
  succ : ℕ → ℕ
```
This first thing to notice about this declaration is that we are using unicode characters in our agda code.
Agda relies on editor support to make programming much easier, and it comes packaged with an [emacs][] plugin.
This includes support for typing unicode using [TeX][]-like macros.

[emacs]: https://www.gnu.org/software/emacs/
[tex]: https://www.tug.org/begin.html

The declaration of natural numbers above is roughly equivalent to this OCaml declaration:
    type nat = Zero | Succ of nat
The declaration is more verbose because it's more flexible than an OCaml data type.
The `: Set` indicates that we're defining a type of values rather than somethiing else.
Annotating `zero'` with `: ℕ` and `succ` with `: ℕ → ℕ` is a function-like notation that defines the "parameters" of each constructor.
In OCaml, `Zero` implicitly says it takes no parameters and gives you a `nat`; the Agda equivalent says that same thing explicitly.
Similarly, `of nat` is OCaml's way of saying that `Succ` takes another `nat` as a parameter and gives you something else of type `nat`.

Agda's emacs mode gives us the ability to both evaluate expressions and to check their types.
Emacs uses a special notation for commands, where `C-x` means "hit the `x` key while pressing the `Ctrl` key."
In order to evaluate an Agda expression in agda2-mode, we use the command `C-c C-n`, so we hold control and hit `c` followed by `n`, and then release control.
For instance, if we type `C-c C-n succ zero'`, Agda will tell us the result of evaluating that expression.
Unsurprisingly, this is just `succ zero'`.

We can define variables in agda using a Haskell-like binding syntax, with the type of a variable defined before the variable itself:
```agda
one : ℕ
one = succ zero'
```
The type declaration can be elided if the type is inferable, so the following is valid agda:
```agda
one' = succ zero'
```
We can then check the inferred type using the emacs command `C-c C-d` (`d` stands for "Deduce").
`C-c C-d one'` then results in the message `ℕ`

Defining functions works similarly to defining a variable.
Like Haskell, Agda uses pattern-matching to define functions.
Again, Agda relies on editor support to make it much easier to write pattern matches.
The emacs mode allows programmers to define functions with *holes*, which can then be filled in later.
When filling in a hole, it also provides information about the term that is required, including its type and the types of the variables in its context.

To define addition over `ℕ` we can start by writing

    plus : ℕ → ℕ → ℕ
    plus n m = ?

Then, load the file using `C-c C-l`. This will produce a hole, like

    plus : ℕ → ℕ → ℕ
    plus n m = { }0

Now, we want to do different things depending on whether `n` is `zero'` or `succ n`.
In order to do a case split, we put our cursor in the brackets (referred to as the *goal*), and do `C-c C-c n`.
This results in the following:

    plus : ℕ → ℕ → ℕ
    plus zero' m = { }0
    plus (succ n) m = { }1

Now, we can fill in these goals pretty easily.
First, `plus zero' m` should just be `m`, so we type `C-c C-SPC m` inside of the brackets labeled `0`.
Agda type-checks this, and then results in

    plus : ℕ → ℕ → ℕ
    plus zero' m = m
    plus (succ n) m = { }0

Similarly, `plus (succ n)  m` should be computed recursively as `succ (plus n m)`.
We can again give this using `C-c C-SPC succ (plus n m)`.
This finally results in the agda code for `plus`:
```agda
plus : ℕ → ℕ → ℕ
plus zero' m = m
plus (succ n) m = succ (plus n m)
```
We can then evaluate expressions with function calls; for instance, `C-c C-n plus one (plus one one)` gives  `succ (succ (succ zero'))`.
We can also check the type of more complicated expressions, for instance `C-c C-d plus one zero'` gives `ℕ`, and `C-c C-d plus` gives `ℕ → ℕ → ℕ`.

Agda also gives nice notation for infix and mixfix operators.
For instance, if we define
```agda
_+'_ : ℕ → ℕ → ℕ
n +' m = plus n m
```
We can then write `C-c C-n one + (one + one)` and get `succ (succ (succ zero'))`.

# Propositions

Let us write our first (very tiny) logical assertion.
It just says that one = one.
```agda
open import Agda.Builtin.Equality
oneIsOne = one ≡ one
```
Note that we use `≡` for equality as a proposition, since `=` is reserved for definitions.
Now `oneIsOne` is a proposition that says that `one` equals `one`.
If we check the type of `oneIsOne`, we get `Set`, indicating that this is a valid type.
We can then write
```agda
oneIsOneProof : oneIsOne
oneIsOneProof = refl
```
which indicates that `one` equals `one` due to reflexivity.

We can also write more complicated propositions.
For instance, we can write
```agda
plusZero' : (n : ℕ) → n +' zero' ≡ n
plusZero' zero' = refl
plusZero' (succ n) rewrite plusZero' n = refl
```
Agda uses the notation `(n : ℕ) → ...` to define a dependent function.
You can think of this as equivalent to the "big pi" that we used in our formal language.
The use of `rewrite` tells Agda to use the result of the recursive call to change the goal.
This only works with the builtin equality.

# Dependent List Library

For a more-complete example, let us recreate our library of list-related functions from the last lecture.
From now on, we will use Agda's built-in `Nat` type.
```agda
open import Agda.Builtin.Nat
```

## Non-Dependent Lists

We can start with a version in Agda that doesn't really use dependent types.
This will look more-or-less like the OCaml equivalent.

```agda
-- An inductive list type *without* lengths encoded in the type
data IList : Set where
  nil : IList
  cons : Nat → IList → IList

-- A datatype represening a possibly-failing computation
data Maybe (A : Set) : Set where
  Some : A → Maybe A
  None : Maybe A

-- Our little library of operations:
-- head, tail, and a nil check

hd : IList → Maybe Nat
hd nil = None
hd (cons x l) = Some x

tl : IList → Maybe IList
tl nil = None
tl (cons x l) = Some l

open import Agda.Builtin.Bool
isnil : IList → Bool
isnil nil = true
isnil (cons x l) = false
```
Note that Agda functions must be total, so we cannot fail to return something from `hd` or `tl` when the list is `nil`.
To handle this, we use a `Maybe` type, which lets us return a default value signaling that the function call failed.

## Using Dependent Types

Next, we'll encode the length of the list into the type.
Instead of declaring a `Set`, we will instead declare a `Nat → Set` to make it a dependent type.
Recall that this means that the client code has to provide a number in order to get a type:
```agda
data IVec : Nat → Set where
  vnil : IVec 0
  vcons : {n : Nat} → Nat → IVec n → IVec (suc n)
```
The curly braces after the `vcons` constructor tell us that the type of our constructor are a dependent function.
Moreover, because they are curly braces rather than parentheses, this tells us that the natural number argument is implicit, and should be inferred from the environment.
Here's how you construct a list:

```agda
somelist = vcons 5 vnil
```
Deducing the type of somelist, we get `IVec 1`, and if we evaluate `somelist` we get `vcons 5 vnil`.
Notice that we didn't write the `1` in the type of somelist, Agda deduced that for us.
We can then write head and tail functions again.
But now, we know that, if the length is not `0`, then we will not fail, and so we do not need to return a `Maybe` type any more:
```agda
vhd : {n : Nat} → IVec (suc n) → Nat
vhd {n} (vcons x v) = x

vtl : {n : Nat} → IVec (suc n) → IVec n
vtl {n} (vcons x v) = v

```
Note that we no longer need branches for the `vnil` case!
Agda is smart enough to figure out that those branches are impossible.

Let's try some operations:
- `C-c C-n vhd somelist` results in `5`
- `C-c C-n vtl somelist` results in `vnil`
- `C-c C-n vtl (vtl somelist)` results in a type error.
