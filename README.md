MessageComposerView
===================

If you find yourself needing a `UITextView` that sticks to the keyboard similar to an `inputAccessoryView` that does *not* disappear when the keyboard hides, you'll quickly find that you'll likely have to build out a fairly time consuming custom view. MessageComposerView aims to save you all that setup time and headache and provide a simple, customizable implementation.

Rather that being an `inputAccessoryView`, it is a custom `UIView` that will automatically "stick" the keyboard, handling rotation, text changes and keyboard state changes.

![](http://www.thegameengine.org/wp-content/uploads/2013/11/message_composer_quad_1.jpg)

Usage
-----
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

In your class file, instantiate and add `MessageComposerView` to the bottom of your view controller. You can do this via `initWithFrame:`

    // standard size is (320, 54) but a custom size will also be respected
    float defaultWidth  = 320;
    float defaultHeight = 54;
    CGRect subviewFrame = CGRectMake(0, self.view.frame.size.height-defaultHeight, defaultWidth, defaultHeight);
    self.messageComposerView = [[MessageComposerView alloc] initWithFrame:subviewFrame];
    [self.view addSubview:self.messageComposerView];

If you need to offset the MessageComposerView from the keyboard by a certain fixed amount you can use `initWithFrame:andKeyboardOffset:` instead. This can be useful when using a `UITabBarController` or when adding your own custom elements below the MessageComposerView.

    // standard size is (320, 54) but a custom size will also be respected
    float defaultWidth  = 320;
    float defaultHeight = 54;
    CGRect subviewFrame = CGRectMake(0, 0, defaultWidth, defaultHeight);
    self.messageComposerView = [[MessageComposerView alloc] initWithFrame:subviewFrame andKeyboardOffset:20];
    self.messageComposerView.delegate = self;
    [self.view addSubview:self.messageComposerView];

####Delegation
The `MessageComposerViewDelegate` has several delegate methods:

1. `- (void)messageComposerSendMessageClickedWithMessage:(NSString*)message;`  
**Required** - Triggered whenever the user presses the send button. `message` is the text within the `UITextView` at the time the button was pressed.

2. `- (void)messageComposerFrameDidChange:(CGRect)frame withAnimationDuration:(float)duration;`  
**Optional** - Triggered whenever the UITextView frame is reconfigured. `frame` is the CGRect that was applied to the MessageComposerView container.

3. `- (void)messageComposerUserTyping;`  
**Optional** - Triggered whenever the UITextView text changes.

How it works
------------

MessageComposerView tries to avoid hooking into `UIKeyboardWillShowNotification` and `UIKeyboardDidShowNotification` as I found them to be at times excessive and difficult to properly manipulate, especially when it came to rotation.
Instead the `UIKeyboardWillShowNotification` notification is used solely to dynamically determine the keyboard animation duration on your device before any animations occur.

The actual resizing of the views is handled via `layoutSubviews` and through the following `UITextViewDelegate` methods:

* `- (void)textViewDidBeginEditing:(UITextView*)textView`
* `- (void)textViewDidEndEditing:(UITextView*)textView` 

Contact
-------

If you need to contact me you can do so via my twitter [@alexgophermix](https://twitter.com/alexgophermix) or through my website [thegameengine.org](http://www.thegameengine.org/)
