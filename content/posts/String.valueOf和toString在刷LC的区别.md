+++
date = '{{ .Date }}'
draft = true
title = '{{ replace .File.ContentBaseName "-" " " | title }}'
+++

LC49 String.valueOf(c) 换成c.toString()就出错

在 Java 里，这两个方法表面相似，但本质完全不同：

1. String.valueOf(c)

c 是 char[]。

String.valueOf(char[]) 的重载方法会把整个字符数组转成字符串。

例如：

char[] c = {'a','n','t'};
System.out.println(String.valueOf(c)); // "ant"

2. c.toString()

c 是一个 对象（char[]）。

char[] 没有重写 toString() 方法，因此会调用 Object.toString() 的默认实现。

Object.toString() 返回的是：

类名@哈希码


比如：

char[] c = {'a','n','t'};
System.out.println(c.toString()); // [C@7a81197d


这里 [C 代表 char 数组的类型，后面是哈希值。