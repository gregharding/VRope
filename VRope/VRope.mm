/*
 
 MIT License.
 
 Copyright (c) 2012 Flightless Ltd.  
 Copyright (c) 2010 Clever Hamster Games.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
*/

//
//  VRope.m
//
//  Created by patrick on 16/10/2010.
//

#import "VRope.h"


@implementation VRope

#ifdef BOX2D_H
-(id)init:(b2Body*)body1 body2:(b2Body*)body2 batchNode:(CCSpriteBatchNode*)ropeBatchNode {
	if((self = [super init])) {
		bodyA = body1;
		bodyB = body2;
		CGPoint pointA = ccp(bodyA->GetPosition().x*PTM_RATIO,bodyA->GetPosition().y*PTM_RATIO);
		CGPoint pointB = ccp(bodyB->GetPosition().x*PTM_RATIO,bodyB->GetPosition().y*PTM_RATIO);
		spriteSheet = ropeBatchNode;
		[self createRope:pointA pointB:pointB];
	}
	return self;
}

// Flightless, init rope using a joint between two bodies
-(id)init:(b2Joint*)joint batchNode:(CCSpriteBatchNode*)ropeBatchNode {
    if((self = [super init])) {
		jointAB = joint;
		CGPoint pointA = ccp(jointAB->GetAnchorA().x*PTM_RATIO,jointAB->GetAnchorA().y*PTM_RATIO);
		CGPoint pointB = ccp(jointAB->GetAnchorB().x*PTM_RATIO,jointAB->GetAnchorB().y*PTM_RATIO);
		spriteSheet = ropeBatchNode;
		[self createRope:pointA pointB:pointB];
	}
	return self;
}

-(void)reset {
    CGPoint pointA, pointB;
    if (bodyA) {
        pointA = ccp(bodyA->GetPosition().x*PTM_RATIO,bodyA->GetPosition().y*PTM_RATIO);
        pointB = ccp(bodyB->GetPosition().x*PTM_RATIO,bodyB->GetPosition().y*PTM_RATIO);
    } else {
        pointA = ccp(jointAB->GetAnchorA().x*PTM_RATIO,jointAB->GetAnchorA().y*PTM_RATIO);
        pointB = ccp(jointAB->GetAnchorB().x*PTM_RATIO,jointAB->GetAnchorB().y*PTM_RATIO);
    }
    [self resetWithPoints:pointA pointB:pointB];
}

-(void)update:(float)dt {
    CGPoint pointA, pointB;
    if (bodyA) {
        pointA = ccp(bodyA->GetPosition().x*PTM_RATIO,bodyA->GetPosition().y*PTM_RATIO);
        pointB = ccp(bodyB->GetPosition().x*PTM_RATIO,bodyB->GetPosition().y*PTM_RATIO);
    } else {
        pointA = ccp(jointAB->GetAnchorA().x*PTM_RATIO,jointAB->GetAnchorA().y*PTM_RATIO);
        pointB = ccp(jointAB->GetAnchorB().x*PTM_RATIO,jointAB->GetAnchorB().y*PTM_RATIO);
    }
    [self updateWithPoints:pointA pointB:pointB dt:dt];
}

// Flightless, update rope by pre-integrating the gravity each step (optimised for changing gravity)
-(void)updateWithPreIntegratedGravity:(float)dt gravityX:(float)gravityX gravityY:(float)gravityY {
    CGPoint pointA, pointB;
    if (bodyA) {
        pointA = ccp(bodyA->GetPosition().x*PTM_RATIO,bodyA->GetPosition().y*PTM_RATIO);
        pointB = ccp(bodyB->GetPosition().x*PTM_RATIO,bodyB->GetPosition().y*PTM_RATIO);
    } else {
        pointA = ccp(jointAB->GetAnchorA().x*PTM_RATIO,jointAB->GetAnchorA().y*PTM_RATIO);
        pointB = ccp(jointAB->GetAnchorB().x*PTM_RATIO,jointAB->GetAnchorB().y*PTM_RATIO);
    }
    
    // update points with pre-integrated gravity
	[self updateWithPoints:pointA pointB:pointB gxdt:gravityX*dt gydt:gravityY*dt];
}

// Flightless, update rope by pre-integrating the gravity each step (optimised for changing gravity)
// nb. uses current global point gravity, should probably be moved to a gravity for each rope
-(void)updateWithPreIntegratedGravity:(float)dt {
    CGPoint pointA, pointB;
    if (bodyA) {
        pointA = ccp(bodyA->GetPosition().x*PTM_RATIO,bodyA->GetPosition().y*PTM_RATIO);
        pointB = ccp(bodyB->GetPosition().x*PTM_RATIO,bodyB->GetPosition().y*PTM_RATIO);
    } else {
        pointA = ccp(jointAB->GetAnchorA().x*PTM_RATIO,jointAB->GetAnchorA().y*PTM_RATIO);
        pointB = ccp(jointAB->GetAnchorB().x*PTM_RATIO,jointAB->GetAnchorB().y*PTM_RATIO);
    }
    
    // pre-integrate current gravity
    CGPoint gravity = ccpMult([VPoint getGravity], dt);
        
    // update points with pre-integrated gravity
	[self updateWithPoints:pointA pointB:pointB gxdt:gravity.x gydt:gravity.y];
}

// Flightless, update rope by pre-integrating the gravity each step (optimised for changing gravity)
// nb. this uses a gravity with origin (0,0) and an average of bodyA and bodyB positions to determine which way is 'down' for each rope.
-(void)updateWithPreIntegratedOriginGravity:(float)dt {
    CGPoint pointA, pointB;
    if (bodyA) {
        pointA = ccp(bodyA->GetPosition().x*PTM_RATIO,bodyA->GetPosition().y*PTM_RATIO);
        pointB = ccp(bodyB->GetPosition().x*PTM_RATIO,bodyB->GetPosition().y*PTM_RATIO);
    } else {
        pointA = ccp(jointAB->GetAnchorA().x*PTM_RATIO,jointAB->GetAnchorA().y*PTM_RATIO);
        pointB = ccp(jointAB->GetAnchorB().x*PTM_RATIO,jointAB->GetAnchorB().y*PTM_RATIO);
    }
    
    // pre-integrate gravity, based on average position of bodies
    CGPoint gravityAtPoint = ccp(-0.5f*(pointA.x+pointB.x), -0.5f*(pointA.y+pointB.y));
    gravityAtPoint = ccpMult(ccpNormalize(gravityAtPoint), -10.0f*dt); // nb. vrope uses negative gravity!
    
    // update points with pre-integrated gravity
	[self updateWithPoints:pointA pointB:pointB gxdt:gravityAtPoint.x gydt:gravityAtPoint.y];
}

#endif

-(id)initWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB spriteSheet:(CCSpriteBatchNode*)spriteSheetArg {
	if((self = [super init])) {
		spriteSheet = spriteSheetArg;
		[self createRope:pointA pointB:pointB];
	}
	return self;
}

-(void)createRope:(CGPoint)pointA pointB:(CGPoint)pointB {
	vPoints = [[NSMutableArray alloc] init];
	vSticks = [[NSMutableArray alloc] init];
	ropeSprites = [[NSMutableArray alloc] init];
	float distance = ccpDistance(pointA,pointB);
	int segmentFactor = 20; // 16; //12; //increase value to have less segments per rope, decrease to have more segments
	numPoints = distance/segmentFactor;
	CGPoint diffVector = ccpSub(pointB,pointA);
	float multiplier = distance / (numPoints-1);
	antiSagHack = 0.1f; //HACK: scale down rope points to cheat sag. set to 0 to disable, max suggested value 0.1
	for(int i=0;i<numPoints;i++) {
		CGPoint tmpVector = ccpAdd(pointA, ccpMult(ccpNormalize(diffVector),multiplier*i*(1-antiSagHack)));
		VPoint *tmpPoint = [[VPoint alloc] init];
		[tmpPoint setPos:tmpVector.x y:tmpVector.y];
		[vPoints addObject:tmpPoint];
        [tmpPoint release];
	}
	for(int i=0;i<numPoints-1;i++) {
		VStick *tmpStick = [[VStick alloc] initWith:[vPoints objectAtIndex:i] pointb:[vPoints objectAtIndex:i+1]];
		[vSticks addObject:tmpStick];
        [tmpStick release];
	}
	if(spriteSheet!=nil) {
		for(int i=0;i<numPoints-1;i++) {
			VPoint *point1 = [[vSticks objectAtIndex:i] getPointA];
			VPoint *point2 = [[vSticks objectAtIndex:i] getPointB];
			CGPoint stickVector = ccpSub(ccp(point1.x,point1.y),ccp(point2.x,point2.y));
			float stickAngle = ccpToAngle(stickVector);
            
            // cocos 1.x
            //CCSprite *tmpSprite = [CCSprite spriteWithBatchNode:spriteSheet rect:CGRectMake(0,0,multiplier,[[[spriteSheet textureAtlas] texture] pixelsHigh]/CC_CONTENT_SCALE_FACTOR())]; // Flightless, retina fix
            
            // cocos 2.x
            CCSprite* tmpSprite = [CCSprite spriteWithTexture:spriteSheet.texture rect:CGRectMake(0,0,multiplier,[[[spriteSheet textureAtlas] texture] pixelsHigh]/CC_CONTENT_SCALE_FACTOR())]; // Flightless, retina fix
            tmpSprite.batchNode = spriteSheet;
            
			ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
			[tmpSprite.texture setTexParameters:&params];
			[tmpSprite setPosition:ccpMidpoint(ccp(point1.x,point1.y),ccp(point2.x,point2.y))];
			[tmpSprite setRotation:-1 * CC_RADIANS_TO_DEGREES(stickAngle)];
			[spriteSheet addChild:tmpSprite];
			[ropeSprites addObject:tmpSprite];
		}
	}
}

-(void)resetWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB {
	float distance = ccpDistance(pointA,pointB);
	CGPoint diffVector = ccpSub(pointB,pointA);
	float multiplier = distance / (numPoints - 1);
	for(int i=0;i<numPoints;i++) {
		CGPoint tmpVector = ccpAdd(pointA, ccpMult(ccpNormalize(diffVector),multiplier*i*(1-antiSagHack)));
		VPoint *tmpPoint = [vPoints objectAtIndex:i];
		[tmpPoint setPos:tmpVector.x y:tmpVector.y];
		
	}
}

-(void)removeSprites {
	for(int i=0;i<numPoints-1;i++) {
		CCSprite *tmpSprite = [ropeSprites objectAtIndex:i];
		[spriteSheet removeChild:tmpSprite cleanup:YES];
	}
	[ropeSprites removeAllObjects];
	[ropeSprites release];
}

-(void)updateWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB dt:(float)dt {
	//manually set position for first and last point of rope
	[[vPoints objectAtIndex:0] setPos:pointA.x y:pointA.y];
	[[vPoints objectAtIndex:numPoints-1] setPos:pointB.x y:pointB.y];
	
	//update points, apply gravity
	for(int i=1;i<numPoints-1;i++) {
		[[vPoints objectAtIndex:i] applyGravity:dt];
		[[vPoints objectAtIndex:i] update];
	}
	
	//contract sticks
	int iterations = 4;
	for(int j=0;j<iterations;j++) {
		for(int i=0;i<numPoints-1;i++) {
			[[vSticks objectAtIndex:i] contract];
		}
	}
}

-(void)updateWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB gxdt:(float)gxdt gydt:(float)gydt {
	//manually set position for first and last point of rope
	[[vPoints objectAtIndex:0] setPos:pointA.x y:pointA.y];
	[[vPoints objectAtIndex:numPoints-1] setPos:pointB.x y:pointB.y];
	
	//update points, apply pre-integrated gravity
	for(int i=1;i<numPoints-1;i++) {
		[[vPoints objectAtIndex:i] applyGravityxdt:gxdt gydt:gydt];
		[[vPoints objectAtIndex:i] update];
	}
	
	//contract sticks
	int iterations = 4;
	for(int j=0;j<iterations;j++) {
		for(int i=0;i<numPoints-1;i++) {
			[[vSticks objectAtIndex:i] contract];
		}
	}
}


-(void)updateSprites {
	if(spriteSheet!=nil) {
		for(int i=0;i<numPoints-1;i++) {
			VPoint *point1 = [[vSticks objectAtIndex:i] getPointA];
			VPoint *point2 = [[vSticks objectAtIndex:i] getPointB];
			CGPoint point1_ = ccp(point1.x,point1.y);
			CGPoint point2_ = ccp(point2.x,point2.y);
			float stickAngle = ccpToAngle(ccpSub(point1_,point2_));
			CCSprite *tmpSprite = [ropeSprites objectAtIndex:i];
			[tmpSprite setPosition:ccpMidpoint(point1_,point2_)];
			[tmpSprite setRotation: -CC_RADIANS_TO_DEGREES(stickAngle)];
		}
	}	
}

/* opengl es 1.1 only
-(void)debugDraw {
	//Depending on scenario, you might need to have different Disable/Enable of Client States
	//glDisableClientState(GL_TEXTURE_2D);
	//glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	//glDisableClientState(GL_COLOR_ARRAY);
	//set color and line width for ccDrawLine
	glColor4f(0.0f,0.0f,1.0f,1.0f);
	glLineWidth(5.0f);
	for(int i=0;i<numPoints-1;i++) {
		//"debug" draw
		VPoint *pointA = [[vSticks objectAtIndex:i] getPointA];
		VPoint *pointB = [[vSticks objectAtIndex:i] getPointB];
		ccDrawPoint(ccp(pointA.x,pointA.y));
		ccDrawPoint(ccp(pointB.x,pointB.y));
		//ccDrawLine(ccp(pointA.x,pointA.y),ccp(pointB.x,pointB.y));
	}
	//restore to white and default thickness
	glColor4f(1.0f,1.0f,1.0f,1.0f);
	glLineWidth(1);
	//glEnableClientState(GL_TEXTURE_2D);
	//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	//glEnableClientState(GL_COLOR_ARRAY);
}
*/

-(void)dealloc {
    /*
	for(int i=0;i<numPoints;i++) {
		[[vPoints objectAtIndex:i] release];
		if(i!=numPoints-1)
			[[vSticks objectAtIndex:i] release];
	}
	[vPoints removeAllObjects];
	[vSticks removeAllObjects];
    */
    
    //[self removeSprites];
    [ropeSprites release];
    
	[vPoints release];
	[vSticks release];
	[super dealloc];
}

@end
