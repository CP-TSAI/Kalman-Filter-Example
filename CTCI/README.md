# CTCI

### Ch12 C/C++

- Class and Inheritance

```
include <iostream>
using namespace std;

#define NAMESIZE 50//Defines a macro

class Person {
	int id; // all members are private by default 
	char name[NAME_SIZE];

public:
	void aboutMe() { cout « "I am a person."; }
};

class Student : public Person { 
public:
	void aboutMe() {cout << "I am a student. "}
};

int main() {
	Student * p = new Student();
	p->aboutMe(); // prints "I am a student."
	delete p; // Important! Make sure to delete allocated memory.
	return 0;
}
```

- Virtual Functions

Q: what if we change the above code to the following, what's the result?
```
Person * p = new Student();
p->aboutMe();
```

A: The result is **I am a person.**  
(1) Because the function is resolved in *compile-time*, which is also called *static binding*.  
(2) If you want to call student's **aboutMe()**, you need to use **virtual function**.  
```
class Person {
	...
public:
	**virtual** void aboutMe() { cout « "I am a person."; }
};

```

**注：將function定義為virtual, 就是將定義留給繼承他的class決定**

Q: what if we don't want to implement the class in parent class?  
A: Make the parent class as a **abstract class**, and define the function as a pure virtual function.  
```
class Person {
	...
public:
	virtual void aboutMe() { cout « "I am a person."; }
	<span style="color:blue">virtual bool addCourse(string s) = 0;</span>
};

class Student : public Person { 
public:
	void aboutMe() {cout << "I am a student. "}
};

int main() {
	Student * p = new Student();
	p->aboutMe(); // prints "I am a student."
	delete p; // Important! Make sure to delete allocated memory.
	return 0;
}

```





