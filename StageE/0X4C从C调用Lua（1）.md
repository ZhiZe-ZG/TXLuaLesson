# 0X4C 从C调用Lua（1）

## 前置知识

* 0X4B 与C交互

## 简介

这一期我们来演示一个从C调用Lua的实例。我们写一个C程序，在其中启动Lua虚拟机，并且让虚拟机执行一条Lua语句。

我将把源码拆开讲解。

## 头文件和常量

首先创建一个文本文件叫做“calllua1.c”。然后在其中写上头文件包含。

首先是会用到的C标准库。

```C
#include<string.h>
```

然后是可能用到的Lua头文件。

```C
#include<lua.h>
#include<lualib.h>
#include<lauxlib.h>
```

我们计划让Lua输出一句话。先把这个Lua语句作为字符串常量声明。

```C
const char* comm="print('hello my lua')";
```

## 主函数

函数头主体。

```C
int main(){
    return 0;
}
```

填入我们需要的命令后得到：

```C
int main(){
    lua_State* L; //declare a point
    L=luaL_newstate(); //create virtual machine.
    luaL_openlibs(L); //open lua standard lib.
    luaL_loadbuffer(L,comm,strlen(comm),"line"); //compile command.
    lua_pcall(L,0,0,0); //excute command.
    lua_close(L); //close virtual machine.
    return 0;
}
```

L是一个指向Lua虚拟机的指针变量。通过luaL_newstate()创建一个新虚拟机并且赋值给L。

luaL_openlibs会在虚拟机L中导入所有的Lua标准库。（相当于在虚拟机中把所有标准库require一遍。）

luaL_loadbuffer的作用是往一个虚拟机中加载一个字符串（这个字符串的内容是一个Lua语句）。其中L是要加载命令的虚拟机，comm是要加载的命令，strlen(comm)是要加载的命令的长度。这个命令加载到虚拟机中后会作为一个代码块（chunk），字符串"line"是这个代码块的名字（在这个代码块debug到错误的时候会显示这个名字）。运行这一行之后相当于把我们要执行的命令输入了虚拟机（但是还没有开始执行）。

lua_pcall的作用是调用虚拟机的中的函数。但是我们这里的写法“lua_pcall(L,0,0,0)”实际上就是在虚拟机L中执行我们刚刚载入的命令。

lua_close的作用是关闭指定虚拟机。

## 编译

使用命令

```shell
gcc calllua1.c -o test1 -llua -lm -ldl
```

进行编译。

其中“-o test1”表示把编译结果命名为“test1”。

后边的三个参数分别用于说明链接库。“-llua”是链接Lua库，“-lm”是链接数学库（lua的头文件中引用了数学库），“-ldl”据说是为了解析未定义的"dlopen"等引用（但是“-ldl”并不是所有的发行版上都要用）。

如果使用上边的命令提示头文件或者库找不到，就试试这个：

```shell
gcc calllua1.c -o test1 -I /usr/local/include -L /usr/local/lib -llua -lm -ldl
```

其中“-I”表示指定头文件目录。后跟的“/usr/local/include”是头文件目录。“-L”表示指定库目录，后跟的“/usr/local/lib”是库目录。

## 参考资料

除了官方的文档和在线电子书*Programming in Lua*，我还参考了以下资料：

<http://lua-users.org/wiki/SimpleLuaApiExample>
<http://www.jb51.net/article/65224.htm>

## 后续推荐

* 0X4D 从C调用Lua（2）
