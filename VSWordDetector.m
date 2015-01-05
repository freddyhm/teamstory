//
//  VSWordDetector.m
//  VSWordDetector
//
//  Created by TheTiger on 05/02/14.
//  Copyright (c) 2014 TheTiger. All rights reserved.
//

#import "VSWordDetector.h"
@interface VSWordDetector ()

@property (strong, nonatomic) id <VSWordDetectorDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *words;
@property (strong, nonatomic) NSMutableArray *wordAreas;

@end

@implementation VSWordDetector
@synthesize delegate = _delegate;
@synthesize words = _words;
@synthesize wordAreas = _wordAreas;

#pragma mark - Initializaiton
-(id)initWithDelegate:(id<VSWordDetectorDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
    }
    
    return self;
}

#pragma mark - Adding Detector on view
-(void)addOnView:(id)view
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    if ([view isKindOfClass:[UITextView class]])
    {
        [view addGestureRecognizer:tapGesture];
        
        UITextView *textView = (UITextView *)view;
        textView.userInteractionEnabled = YES;
        textView.editable = NO;
        textView.scrollEnabled = NO;
    }
    else if ([view isKindOfClass:[UILabel class]])
    {
        [view addGestureRecognizer:tapGesture];
        
        UILabel *label = (UILabel *)view;
        label.userInteractionEnabled = YES;
    }
}

#pragma mark - Tapped
-(void)tapped:(UIGestureRecognizer *)recognizer
{
    if ([recognizer.view isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView *)recognizer.view;
        
        NSLayoutManager *layoutManager = textView.layoutManager;
        CGPoint location = [recognizer locationInView:textView];
        location.x -= textView.textContainerInset.left;
        location.y -= textView.textContainerInset.top;
        
        
        
        // FIND THE CHARACTER WHICH HAVE BEEN TAPPED
        
        NSInteger characterIndex = [layoutManager characterIndexForPoint:location inTextContainer:textView.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
        if (characterIndex < textView.textStorage.length)
        {
            NSString *word = [self tappedWordInTextView:textView fromIndex:characterIndex];
            if ([self.delegate respondsToSelector:@selector(wordDetector:detectWord:)])
            {
                [self.delegate wordDetector:self detectWord:word];
            }
        }
    }
    else if ([recognizer.view isKindOfClass:[UILabel class]])
    {
        UILabel *label = (UILabel *)recognizer.view;
        CGPoint location = [recognizer locationInView:label];
        
    
        // GETTING ALL WORDS OF LABEL
        self.words = nil;
        self.words = [[[label text] componentsSeparatedByString:@" "] mutableCopy];
        
        self.wordAreas = nil;
        self.wordAreas = [[NSMutableArray alloc] init];
        
        __block CGPoint drawPoint = CGPointMake(0, 0);
        CGRect rect = [label frame];
        
        CGRect spaceRect = [@" " boundingRectWithSize:rect.size
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:label.font}
                                              context:nil];
        
        CGSize space = spaceRect.size;
        
        // GETTING AREA OF EACH WORD OF LABEL
        [self.words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
            
            UIFont *font = [label font];
            CGSize size = [word sizeWithAttributes:@{NSFontAttributeName:font}];
            
            if(drawPoint.x + size.width > rect.size.width) {
                drawPoint = CGPointMake(0, drawPoint.y + size.height);
            }
            
            [self.wordAreas addObject:[NSValue valueWithCGRect:CGRectMake(drawPoint.x, drawPoint.y, size.width, size.height)]];
            
            drawPoint = CGPointMake(drawPoint.x + size.width + space.width, drawPoint.y);
        }];

        // NOW FINDING THE WORD OF TAPPED AREA
        [self.wordAreas enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
            CGRect area = [obj CGRectValue];
            if (CGRectContainsPoint(area, location)) {
                if([self.delegate respondsToSelector:@selector(wordDetector:detectWord:)]){
                    NSString *word = [self.words objectAtIndex:idx];
                    [self.delegate wordDetector:self detectWord:word];
                }
                *stop = YES;
            }
        }];

        
    }
}

// ONLY FOR TEXT VIEW
-(NSString *)tappedWordInTextView:(UITextView *)textView fromIndex:(NSUInteger)index
{
    NSMutableString *fString = [[NSMutableString alloc] init];
    NSMutableString *sString = [[NSMutableString alloc] init];
    
    // GET STRING BEFORE TAPPED CHARACTER UNTIL SPACE
    
    for (NSInteger i=index; i>=0; i--)
    {
        unichar character = [textView.text characterAtIndex:i];
        NSInteger asciiValue = [[NSString stringWithFormat:@"%d", character] integerValue];
        if (asciiValue == 32)
        {
            // THIS IS SPACE
            break;
        }
        
        [fString appendFormat:@"%c", character];
    }
    
    // REVERSE fString
    
    NSMutableString *reversedString = [NSMutableString stringWithCapacity:[fString length]];
    
    [fString enumerateSubstringsInRange:NSMakeRange(0,[fString length])
                                options:(NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences)
                             usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                 [reversedString appendString:substring];
                             }];
    fString = reversedString;
    
    // GET STRING AFTER TAPPED CHARACTER UNTIL SPACE
    
    for (NSInteger i=index+1; i<textView.text.length; i++)
    {
        unichar character = [textView.text characterAtIndex:i];
        NSInteger asciiValue = [[NSString stringWithFormat:@"%d", character] integerValue];
        if (asciiValue == 32)
        {
            // THIS IS SPACE
            break;
        }
        
        [sString appendFormat:@"%c", character];
    }
    
    return [NSString stringWithFormat:@"%@%@", fString, sString];
    
}


@end
