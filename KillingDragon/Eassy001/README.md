# 文字游戏

我们来玩一个游戏。别紧张，没有脚镣，也没有锯子。只需要纸和笔就行。如果你实在不想浪费纸，也可以像我一样用Lua中的字符串操作来玩。

> 为了让后续代码简洁一点，我默认使用了这些约定。
>
> ```lua
> gsub = string.gsub
> ```

游戏的规则很简单，在一串文字中查找替换，看看替换后结果是什么。

让我们先做一个简单的替换。

```lua
s = "我是酒石酸。这里是酒石酸的新视频。"
p = "酒石酸"
r = "太玄"
o = gsub(s, p, r)
print(o)
```

其中`s`是原字符串，`p`是要匹配的部分，匹配成功后把匹配到的部分替换为`r`的内容。替换结果保存到`o`中。这个例子很简单。最终输出的结果是

```tex
我是太玄。这里是太玄的新视频。
```

希望这个例子让你会想起了之前我介绍的关于Lua处理字符串的内容。现在热身结束了，我们进入正题。

## 真与假

现在我想把一段话中的`true`替换为`false`。这个很容易实现，直接调用`gsub`搜索替换就行了。

我又想把`false`替换为`true`，也很容易。但是我想把原文中的所有`true`换成`false`的同时把所有`false`换成`true`。该怎么做呢？实际上也不麻烦。我们先把所有`true`换成另一个单词，然后把所有`false`换成`true`。然后再把之前`true`变成的单词换成`false`。

```lua
function Not(s)
    m = '____'
    o = gsub(s, 'true', m)
    o = gsub(o, 'false', 'true')
    o = gsub(o, m, 'false')
    return o
end

print(Not('true is true and false is false.'))
```

> 如果原字符串中出现了`____`当然可能导致替换错误。不过我们这里不考虑这么多，我们只考虑原字符串中不会出现`_`的情况。

这段代码中的`Not`就实现了这个功能。

当我们需要同时替换多组字符的时候，自然需要约定多种像这里的`____`一样的中间符号。为了减少代码量。我干脆写一个通用的替换工具。

```lua
function Replace(s, L)
    local o = ''
    o = s
    for i,v in pairs(L) do
        o = gsub(o, i, '__'..i..'__') 
    end
    for i,v in pairs(L) do
        o = gsub(o, '__'..i..'__', v)
    end
    return o
end
```

有了这样的函数，我们只需要把替换规则当作一张表传入其中就可以了。例如：

```lua
s = 'true is true and false is false'
r1 = {}
r1['true']  = 'false'
r1['false'] = 'true'
print(Replace(s,r1))
```

## 与或非

仅仅是两个单词互换也太无聊了。我希望把规则弄得复杂一点。并不是全部的`true`都被替换为`false`，同理也不是所有`false`被替换为`true`。我想让它们前边有`not`的时候再进行转换。

```lua
r1 = {}
r1['not true']  = 'false'
r1['not false'] = 'true'
s = 'true is not false'
print(Replace(s,r1))
```

如果不出意外的话，这里的输出是：

```tex
true is true
```

有没有注意到，`true is not false`和`true is true`，好像是有着逻辑关系的两句话？

先不管那么多，我要添加更多的规则：

```lua
r1 = {}
-- Not
r1['not true']  = 'false'
r1['not false'] = 'true'
-- And
r1['true and true'] = 'true'
r1['true and false'] = 'false'
r1['false and true'] = 'false'
r1['false and false'] = 'false'
-- Or
r1['true or true'] = 'true'
r1['true or false'] = 'true'
r1['false or true'] = 'true'
r1['false or false'] = 'false'

s = 'if not true, it is false. if true or not false, it is true.'
print(Replace(s, r1))
```

输出结果是：

```tex
if false, it is false. if true or true, it is true.
```

嗯，输出中的第一句看起来有点像废话，先不管它。后一句呢，似乎还有可以替换的内容。我们把替换结果再替换一次得到：

```lua
if false, it is false. if true, it is true.
```

每次都要写很多遍替换函数调用实在是很麻烦，所以我把`Replace`打包了一下。

```lua
function ReplaceLoop(s, L)
    local o = s
    repeat
        s = o
        o = Replace(s, L)
    until o==s
    return o
end
```

这次调用`ReplaceLoop(s, r1)`直接给出结果：

```lua
if false, it is false. if true, it is true.
```

可能你已经意识到上边的代码是在作什么，我们用最简单的的字符替功能换制造了一个能进行简易逻辑运算的工具。虽然这个小工具看起来没什么了不起的，但是它所代表的思想是很有意义的。我们没有动脑筋去思考`true or not false`是什么，也没有调用Lua内置的逻辑运算，仅仅是按照死板的既定规则做字符替换就得到了问题的答案。而且这种规则是如此简单，不需要任何高深的知识，即便是机器都能做得来。

在这个小成功的激励下，我不禁有了一个大胆的想法——我来定义一套字符替换规则。然后把我想解决的问题转化为文本。找一台机器来按照我的规则对文本不断进行替换。过一段时间后，当文本替换工作结束，我也就得到了我想要的问题的结果。这个设想简直太美好了，有了这样的替换规则和机器，我就可以把问题交给机器解决，而我只负责吃喝玩乐。

那么我这个大胆的想法第一步应该怎么走呢？这就要下回分解了。

