# 0X4E 从Lua调用C

这一次我们从Lua调用C。我们从Lua调用C的时候就要方便很多。只要按照Lua的要求把C打包成指定形式。然后编译为库。直接从Lua中require就可以使用了。

## 写个C库

创建一个C文件，名为“mylib.c”。然后写入如下代码：

```C
#include<lua.h>
#include<lualib.h>
#include<lauxlib.h>
#include<luaconf.h>

static int ladd(lua_State* L) {
    double x = luaL_checknumber(L, 1); //get parameter
    double y = luaL_checknumber(L, 2);
    double z;
    z=x+y;// do something
    lua_pushnumber(L, z); //return result to virtual machine
    return 1;
}

int luaopen_mylib(lua_State* L) {

    struct luaL_Reg funcs[] = {
        {"add", ladd},
        {NULL,  NULL}
    };

    luaL_newlib(L, funcs);
    return 1;
}
```

代码我们一会细讲。这里要明白ladd是最终被注册到库里的函数。luaopen_mylib是把ladd注册到库里的那个函数，但是它本身不是一个库函数。

## 编译

使用这个命令编译C语言写的库。

```shell
gcc mylib.c -o mylib.so -shared -fPIC
```

说明：

“so”是Linux下动态库文件的后缀。

“-shared”参数说明编译出来的是一个没有主函数的库。

“-fPIC”说明使用地址无关代码。“PIC”是Position Independent Code的缩写。具体到这里，不用这个参数可能无法正常编译。

编译库的时候同样可能出现头文件或者链接库路径错误。解决方法同之前两期所介绍的。

## 读取和应用

成功编译出库以后，我们就能在Lua虚拟机中直接调用这个库了。打开一个Lua交互式编程环境，如果库文件存放的路径正好是虚拟机运行路径那么尝试以下代码：

```lua
my=require('mylib')
print(my.add(4,2))
```

和调用lua脚本库类似。虚拟机会在一些路径下搜索可以调用的动态库。这些路径是由虚拟机的环境变量package.cpath确定的。如果虚拟机执行路径和库文件存放位置不同，注意检查这个环境变量。

## C代码解说

现在返回来解释一下一开始的C代码。

首先，所有能在Lua作为库函数调用的C函数都必须是这里边ladd函数的形式。被声明为static,以int为返回值，并且接收一个虚拟机作为参数。而它在虚拟机中实际的参数和返回值则通过栈来传递。

当Lua虚拟机调用函数ladd的时候，会创建一个新的虚拟栈。然后把调用这个函数时候的参数按顺序压入（例如这里我们调用“my.add(4,2)，先压入4，然后压入2”）。然后把控制权交给被调用的函数。

在ladd中通过luaL_checknumber来获取两个参数（只是获取，并不会弹栈）。经过计算后再用lua_pushnumber把给虚拟机的返回值压栈（要确保直到函数结束这个元素都在在栈顶）。

当ladd执行结束后，控制权交给虚拟机。虚拟机默认从栈顶取回一个元素作为函数返回值。然后销毁这个专为函数调用创建的虚拟栈。

至此为止库函数就定义好了。但是这还不够，我们还需要写一个函数在库初始化的时候逐个把库函数加载进去。luaopen_mylib就是起到这个作用。注意这个函数名里的“mylib”可以换成其他东西，但是一般要和你所写的库的名称保持一致。

在这里我们就进行了两步，完成库函数的注册。首先按照Lua的约定创建一个luaL_Reg类型的结构体数组。其中的每一个结构体代表一个库函数。例如“{"add",ladd}”表示把函数ladd进行注册。注册后ladd函数在Lua中的函数名为“add”。这个数组最后一定要以“{NULL,NULL}”作为结束。这个结构体数组就代表我们要注册的库。

最后调用luaL_newlib向指定虚拟机中注册我们的库。库的注册过程就结束了。

## 参考资料

除了官方的书籍和文档，我还参考了这篇文章。

<http://www.cnblogs.com/wolfred7464/p/5147675.html>