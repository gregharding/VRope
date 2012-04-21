/*
 
 MIT License.
 
 Copyright (c) 2012 Flightless Ltd.  
 Copyright (c) 2010 Clever Hamster Games.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
*/

//
//  VPoint.m
//
//  Created by patrick on 14/10/2010.
//  Modified by Flightless www.flightless.co.nz 20/4/2012
//

#import "VPoint.h"


@implementation VPoint

static float vPointGravityX = 0.0f;
static float vPointGravityY = 9.8f;

@synthesize x;
@synthesize y;

// Flightless, global gravity for all VPoints
// useful when all points share the same changing gravity
+(void) setGravityX:(float)gx Y:(float)gy {
	vPointGravityX = gx;
	vPointGravityY = gy;
}
+(CGPoint) getGravity {
    return CGPointMake(vPointGravityX, vPointGravityY);
}

-(void)setPos:(float)argX y:(float)argY {
	x = oldx = argX;
	y = oldy = argY;
}

-(void)update {
	float tempx = x;
	float tempy = y;
	x += x - oldx;
	y += y - oldy;
	oldx = tempx;
	oldy = tempy;
}

-(void)applyGravity:(float)dt {
	//y -= 10.0f*dt; //gravity magic number
	
	x -= vPointGravityX*dt;
	y -= vPointGravityY*dt;
}

// Flightless, time delta and specific gravity for point
// useful when all points have different gravity
-(void)applyGravity:(float)dt gx:(float)gx gy:(float)gy {
	x -= gx*dt;
	y -= gy*dt;
}

// Flightless, pre-integrated step with specific gravity for point
// useful when all points have different gravity, slightly optimised so caller can pre-integrate the step)
-(void)applyGravityxdt:(float)gxdt gydt:(float)gydt {
    x -= gxdt;
    y -= gydt;
}

-(void)setX:(float)argX {
	x = argX;
}

-(void)setY:(float)argY {
	y = argY;
}

-(float)getX {
	return x;
}

-(float)getY {
	return y;
}

@end
