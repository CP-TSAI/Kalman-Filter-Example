## How to use cmake to make your life easier

- Standard Method:

```
cpp-boilerplate

$ git clone --recursive https://github.com/dpiet/cpp-boilerplate.git
$ cd <repository>
$ mkdir build
$ cd build
$ cmake ..
$ make

Run tests:
$ ./test/cpp-test

Run program:
$ ./app/shell-app
```

---

最簡單用法 (以下兩檔案都放在同個資料夾下)

*main.cpp*

```c++
#include <iostream>
using namespace std;

int main() {
    cout << "hellooooo" << endl;
    return 0;
}
```

*CMakeLists.txt*

```
cmake_minimum_required(VERSION 3.0)

set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

project(sample)

add_executable(
    sample          # <===== 這是執行檔名稱
    main.cpp        # <===== 這是原始檔
)
```


放完之後，
- $ cmake .     (產生 make file 以及一些相關檔案)
- $ make  (編譯)
- $ ./sample    (執行)


---


承上，直接 
$ cmake . 
會讓所有檔案都產生在同個資料夾下，會超級亂。
好一點的方法是，

```
$ mkdir build 
$ cd build
$ cmake ..
$ make
$ ./sample
```
如此編譯, 執行相關的檔案全都會被放在 build 資料夾下。


注：
要來科普一下， cmake .. 到底在幹嘛
* 首先 cmake 是 makefile 產生器，
* 當執行 cmake [path], 他會去找 [path] 底下的 CMakeLists.txt 並根據他的內容進行編譯，
* 產生的檔案會在當前的 file 當中
* 如果是建立一個空 build 檔案做編譯，這招叫做 “out-of-source build”, 可以把產生的檔案跟原始檔分開並很輕鬆地清除。
* 而且，這招讓你可以有很多不同的編譯結果，你可以對同個原始檔測試不同版本的 gcc, 或 options, ...

---


好，再來更麻煩一點的玩法，
假設現在有 src file （放 main.cpp ）, 也有新定義的物件在 include file 內，CMakeLists 該怎麼做?

先看一下檔案結構 (其實就是定義最上層的CMake, 讓他去call 其他 CMake, 編譯的話還是在 build 裡面編譯)

* sample
    * build
    * CMakeLists.txt
    * include
        * animal.h
    * src
        * CMakeLists.txt
        * main.cpp


(上層)
*CMakeLists.txt*
```
cmake_minimum_required(VERSION 3.0)
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
project(sample)
add_subdirectory(src)
```


(下層)
*CMakeLists.txt*
```
add_executable(
    shell
    main.cpp
)

include_directories(
    ${CMAKE_SOURCE_DIR}/include
)
```


*animal.h*
```c++	
#ifndef INCLUDE_ANIMAL_H_
#define INCLUDE_ANIMAL_H_

#include <iostream>
#include <string>

class animal {
private:
    std::string sound; 
public:
    animal(){ sound = "wwwww"; }
    void make_sound() {
        std::cout << sound << std::endl;
    }
};
#endif
```


*main.cpp*
```c++
#include <iostream>
#include <animal.h>
using namespace std;

int main() {
    animal animal_object;
    animal_object.make_sound();
    return 0;
}
```

---

承上，再來把實作分開   開一個新的 animal.cpp 在 src 資料夾裡
(主要就是改下層的 CMakeLists.txt)

* sample
    * build
    * CMakeLists.txt
    * include
        * animal.h
    * src
        * CMakeLists.txt
        * main.cpp
        * animal.cpp


*CMakeLists.txt*
```
add_executable(
    shell
    main.cpp
    animal.cpp
)

include_directories(
    ${CMAKE_SOURCE_DIR}/include
)
```


*animal.h*   <==== 把實作隱藏起來，純定義
```c++
#ifndef INCLUDE_ANIMAL_H_
#define INCLUDE_ANIMAL_H_

#include <iostream>
#include <string>

class animal {
private:
    std::string sound; 
public:
    animal(){ sound = "wwwww"; }
    void make_sound();
    void make_sound_several_time(int);
};
#endif
```


*animal.cpp*  <==== 實作在這邊
```c++
#include <animal.h>

void animal::make_sound() {
    std::cout << sound << std::endl;
}
void animal::make_sound_several_time(int times) {
    for(int i = 0; i < times; i++) {
        std::cout << sound << std::endl;
    }
}
```


*main.cpp*
```c++
#include <iostream>
#include <animal.h>
using namespace std;

int main() {
    animal animal_object;
    animal_object.make_sound();
    animal_object.make_sound_several_time(5);
    return 0;
}
```


---

<使用庫>

當想要加入沒有 `main()`  的 cpp file 時，可以使用`庫`。

ex: *libHelloSLAM.cpp*
```c++
#include <iostream>
using namespace std;
void printHello() {
	cout << "Hello" << endl;
}
```

可以使用 
```
add_library(hello libHelloSLAM.cpp)
```

如此就會生成一個 `libhello.a` 的文件。就是我們要的`庫`。

在linux 中，`庫`分為兩種，

- 靜態庫 (`.a`做為結尾)

- 共享庫 (`.so`作為結尾)

差別在於`靜態庫每次被調用都會生成一個副本，而共享庫則只有一個副本，更省空間`。

如果想生成`共享庫`而非`靜態庫`，可以使用 
```
add_library(hello_shared SHARED libHelloSLAM.cpp)
```

就會生成 `libhello_shared.so`


---

要調用`庫`, 只要`頭文件` 及 `庫文件` 即可。

ex: **頭文件** 
```c++
#ifndef LIBHELLOSLAM_H_
#define LIBHELLOSLAM_H_

void printHello();

#endif
```

**庫文件**

ex: *libHelloSLAM.cpp*
```c++
#include <iostream>
using namespace std;
void printHello() {
	cout << "Hello" << endl;
}
```

調用函式

```c++
#include "libHelloSLAM.h"

// 使用 libHelloSLAM.h 中的 printHello() 函数
int main( int argc, char** argv )
{
    printHello();
    return 0;
}
```

CMakeLists

```
# 声明要求的 cmake 最低版本
cmake_minimum_required( VERSION 2.8 )

# 声明一个 cmake 工程
project( HelloSLAM )

# 设置编译模式
set( CMAKE_BUILD_TYPE "Debug" )

# 添加一个可执行程序
# 语法：add_executable( 程序名 源代码文件 ）
add_executable( helloSLAM helloSLAM.cpp )

# 添加一个库
add_library( hello libHelloSLAM.cpp )
# 共享库
add_library( hello_shared SHARED libHelloSLAM.cpp )

add_executable( useHello useHello.cpp )
# 将库文件链接到可执行程序上
target_link_libraries( useHello hello_shared )
```




---

<後記> 不用CMake, 直接用Makefile



其實也可以省略cmake, 自己手動建立自己的 Makefile,
再來就是直接
```
$ make
$ make run
$ make clean
```

Example: 
```
# DSA_HW2
#g++ main.cpp -o main.out

all:
    g++ -O3 -std=c++11 main.cpp -o main.out
run:
    ./main.out
clean:
    rm *.o main.out

#Source: main.o
#    g++ -O3 main.cpp -o main.out
#Source.o: main.cpp
#    g++ main.cpp -c
#run: main
#    ./main.out
#clean: main.o
#    rm main.o
```


