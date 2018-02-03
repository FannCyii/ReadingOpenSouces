category实现原理初探

这里通过阅读最新的objc4-709源码来窥探category的实现原理。要知道category作为runtime的重要特性，了解其实现原理也是非常重要的。

* 加载过程

 OC程序在编译到运行都是由dyld来主导【参考：[1 mikeash](https://www.mikeash.com/pyblog/friday-qa-2012-11-09-dyld-dynamic-linking-on-os-x.html)；[2 源码](https://github.com/opensource-apple/dyld)；[3 动态连接介绍](http://blog.sunnyxx.com/2014/08/30/objc-pre-main/)】，runtime机制就是在dyld基础之上运行的，对dyld感兴趣的同学可以看上面推荐的几篇文章，对runtime机制感兴趣的那就直接看objc源码吧，哈哈【[objc源码在这里](https://opensource.apple.com/tarballs/objc4/)】
 
 
> 首先看一个问题，给NSString添加一个Category名为OOTest，并设置公开的-ootest方法。 那么在其他任何文件中不引入该Category的头文件的情况下，是否能调用到该ootest方法呢? 
> 答案是可以，只不过要使用performSelector方法来调用，这就说明在编译阶段category的方法就会被添加到主类的方法列表中。接下来就通过源码看看category的方法时如何加载的。
 
* `category的组成`   

```
struct category_t {
    const char *name;//名称
    classref_t cls;//所属类
    struct method_list_t *instanceMethods;
    struct method_list_t *classMethods;
    struct protocol_list_t *protocols;
    struct property_list_t *instanceProperties;
    // Fields below this point are not always present on disk.
    struct property_list_t *_classProperties;

    method_list_t *methodsForMeta(bool isMeta) {
        if (isMeta) return classMethods;
        else return instanceMethods;
    }

    property_list_t *propertiesForMeta(bool isMeta, struct header_info *hi);
};

```

其实和objc_object的结构体的组成相似。 category_t结构体包含了实例方法列表、类方法列表、协议列表、实例属性列表、类属性列表等，这里类属性是iOS新增的特性，可以参看这里[【iOS类属性】](http://www.jianshu.com/p/8e21d12e9b6a)

 开始进入objc源码了，在源码中category的加载主要是在objc-runtime-new.m文件的_read_images方法中代码截取如下：
 
 ```
 void _read_images(header_info **hList, uint32_t hCount, int totalClasses, int unoptimizedTotalClasses){
 ...
 
 // Discover categories. 
    for (EACH_HEADER) {
        category_t **catlist = 
            _getObjc2CategoryList(hi, &count); //获取category列表头指针和所含category的数量
        bool hasClassProperties = hi->info()->hasCategoryClassProperties();

        for (i = 0; i < count; i++) {
            category_t *cat = catlist[i];//遍历每一个category
            Class cls = remapClass(cat->cls); //

            if (!cls) {
                // Category's target class is missing (probably weak-linked).
                // Disavow any knowledge of this category.
                catlist[i] = nil;
                if (PrintConnecting) {
                    _objc_inform("CLASS: IGNORING category \?\?\?(%s) %p with "
                                 "missing weak-linked target class", 
                                 cat->name, cat);
                }
                continue;
            }

            // Process this category. 
            // First, register the category with its target class. 
            // Then, rebuild the class's method lists (etc) if 
            // the class is realized. 
            bool classExists = NO;
            if (cat->instanceMethods ||  cat->protocols  
                ||  cat->instanceProperties) //category的实例方法，属性，以及协议 处理
            {
                addUnattachedCategoryForClass(cat, cls, hi);//将该category加入到一个hash映射表中
                if (cls->isRealized()) { //如果类已经实现
                    remethodizeClass(cls); //重新布局该类，即将实例方法，属性，协议添加到相应列表上
                    classExists = YES;
                }
                if (PrintConnecting) {
                    _objc_inform("CLASS: found category -%s(%s) %s", 
                                 cls->nameForLogging(), cat->name, 
                                 classExists ? "on existing class" : "");
                }
            }

            if (cat->classMethods  ||  cat->protocols  
                ||  (hasClassProperties && cat->_classProperties)) //category的类方法，协议 ，类属性的处理的处理。注意：1、这里协议会添加到类和其元类上，2、新增了类属性
            {
                addUnattachedCategoryForClass(cat, cls->ISA(), hi);//同上
                if (cls->ISA()->isRealized()) {
                    remethodizeClass(cls->ISA());//同上
                }
                if (PrintConnecting) {
                    _objc_inform("CLASS: found category +%s(%s)", 
                                 cls->nameForLogging(), cat->name);
                }
            }
        }
    }

 
 ...
 
 }
 
 ```
 
 添加一个独立的category到映射表中
 
 ```
 static void addUnattachedCategoryForClass(category_t *cat, Class cls, 
                                          header_info *catHeader)
{
    runtimeLock.assertWriting();

    // DO NOT use cat->cls! cls may be cat->cls->isa instead
    NXMapTable *cats = unattachedCategories(); //创建包含独立category hash映射表，只创建一次
    category_list *list;

    list = (category_list *)NXMapGet(cats, cls);//获取映射表的表头
    if (!list) {//如果表头为空，这分配一个空间
        list = (category_list *)
            calloc(sizeof(*list) + sizeof(list->list[0]), 1);
    } else {
        list = (category_list *)
            realloc(list, sizeof(*list) + sizeof(list->list[0]) * (list->count + 1));//重新分配一个长度多一的空间大小，这个多空间就是留给该独立category的
    }
    list->list[list->count++] = (locstamped_category_t){cat, catHeader};//将独立category插入到映射表的最后
    NXMapInsert(cats, cls, list);
}
 ```
 
 
remethodizeClass是关键方法，相关于重构目标类，添加一个category到存在的类中。  

 ```
 static void remethodizeClass(Class cls)
{
    category_list *cats;
    bool isMeta;

    runtimeLock.assertWriting();

    isMeta = cls->isMetaClass();//判断是否是元类

    // Re-methodizing: check for more categories
    if ((cats = unattachedCategoriesForClass(cls, false/*not realizing*/))) {
        if (PrintConnecting) {
            _objc_inform("CLASS: attaching categories to class '%s' %s", 
                         cls->nameForLogging(), isMeta ? "(meta)" : "");
        }
        
        attachCategories(cls, cats, true /*flush caches*/);        
        free(cats);
    }
}
 ```
而remethodizeClass函数中的起作用的就是attachCategories函数了：
 
 ```
 static void 
attachCategories(Class cls, category_list *cats, bool flush_caches)
{
    if (!cats) return;
    if (PrintReplacedMethods) printReplacements(cls, cats);

    bool isMeta = cls->isMetaClass();//判断该类是否是元类

    // fixme rearrange to remove these intermediate allocations //创建方法列表的列表，属性列表的列表，协议列表的列表，
    method_list_t **mlists = (method_list_t **)
        malloc(cats->count * sizeof(*mlists));
    property_list_t **proplists = (property_list_t **)
        malloc(cats->count * sizeof(*proplists));
    protocol_list_t **protolists = (protocol_list_t **)
        malloc(cats->count * sizeof(*protolists));

    // Count backwards through cats to get newest categories first
    int mcount = 0;
    int propcount = 0;
    int protocount = 0;
    int i = cats->count;
    bool fromBundle = NO;
    while (i--) { //从映射表中获取的category列表后想前遍历每一个category
        auto& entry = cats->list[i]; //栈上进行分配

        method_list_t *mlist = entry.cat->methodsForMeta(isMeta);//获取category中的类方法列表 ，并添加到方法列表的列表中
        if (mlist) {
            mlists[mcount++] = mlist;
            fromBundle |= entry.hi->isBundle();
        }

        property_list_t *proplist = 
            entry.cat->propertiesForMeta(isMeta, entry.hi); //获取category中的属性列表 ，并添加到属性列表的列表中
        if (proplist) {
            proplists[propcount++] = proplist;
        }

        protocol_list_t *protolist = entry.cat->protocols;//获取category中的协议列表 ，并添加到协议列表的列表中
        if (protolist) {
            protolists[protocount++] = protolist;
        }
    }

    auto rw = cls->data();

    prepareMethodLists(cls, mlists, mcount, NO, fromBundle);
    rw->methods.attachLists(mlists, mcount); //将category方法添加到该类方法列表前面
    free(mlists);
    if (flush_caches  &&  mcount > 0) flushCaches(cls);

    rw->properties.attachLists(proplists, propcount);//将category属性添加到该类属性列表前面
    free(proplists);

    rw->protocols.attachLists(protolists, protocount);//将category协议添加到该类协议列表前面
    free(protolists);
}
 
 ```
 
 在attachCategories方法中，方法列表、属性列表、协议列表都是通过attachLists这个类方法来处理，并添加到class中的，它是是list_array_tt类的公共函数。
 ```
 //将新列表添加到旧列表中
    void attachLists(List* const * addedLists, uint32_t addedCount) {
        if (addedCount == 0) return;

        if (hasArray()) {
            // many lists -> many lists
            uint32_t oldCount = array()->count; //获取就列表长度
            uint32_t newCount = oldCount + addedCount; //新的列表需要的长度
            setArray((array_t *)realloc(array(), array_t::byteSize(newCount))); //重新分配就列表，也就是扩充就列表的长度
            array()->count = newCount;
            memmove(array()->lists + addedCount, array()->lists, 
                    oldCount * sizeof(array()->lists[0])); //将内存中旧列表内容，移动到addedCount的位置上，也就是前面留有addedCount的类容，这里就是方法会覆盖的原因
            memcpy(array()->lists, addedLists, 
                   addedCount * sizeof(array()->lists[0]));//将新增列表中的内容添加到，新列表最前面
        }
        else if (!list  &&  addedCount == 1) {
            // 0 lists -> 1 list
            list = addedLists[0];
        } 
        else {
            // 1 list -> many lists
            List* oldList = list;
            uint32_t oldCount = oldList ? 1 : 0;
            uint32_t newCount = oldCount + addedCount;
            setArray((array_t *)malloc(array_t::byteSize(newCount)));
            array()->count = newCount;
            if (oldList) array()->lists[addedCount] = oldList;
            memcpy(array()->lists, addedLists, 
                   addedCount * sizeof(array()->lists[0]));
        }
    }

 ```
 
 
 总结：透过源码，可以看到，category的实例方法、协议、实例属性都添加到目标类实例列表中，并且添加在各个列表前面，所以当有重名时会屏蔽原有的(使用屏蔽，而不是覆盖，因为并没有覆盖)。而category的类方法、列属性、协议都添加到目标类的类列表中。
 
 附加：通过消息转发的形式调用方法，需要遍历主类的方法列表。而在runtime加载时调用+load方法不是通过消息转发的形式调用的，而是系统直接使用函数指针来调用，先调用主类的+load再调用分类的+load方法，这里并不会去遍历类的方法列表。
 
 
 > 参看：[category原理](http://blog.leichunfeng.com/blog/2015/05/18/objective-c-category-implementation-principle/)  
 [category原理](http://tech.meituan.com/DiveIntoCategory.html)
 

 