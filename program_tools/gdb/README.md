### gdb tools

- compile the code with "-g" parameter
```
$ g++ main.cpp -g -o main.out -std=c++11
$ gdb main.out
```

- Execute the program
```
$ start <--- start running the code
$ list  <--- shows the source code
$ step  <--- execute the first command
$ print <variable name>  <---print the variable name, or you can simply use "p <variable name>"
$ next  <--- neglect the subroutine, just show the main program
```