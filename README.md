VRope 0.5
=========

A simple rope system for [cocos2d](http://www.cocos2d-iphone.org) using [Verlet Integration](http://en.wikipedia.org/wiki/Verlet_integration), based on examples by [YoAmbulante.com](http://www.yoambulante.com/en/labs/verlet.php).

VRope 0.5 for cocos2d 2.0 by [Flightless](http://www.flightless.co.nz). Used in the games [Bee Leader](http://www.flightless.co.nz/beeleader) (released in May 2012) and [Bee Leader Free](http://www.flightless.co.nz/beeleader) (released in August 2012) for iOS (iPhone/iPad/iPod Touch).

Update of VRope 0.3 for cocos2d 0.99.x by [patrickC](http://cleverhamstergames.com), posted on the cocos site at [www.cocos2d-iphone.org/archives/1112](http://www.cocos2d-iphone.org/archives/1112).

### Modifications:

- added retina fix (tested on iPhone 4s and iPad 3)
- added global gravity for points, making it easy to update gravity for the entire rope system
- added individual gravity support for points, making it easy to update gravity for each specific point
- added support to init/attach rope to a joint, rather than two bodies, allowing the rope to join away from body origins
- supports cocos2d 2.0

### TODO:
- add nicer gravity variables to ropes and points, rather than using a global gravity hack in VPoint
- remove references to older/deprecated cocos2d classes/methods, pre-cocos 1.x

Usage
-----

Refer to VRope.h for more information and usage examples, including the original VRope 0.3 usage.

### Create

    // create joint between bodyA and bodyB
    b2RopeJoint* bodyAbodyBJoint = (b2RopeJoint*)b2World->CreateJoint(&bodyAbodyBJointDef);
    
    // create batchnode and vrope for joint
    CCSpriteBatchNode *ropeSegmentBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"ropesegment.png"];
    [self addChild:ropeSegmentBatchNode];
    VRope *verletRope = [[VRope alloc] init:bodyAbodyBJoint batchNode:ropeSegmentBatchNode];
 
    // or, create vrope between bodies
    VRope *verletRope = [[VRope alloc] init:body1 body2:body2 batchNode:ropeSegmentBatchNode];
 
### Updating

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


nb. the example `[verletRope updateWithPreIntegratedOriginGravity:dt]` has gravity origin at (0,0) and uses
  an average of bodyA and bodyB positions to determine which way is 'down' for each rope.
  This was used in Flightless's game [Bee Leader](http://www.flightless.co.nz/beeleader).
  Obviously, you can change this method or add others to suit your own simulation.


License
-------

The original VRope 0.3 contained no licensing. This version of VRope uses the MIT License. We reserve the right to change this license based on any requests from the original author [patrickC](http://cleverhamstergames.com).

MIT License.

Copyright (c) 2012 Flightless Ltd.  
Copyright (c) 2010 Clever Hamster Games.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
