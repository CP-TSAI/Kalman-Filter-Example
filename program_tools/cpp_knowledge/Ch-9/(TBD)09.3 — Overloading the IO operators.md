
## 9.3 — Overloading the I/O operators

For classes that have multiple member variables, printing each of the individual variables on the screen can get tiresome fast. For example, consider the following class:

```c++
class Point
{
private:
    double m_x, m_y, m_z;
 
public:
    Point(double x=0.0, double y=0.0, double z=0.0): m_x(x), m_y(y), m_z(z)
    {
    }
 
    double getX() { return m_x; }
    double getY() { return m_y; }
    double getZ() { return m_z; }
};
```

If you wanted to print an instance of this class to the screen, you’d have to do something like this:

```c++
Point point(5.0, 6.0, 7.0);
 
std::cout << "Point(" << point.getX() << ", " <<
    point.getY() << ", " <<
    point.getZ() << ")";
```

Of course, it makes more sense to do this as a reusable function. And in previous examples, you’ve seen us create print() functions that work like this:

```c++
class Point
{
private:
    double m_x, m_y, m_z;
 
public:
    Point(double x=0.0, double y=0.0, double z=0.0): m_x(x), m_y(y), m_z(z)
    {
    }
 
    double getX() { return m_x; }
    double getY() { return m_y; }
    double getZ() { return m_z; }
 
    void print()
    {
        std::cout << "Point(" << m_x << ", " << m_y << ", " << m_z << ")";
    }
};
```

While this is much better, it still has some downsides. Because print() returns void, it can’t be called in the middle of an output statement. Instead, you have to do this:

```c++
int main()
{
    Point point(5.0, 6.0, 7.0);
 
    std::cout << "My point is: ";
    point.print();
    std::cout << " in Cartesian space.\n";
}
```

It would be much easier if you could simply type:

```c++
Point point(5.0, 6.0, 7.0);
cout << "My point is: " << point << " in Cartesian space.\n";
```

and get the same result. There would be no breaking up output across multiple statements, and no having to remember what you named the print function.

Fortunately, by overloading the `<<` operator, you can!

---

**Overloading operator<<**

Overloading `operator<<` is similar to overloading operator+ (they are both binary operators), except that the parameter types are different.

Consider the expression std::cout << point. If the operator is <<, what are the operands? The left operand is the std::cout object, and the right operand is your Point class object. std::cout is actually an object of type std::ostream. Therefore, our overloaded function will look like this:


```c++
// std::ostream is the type for object std::cout
friend std::ostream& operator<< (std::ostream &out, const Point &point);
```

Implementation of `operator<<` for our Point class is fairly straightforward -- because C++ already knows how to output doubles using operator<<, and our members are all doubles, we can simply use operator<< to output the member variables of our Point. Here is the above Point class with the overloaded operator<<.


```c++
#include <iostream>
 
class Point
{
private:
    double m_x, m_y, m_z;
 
public:
    Point(double x=0.0, double y=0.0, double z=0.0): m_x(x), m_y(y), m_z(z)
    {
    }
 
    friend std::ostream& operator<< (std::ostream &out, const Point &point);
};
 
std::ostream& operator<< (std::ostream &out, const Point &point)
{
    // Since operator<< is a friend of the Point class, we can access Point's members directly.
    out << "Point(" << point.m_x << ", " << point.m_y << ", " << point.m_z << ")"; // actual output done here
 
    return out; // return std::ostream so we can chain calls to operator<<
}
 
int main()
{
    Point point1(2.0, 3.0, 4.0);
    std::cout << point1;
    return 0;
}
```


This is pretty straightforward -- note how similar our output line is to the line in the print() function we wrote previously. The most notable difference is that std::cout has become parameter out (which will be a reference to std::cout when the function is called).

The trickiest part here is the return type. With the arithmetic operators, we calculated and returned a single answer by value (because we were creating and returning a new result). However, if you try to return std::ostream by value, you’ll get a compiler error. This happens because std::ostream specifically disallows being copied.

