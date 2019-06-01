# 引言

必要前驱：

无

## 什么是dotnet

dotnet，一般写作`.Net`。由于`.`一般具有语法意义，所以我习惯把它写作`dotnet`。

dotnet是一个在统一标准下正在形成的统一平台加上多门不同范式、擅长不同领域的语言，这就是dotnet。今天的dotnet生态是如何形成的，是一个很长的故事。并不适合放到这个系列中细讲。

关于dotnet，我认为现在必须知道的信息有以下几点：

- 有一个组织叫Dotnet Foundation（.Net Foundation）。其官网是<https://dotnetfoundation.org/>。
- Dotnet Foundation制定了一个平台标准，并且主持实现了符合这个标准的平台。这个平台就是Dotnet（也写作.Net或者dotnet）。
- 由于一些历史原因，dotnet现在还没有完全统一。现在最主要的跨平台实现（指能在Linux，Windows，OS X等不同操作系统上运行），是Dotnet Core（也写作.Net Core或者dotnet core）。在不久的将来，Dotnet Core将与其他的Dotnet分支合并为Dotnet 5（.Net 5）。合并之后，将只会有一个Dotnet。现在Dotnet Core以及未来统一的Dotnet的官网是<https://dotnet.microsoft.com/>。
- 在Dotnet官网上可以下载到两种Dotnet软件包。一种是Runtime Environment， 另一种是Software Development Kit（SDK）。Runtime Environment仅仅提供Dotnet程序运行所必须的环境，适合最终用户安装。SDK则在Runtime Environment的基础上增加了编译器，项目构建工具，调试工具等开发工具，适合基于Dotnet做开发的人安装。

- 如果你想在Dotnet上做开发，那么最好顺便了解一下Dotnet所支持的编程语言。Dotnet主要支持三门编程语言：C#，F#，VB。由于C#和VB有一定的功能重复，所以我建议学C#和F#就足够了。

