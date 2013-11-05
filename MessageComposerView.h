#import <UIKit/UIKit.h>

@protocol MessageComposerViewDelegate <NSObject>

- (void)messageComposerSendMessageClickedWithMessage:(NSString*)message;
- (void)messageComposerFrameDidChange:(CGRect)frame withAnimationDuration:(float)duration;

@optional
- (void)messageComposerUserTyping;

@end

@interface MessageComposerView : UIView<EmoticonReactionKeyboardViewDelegate, ImagePickerDelegate, UITextViewDelegate>

- (void)showSendButton;

@property(nonatomic, strong) id<MessageComposerViewDelegate> delegate;

@property(nonatomic, strong) IBOutlet PlaceHolderTextView* messageTextView;
@property(nonatomic, strong) IBOutlet UIProfileImageView* profileButton;
@property(nonatomic, strong) IBOutlet UIButton* sendButton;
@property(nonatomic, strong) IBOutlet UIButton* cameraButton;
@property(nonatomic, strong) IBOutlet UIButton* emojiButton;
@property(nonatomic, strong) IBOutlet UIView* textFieldContainerView;
@property(nonatomic, strong) IBOutlet UIImageView* textFieldImageView;
@property(nonatomic, strong) IBOutlet UIImageView* chatBubbleTail;
@property(nonatomic, strong) IBOutlet NSString *messageTextPlaceholder;
@property(nonatomic, strong) EmoticonReactionKeyboardView* emoticonReactionKeyboard;
@property(nonatomic) BOOL showingCustomKeyboard;
@property(nonatomic) BOOL showingSendButton;
@property(nonatomic, strong) ImagePickerController* imagePicker;

- (void)toggleCustomKeyboardButtonsHidden:(BOOL)hidden;;
- (void)showCustomKeyboard;
- (void)hideCustomKeyboard;
- (IBAction)sendClicked:(id)sender;
// needed for loading drafts
- (void)resizeTextViewForText:(NSString*)text;
- (void)scrollTextViewToBottom;
@end

