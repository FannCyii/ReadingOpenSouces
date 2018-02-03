struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

struct __blk_block_impl_0 {
  struct __block_impl impl;
  struct __blk_block_desc_0* Desc;
  __blk_block_impl_0(void *fp, struct __blk_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteGlobalBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __blk_block_func_0(struct __blk_block_impl_0 *__cself) {
printf("%s","this is a globle block!");}

static struct __blk_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __blk_block_desc_0_DATA = { 0, sizeof(struct __blk_block_impl_0)};
static __blk_block_impl_0 __global_blk_block_impl_0((void *)__blk_block_func_0, &__blk_block_desc_0_DATA);
void (*blk)(void) = ((void (*)())&__global_blk_block_impl_0);

int main(int argc, const char * argv[])
{



    ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
    return 0;
}