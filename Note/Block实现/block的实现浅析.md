Block浅析

目录  
[1.Block的实现]()  
[2.Block截获自动变量]()  
[3.Block存储域]()  
[4.Block引用循环]()  

##`Block`的实现##
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;在实际编译时源代码转换后是我们无法理解的，但是通过clang提供了“-rewrite-objc”命令可以将其装换成我们可以理解的源代码。(以下代码都是在MRC模式下进行)  
&nbsp;&nbsp;&nbsp;&nbsp; 通过几个简单的`Objcetive-C`的代码来窥探`block`的实现。`test.m`文件内容如下：

```
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{
    void (^blk)(void) = ^{
        printf("%s","baabbaa");
    };
    blk();
    return 0;
}

```

通过 `clang -rewrite-objc test.m` 可以将代码转换成相依的`C++`文件：`test.cpp`，装换后文件变得非常大，这里只截取部分代码：

```

struct __block_impl { //Block定义
  void *isa; //相当于对象中的isa，这里表面Block也可当做一个对象
  int Flags;  //
  int Reserved; 
  void *FuncPtr; //执行函数
};

struct __main_block_impl_0 {  //Block主体
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {// Block执行函数

        printf("%s","baabbaa");
}

static struct __main_block_desc_0 { //Block存储大小
  size_t reserved; //版本升级所需的区域
  size_t Block_size; //block分配大小
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};

int main(int argc, const char * argv[]) //main函数
{
    void (*blk)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));
    ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
    return 0;
}
```

从代码中可以看出blk实现部分主要如下结构体组成：
> `__block_impl`  
> `__main_block_impl_0`  
> `__main_block_desc_0`  
> `__main_block_func_0`  







##`Block`截获自动变量##

首先要明白内存中几个常用的区域
>1、栈区（stack）： 由编译器自动分配释放 ，存放函数的参数值，局部变量的值等。其操作方式类似于数据结构中的栈。   
2、堆区（heap） ： 一般由程序员分配释放， 若程序员不释放，程序结束时可能由OS回收 。注意它与数据结构中的堆是两回事，分配方式倒是类似于链表。   
3、全局区（静态区）（static）：全局变量和静态变量的存储是放在一块的，初始化的全局变量和静态变量在一块区域， 未初始化的全局变量和未初始化的静态变量在相邻的另一块区域， 程序结束后由系统释放 。  
4、文字常量区：常量字符串就是放在这里的， 程序结束后由系统释放 。  
5、程序代码区：存放函数体的二进制代码。    
参考：[【栈，堆，全局，文字常量，代码区总结】](http://blog.csdn.net/evankaka/article/details/44457765)


明白以上的概念后再来看看block是如何捕获各种变量的：
* 全局变量、全局常量  

```
int a = 123;
static int b = 321;
const int c = 456;


struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {

  printf("%d in this blk!",a);
  printf("%d in this blk!",b++);
  printf("%d in this blk!",c);
 }

```

转化后看看到，blk并没有捕获全局变量和全局常量，而是直接使用。

* 局部变量、局部常量 

```
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int a;
  int *b;
  const int c;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _a, int *_b, const int _c, int flags=0) : a(_a), b(_b), c(_c) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

int main(){

int a = 123;
static int b = 321; //和Block执行函数不在同一个作用域
const int c = 456;

 void(*blk)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, a, &b, c));

 return 1;
}

```
这里就有明细的不同，blk捕获了这些变量或常量，并在blk结构体中声明了相应的属性，将捕获额常量或变量作为自己的成员。观察这些新增的成员变量，发现静态变量b被被捕获后是一个指针，而且在block中可以直接修改该变量的，所以可以看出block在捕获静态变量的时候是直接使用指针从静态区中获取变量的值，而不需要添加__block修饰符的。(超出函数作用域)  

* __block修饰符

如果允许block改变变量的值，有两种方法：一种，设置静态变量或全局变量；二种，给变量添加__block修饰符。第一种情况上面已经讲过，那添加__block修饰符又是什么情况呢？直接看代码转换如下：
> test.m 文件  

```  
#import "Foundation/Foundation.h"
int main(){

	__block int a = 123;
	static int b = 321;
	const int c = 456;

	void(^blk)(void) = ^{
		int e = a + 10;
		printf("%d in this blk!",e);
		printf("%d in this blk!",b++);
		printf("%d in this blk!",c);
	};
	return 1;
} 
```

转化后部分代码：  

```
struct __Block_byref_a_0 {
  void *__isa;
__Block_byref_a_0 *__forwarding;
 int __flags;
 int __size;
 int a;
};

truct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int *b;
  const int c;
  __Block_byref_a_0 *a; // by ref
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_b, const int _c, __Block_byref_a_0 *_a, int flags=0) : b(_b), c(_c), a(_a->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

```

可见，局部变量a添加`__block`说明符，变量`a`被`block`捕获后变成了结构体`__Block_byref_a_0`的实例。实际上，在由`Block`语法生成的`Block`值上，可以存有超过其变量作用域的被截获的自动变量。变量作用域结束后，原来的变量被废弃，因此block中超过变量作用域而存在的变量同静态变量一样将不能通过指针访问原来的自动变量。解决办法就是`__Block_byref_a_0 `结构体。   
准确的来说`__block`应称为："`__block`存储域类说明符"。
>C语言中的存储域类说明符  
>* typedef    
>* extern  
>* static  
>* auto  //修饰的变量，作为自动变量存储在栈中  
>* register   //请求编译器尽可能的将变量存在CPU内部寄存器中

`__block`说明符和 `static`,`auto`,`register`类似，用于指定变量设置到哪个存储区域中。使用`__block`说明符修饰的变量，将会在栈上生成`_Block_byref_a_0`结构体实例。

```
struct __Block_byref_a_0 {
  void *__isa;
__Block_byref_a_0 *__forwarding; //指向该结构体的实例
 int __flags;
 int __size;
 int a;
};

```

## `Block`存储域## 
  
Block类型 | 存储域类型  
--- | ---  
`_NSConcreteStackBlock` | 栈  
`_NSConcreteGlobalBlock`| 程序的数据区域  
`_NSConcreteMallocBlock`| 堆  
 

* `_NSConcreteGlobalBlock`  
 	并不是所有的block都是NSConcereteStackBlock类型的，~~但是事实并不是这样的，~~在记录全局变量的地方使用Block语法时，生成的block为_NSConcereteGlobalBlock类对象

* `_NSConcreteStackBlock`
除以上情况，在使用的时候Block都是在栈上生成的。
>问题：有的书上或者博客上都是说： block语法的表达式中不使用截获的自动变量的时候。

* `_NSConcereteMallocBlock `  
1 `Block`超出变量作用域，如将`Block`作为返回结果的时候  
2 `_block`变量用结构体成员变量`_fowarding`存在的原因

>注：`_block`变量结构体实例在从栈上复制到堆上的时候，会将成员变量的`_forwarding`的值替换为复制目标的堆上的`_block`变量的结构体实例的地址  


##循环引用##

如下代码能很直观的看出Block有环与无环的区别  
-有环

```
struct __TestOb__test001_block_impl_0 {
  struct __block_impl impl;
  struct __TestOb__test001_block_desc_0* Desc;
  TestOb *self;//捕获是self指针，造成引用循环
  __TestOb__test001_block_impl_0(void *fp, struct __TestOb__test001_block_desc_0 *desc, TestOb *_self, int flags=0) : self(_self) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __TestOb__test001_block_func_0(struct __TestOb__test001_block_impl_0 *__cself, NSString *message) {
  		TestOb *self = __cself->self; // bound by copy

        NSString* log = ((NSString *(*)(id, SEL))(void *)objc_msgSend)((id)self, sel_registerName("testStr"));
        NSLog((NSString *)&__NSConstantStringImpl__var_folders_kc_8x5cmpm57c5147d9_v1v54bc0000gp_T_test_ea3a8f_mi_1,log);
    }
```  

-无环


```  
struct __TestOb2__test001_block_impl_0 {
  struct __block_impl impl;
  struct __TestOb2__test001_block_desc_0* Desc;
  typeof (self) weakSelf;  //捕获的并不是self指针，没有造成引用循环
  __TestOb2__test001_block_impl_0(void *fp, struct __TestOb2__test001_block_desc_0 *desc, typeof (self) _weakSelf, int flags=0) : weakSelf(_weakSelf) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __TestOb2__test001_block_func_0(struct __TestOb2__test001_block_impl_0 *__cself, NSString *message) {
  typeof (self) weakSelf = __cself->weakSelf; // bound by copy
  
        NSString* log = ((NSString *(*)(id, SEL))(void *)objc_msgSend)((id)weakSelf, sel_registerName("testStr"));
        NSLog((NSString *)&__NSConstantStringImpl__var_folders_kc_8x5cmpm57c5147d9_v1v54bc0000gp_T_test_ea3a8f_mi_3,log);
    }

```  


>[Block考试题](http://blog.parse.com/learn/engineering/objective-c-blocks-quiz/)













