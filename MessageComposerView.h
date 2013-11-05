#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol MessageComposerViewDelegate <NSObject>
- (void)messageComposerSendMessageClickedWithMessage:(NSString*)message;
- (void)messageComposerFrameDidChange:(CGRect)frame withAnimationDuration:(float)duration;
@optional
- (void)messageComposerUserTyping;
@end

@interface MessageComposerView : UIView<UITextViewDelegate>
@property(nonatomic, strong) id<MessageComposerViewDelegate> delegate;
@property(nonatomic, strong) IBOutlet UITextView *messageTextView;
@property(nonatomic, strong) IBOutlet UIButton *sendButton;
@property(nonatomic, strong) IBOutlet UIView *textFieldContainerView;
@property(nonatomic, strong) IBOutlet UIImageView *textFieldImageView;
@property(nonatomic, strong) NSString *messageTextPlaceholder;
@property(nonatomic) BOOL showingSendButton;
- (IBAction)sendClicked:(id)sender;
- (void)showSendButton;
// needed for loading drafts
- (void)resizeTextViewForText:(NSString*)text;
- (void)scrollTextViewToBottom;
@end

