//
//  TKKeyboardTableViewController.m
//  Created by Devin Ross on 10/1/13.
//
/*
 
 tapku || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKKeyboardTableViewController.h"
#import "UIDevice+TKCategory.h"

@interface TKKeyboardTableViewController ()
@property (nonatomic,assign) UIEdgeInsets originalContentInsets;
@end

@implementation TKKeyboardTableViewController

- (id) init{
	if(!(self=[super init])) return nil;
	self.scrollToTextField = YES;
	self.hideKeyboardOnScroll = [UIDevice phoneIdiom];
	return self;
}
- (id) initWithStyle:(UITableViewStyle)style{
	if(!(self=[super initWithStyle:style])) return nil;
	self.scrollToTextField = YES;
	self.hideKeyboardOnScroll = [UIDevice phoneIdiom];
	return self;
}
- (void) dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark View Lifecycle
- (void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}
- (void) viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark Move ScrollView
- (void) keyboardWillAppear:(NSNotification*)sender{
	_scrollLock = YES;
	
	self.originalContentInsets = self.tableView.contentInset;
	
	CGRect keyboardFrame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIWindow *window = [UIApplication sharedApplication].windows[0];
	UIView *mainSubviewOfWindow = window.rootViewController.view;
	CGRect keyboardFrameConverted = [mainSubviewOfWindow convertRect:keyboardFrame fromView:window];
	CGRect rect = [self.view convertRect:keyboardFrameConverted fromView:mainSubviewOfWindow];
	rect = CGRectIntersection(rect, self.view.bounds);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.05];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	self.tableView.contentInset = self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, rect.size.height, 0);
	[UIView commitAnimations];
	
}
- (void) keyboardWillDisappear:(NSNotification*)sender{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	self.tableView.contentInset = self.originalContentInsets;
	[UIView commitAnimations];
	
	self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}
- (void) textViewDidBeginEditing:(UITextView *)textView{
	_scrollLock = YES;
	[self performSelector:@selector(scrollToView:) withObject:textView afterDelay:0.1];
}
- (void) textFieldDidBeginEditing:(UITextField *)textField{
	_scrollLock = YES;
	[self performSelector:@selector(scrollToView:) withObject:textField afterDelay:0.1];
}



#pragma mark UIScrollView Delegate
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
	if(self.hideKeyboardOnScroll)
		[self resignResponders];
}
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	_scrollLock = NO;
}
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
	_scrollLock = NO;
}
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if(!decelerate) _scrollLock = NO;
}
- (void) _unlock{
	dispatch_async(dispatch_get_main_queue(), ^{
		_scrollLock = NO;
	});
}

#pragma mark Public Functions
- (void) scrollToView:(UIView*)view{
	if(!self.scrollToTextField) return;
	CGRect rect = [view convertRect:view.bounds toView:self.tableView];
	rect = CGRectInset(rect, 0, -30);
	[self.tableView scrollRectToVisible:rect animated:YES];
	[self performSelector:@selector(_unlock) withObject:nil afterDelay:0.35];
}
- (BOOL) resignResponders{
	if(self.scrollLock) return NO;
	return YES;
}

@end
