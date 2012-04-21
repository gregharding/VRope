/*
 
 MIT License.
 
 Copyright (c) 2012 Flightless Ltd.  
 Copyright (c) 2010 Clever Hamster Games.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
*/

//
//  VPoint.h
//
//  Created by patrick on 14/10/2010.
//  Modified by Flightless www.flightless.co.nz 20/4/2012
//

#import <Foundation/Foundation.h>

@interface VPoint : NSObject {
	float x,y,oldx,oldy;
}

@property(nonatomic,assign) float x;
@property(nonatomic,assign) float y;

+(void) setGravityX:(float)gx Y:(float)gy; // Flightless, global gravity for all VPoints
+(CGPoint) getGravity; // Flightless, global gravity for all VPoints

-(void) setPos:(float)argX y:(float)argY;
-(void) update;
-(void) applyGravity:(float)dt;
-(void) applyGravity:(float)dt gx:(float)gx gy:(float)gy; // Flightless, time delta and specific gravity for point
-(void) applyGravityxdt:(float)gxdt gydt:(float)gydt; // Flightless, pre-integrated step with specific gravity for point

@end
