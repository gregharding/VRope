VRope
=====

VRope 0.4 for Cocos2d.

Based on VRope 0.3 by patrickC [www.cocos2d-iphone.org/archives/1112](http://www.cocos2d-iphone.org/archives/1112).

Modifications
--------------
- added retina fix
- added global gravity for points, making it easy to update gravity for the entire rope system
- added individual gravity for points, making it easy to update gravity for each specific point
- added support to init/attach rope to a joint, rather than two bodies, allowing the rope to join away from body origins

TODO
-----
- add nicer gravity variable to each rope, rather than use global gravity in VPoint

USAGE
-----

*CREATE*
`// create joint between bodyA and bodyB`
`b2RopeJoint* bodyAbodyBJoint = (b2RopeJoint*)b2World->CreateJoint(&bodyAbodyBJointDef);`
``
`// create batchnode, create vrope`
`CCSpriteBatchNode *ropeSegmentBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"ropesegment.png" ];`
`[self addChild:ropeSegmentBatchNode];`
`VRope *verletRope = [[VRope alloc] init:bodyAbodyBJoint batchNode:ropeSegmentBatchNode];`

 
*UPDATING*
> // update vrope (like original VRope, without any changing gravity)
> [verletRope update:dt];
> [verletRope updateSprites]; // doesn't need to be in draw loop (could be called internally)
 
> // update vrope (using global gravity, nb. will affect all ropes!)
> CGPoint newGravity = ccp(0.7f,0.7f); // update gravity to something else (based on your simulation, interactivity)
> [VPoint setGravityX:newGravity.x Y:newGravity.y];
> [verletRope update:dt];
> [verletRope updateSprites]; // doesn't need to be in draw loop (could be called internally)
 
> // update vrope (example using gravity for specific ropes or points, the gravity component is preintegrated before being applied to points)
> CGPoint newGravity = ccp(0.7f,0.7f); // update gravity to something else (based on your simulation, interactivity)
> [verletRope updateWithPreIntegratedGravity:dt gravityX:newGravity gravityY:newGravity]; // update gravity for each rope (based on your simulation, interactivity)
> [verletRope updateSprites]; // doesn't need to be in draw loop (could be called internally)
 
nb. the example [verletRope updateWithPreIntegratedOriginGravity:dt] has gravity origin at (0,0) and uses
  an average of bodyA and bodyB positions to determine which way is 'down' for each rope.
  This was used for Flightless's game Bee Leader - http://www.flightless.co.nz/beeleader 
  Obviously, you can change this method or add others to suit your own simulation.
  