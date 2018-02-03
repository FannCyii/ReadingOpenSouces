
struct __TestOb__test001_block_impl_0 {
  struct __block_impl impl;
  struct __TestOb__test001_block_desc_0* Desc;
  TestOb *self;
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
static void __TestOb__test001_block_copy_0(struct __TestOb__test001_block_impl_0*dst, struct __TestOb__test001_block_impl_0*src) {_Block_object_assign((void*)&dst->self, (void*)src->self, 3/*BLOCK_FIELD_IS_OBJECT*/);}

static void __TestOb__test001_block_dispose_0(struct __TestOb__test001_block_impl_0*src) {_Block_object_dispose((void*)src->self, 3/*BLOCK_FIELD_IS_OBJECT*/);}

static struct __TestOb__test001_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __TestOb__test001_block_impl_0*, struct __TestOb__test001_block_impl_0*);
  void (*dispose)(struct __TestOb__test001_block_impl_0*);
} __TestOb__test001_block_desc_0_DATA = { 0, sizeof(struct __TestOb__test001_block_impl_0), __TestOb__test001_block_copy_0, __TestOb__test001_block_dispose_0};

static void _I_TestOb_test001(TestOb * self, SEL _cmd) {

 ((void (*)(id, SEL, TestBlock))(void *)objc_msgSend)((id)self, sel_registerName("setTestBlock:"), ((void (*)(NSString *))&__TestOb__test001_block_impl_0((void *)__TestOb__test001_block_func_0, &__TestOb__test001_block_desc_0_DATA, self, 570425344)));

}


int main(int argc, const char * argv[])
{
    void (*blk)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));
    ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);

    TestOb * tob = (
    	(TestOb *(*)(id, SEL))
    	(void *)objc_msgSend
    	)(
    	(id)(
    		(TestOb *(*)(id, SEL)) 
    		(void *)objc_msgSend)((id)objc_getClass("TestOb"), sel_registerName("alloc")), sel_registerName("init"));


    ((void (*)(id, SEL))(void *)objc_msgSend)((id)tob, sel_registerName("test001"));

    return 0;
}
