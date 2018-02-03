#import <Foundation/Foundation.h>

void(^bbblk)(void)=^{printf("Block");};
void(^bbbbllllk)(void);

typedef void (^TestBlock)(NSString* str);
@interface TestOb:NSObject
@property(nonatomic, copy)TestBlock testBlock;
@property(nonatomic, copy)NSString * testStr;
@end

@implementation TestOb

- (id)init{
	self = [super init];
	if(self){
		_testStr = @"1234567878qwe";
	}
	return self;
}

-(void)test001{

	self.testBlock = ^(NSString* message){
        NSString* log = self.testStr;// 循环引用
        NSLog(@"%@",log);
    };

}
@end


@interface TestOb2:NSObject
@property(nonatomic, copy)TestBlock testBlock;
@property(nonatomic, copy)NSString * testStr;
@end

@implementation TestOb2

- (id)init{
	self = [super init];
	if(self){
		_testStr = @"bafbafbadf";
	}
	return self;
}

-(void)test001{

	//__weak __typeof(self) weakSelf = self; //__unsafe_unretained
	__unsafe_unretained __typeof(self) weakSelf = self;
	self.testBlock = ^(NSString* message){
		//__strong __typeof(weakSelf) strongSelf = self;
        NSString* log = weakSelf.testStr;// 循环引用
        NSLog(@"%@",log);
    };

}
@end


int main(int argc, const char * argv[])
{
    void (^blk)(void) = ^{
        printf("%s","baabbaa");
    };
    blk();

    TestOb * tob = [[TestOb alloc]init];
    [tob test001];

    return 0;
}

