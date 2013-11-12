#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "UIProfileImageView.h"

@protocol MessageComposerViewDelegate <NSObject>
- (void)messageComposerSendMessageClickedWithMessage:(NSString*)message;
@optional
- (void)messageComposerFrameDidChange:(CGRect)frame withAnimationDuration:(float)duration;
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
- (void)resizeTextViewForText:(NSString*)text;
- (void)resizeTextViewForText:(NSString*)text animated:(BOOL)animated;
- (void)scrollTextViewToBottom;

- (void)hideCustomKeyboard;
- (void)showCustomKeyboard;
- (void)toggleCustomKeyboardButtonsHidden:(BOOL)hidden;
@property(nonatomic, strong) UIProfileImageView *profileButton;
@property(nonatomic) BOOL showingCustomKeyboard;
@end

