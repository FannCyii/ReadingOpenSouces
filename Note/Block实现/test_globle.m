#import <Foundation/Foundation.h>

void (^blk)(void) = ^{printf("%s","this is a globle block!");};

int main(int argc, const char * argv[])
{
//    void (^blk)(void) = ^{
//        printf("%s","baabbaa");
//    };
    blk();
    return 0;
}
