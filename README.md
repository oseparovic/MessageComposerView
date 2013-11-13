MessageComposerView
===================

If you find yourself needing a textview that sticks to the keyboard and does *not* disappear when the keyboard hides, you'll quickly find that there is no clean way of doing it. `MessageComposerView` is a custom view implementation that aims to fill that void. Rather that being an `inputAccessoryView` once added to your `ViewController` it will automatically "follow" the keyboard, handling rotation showing and hiding etc.

![](http://www.thegameengine.org/wp-content/uploads/2013/11/message_composer_quad_1.jpg)

Usage
=====
####Setup
In your header file:

1. Import the `MessageComosposerView.h` file
2. Add the `MessageComposerViewDelegate` delegate
3. Optionally create a `MessageComposerView` property for your message composer view.

Example:


    #import "MessageComposerView.h"
    @interface ViewController : UIViewController<MessageComposerViewDelegate>
    @property (nonatomic, strong) MessageComposerView *messageComposerView;
    @end

In your class file, instantiate and add `MessageComposerView` to the bottom of your view controller. Example: 

    self.messageComposerView = [[NSBundle mainBundle] loadNibNamed:@"MessageComposerView" owner:nil options:nil][0];
    self.messageComposerView.delegate = self;
    self.messageComposerView.frame = CGRectMake(0,
                                                self.view.frame.size.height - self.messageComposerView.frame.size.height,
                                                self.messageComposerView.frame.size.width,
                                                self.messageComposerView.frame.size.height);
    [self.view addSubview:self.messageComposerView];

####Delegation
The `MessageComposerViewDelegate` has several delegate methods:

1. `- (void)messageComposerSendMessageClickedWithMessage:(NSString*)message;`  
**Required** - Triggered whenever the user presses the send button. `message` is the text within the `UITextView` at the time the button was pressed.

2. `- (void)messageComposerFrameDidChange:(CGRect)frame withAnimationDuration:(float)duration;`  
**Optional** - Triggered whenever the UITextView frame is reconfigured. `frame` is the CGRect that was applied to the MessageViewComposer container.

3. `- (void)messageComposerUserTyping;`  
**Optional** - Triggered whenever the UITextView text changes.
