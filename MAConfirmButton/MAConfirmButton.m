//
//  MAConfirmButton.m
//
//  Created by Mike on 11-03-28.
//  Copyright 2011 Mike Ahmarani. All rights reserved.
//

#import "MAConfirmButton.h"
#import "UIColor-Expanded.h"

#define kHeight 26.0
#define kPadding 20.0
#define kFontSize 14.0

@interface MAConfirmButton ()

@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *confirmationString;
@property (nonatomic, retain) NSString *disabledString;
@property (nonatomic, retain) UIColor *tintColor;
@property (nonatomic, assign, getter = isSelected) BOOL selected;
@property (nonatomic, assign, getter = isConfirmed) BOOL confirmed;
@property (nonatomic, retain) CALayer* colorLayer;
@property (nonatomic, retain) CALayer* darkenLayer;
@property (nonatomic, retain) UIButton* cancelOverlayButton;

- (void)toggle;
- (void)setupLayers;
- (void)cancel;
- (void)lighten;
- (void)darken;

@end

@implementation MAConfirmButton

@synthesize titleString = mTitleString;
@synthesize confirmationString = mConfirmationString;
@synthesize disabledString = mDisabledString;
@synthesize tintColor = mTintColor;
@synthesize selected = mSelected;
@synthesize confirmed = mConfirmed;
@synthesize colorLayer = mColorLayer;
@synthesize darkenLayer = mDarkenLayer;
@synthesize cancelOverlayButton = mCancelOverlayButton;

- (void) dealloc
{
	[mTitleString release];
	[mConfirmationString release];
	[mDisabledString release];
	[mTintColor release];
    [mColorLayer release];
    [mDarkenLayer release];
    [super dealloc];
}

+ (MAConfirmButton*) buttonWithTitle: (NSString*) titleString confirm: (NSString*) confirmString
{	
	MAConfirmButton* button = [[[super alloc] initWithTitle: titleString confirm: confirmString] autorelease];	
	return button;
}

+ (MAConfirmButton*) buttonWithDisabledTitle: (NSString*) disabledString
{
	MAConfirmButton* button = [[[super alloc] initWithDisabledTitle: disabledString] autorelease];	
	return button;
}

- (id) initWithDisabledTitle: (NSString*) disabledString
{
	self = [super initWithFrame:CGRectZero];
	if( self != nil )
    {
		mDisabledString = [disabledString copy];
		
		self.layer.needsDisplayOnBoundsChange = YES;
		
		CGSize size = [mDisabledString sizeWithFont: [UIFont boldSystemFontOfSize: kFontSize]];
		CGRect frameRect = self.frame;
		frameRect.size.height = kHeight;
		frameRect.size.width = size.width+kPadding;
		self.frame = frameRect;
		
		[self setTitle: mDisabledString forState:UIControlStateNormal];
		[self setTitleColor: [UIColor colorWithWhite: 0.6f alpha: 1.0f] forState: UIControlStateNormal];
		[self setTitleShadowColor: [UIColor colorWithWhite: 1.0f alpha: 1.0f] forState: UIControlStateNormal];		
		
		self.titleLabel.textAlignment = UITextAlignmentCenter;
		self.titleLabel.shadowOffset = CGSizeMake( 0.0f, 1.0f );
		self.titleLabel.backgroundColor = [UIColor clearColor];
		self.titleLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
		mTintColor = [[UIColor colorWithWhite: 0.85f alpha: 1.0f] retain];	
		
		[self setupLayers];
	}	
	return self;	
}

- (id) initWithTitle: (NSString*) titleString confirm: (NSString*) confirmString
{
	self = [super initWithFrame:CGRectZero];
	if( self != nil )
    {
		mTitleString = [titleString copy];
		mConfirmationString = [confirmString copy];
		
		self.layer.needsDisplayOnBoundsChange = YES;
		
		CGSize size = [mTitleString sizeWithFont: [UIFont boldSystemFontOfSize: kFontSize]];
		CGRect frameRect = self.frame;
		frameRect.size.height = kHeight;
		frameRect.size.width = size.width + kPadding;
		self.frame = frameRect;
		
		[self setTitle: mTitleString forState: UIControlStateNormal];
		[self setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];		
		[self setTitleShadowColor: [UIColor colorWithWhite: 0.0f alpha: 0.5f] forState: UIControlStateNormal];
		
		self.titleLabel.textAlignment = UITextAlignmentCenter;
		self.titleLabel.shadowOffset = CGSizeMake( 0.0f, -1.0f );
		self.titleLabel.backgroundColor = [UIColor clearColor];
		self.titleLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
		mTintColor = [[UIColor colorWithRed: 0.220f green: 0.357f blue: 0.608f alpha: 1.0f] retain];
		
		[self setupLayers];
	}	
	return self;
}

- (void) toggle
{		
	self.titleLabel.alpha = 0;
	
	CGSize newButtonSize = CGSizeZero;

	if( self.disabledString )
    {
		[self setTitle: self.disabledString forState: UIControlStateNormal];
		[self setTitleColor: [UIColor colorWithWhite: 0.6f alpha: 1.0f] forState: UIControlStateNormal];
		[self setTitleShadowColor: [UIColor colorWithWhite: 1.0f alpha: 1.0f] forState: UIControlStateNormal];
		self.titleLabel.shadowOffset = CGSizeMake( 0.0f, 1.0f );
		newButtonSize = [self.disabledString sizeWithFont: [UIFont boldSystemFontOfSize: kFontSize]];
	}
    else if( self.selected )
    {
		[self setTitle: self.confirmationString forState: UIControlStateNormal];		
		newButtonSize = [self.confirmationString sizeWithFont: [UIFont boldSystemFontOfSize: kFontSize]];
	}
    else 
    {
		[self setTitle: self.titleString forState: UIControlStateNormal];
		newButtonSize = [self.titleString sizeWithFont: [UIFont boldSystemFontOfSize: kFontSize]];
	}
	
	newButtonSize.width += kPadding;
	float offset = newButtonSize.width - self.frame.size.width;
	
	[CATransaction begin];
	[CATransaction setAnimationDuration: 0.25f];
	[CATransaction setCompletionBlock: 
     ^{
		//Readjust button frame for new touch area, move layers back now that animation is done
		
		CGRect frameRect = self.frame;
		frameRect.origin.x = frameRect.origin.x - offset;
		frameRect.size.width = frameRect.size.width + offset;
		self.frame = frameRect;
		
		[CATransaction setDisableActions:YES];
		for(CALayer *layer in self.layer.sublayers){
			CGRect rect = layer.frame;
			rect.origin.x = rect.origin.x+offset;
			layer.frame = rect;
		}
		[CATransaction commit];
		
		self.titleLabel.alpha = 1.0f;
		
	}];
	
	UIColor* greenColor = [UIColor colorWithRed: 0.439f green: 0.741f blue: 0.314f alpha: 1.0f];
	
	//Animate color change
	CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
	colorAnimation.removedOnCompletion = NO;
	colorAnimation.fillMode = kCAFillModeForwards;
	
	if( self.disabledString )
    {
		colorAnimation.fromValue = (id)[greenColor CGColor];
		colorAnimation.toValue = (id)[[UIColor colorWithWhite: 0.85f alpha: 1.0f] CGColor];
	}
    else
    {
		colorAnimation.fromValue = self.selected ? (id)[self.tintColor CGColor] : (id)[greenColor CGColor];
		colorAnimation.toValue = self.selected ? (id)[greenColor CGColor] : (id)[self.tintColor CGColor];	
	}
	
	[self.colorLayer addAnimation: colorAnimation forKey: @"colorAnimation"];
	
	//Animate layer scaling
	for( CALayer* layer in self.layer.sublayers )
    {
		CGRect rect = layer.frame;
		rect.origin.x = rect.origin.x-offset;
		rect.size.width = rect.size.width+offset;
		layer.frame = rect;
	}
	
	[CATransaction commit];

	[self setNeedsDisplay];
}

- (void) setupLayers
{
	CAGradientLayer* bevelLayer = [CAGradientLayer layer];
	bevelLayer.frame = CGRectMake( 0.0f, 0.0f, CGRectGetWidth( self.frame ), CGRectGetHeight( self.frame ) );		
	bevelLayer.colors = [NSArray arrayWithObjects: (id)[[UIColor colorWithWhite: 0.0f alpha: 0.5f] CGColor], [[UIColor whiteColor] CGColor], nil];
	bevelLayer.cornerRadius = 4.0f;
	bevelLayer.needsDisplayOnBoundsChange = YES;
	
	self.colorLayer = [CALayer layer];
	self.colorLayer.frame = CGRectMake( 0.0f, 1.0f, CGRectGetWidth( self.frame ), CGRectGetHeight( self.frame ) - 2.0f);		
	self.colorLayer.borderColor = [[UIColor colorWithWhite: 0 alpha: 0.1f] CGColor];
	self.colorLayer.backgroundColor = [self.tintColor CGColor];
	self.colorLayer.borderWidth = 1.0f;
	self.colorLayer.cornerRadius = 4.0f;
	self.colorLayer.needsDisplayOnBoundsChange = YES;		
	
	CAGradientLayer* colorGradient = [CAGradientLayer layer];
	colorGradient.frame = CGRectMake( 0.0f, 1.0f, CGRectGetWidth( self.frame ), CGRectGetHeight( self.frame ) - 2.0f );		
	colorGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite: 1.0f alpha: 0.1f] CGColor], [[UIColor colorWithWhite: 0.2f alpha: 0.1f] CGColor] , nil];		
	colorGradient.locations = [NSArray arrayWithObjects: [NSNumber numberWithFloat: 0.0f], [NSNumber numberWithFloat: 1.0f], nil];		
	colorGradient.cornerRadius = 4.0f;
	colorGradient.needsDisplayOnBoundsChange = YES;	
	
	[self.layer addSublayer: bevelLayer];
	[self.layer addSublayer: self.colorLayer];
	[self.layer addSublayer: colorGradient];
	[self bringSubviewToFront: self.titleLabel];
	
}

- (void) setSelected: (BOOL) selected
{	
	mSelected = selected;
	[self toggle];
}

- (void) disableWithTitle: (NSString*) disabledString
{
	self.disabledString = disabledString;
	[self toggle];	
}

- (void) setAnchor: (CGPoint) anchor
{
	//Top-right point of the view (MUST BE SET LAST)
	CGRect rect = self.frame;
	rect.origin = CGPointMake(anchor.x - rect.size.width, anchor.y);
	self.frame = rect;
}

- (void) setTintColor: (UIColor*) color
{
	mTintColor = [[UIColor colorWithHue: color.hue saturation: color.saturation + 0.15f brightness: color.brightness alpha: 1] retain];
	self.colorLayer.backgroundColor = [self.tintColor CGColor];
	[self setNeedsDisplay];
}

- (void) darken
{
	self.darkenLayer = [CALayer layer];
	self.darkenLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight( self.frame ) );
	self.darkenLayer.backgroundColor = [[UIColor colorWithWhite: 0.0f alpha: 0.2f] CGColor];
	self.darkenLayer.cornerRadius = 4.0f;
	self.darkenLayer.needsDisplayOnBoundsChange = YES;
	[self.layer addSublayer: self.darkenLayer];
}

- (void) lighten
{
	if( self.darkenLayer )
    {
		[self.darkenLayer removeFromSuperlayer];
		self.darkenLayer = nil;
	}
}

- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event
{
	if( !self.disabledString && !self.confirmationString )
    {
		[self darken];
	}
	[super touchesBegan: touches withEvent: event];
}

- (void) touchesEnded: (NSSet*) touches withEvent: (UIEvent*) event
{
	
	if( !self.disabledString && !self.confirmed )
    {
		if( !CGRectContainsPoint( self.frame, [[touches anyObject] locationInView: self.superview] ) )
        {
			[self lighten];
			[super touchesCancelled: touches withEvent: event];
		}
        else if( self.selected )
        {
			[self lighten];
			self.confirmed = YES;
			[self.cancelOverlayButton removeFromSuperview];
			self.cancelOverlayButton = nil;
			[super touchesEnded:touches withEvent:event];
		}
        else
        {
			[self lighten];			
			self.selected = YES;		
			self.cancelOverlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[self.cancelOverlayButton setFrame: CGRectMake( 0.0f, 0.0f, 1024.0f, 1024.0f )];
			[self.cancelOverlayButton addTarget: self action: @selector( cancel ) forControlEvents: UIControlEventTouchDown];
			[self.superview addSubview: self.cancelOverlayButton ];
			[self.superview bringSubviewToFront: self];
		}
	}
}

- (void) cancel
{
	if( self.cancelOverlayButton )
    {
		[self.cancelOverlayButton removeFromSuperview];
		self.cancelOverlayButton = nil;	
	}	
	self.selected = NO;
}

@end
