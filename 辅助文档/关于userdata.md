# 关于userdata

Lua中的userdata类型，是为了和其他语言交互准备的。例如和C通过虚拟栈交互数据。如果C要压入栈的数据不能用其他几种Lua的数据类型表示，就要创建为一个Lua中的userdata。

一些参考资料：

<https://www.cnblogs.com/pk-run/p/3622947.html>
<https://www.cnblogs.com/zsb517/p/6420885.html>
<http://bbs.csdn.net/topics/350261649>
<https://www.lua.org/pil/28.1.html>