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
Person* p = new Student();
p->aboutMe();
```

A: The result is **I am a person.**  
(1) Because the function is resolved in *compile-time*, which is also called *static binding*.  
(2) If you want to call student's **aboutMe()**, you need to use **virtual function**.  
```
class Person {
	...
public:
	virtual void aboutMe() { cout « "I am a person."; }
};

```

**注：將function定義為virtual, 就是將定義留給繼承他的class決定**

Q: what if we don't want to implement the class in parent class?  
A: Make the parent class as a **abstract class**, and define the function as a **pure virtual function**.  
```
class Person {
	...
public:
	virtual void aboutMe() { cout « "I am a person."; }
	virtual bool addCourse(string s) = 0;
};

class Student : public Person { 
public:
	void aboutMe() {cout << "I am a student. "}
	bool addCourse(string s) {
		cout << "addCourse " << s << endl;
		return true;
	}

};

int main() {
	Person * p = new Student();
	p->aboutMe(); // prints "I am a student."
	p->addCourse("history");
	delete p;
}
```
**注：將function定義為pure virtual function, 就是在後面加"= 0", 並使之成為 **abstract class** 之後就無法利用該parent class 來建立object了**


- Virtual Destructor

Q: Let's take a look at the naive solution, what's the problem?

```
class Person {
public:
	~Person() { cout << "Deleting a person" << endl; }
}

class Student : public Person {
public:
	~Student() {cout << "Deleting a student" << endl;}
}

int main() {
	Person* p = new Student();
	delete p; // print "Deleting a person"
}
```

A:  
(1) Since p is a **Person**, the destructor of **Person** is called.  But the memory for **Student** is not cleaned up.  
(2) To fix it, the destructor of **Person** needs to be **virtual**.

```
class Person {
public:
	virtual ~Person() { cout << "Deleting a person" << endl; }
}

class Student : public Person {
public:
	~Student() {cout << "Deleting a student" << endl;}
}

int main() {
	Person* p = new Student();
	delete p;
}

the result would be:  
Deleting a student  
Deleting a person
```


- Pointers and References

Q: What's the difference between them?  
A:  
(1) **Pointer**: holds the address of a variable, and can be used to perform any operation that can be directly done on the variable, ex: access and modify it. The size of pointer is 32bits/64bits (depending on the machine).  
(2) **Reference**: an alias for a pre-existing object, and it does not have memory of its own. 
(3) Pointer can be null, reference can't.  
(4) Pointer can be re-assign, reference can't.  








