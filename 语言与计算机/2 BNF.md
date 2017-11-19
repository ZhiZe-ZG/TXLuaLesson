# BNF

还是把正则表达式作为一个Lua的模块介绍(此分支无后续)
并列文件和IO(文件和IO后加编译原理,动态加载)
异常,调试,内存管理和工具
元表和元表的特性(介绍过后,此分支无后续)
小专题(时间获取,随机数生成),这些小工具全部在模块,这个Stage介绍.说明可以直接把别的语言的甚至是硬件的功能打包成模块.在介绍C语言之后会介绍.
最后介绍一个线程
弄清用户数据块什么用<https://www.cnblogs.com/pk-run/p/3622947.html>
<https://www.cnblogs.com/zsb517/p/6420885.html>
<http://bbs.csdn.net/topics/350261649>

Lua语言课的后继知识.

* 严格语法(BNF,BNF重讲Lua语法)
  * C语言
  * Python语言
* 

考虑BNF专门出个课程

lambda表达式放到函数式专题中

VSCode,emacs等也做专门介绍

介绍sgml,html,xml,markdown,tex

数据库等

<http://matt.might.net/articles/grammars-bnf-ebnf/>

太玄的超级精简版BNF TXBNF

Wiki上的BNF

常见的EBNF(允许可选项目和重复)

BNF实现
BNF表示Lambda表达式
BNF重讲Lua语法

精简版BNF

只用一种引号,加入对空字符串的定义.允许转义字符(文本中任何地方出现都是转义字符).

支持\n,\r,\t,\uxxxx,\UXXXXXXXX等写法

语法自描述

然后加语法扩展和其他形式的BNF

比如两种语法

比如循环

比如可选必选

比如加UTF字符,转义字符