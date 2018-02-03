#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{
@autoreleasepool{
    void (^blk)(void) = ^{
        printf("%s","baabbaa");
    };
    blk();
}
    return 0;
}
