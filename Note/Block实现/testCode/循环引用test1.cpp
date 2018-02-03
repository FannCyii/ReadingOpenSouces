
struct __TestOb2__test001_block_impl_0 {
  struct __block_impl impl;
  struct __TestOb2__test001_block_desc_0* Desc;
  typeof (self) weakSelf;
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