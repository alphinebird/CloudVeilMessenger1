#import "TGDiscardEncryptedChatActor.h"

#import "ActionStage.h"
#import "TGTelegraph.h"

static NSMutableDictionary *processedChats()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

@interface TGDiscardEncryptedChatActor ()
{
    int64_t _encryptedConversationId;
}

@end

@implementation TGDiscardEncryptedChatActor

+ (NSString *)genericPath
{
    return @"/tg/encrypted/discardEncryptedChat/@";
}

- (void)execute:(NSDictionary *)options
{
    _encryptedConversationId = [options[@"encryptedConversationId"] longLongValue];
    if (processedChats()[@(_encryptedConversationId)] != nil)
        [ActionStageInstance() actionCompleted:self.path result:nil];
    else
        self.cancelToken = [TGTelegraphInstance doRejectEncryptedChat:_encryptedConversationId actor:(TGSynchronizeActionQueueActor *)self];
}

- (void)rejectEncryptedChatSuccess
{
    processedChats()[@(_encryptedConversationId)] = [NSNumber numberWithBool:true];
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)rejectEncryptedChatFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
