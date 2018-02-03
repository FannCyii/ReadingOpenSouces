#import "Foundation/Foundation.h"



int main(){

	__block int a = 123;
	static int b = 321;
	const int c = 456;


	void(^blk)(void) = ^{
		// int e = a + 10;
		// printf("%d in this blk!",e);
		// printf("%d in this blk!",b++);
		// printf("%d in this blk!",c);
	};

	^{

		
	};

	return 1;
}
