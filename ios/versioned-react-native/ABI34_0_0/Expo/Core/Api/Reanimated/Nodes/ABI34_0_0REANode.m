#import "ABI34_0_0REANode.h"
#import "ABI34_0_0REANodesManager.h"

#import <ReactABI34_0_0/ABI34_0_0RCTDefines.h>

@interface ABI34_0_0REAUpdateContext ()

@property (nonatomic, nonnull) NSMutableArray<ABI34_0_0REANode *> *updatedNodes;
@property (nonatomic) NSUInteger loopID;

@end

@implementation ABI34_0_0REAUpdateContext

- (instancetype)init
{
  if ((self = [super init])) {
    _loopID = 1;
    _updatedNodes = [NSMutableArray new];
  }
  return self;
}

@end


@interface ABI34_0_0REANode ()

@property (nonatomic) NSUInteger lastLoopID;
@property (nonatomic) id memoizedValue;
@property (nonatomic, nullable) NSMutableArray<ABI34_0_0REANode *> *childNodes;

@end

@implementation ABI34_0_0REANode

- (instancetype)initWithID:(ABI34_0_0REANodeID)nodeID config:(NSDictionary<NSString *,id> *)config
{
  if ((self = [super init])) {
    _nodeID = nodeID;
    _lastLoopID = 0;
  }
  return self;
}

ABI34_0_0RCT_NOT_IMPLEMENTED(- (instancetype)init)

- (void)dangerouslyRescheduleEvaluate
{
  _lastLoopID = 0;
  [self markUpdated];
}

- (void)forceUpdateMemoizedValue:(id)value
{
  _memoizedValue = value;
  [self markUpdated];
}

- (id)evaluate
{
  return 0;
}

- (id)value
{
  if (_lastLoopID < _updateContext.loopID) {
    _lastLoopID = _updateContext.loopID;
    return (_memoizedValue = [self evaluate]);
  }
  return _memoizedValue;
}

- (void)addChild:(ABI34_0_0REANode *)child
{
  if (!_childNodes) {
    _childNodes = [NSMutableArray new];
  }
  if (child) {
    [_childNodes addObject:child];
    [self dangerouslyRescheduleEvaluate];
  }
}

- (void)removeChild:(ABI34_0_0REANode *)child
{
  if (child) {
    [_childNodes removeObject:child];
  }
}

- (void)markUpdated
{
  [_updateContext.updatedNodes addObject:self];
  [self.nodesManager postRunUpdatesAfterAnimation];
}

+ (NSMutableArray<ABI34_0_0REANode *> *)updatedNodes
{
  static NSMutableArray<ABI34_0_0REANode *> *updatedNodes;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    updatedNodes = [NSMutableArray new];
  });
  return updatedNodes;
}

+ (void)findAndUpdateNodes:(nonnull ABI34_0_0REANode *)node
            withVisitedSet:(NSMutableSet<ABI34_0_0REANode *> *)visitedNodes
            withFinalNodes:(NSMutableArray<id<ABI34_0_0REAFinalNode>> *)finalNodes
{
  if ([visitedNodes containsObject:node]) {
    return;
  } else {
    [visitedNodes addObject:node];
  }
  for (ABI34_0_0REANode *child in node.childNodes) {
    [self findAndUpdateNodes:child withVisitedSet:visitedNodes withFinalNodes:finalNodes];
  }
  if ([node conformsToProtocol:@protocol(ABI34_0_0REAFinalNode)]) {
    [finalNodes addObject:(id<ABI34_0_0REAFinalNode>)node];
  }
}

+ (void)runPropUpdates:(ABI34_0_0REAUpdateContext *)context
{
  NSMutableSet<ABI34_0_0REANode *> *visitedNodes = [NSMutableSet new];
  NSMutableArray<id<ABI34_0_0REAFinalNode>> *finalNodes = [NSMutableArray new];
  for (NSUInteger i = 0; i < context.updatedNodes.count; i++) {
    [self findAndUpdateNodes:context.updatedNodes[i]
              withVisitedSet:visitedNodes
              withFinalNodes:finalNodes];
    if (i == context.updatedNodes.count - 1) {
      while (finalNodes.count > 0) {
        // NSMutableArray used for stack implementation
        [[finalNodes lastObject] update];
        [finalNodes removeLastObject];
      }
    }
  }

  [context.updatedNodes removeAllObjects];
  context.loopID++;
}

@end
