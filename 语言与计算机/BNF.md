# BNF

预定义一个名称叫做LineEnd表示换行.之后会作处理.

## Literal

```BNF
CharacterSetA=NameCharacter|','|';'|'|'|'='|'"'
CharacterSetB=NameCharacter|','|';'|'|'|'='|"'"
TextA=''|CharacterSetA,TextA
TextB=''|CharacterSetB,TextB
Literal="'",TextA,"'"|'"',TextB,"'"
```

## Name

```BNF
NameCharacter='A'|'B'|'C'|'D'|'E'|'F'|'G'|'H'|'I'|'J'|'K'|'L'|'M'|'N'|'O'|'P'|'Q'|'R'|'S'|'T'|'U'|'V'|'W'|'X'|'Y'|'Z'|'a'|'b'|'c'|'d'|'e'|'f'|'g'|'h'|'i'|'j'|'k'|'l'|'m'|'n'|'o'|'p'|'q'|'r'|'s'|'t'|'u'|'v'|'w'|'x'|'y'|'z'
Name=NameCharacter|NameCharacter,Name
```

## Expression

```BNF
Term=Literal|Name
List=Term|Term,',',List
Expression=List|List,'|',Expression
```

## Syntax

```BNF
Rule=Name,'=',Expression,LineEnd
Syntax=Rule|Rule,Syntax
```

## 最终版

为了保持一定的可读性(其实这样写可读性已经非常差了),我使用了预定义的LineEnd.为了不留缺憾,最后给出一种不需要预定义的版本,这个版本中我们把LineEnd定义为';'.

```BNF
LineEnd=';'
```

完整的版本应该是

```BNF
NameCharacter='A'|'B'|'C'|'D'|'E'|'F'|'G'|'H'|'I'|'J'|'K'|'L'|'M'|'N'|'O'|'P'|'Q'|'R'|'S'|'T'|'U'|'V'|'W'|'X'|'Y'|'Z'|'a'|'b'|'c'|'d'|'e'|'f'|'g'|'h'|'i'|'j'|'k'|'l'|'m'|'n'|'o'|'p'|'q'|'r'|'s'|'t'|'u'|'v'|'w'|'x'|'y'|'z';Name=NameCharacter|NameCharacter,Name;CharacterSetA=NameCharacter|','|';'|'|'|'='|'"';CharacterSetB=NameCharacter|','|';'|'|'|'='|"'";TextA=''|CharacterSetA,TextA;TextB=''|CharacterSetB,TextB;Literal="'",TextA,"'"|'"',TextB,"'";Term=Literal|Name;List=Term|Term,',',List;Expression=List|List,'|',Expression;LineEnd=';';Rule=Name,'=',Expression,LineEnd;Syntax=Rule|Rule,Syntax
```

以上一共十三条规则.

如果要进一步精简可以精简命名用的字符集.比如取消大写(或者小写)字母.最极端可以简化到一个字符,这样又能省略一条规则.

也可以考虑用一个符号的重复来取代一些语法标记符号(比如用';,'取代'=').

另外引号其实可以用转义字符处理,比如

```BNF
LiteralSingle= '\''
```

把转义符和单引号作为一个整体放到CharacterSet中(也就是说句中出现前边没有转义符的单独的引号是非法的).然后其他用到单引号本身的字面值的地方都用'\''取代.

## 语义解释

Literal就是字符串,''表示空字符串.

','表示字符串连接操作(原版中用空格和尖括号可以表达这种意思.但是空格排版出来不容易看,所以我用了逗号.)

'|'表示或关系

'='表示名称定义

需要说明的是BNF只是定义语法,语义层面的事情是不容易处理的.比如一个Name被定义了两次,应该怎么处理.这不属于BNF所能处理的范畴.

## 原版BNF

```BNF
 <syntax>         ::= <rule> | <rule> <syntax>
 <rule>           ::= <opt-whitespace> "<" <rule-name> ">" <opt-whitespace> "::=" <opt-whitespace> <expression> <line-end>
 <opt-whitespace> ::= " " <opt-whitespace> | ""
 <expression>     ::= <list> | <list> <opt-whitespace> "|" <opt-whitespace> <expression>
 <line-end>       ::= <opt-whitespace> <EOL> | <line-end> <line-end>
 <list>           ::= <term> | <term> <opt-whitespace> <list>
 <term>           ::= <literal> | "<" <rule-name> ">"
 <literal>        ::= '"' <text1> '"' | "'" <text2> "'"
 <text1>          ::= "" | <character1> <text1>
 <text2>          ::= "" | <character2> <text2>
 <character>      ::= <letter> | <digit> | <symbol>
 <letter>         ::= "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z" | "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z"
 <digit>          ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
 <symbol>         ::=  "|" | " " | "-" | "!" | "#" | "$" | "%" | "&" | "(" | ")" | "*" | "+" | "," | "-" | "." | "/" | ":" | ";" | ">" | "=" | "<" | "?" | "@" | "[" | "\" | "]" | "^" | "_" | "`" | "{" | "}" | "~"
 <character1>     ::= <character> | "'"
 <character2>     ::= <character> | '"'
 <rule-name>      ::= <letter> | <rule-name> <rule-char>
 <rule-char>      ::= <letter> | <digit> | "-"
```

这里的`<EOL>`表示换行的符号(不同的操作系统中会有所不同).

维基百科在符号里多写了一个"-"

在原版的基础上新增

1. 预处理所有的换行和Tab都是为了好看.输入的时候要过滤掉.
1. 行尾符号是';'
1. 新定义大写,小写,数字,十六进制数字等字符集.
1. 用于定义Lua和C语言的各种字面值和语法.
1. 名称的命名规则和C,lua一致
1. 不使用尖括号
1. 加入单行注释写法

字符集

```TXBNF2
"::::Character Set::::" ;
Uppercase      ::= "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z" ;
Lowercase      ::= "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z" ;
Digit          ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
Bracket_Slash  ::= "<" | ">" | "(" | ")" | "[" | "]" | "{" | "}" | "/" | "\" ;
Math_Logic     ::= "-" | "+" | "*" | "%" | "=" | "^" | "&" | "|" | "~" ;
WithPoint      ::= "." | "," | ":" | ";" | "!" | "?" ;
QuotationMark  ::= "'" | '"' | "`" ;
OtherSymbol    ::= "#" | "$" | "@" ;
Underscore     ::= "_" ;
Space          ::= " " ;
"::::Name::::" ;
Letter         ::= Uppercase | Lowercase ;
HeadLetter     ::= Letter | Underscore ;
NameLetter     ::= HeadLetter | Digit ;
Name           ::= HeadLetter | Name NameLetter ;
"::::Literal::::" ;
NormalLetter   ::= NameLetter | Bracket_Slash | Math_Logic | WithPoint | OtherSymbol | Space | "`" ;
LiteralSet1    ::= NormalLetter | "'" ;
LiteralSet2    ::= NormalLetter | '"' ;
Text1          ::= "" | LiteralSet1 Text1 ;
Text2          ::= "" | LiteralSet2 Text2 ;
Literal        ::= '"' Text1 '"' | "'" Text2 "'" ;
"::::Space::::" ;
MoreSpace ::= Space | Space MoreSpace ;
OptionalSpace  ::= "" | MoreSpace ;
"::::Expression::::" ;
Term           ::= Name | Literal ;
List           ::= Term | Term MoreSpace List ;
Expression     ::= List | List OptionalSpace "|" OptionalSpace Expression ;
"::::End Of Line::::" ;
EndOfLine      ::= ";" ;
LineEnd        ::= OptionalSpace EndOfLine ;
"::::Rule::::" ;
Rule           ::= OptionalSpace Name OptionalSpace "::=" OptionalSpace Expression LineEnd ;
"::::Comment::::" ;
Comment        ::= OptionalSpace Literal OptionalSpace ";"
```


源码不应该有换行或者tab,为了排版好看所有行尾之后自动加了换行.

```TXBNF3
"::::Character Set::::" ;
Letter         = "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z" | "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z" ;
Digit          = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
OtherSymbol    = "<" | ">" | "(" | ")" | "[" | "]" | "{" | "}" | "/" | "\" | "-" | "+" | "*" | "%" | "=" | "^" | "&" | "|" | "~" | "." | "," | ":" | ";" | "!" | "?" | "#" | "$" | "@" | "`" ;
Space          = " " ;
"::::Name::::" ;
HeadLetter     = Letter | "_" ;
NameLetter     = HeadLetter | Digit ;
Name           = HeadLetter | Name NameLetter ;
"::::Literal::::" ;
NormalLetter   = NameLetter | OtherSymbol | Space ;
LiteralSet1    = NormalLetter | "'" ;
LiteralSet2    = NormalLetter | '"' ;
Text1          = "" | LiteralSet1 Text1 ;
Text2          = "" | LiteralSet2 Text2 ;
Literal        = '"' Text1 '"' | "'" Text2 "'" ;
"::::Space::::" ;
MoreSpace      = Space | Space MoreSpace ;
OptionalSpace  = "" | MoreSpace ;
"::::Expression::::" ;
Term           = Name | Literal ;
List           = Term | Term MoreSpace List ;
Expression     = List | List OptionalSpace "|" OptionalSpace Expression ;
"::::End Of Line::::" ;
LineEnd        = ";" | OptionalSpace LineEnd ;
"::::Rule::::" ;
Rule           = OptionalSpace Name OptionalSpace "=" OptionalSpace Expression LineEnd ;
"::::Comment::::" ;
Comment        = OptionalSpace Literal LineEnd ;
"::::Syntax::::" ;
Sentence       = Rule | Comment
Syntax         = Sentence | Sentence Syntax ;
```


可以利用编译的机制来防止字面值和行终止符冲突.
字面值的检索不能被行终止符打断,所以在一个字面值内部的终止符,不会打断这次字面值识别.
不需要,先定义的语法优先级高.越先定义,优先级越高.
整个语法的定义可以是没有顺序的.


预处理:

1. 去掉所有的非可打印字符,换成一个空格(不仅仅是控制字符,还包括未定义的ASCII码)
1. 处理循环,选择写法



## 扩展

无论我们所介绍的精简版BNF(我打算称之为'TaiXuan BNF',第一代简写TXBNF1,手动滑稽)原版的BNF在现实中都比较难用.因为可读性比较差.

如果要描述一门语言,一般用的是BNF的扩展版Extended BNF,简称EBNF.

在Bash命令的说明文件中,Lua的语法文档中,Minecraft的控制台命令使用说明中都可以见到用EBNF描述的语法.

EBNF的自我描述:

```EBNF
letter = "A" | "B" | "C" | "D" | "E" | "F" | "G"
       | "H" | "I" | "J" | "K" | "L" | "M" | "N"
       | "O" | "P" | "Q" | "R" | "S" | "T" | "U"
       | "V" | "W" | "X" | "Y" | "Z" | "a" | "b"
       | "c" | "d" | "e" | "f" | "g" | "h" | "i"
       | "j" | "k" | "l" | "m" | "n" | "o" | "p"
       | "q" | "r" | "s" | "t" | "u" | "v" | "w"
       | "x" | "y" | "z" ;
digit = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
symbol = "[" | "]" | "{" | "}" | "(" | ")" | "<" | ">"
       | "'" | '"' | "=" | "|" | "." | "," | ";" ;
character = letter | digit | symbol | "_" ;

identifier = letter , { letter | digit | "_" } ;
terminal = "'" , character , { character } , "'"
         | '"' , character , { character } , '"' ;

lhs = identifier ;
rhs = identifier
     | terminal
     | "[" , rhs , "]"
     | "{" , rhs , "}"
     | "(" , rhs , ")"
     | rhs , "|" , rhs
     | rhs , "," , rhs ;

rule = lhs , "=" , rhs , ";" ;
grammar = { rule } ;
```

这个版本的语法自我描述是我在Wiki上找到的.这个版本又很多问题.

注意这里关于字符串字面值的定义,没有用两种引号互相描述的方法.是可能引起字符串识别的问题的.而且它没有定义空字符串.

另外它也没有定义就使用了空格.

对比原版BNF它主要的扩展语法,是以下几点:

1. 名称不使用尖括号包括,但是多个名称相连的时候中间使用逗号分隔.(有的版本中尖括号括起来的部分表示必须有的项目)
1. 可以有也可以没有的可选项目用方括号括起来表述.
1. 可以不出现也可以重复任意有限次的项目会用花括号包括起来.
1. 如果一个位置上有多种选项,你又不想因为合并这些选项再新增一个规则.就可以使用组(group).在圆括号里边,用竖线分隔开的若干项就表示任选其一,然后作为外层的表达式的一部分.例如`'a'|('b'|'c'),'d'`表示'a'或者'bd'或者'cd'.

以上规则不一定被所有的版本EBNF所采用.所以我无法给出一个完整的EBNF的定义.如果你非常想要一个有统一定义的BNF.可以去看看ABNF.

## 参考资料

[Wikipedia: Backus–Naur form](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form)
[Wikipedia: Extended Backus–Naur form](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form)


"::::Space::::" ;
OptionalSpace  = "" | MoreSpace ;
"::::Expression::::" ;
Term           = Name | Literal ;
List           = Term | Term MoreSpace List ;
Expression     = List | List OptionalSpace "|" OptionalSpace Expression ;
"::::End Of Line::::" ;
LineEnd        = ";" | OptionalSpace LineEnd ;
"::::Rule::::" ;
Rule           = OptionalSpace Name OptionalSpace "=" OptionalSpace Expression LineEnd ;
"::::Comment::::" ;
Comment        = OptionalSpace Literal LineEnd ;
"::::Syntax::::" ;
Sentence       = Rule | Comment
Syntax         = Sentence | Sentence Syntax ;
```

采用自动去除开头空格的机制,所有的匹配都锚定到开头(空格也是)

语法分析仍然用词法的方法(string.find)

一次分析后的结果
term equal term term term thenend
|
tetttd

然后搜索


词法分析器
二阶,三阶,任意阶词法分析

语法检查
自动lint
代码风格识别,自动生成lint规则
代码生成
HTML生成器 XAML生成器(给定大致风格需求,自动生成)