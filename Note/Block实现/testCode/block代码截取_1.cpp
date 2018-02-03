
//block定义
struct __block_impl {
  void *isa; //类指针
  int Flags; //内部标识符
  int Reserved;//保留变量（版本升级）
  void *FuncPtr; //block执行的函数指针
};

//block主体
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

//block执行函数
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {

        printf("%s","baabbaa");
}

//block描述
static struct __main_block_desc_0 {
  size_t reserved;  //保留变量（版本升级所需）区域              
  size_t Block_size; //block大小
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};

int main(int argc, const char * argv[])
{
    void (*blk)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));
    ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
    return 0;
}