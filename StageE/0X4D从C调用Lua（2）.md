# 0X4D 从C调用Lua（2）

## 前置知识

* 0X4C 从C调用Lua（1）

## 简介

这一期我们更进一步，讨论在C中加载Lua脚本的问题。同时讨论一下C和Lua交换数据的问题。

## 写一个Lua脚本

写一个名为“script.lua”的脚本。其内容为：

```lua
x=0
for i=1,#foo do
    x=x+foo[i]
end
return x
```

代码很简单，就是求表foo中所有成员的和然后返回这个和。但是foo却没有在脚本中声明，需要用C程序传入。

## C代码

我们创建一个名为“calllua2.c”的文件，然后写入如下代码：

```C
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <stdlib.h>
#include <stdio.h>

int main(void)
{
    int result, i;
    double sum;
    lua_State *L;

    L = luaL_newstate(); //create virtual machine
    luaL_openlibs(L); // Load Lua libraries

    luaL_loadfile(L, "script.lua"); //load lua script

    lua_newtable(L);    // We will pass a table

    // add elements to the table
    for (i = 1; i <= 5; i++) {
        lua_pushnumber(L, i);   // Push the table index
        lua_pushnumber(L, i*2); // Push the cell value
        lua_rawset(L, -3);      // Stores the pair in the table
    }

    lua_setglobal(L, "foo"); // lua get the table

    lua_pcall(L, 0, LUA_MULTRET, 0); //run script

    sum = lua_tonumber(L, -1); //Get the returned value at the top of the stack (index -1)

    printf("Script returned: %.0f\n", sum);

    lua_pop(L, 1);  /* Take the returned value out of the stack */

    lua_close(L); //close virtual machine.

    return 0;
}
```

前边创建虚拟机等工作和上次是一样的。luaL_loadfile和上次的luaL_loadbuffer类似。只不过这次我们加载的是一个文件，而不是一个字符串。

lua_newtable往指定虚拟机的栈里压入一个新建的lua表。在压入之前L的栈是空栈，压入之后栈底有一个表。

如果不执行那个for循环，直接调用lua_setglobal(L,"foo")那么虚拟机L就会从其栈中弹出一个元素然后将之设置为虚拟机中的一个全局变量，名为“foo”。如果没有执行for循环，栈中只有lua_newtable创建的空表，这个空表就会被命名为“foo”。

如果我们要传递的是字符串，数字等变量，直接压栈（用lua_pushnumber等），然后设置为变量（用lua_setglobal等）即可。但是这里传递一个空表是没啥意义的，所以我们在把这个空表弹栈之前给表设置一些元素。这就是for循环中的内容。

我们分析一个循环来说明。首先lua_pushnumber(L,i)会把数字i当作lua的number类型压入虚拟机L的栈中。此时栈中一共两个元素，栈底是刚刚的空表，栈顶是数字1。然后再次压栈lua_pushnumber(L,i*2)，栈顶变成了2。lua_rawset会进行两次弹栈，把第一次弹栈的值作为value，把第二次弹栈的值作为key，然后把这个键值对赋予指定的表。比如这里的lua_rawset(L,-3)。L是要进行操作的虚拟机 。lua_rawset的参数“-3”表示往栈中从上往下数第三个元素（弹栈之前它是从上往下数第三个）——就是我们刚刚压入的空表。这个空表就是目标表。第一次弹栈得到2，第二次弹栈得到1。然后给表中设置键值对（相当于lua中的“foo[1]=2”）。完成这个设置之后，栈中又仅剩一个表。但是这个表不再是空表，而是有了一个键值对。循环五次，就有了五个键值对。

表的内容 设置完之后 用lua_setglobal弹栈，并把这个表命名为“foo”。这样栈成了空栈。

接下来lua_pcall(L, 0, LUA_MULTRET, 0)表示执行我们刚刚加载到虚拟机中的脚本。其中的LUA_MULTRET是个Lua定义的宏。脚本执行完之后，虚拟机会把返回值压入栈中。

之前设置表的时候，我们都是从C语言这边压栈，从Lua虚拟机弹栈。而虚拟机返回值的时候是虚拟机压栈。我们要获得返回值就要从C语言这边弹栈。lua_pop(L,1)就起到弹栈的作用。但是由于C语言没有动态类型所以这个函数被设置为仅仅能弹出元素，却不会返回元素。我们要从C这边读取栈中元素我们需要另一些函数。（也就是说Lua的实现中把从C这边读取栈中值和弹栈分为了两类函数。）

要从C这边读取栈中一个数字类型值，我们使用lua_tonumber这个函数只读取但是不弹栈。它的第一个参数是要读取的虚拟机，第二个参数是要读取的元素的索引。

读取并且输出结果之后，依旧是关闭虚拟机。

## 编译

编译命令和上一期介绍的一样。只不过便宜的文件名换一下。

## 后续推荐

* 0X4E 从Lua调用C
