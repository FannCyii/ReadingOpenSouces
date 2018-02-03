#import <Foundation/Foundation.h>

typedef void (^Blk)(void);

void blockTest(Blk blk)
{
	blk();
}


int main(int argc, const char * argv[])
{
    void (^blk)(void) = ^{
        printf("%s","baabbaa");
    };

	blockTest(blk);

    return 0;
}

