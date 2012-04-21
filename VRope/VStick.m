/*
 
 MIT License.
 
 Copyright (c) 2012 Flightless Ltd.  
 Copyright (c) 2010 Clever Hamster Games.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
*/

//
//  VStick.m
//
//  Created by patrick on 14/10/2010.
//

#import "VStick.h"
#import	 "cocos2d.h"

@implementation VStick
-(id)initWith:(VPoint*)argA pointb:(VPoint*)argB {
	if((self = [super init])) {
		pointA = argA;
		pointB = argB;
		hypotenuse = ccpDistance(ccp(pointA.x,pointA.y),ccp(pointB.x,pointB.y));
	}
	return self;
}

-(void)contract {
	float dx = pointB.x - pointA.x;
	float dy = pointB.y - pointA.y;
	float h = ccpDistance(ccp(pointA.x,pointA.y),ccp(pointB.x,pointB.y));
	float diff = hypotenuse - h;
	float offx = (diff * dx / h) * 0.5;
	float offy = (diff * dy / h) * 0.5;
	pointA.x-=offx;
	pointA.y-=offy;
	pointB.x+=offx;
	pointB.y+=offy;
}
-(VPoint*)getPointA {
	return pointA;
}
-(VPoint*)getPointB {
	return pointB;
}
@end
