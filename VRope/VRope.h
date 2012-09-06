/*
 
 MIT License.
 
 Copyright (c) 2012 Flightless Ltd.  
 Copyright (c) 2010 Clever Hamster Games.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
*/

//
//  VRope.h - 0.5
//
//  Modified by Flightless www.flightless.co.nz 20/4/2012
//  Used in Flightless's game Bee Leader - http://www.flightless.co.nz/beeleader 
//
//  Modifications:
//  added retina fix (tested on iPhone 4s and iPad 3)
//  added global gravity for points, making it easy to update gravity for the entire rope system
//  added individual gravity support for points, making it easy to update gravity for each specific point
//  added support to init/attach rope to a joint, rather than two bodies, allowing the rope to join away from body origins
//  supports cocos2d 2.0
//
//  TODO:
//  add nicer gravity variables to ropes and points, rather than using a global gravity hack in VPoint
//  remove references to older/deprecated cocos2d classes/methods, pre-cocos 1.x

/*

 VPoint additions;

 [VPoint setGravityX:gx Y:gy]; // global gravity for all VPoints
 [VPoint getGravity];
 [vpoint applyGravity:dt gx:gx gy:gy]; // (internal) time delta and specific gravity for point
 [vpoint applyGravityxdt:gxdt gydt:gydt]; // (internal) pre-integrated step with specific gravity for point

 VRope additions;

 [[VRope alloc] init:joint batchNode:ropeBatchNode]; // init rope using a joint between two bodies
 [verletRope updateWithPreIntegratedGravity:dt]; // update rope by pre-integrating the gravity each step (optimised for changing gravity)
 [verletRope updateWithPreIntegratedGravity:dt gravityX:gravityX gravityY:gravityY]; // update rope by pre-integrating the gravity each step (optimised for changing gravity)
 [verletRope updateWithPreIntegratedOriginGravity:dt;] // update rope by pre-integrating the gravity each step (optimised for changing gravity), nb. uses gravity at origin (0,0)
 [verletRope updateWithPoints:pointA pointB:pointB gxdt:gxdt gydt:gydt; // (internal) update with support for pre-integrating the gravity each step (optimised for changing gravity)

 
 CREATE:
 // create joint between bodyA and bodyB
 b2RopeJoint* bodyAbodyBJoint = (b2RopeJoint*)b2World->CreateJoint(&bodyAbodyBJointDef);
 
 // create batchnode and vrope for joint
 CCSpriteBatchNode *ropeSegmentBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"ropesegment.png"];
 [self addChild:ropeSegmentBatchNode];
 VRope *verletRope = [[VRope alloc] init:bodyAbodyBJoint batchNode:ropeSegmentBatchNode];
 
 // or, create vrope between bodies
 VRope *verletRope = [[VRope alloc] init:body1 body2:body2 batchNode:ropeSegmentBatchNode];
 
 UPDATING:
 // update vrope (like original VRope, without any changing gravity)
 [verletRope update:dt];
 [verletRope updateSprites]; // nb. doesn't need to be in draw loop (could be called internally)
 
 // update vrope (using global gravity, nb. will affect all ropes!)
 CGPoint newGravity = ccp(0.7f,0.7f); // update gravity to something else (based on your simulation, interactivity)
 [VPoint setGravityX:newGravity.x Y:newGravity.y];
 [verletRope update:dt];
 [verletRope updateSprites]; // nb. doesn't need to be in draw loop (could be called internally)
 
 // update vrope (example using gravity for specific ropes or points, the gravity component is preintegrated before being applied to points)
 CGPoint newGravity = ccp(0.7f,0.7f); // update gravity to something else (based on your simulation, interactivity)
 [verletRope updateWithPreIntegratedGravity:dt gravityX:newGravity gravityY:newGravity]; // update gravity for each rope (based on your simulation, interactivity)
 [verletRope updateSprites]; // nb. doesn't need to be in draw loop (could be called internally)
 
 nb. the example [verletRope updateWithPreIntegratedOriginGravity:dt] has gravity origin at (0,0) and uses
     an average of bodyA and bodyB positions to determine which way is 'down' for each rope.
     This was used for Flightless's game Bee Leader - http://www.flightless.co.nz/beeleader 
     Obviously, you can change this method or add others to suit your own simulation.
 
*/


//
//  VRope.h - 0.3
//
//  Updated by patrick on 28/10/2010.
//

/*
Verlet Rope for cocos2d
 
Visual representation of a rope with Verlet integration.
The rope can't (quite obviously) collide with objects or itself.
This was created to use in conjuction with Box2d's new b2RopeJoint joint, although it's not strictly necessary.
Use a b2RopeJoint to physically constrain two bodies in a box2d world and use VRope to visually draw the rope in cocos2d. (or just draw the rope between two moving or static points)

*** IMPORTANT: VRope does not create the b2RopeJoint. You need to handle that yourself, VRope is only responsible for rendering the rope
*** By default, the rope is fixed at both ends. If you want a free hanging rope, modify VRope.h and VRope.mm to only take one body/point and change the update loops to include the last point. 
 
HOW TO USE:
Import VRope.h into your class
 
CREATE:
To create a verlet rope, you need to pass two b2Body pointers (start and end bodies of rope)
and a CCSpriteBatchNode that contains a single sprite for the rope's segment. 
The sprite should be small and tileable horizontally, as it gets repeated with GL_REPEAT for the necessary length of the rope segment.

ex:
CCSpriteBatchNode *ropeSegmentSprite = [CCSpriteBatchNode batchNodeWithFile:@"ropesegment.png" ]; //create a spritesheet 
[self addChild:ropeSegmentSprite]; //add batchnode to cocos2d layer, vrope will be responsible for creating and managing children of the batchnode, you "should" only have one batchnode instance
VRope *verletRope = [[VRope alloc] init:bodyA pointB:bodyB spriteSheet:ropeSegmentSprite];

 
UPDATING:
To update the verlet rope you need to pass the time step
ex:
[verletRope updateRope:dt];

 
DRAWING:
From your layer's draw loop, call the updateSprites method
ex:
[verletRope updateSprites];

Or you can use the debugDraw method, which uses cocos2d's ccDrawLine method
ex:
[verletRope debugDraw];
 
REMOVING:
To remove a rope you need to call the removeSprites method and then release:
[verletRope removeSprites]; //remove the sprites of this rope from the spritebatchnode
[verletRope release];
 
There are also a few helper methods to use the rope without box2d bodies but with CGPoints only.
Simply remove the Box2D.h import and use the "WithPoints" methods.
 

For help you can find me on the cocos2d forums, username: patrickC
Good luck :) 

*/
#import <Foundation/Foundation.h>
#import "VPoint.h"
#import "VStick.h"
#import "cocos2d.h"
#import "Box2D.h"

//PTM_RATIO defined here is for testing purposes, it should obviously be the same as your box2d world or, better yet, import a common header where PTM_RATIO is defined
#define PTM_RATIO 32

@interface VRope : NSObject {
	int numPoints;
	NSMutableArray *vPoints;
	NSMutableArray *vSticks;
	NSMutableArray *ropeSprites;
	CCSpriteBatchNode* spriteSheet;
	float antiSagHack;
	#ifdef BOX2D_H
	b2Body *bodyA;
	b2Body *bodyB;
    b2Joint *jointAB;
	#endif
}
#ifdef BOX2D_H
-(id)init:(b2Body*)body1 body2:(b2Body*)body2 batchNode:(CCSpriteBatchNode*)ropeBatchNode;
-(id)init:(b2Joint*)joint batchNode:(CCSpriteBatchNode*)ropeBatchNode; // Flightless, init rope using a joint between two bodies
-(void)update:(float)dt;
-(void)updateWithPreIntegratedGravity:(float)dt; // Flightless, update rope by pre-integrating the gravity each step (optimised for changing gravity)
-(void)updateWithPreIntegratedGravity:(float)dt gravityX:(float)gravityX gravityY:(float)gravityY; // Flightless, update rope by pre-integrating the gravity each step (optimised for changing gravity)
-(void)updateWithPreIntegratedOriginGravity:(float)dt; // Flightless, update rope by pre-integrating the gravity each step (optimised for changing gravity)
-(void)reset;
#endif
-(id)initWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB spriteSheet:(CCSpriteBatchNode*)spriteSheetArg;
-(void)createRope:(CGPoint)pointA pointB:(CGPoint)pointB;
-(void)resetWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB;
-(void)updateWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB dt:(float)dt;
-(void)updateWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB gxdt:(float)gxdt gydt:(float)gydt; // Flightless, update with support for pre-integrating the gravity each step (optimised for changing gravity)
//-(void)debugDraw; // opengl es 1.1 only
-(void)updateSprites;
-(void)removeSprites;

@end
