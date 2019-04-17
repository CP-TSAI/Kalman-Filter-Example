## cpp Knowledge

- reference: https://www.learncpp.com/

---

#### 6.9 Dynamic memory allocation with "new" and "delete"

C++ supports three basic types of memory allocation:  

(1) **Static memory allocation** happens for static and global variables. 
Memory for these types of variables is allocated once when your program is run and persists throughout the life of your program.

(2) **Automatic memory allocation** happens for function parameters and local variables. Memory for these types of variables is allocated when the relevant block is entered, and freed when the block is exited, as many times as necessary.


(3) **Dynamic memory allocation** is the topic of this article.
Both static and automatic allocation have two things in common:  
	- The size of the variable / array must be known at compile time.
	- Memory allocation and deallocation happens automatically (when the variable is instantiated / destroyed).

Most of the time, this is just fine. However, you will come across situations where one or both of these constraints cause problems, **usually when dealing with external (user or file) input**.

For example, we may want to use a string to hold someone’s name, but we do not know how long their name is until they enter it. Or we may want to read in a number of records from disk, but we don’t know in advance how many records there are. Or we may be creating a game, with a variable number of monsters (that changes over time as some monsters die and new ones are spawned) trying to kill the player.

If we have to declare the size of everything at compile time, the best we can do is try to make a guess the maximum size of variables we’ll need and hope that’s enough:

```
char name[25]; // let's hope their name is less than 25 chars!
Record record[500]; // let's hope there are less than 500 records!
Monster monster[40]; // 40 monsters maximum
Polygon rendering[30000]; // this 3d rendering better not have more than 30,000 polygons!
```

This is a poor solution for at least four reasons:

First, it leads to wasted memory if the variables aren’t actually used. For example, if we allocate 25 chars for every name, but names on average are only 12 chars long, we’re using over twice what we really need. Or consider the rendering array above: if a rendering only uses 10,000 polygons, we have 20,000 Polygons worth of memory not being used!

Second, how do we tell which bits of memory are actually used? For strings, it’s easy: a string that starts with a \0 is clearly not being used. But what about monster[24]? Is it alive or dead right now? That necessitates having some way to tell active from inactive items, which adds complexity and can use up additional memory.

Third, most normal variables (including fixed arrays) are allocated in a portion of memory called the **stack**. The amount of stack memory for a program is generally quite small -- Visual Studio defaults the stack size to 1MB. If you exceed this number, stack overflow will result, and the operating system will probably close down the program.

---

On Visual Studio, you can see this happen when running this program:
```
int main()
{
    int array[1000000]; // allocate 1 million integers (probably 4MB of memory)
}
```


Being limited to just 1MB of memory would be problematic for many programs, especially those that deal with graphics.

Fourth, and most importantly, it can lead to artificial limitations and/or array overflows. What happens when the user tries to read in 600 records from disk, but we’ve only allocated memory for a maximum of 500 records? Either we have to give the user an error, only read the 500 records, or (in the worst case where we don’t handle this case at all) overflow the record array and watch something bad happen.

Fortunately, these problems are easily addressed via dynamic memory allocation. **Dynamic memory allocation** is a way for running programs to request memory from the operating system when needed. This memory does not come from the program’s limited stack memory -- instead, it is allocated from a much larger pool of memory managed by the operating system called the **heap**. On modern machines, the heap can be gigabytes in size.

---

**Dynamically allocating single variables**

To allocate a single variable dynamically, we use the scalar (non-array) form of the new operator:

```
new int; // dynamically allocate an integer (and discard the result)
```

In the above case, we’re requesting an integer’s worth of memory from the operating system. The new operator creates the object using that memory, and then returns a pointer containing the address of the memory that has been allocated.

Most often, we’ll assign the return value to our own pointer variable so we can access the allocated memory later.

```
int *ptr = new int; // dynamically allocate an integer and assign the address to ptr so we can access it later
```

We can then dereference the pointer to access the memory:

```
*ptr = 7; // assign value of 7 to allocated memory
```

If it wasn’t before, it should now be clear at least one case in which pointers are useful. Without a pointer to hold the address of the memory that was just allocated, we’d have no way to access the memory that was just allocated for us!

---

**How does dynamic memory allocation work?**

Your computer has memory (probably lots of it) that is available for applications to use. When you run an application, your operating system loads the application into some of that memory. This memory used by your application is divided into different areas, each of which serves a different purpose. One area contains your code. Another area is used for normal operations (keeping track of which functions were called, creating and destroying global and local variables, etc…). We’ll talk more about those later. However, much of the memory available just sits there, waiting to be handed out to programs that request it.

When you dynamically allocate memory, you’re asking the operating system to reserve some of that memory for your program’s use. If it can fulfill this request, it will return the address of that memory to your application. From that point forward, your application can use this memory as it wishes. When your application is done with the memory, it can return the memory back to the operating system to be given to another program.

Unlike static or automatic memory, the program itself is responsible for requesting and disposing of dynamically allocated memory.

---

**Initializing a dynamically allocated variable**

When you dynamically allocate a variable, you can also initialize it via "direct initialization" or "uniform initialization" (in C++11):

```
int *ptr1 = new int (5); // use direct initialization
int *ptr2 = new int { 6 }; // use uniform initialization
```

---

**Deleting single variables**

When we are done with a dynamically allocated variable, we need to explicitly tell C++ to free the memory for reuse. For single variables, this is done via the scalar (non-array) form of the delete operator:

```
// assume ptr has previously been allocated with operator new
delete ptr; // return the memory pointed to by ptr to the operating system
ptr = 0; // set ptr to be a null pointer (use nullptr instead of 0 in C++11)
```

---

**What does it mean to delete memory?**

The delete operator does not actually delete anything. It simply returns the memory being pointed to back to the operating system. The operating system is then free to reassign that memory to another application (or to this application again later).

Although it looks like we’re deleting a variable, this is not the case! The pointer variable still has the same scope as before, and can be assigned a new value just like any other variable.

Note that deleting a pointer that is not pointing to dynamically allocated memory may cause bad things to happen.

---

**Dangling pointers**

C++ does not make any guarantees about what will happen to the contents of deallocated memory, or to the value of the pointer being deleted. In most cases, the memory returned to the operating system will contain the same values it had before it was returned, and the pointer will be left pointing to the now deallocated memory.

**A pointer that is pointing to deallocated memory is called a dangling pointer**. Dereferencing or deleting a dangling pointer will lead to undefined behavior. Consider the following program:

```
#include <iostream>
 
int main()
{
    int *ptr = new int; // dynamically allocate an integer
    *ptr = 7; // put a value in that memory location
 
    delete ptr; // return the memory to the operating system.  ptr is now a dangling pointer.
 
    std::cout << *ptr; // Dereferencing a dangling pointer will cause undefined behavior
    delete ptr; // trying to deallocate the memory again will also lead to undefined behavior.
 
    return 0;
}
```

In the above program, the value of 7 that was previously assigned to the allocated memory will probably still be there, but it’s possible that the value at that memory address could have changed. It’s also possible the memory could be allocated to another application (or for the operating system’s own usage), and trying to access that memory will cause the operating system to shut the program down.

Deallocating memory may create multiple dangling pointers. Consider the following example:

```
#include <iostream>
 
int main()
{
    int *ptr = new int; // dynamically allocate an integer
    int *otherPtr = ptr; // otherPtr is now pointed at that same memory location
 
    delete ptr; // return the memory to the operating system.  ptr and otherPtr are now dangling pointers.
    ptr = 0; // ptr is now a nullptr
 
    // however, otherPtr is still a dangling pointer!
 
    return 0;
}
```

There are a few best practices that can help here.

First, try to avoid having multiple pointers point at the same piece of dynamic memory. If this is not possible, be clear about which pointer “owns” the memory (and is responsible for deleting it) and which are just accessing it.

Second, when you delete a pointer, if that pointer is not going out of scope immediately afterward, set the pointer to 0 (or nullptr in C++11). We’ll talk more about null pointers, and why they are useful in a bit.

**Rule: Set deleted pointers to 0 (or nullptr in C++11) unless they are going out of scope immediately afterward.**

---

**Operator new can fail**

When requesting memory from the operating system, in rare circumstances, the operating system may not have any memory to grant the request with.

By default, if new fails, a bad_alloc exception is thrown. If this exception isn’t properly handled (and it won’t be, since we haven’t covered exceptions or exception handling yet), the program will simply terminate (crash) with an unhandled exception error.

In many cases, having new throw an exception (or having your program crash) is undesirable, so there’s an alternate form of new that can be used instead to tell new to return a null pointer if memory can’t be allocated. This is done by adding the constant std::nothrow between the new keyword and the allocation type:

```
int *value = new (std::nothrow) int; // value will be set to a null pointer if the integer allocation fails
```

In the above example, if new fails to allocate memory, it will return a null pointer instead of the address of the allocated memory.

Note that if you then attempt to dereference this memory, undefined behavior will result (most likely, your program will crash). Consequently, the best practice is to check all memory requests to ensure they actually succeeded before using the allocated memory.

```
int *value = new (std::nothrow) int; // ask for an integer's worth of memory
if (!value) // handle case where new returned null
{
    // Do error handling here
    std::cout << "Could not allocate memory";
}
```

Because asking new for memory only fails rarely (and almost never in a dev environment), it’s common to forget to do this check!

---

**Null pointers and dynamic memory allocation**

Null pointers (pointers set to address 0 or nullptr) are particularly useful when dealing with dynamic memory allocation. In the context of dynamic memory allocation, a null pointer basically says “no memory has been allocated to this pointer”. This allows us to do things like conditionally allocate memory:

```
// If ptr isn't already allocated, allocate it
if (!ptr)
    ptr = new int;

```
Deleting a null pointer has no effect. Thus, there is no need for the following:

```
if (ptr)
    delete ptr;
```


Instead, you can just write:

```
delete ptr;
```
If ptr is non-null, the dynamically allocated variable will be deleted. If it is null, nothing will happen.


---

**Memory leaks**

Dynamically allocated memory effectively has no scope. That is, it stays allocated until it is explicitly deallocated or until the program ends (and the operating system cleans it up, assuming your operating system does that). However, the pointers used to hold dynamically allocated memory addresses follow the scoping rules of normal variables. This mismatch can create interesting problems.

Consider the following function:

```
void doSomething()
{
    int *ptr = new int;
}
```
This function allocates an integer dynamically, but never frees it using delete. Because pointers follow all of the same rules as normal variables, when the function ends, ptr will go out of scope. Because ptr is the only variable holding the address of the dynamically allocated integer, when ptr is destroyed there are no more references to the dynamically allocated memory. This means the program has now “lost” the address of the dynamically allocated memory. As a result, this dynamically allocated integer can not be deleted.

This is called a **memory leak**. Memory leaks happen when your program loses the address of some bit of dynamically allocated memory before giving it back to the operating system. When this happens, your program can’t delete the dynamically allocated memory, because it no longer knows where it is. The operating system also can’t use this memory, because that memory is considered to be still in use by your program.

Memory leaks eat up free memory while the program is running, making less memory available not only to this program, but to other programs as well. Programs with severe memory leak problems can eat all the available memory, causing the entire machine to run slowly or even crash. Only after your program terminates is the operating system able to clean up and “reclaim” all leaked memory.

Although memory leaks can result from a pointer going out of scope, there are other ways that memory leaks can result. For example, a memory leak can occur if a pointer holding the address of the dynamically allocated memory is assigned another value:

```
int value = 5;
int *ptr = new int; // allocate memory
ptr = &value; // old address lost, memory leak results
```
This can be fixed by deleting the pointer before reassigning it:

```
int value = 5;
int *ptr = new int; // allocate memory
delete ptr; // return memory back to operating system
ptr = &value; // reassign pointer to address of value
```

Relatedly, it is also possible to get a memory leak via double-allocation:

```
int *ptr = new int;
ptr = new int; // old address lost, memory leak results
```
The address returned from the second allocation overwrites the address of the first allocation. Consequently, the first allocation becomes a memory leak!

Similarly, this can be avoided by ensuring you delete the pointer before reassigning.

---
Conclusion

Operators "new" and "delete" allow us to dynamically allocate single variables for our programs.

Dynamically allocated memory has no scope and will stay allocated until you deallocate it or the program terminates.

Be careful not to dereference dangling or null pointers.

In the next lesson, we’ll take a look at using new and delete to allocate and delete arrays.


---

#### 11.1 Introduction to inheritance

In the last chapter, we discussed object composition, where complex classes are constructed from simpler classes and types. Object composition is perfect for building new objects that have a “has-a” relationship with their parts. However, object composition is just one of the two major ways that C++ lets you construct complex classes. The second way is through inheritance, which models an “is-a” relationship between two objects.

Unlike object composition, which involves creating new objects by combining and connecting other objects, inheritance involves creating new objects by directly acquiring the attributes and behaviors of other objects and then extending or specializing them. Like object composition, inheritance is everywhere in real life. When you were conceived, you inherited your parents genes, and acquired physical attributes from both of them -- but then you added your own personality on top. Technological products (computers, cell phones, etc…) inherit features from their predecessors (often used for backwards compatibility). For example, the Intel Pentium processor inherited many of the features defined by the Intel 486 processor, which itself inherited features from earlier processors. C++ inherited many features from C, the language upon which it is based, and C inherited many of its features from the programming languages that came before it.

Consider apples and bananas. Although apples and bananas are different fruits, both have in common that they are fruits. And because apples and bananas are fruits, simple logic tells us that anything that is true of fruits is also true of apples and bananas. For example, all fruits have a name, a color, and a size. Therefore, apples and bananas also have a name, a color, and a size. We can say that apples and bananas inherit (acquire) these all of the properties of fruit because they are fruit. We also know that fruit undergoes a ripening process, by which it becomes edible. Because apples and bananas are fruit, we also know that apples and bananas will inherit the behavior of ripening.

Put into a diagram, the relationship between apples, bananas, and fruit might look something like this: [plot]
This diagram defines a hierarchy.

---

**Hierarchies**

A hierarchy is a diagram that shows how various objects are related. Most hierarchies either show a progression over time (386 -> 486 -> Pentium), or categorize things in a way that moves from general to specific (fruit -> apple -> red delicious). If you’ve ever taken biology, the famous domain, kingdom, phylum, class, order, family, genus, and species ordering defines a hierarchy (from general to specific).

Here’s another example of a hierarchy: a square is a rectangle, which is a quadrilateral, which is a shape. A right triangle is a triangle, which is also a shape. Put into a hierarchy diagram, that would look like this: [plot]

This diagram goes from general (top) to specific (bottom), with each item in the hierarchy inheriting the properties and behaviors of the item above it.

---

**A look ahead**

In this chapter, we’ll explore the basics of how inheritance works in C++.

Next chapter, we’ll explore how inheritance enables polymorphism (one of object-oriented programming’s big buzzwords) through virtual functions.

As we progress, we’ll also talk about inheritance’s key benefits, as well as some of the downsides.


---

#### 12.5 The virtual table

- To implement virtual functions, C++ uses a special form of late binding known as the **"virtual table"**. 
- **The virtual table is a lookup table of functions used to resolve function calls in a dynamic/late binding manner.** 

The virtual table sometimes goes by other names, such as **“vtable”**, “virtual function table”, “virtual method table”, or “dispatch table”.

Because knowing how the virtual table works is not necessary to use virtual functions, this section can be considered optional reading.

The virtual table is actually quite simple, though it’s a little complex to describe in words. First, every class that uses virtual functions (or is derived from a class that uses virtual functions) is given its own virtual table. This table is simply a static array that the compiler sets up at compile time. A virtual table contains one entry for each virtual function that can be called by objects of the class. Each entry in this table is simply a function pointer that points to the most-derived function accessible by that class.

Second, the compiler also adds a hidden pointer to the base class, which we will call vptr. 
vptr is set (automatically) when a class instance is created so that it points to the virtual table for that class. 
Unlike the 'this' pointer, which is actually a function parameter used by the compiler to resolve self-references, 
vptr is a real pointer. 
Consequently, it makes each class object allocated bigger by the size of one pointer. It also means that vptr is inherited by derived classes, which is important.

By now, you’re probably confused as to how these things all fit together, so let’s take a look at a simple example:

```
class Base
{
public:
    virtual void function1() {};
    virtual void function2() {};
};
 
class D1: public Base
{
public:
    virtual void function1() {};
};
 
class D2: public Base
{
public:
    virtual void function2() {};
};
```

Because there are 3 classes here, the compiler will set up 3 virtual tables: one for Base, one for D1, and one for D2.

The compiler also adds a hidden pointer to the most base class that uses virtual functions. Although the compiler does this automatically, we’ll put it in the next example just to show where it’s added:

```
class Base
{
public:
    FunctionPointer vptr;
    virtual void function1() {};
    virtual void function2() {};
};
 
class D1: public Base
{
public:
    virtual void function1() {};
};
 
class D2: public Base
{
public:
    virtual void function2() {};
};
```


When a class object is created, vptr is set to point to the virtual table for that class. For example, when a object of type Base is created, vptr is set to point to the virtual table for Base. When objects of type D1 or D2 are constructed, vptr is set to point to the virtual table for D1 or D2 respectively.

Now, let’s talk about how these virtual tables are filled out. Because there are only two virtual functions here, each virtual table will have two entries (one for function1(), and one for function2()). Remember that when these virtual tables are filled out, each entry is filled out with the most-derived function an object of that class type can call.

The virtual table for Base objects is simple. An object of type Base can only access the members of Base. Base has no access to D1 or D2 functions. Consequently, the entry for function1 points to Base::function1(), and the entry for function2 points to Base::function2().

The virtual table for D1 is slightly more complex. An object of type D1 can access members of both D1 and Base. However, D1 has overridden function1(), making D1::function1() more derived than Base::function1(). Consequently, the entry for function1 points to D1::function1(). D1 hasn’t overridden function2(), so the entry for function2 will point to Base::function2().

The virtual table for D2 is similar to D1, except the entry for function1 points to Base::function1(), and the entry for function2 points to D2::function2().

Here’s a picture of this graphically: [plot]

Although this diagram is kind of crazy looking, it’s really quite simple: the vptr in each class points to the virtual table for that class. The entries in the virtual table point to the most-derived version of the function objects of that class are allowed to call.

So consider what happens when we create an object of type D1:

int main()
{
    D1 d1;
}
Because d1 is a D1 object, d1 has its vptr set to the D1 virtual table.

Now, let’s set a base pointer to D1:

```
int main()
{
    D1 d1;
    Base *dPtr = &d1;
}
```
Note that because dPtr is a base pointer, it only points to the Base portion of d1. However, also note that vptr is in the Base portion of the class, so dPtr has access to this pointer. Finally, note that dPtr->vptr points to the D1 virtual table! Consequently, even though dPtr is of type Base, it still has access to D1’s virtual table (through vptr).

So what happens when we try to call dPtr->function1()?

```
int main()
{
    D1 d1;
    Base *dPtr = &d1;
    dPtr->function1();
}
```
First, the program recognizes that function1() is a virtual function. Second, the program uses dPtr->vptr to get to D1’s virtual table. Third, it looks up which version of function1() to call in D1’s virtual table. This has been set to D1::function1(). Therefore, dPtr->function1() resolves to D1::function1()!

Now, you might be saying, “But what if dPtr really pointed to a Base object instead of a D1 object. Would it still call D1::function1()?”. The answer is no.


```
int main()
{
    Base b;
    Base *bPtr = &b;
    bPtr->function1();
}
```

In this case, when b is created, vptr points to Base’s virtual table, not D1’s virtual table. Consequently, bPtr->vptr will also be pointing to Base’s virtual table. Base’s virtual table entry for function1() points to Base::function1(). Thus, bPtr->function1() resolves to Base::function1(), which is the most-derived version of function1() that a Base object should be able to call.

By using these tables, the compiler and program are able to ensure function calls resolve to the appropriate virtual function, even if you’re only using a pointer or reference to a base class!

Calling a virtual function is slower than calling a non-virtual function for a couple of reasons: First, we have to use the vptr to get to the appropriate virtual table. Second, we have to index the virtual table to find the correct function to call. Only then can we call the function. As a result, we have to do 3 operations to find the function to call, as opposed to 2 operations for a normal indirect function call, or one operation for a direct function call. However, with modern computers, this added time is usually fairly insignificant.

Also as a reminder, any class that uses virtual functions has a vptr, and thus each object of that class will be bigger by one pointer. Virtual functions are powerful, but they do have a performance cost.









