#import "UIView+Facade.h"

@implementation UIView (Facade)


#pragma mark - Alignment Relative To Superview

#pragma mark - Fill superview

- (void)fillSuperview {
    self.frame = CGRectMake(0, 0, CGRectGetWidth(self.superview.frame), CGRectGetHeight(self.superview.frame));
}

#pragma mark - Corner alignment

- (void)anchorTopLeftWithLeftPadding:(CGFloat)left topPadding:(CGFloat)top width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(left, top, width, height);
}

- (void)anchorTopRightWithRightPadding:(CGFloat)right topPadding:(CGFloat)top width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetWidth(self.superview.frame) - width - right, top, width, height);
}

- (void)anchorBottomLeftWithLeftPadding:(CGFloat)left bottomPadding:(CGFloat)bottom width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(left, CGRectGetHeight(self.superview.frame) - height - bottom, width, height);
}

- (void)anchorBottomRightWithRightPadding:(CGFloat)right bottomPadding:(CGFloat)bottom width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetWidth(self.superview.frame) - width - right, CGRectGetHeight(self.superview.frame) - height - bottom, width, height);
}


#pragma mark - Center alignment

- (void)anchorInCenterWithWidth:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake((CGRectGetWidth(self.superview.frame) / 2.0) - (width / 2.0), (CGRectGetHeight(self.superview.frame) / 2.0) - (height / 2.0), width, height);
}

- (void)anchorCenterLeftWithLeftPadding:(CGFloat)left width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(left, (CGRectGetHeight(self.superview.frame) / 2.0) - (height / 2.0), width, height);
}

- (void)anchorCenterRightWithRightPadding:(CGFloat)right width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetWidth(self.superview.frame) - width - right, (CGRectGetHeight(self.superview.frame) / 2.0) - (height / 2.0), width, height);
}

- (void)anchorTopCenterWithTopPadding:(CGFloat)top width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake((CGRectGetWidth(self.superview.frame) / 2.0) - (width / 2.0), top, width, height);
}

- (void)anchorBottomCenterWithBottomPadding:(CGFloat)bottom width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake((CGRectGetWidth(self.superview.frame) / 2.0) - (width / 2.0), CGRectGetHeight(self.superview.frame) - height - bottom, width, height);
}


#pragma mark - Filling width / height

- (void)anchorInCenterFillingWidthAndHeightWithLeftAndRightPadding:(CGFloat)leftAndRight topAndBottomPadding:(CGFloat)topAndBottom {
    self.frame = CGRectMake(leftAndRight, topAndBottom, CGRectGetWidth(self.superview.frame) - (2 * leftAndRight), CGRectGetHeight(self.superview.frame) - (2 * topAndBottom));
}

- (void)anchorTopCenterFillingWidthWithLeftAndRightPadding:(CGFloat)leftAndRight topPadding:(CGFloat)top height:(CGFloat)height {
    self.frame = CGRectMake(leftAndRight, top, CGRectGetWidth(self.superview.frame) - (2 * leftAndRight), height);
}

- (void)anchorBottomCenterFillingWidthWithLeftAndRightPadding:(CGFloat)leftAndRight bottomPadding:(CGFloat)bottom height:(CGFloat)height {
    self.frame = CGRectMake(leftAndRight, CGRectGetHeight(self.superview.frame) - height - bottom, CGRectGetWidth(self.superview.frame) - (2 * leftAndRight), height);
}


#pragma mark - Alignment Relative to Siblings

#pragma mark - To the right

- (void)alignToTheRightOf:(UIView *)view matchingTopWithLeftPadding:(CGFloat)left width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMaxX(view.frame) + left, CGRectGetMinY(view.frame), width, height);
}

- (void)alignToTheRightOf:(UIView *)view matchingTopAndFillingWidthWithLeftAndRightPadding:(CGFloat)leftAndRight height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMaxX(view.frame) + leftAndRight, CGRectGetMinY(view.frame), CGRectGetWidth(view.superview.frame) - CGRectGetMaxX(view.frame) - (2 * leftAndRight), height);
}

- (void)alignToTheRightOf:(UIView *)view matchingCenterWithLeftPadding:(CGFloat)left width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMaxX(view.frame) + left, CGRectGetMidY(view.frame) - (height / 2.0), width, height);
}

- (void)alignToTheRightOf:(UIView *)view matchingCenterAndFillingWidthWithLeftAndRightPadding:(CGFloat)leftAndRight height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMaxX(view.frame) + leftAndRight, CGRectGetMidY(view.frame) - (height / 2.0), CGRectGetWidth(view.superview.frame) - CGRectGetMaxX(view.frame) - (2 * leftAndRight), height);
}

- (void)alignToTheRightOf:(UIView *)view matchingBottomWithLeftPadding:(CGFloat)left width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMaxX(view.frame) + left, CGRectGetMaxY(view.frame) - height, width, height);
}

- (void)alignToTheRightOf:(UIView *)view matchingBottomAndFillingWidthWithLeftAndRightPadding:(CGFloat)leftAndRight height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMaxX(view.frame) + leftAndRight, CGRectGetMaxY(view.frame) - height, CGRectGetWidth(view.superview.frame) - CGRectGetMaxX(view.frame) - (2 * leftAndRight), height);
}


#pragma mark - To the left

- (void)alignToTheLeftOf:(UIView *)view matchingTopWithRightPadding:(CGFloat)right width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMinX(view.frame) - width - right, CGRectGetMinY(view.frame), width, height);
}

- (void)alignToTheLeftOf:(UIView *)view matchingTopAndFillingWidthWithLeftAndRightPadding:(CGFloat)leftAndRight height:(CGFloat)height {
    self.frame = CGRectMake(leftAndRight, CGRectGetMinY(view.frame), CGRectGetMinX(view.frame) - (2 * leftAndRight), height);
}

- (void)alignToTheLeftOf:(UIView *)view matchingCenterWithRightPadding:(CGFloat)right width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMinX(view.frame) - width - right, CGRectGetMidY(view.frame) - (height / 2.0), width, height);
}

- (void)alignToTheLeftOf:(UIView *)view matchingCenterAndFillingWidthWithLeftAndRightPadding:(CGFloat)leftAndRight height:(CGFloat)height {
    self.frame = CGRectMake(leftAndRight, CGRectGetMidY(view.frame) - (height / 2.0), CGRectGetMinX(view.frame) - (2 * leftAndRight), height);
}

- (void)alignToTheLeftOf:(UIView *)view matchingBottomWithRightPadding:(CGFloat)right width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMinX(view.frame) - width - right, CGRectGetMaxY(view.frame) - height, width, height);
}

- (void)alignToTheLeftOf:(UIView *)view matchingBottomAndFillingWidthWithLeftAndRightPadding:(CGFloat)leftAndRight height:(CGFloat)height {
    self.frame = CGRectMake(leftAndRight, CGRectGetMaxY(view.frame) - height, CGRectGetMinX(view.frame) - (2 * leftAndRight), height);
}


#pragma mark - Under

- (void)alignUnder:(UIView *)view withLeftPadding:(CGFloat)left topPadding:(CGFloat)top width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(left, CGRectGetMaxY(view.frame) + top, width, height);
}

- (void)alignUnder:(UIView *)view withRightPadding:(CGFloat)right topPadding:(CGFloat)top width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMaxX(self.superview.frame) - width - right, CGRectGetMaxY(view.frame) + top, width, height);
}

- (void)alignUnder:(UIView *)view matchingLeftWithTopPadding:(CGFloat)top width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMinX(view.frame), CGRectGetMaxY(view.frame) + top, width, height);
}

- (void)alignUnder:(UIView *)view matchingLeftAndFillingWidthWithRightPadding:(CGFloat)right topPadding:(CGFloat)top height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMinX(view.frame), CGRectGetMaxY(view.frame) + top, CGRectGetWidth(view.superview.frame) - CGRectGetMinX(view.frame) - right, height);
}

- (void)alignUnder:(UIView *)view matchingCenterWithTopPadding:(CGFloat)top width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMidX(view.frame) - (width / 2.0), CGRectGetMaxY(view.frame) + top, width, height);
}

- (void)alignUnder:(UIView *)view centeredFillingWidthWithLeftAndRightPadding:(CGFloat)leftAndRight topPadding:(CGFloat)top height:(CGFloat)height {
    self.frame = CGRectMake(leftAndRight, CGRectGetMaxY(view.frame) + top, CGRectGetWidth(view.superview.frame) - (2 * leftAndRight), height);
}

- (void)alignUnder:(UIView *)view centeredFillingWidthAndHeightWithLeftAndRightPadding:(CGFloat)leftAndRight topAndBottomPadding:(CGFloat)topAndBottom {
    self.frame = CGRectMake(leftAndRight, CGRectGetMaxY(view.frame) + topAndBottom, CGRectGetWidth(view.superview.frame) - (2 * leftAndRight), CGRectGetHeight(self.superview.frame) - CGRectGetMaxY(view.frame) - topAndBottom - topAndBottom);
}

- (void)alignUnder:(UIView *)view matchingRightWithTopPadding:(CGFloat)top width:(CGFloat)width height:(CGFloat)height {
    self.frame = CGRectMake(CGRectGetMaxX(view.frame) - width, CGRectGetMaxY(view.frame) + top, width, height);
}

- (void)alignUnder:(UIView *)view matchingRightAndFillingWidthWithLeftPadding:(CGFloat)left topPadding:(CGFloat)top height:(CGFloat)height {
    self.frame = CGRectMake(left, CGRectGetMaxY(view.frame) + top, CGRectGetMinX(view.frame) + CGRectGetWidth(view.frame) - left, height);
}

- (void)alignUnder:(UIView *)view matchingLeftAndRightFillingHeightWithTopPadding:(CGFloat)top bottomPadding:(CGFloat)bottom {
    self.frame = CGRectMake(CGRectGetMinX(view.frame), CGRectGetMaxY(view.frame) + top, CGRectGetWidth(view.frame), CGRectGetHeight(self.superview.frame) - CGRectGetMaxY(view.frame) - top - bottom);
}

- (void)alignUnder:(UIView *)view matchingLeftFillingWidthAndHeightWithRightPadding:(CGFloat)right topPadding:(CGFloat)top bottomPadding:(CGFloat)bottom {
    self.frame = CGRectMake(CGRectGetMinX(view.frame), CGRectGetMaxY(view.frame) + top, CGRectGetWidth(self.superview.frame) - CGRectGetMinX(view.frame) - right, CGRectGetHeight(self.superview.frame) - CGRectGetMaxY(view.frame) - top - bottom);
}
