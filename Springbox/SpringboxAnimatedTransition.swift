//
//  SpringboxAnimatedTransition.swift
//  Springbox
//
//  Created by Katsuma Tanaka on 2015/10/11.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit

public class SpringboxAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Properties
    
    public var presenting: Bool = true
    
    public var animationDuration: NSTimeInterval = 0.45
    public var dampingRatio: CGFloat = 1
    public var initialSpringVelocity: CGFloat = 0
    
    public var image: UIImage?
    public var sourceRect: CGRect = CGRectZero
    public var sourceContentMode: UIViewContentMode = .ScaleAspectFit
    
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
    }
    
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            animatePresentation(transitionContext)
        } else {
            animateDismissal(transitionContext)
        }
    }
    
    private func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView(),
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey),
            let image = self.image else {
                return
        }
        
        // Prelayout
        let backgroundView = UIView(frame: containerView.bounds)
        backgroundView.backgroundColor = toView.backgroundColor
        backgroundView.alpha = 0
        containerView.addSubview(backgroundView)
        
        let imageView = UIImageView(image: image)
        imageView.frame = sourceRect
        imageView.contentMode = sourceContentMode
        imageView.alpha = 0
        containerView.addSubview(imageView)
        
        // Compute scaled image size
        let scale = min(
            CGRectGetWidth(containerView.frame) / image.size.width,
            CGRectGetHeight(containerView.frame) / image.size.height
        )
        let size = CGSizeMake(image.size.width * scale, image.size.height * scale)
        let frame = CGRectMake(
            (CGRectGetWidth(containerView.frame) - size.width) * 0.5,
            (CGRectGetHeight(containerView.frame) - size.height) * 0.5,
            size.width,
            size.height
        )
        
        // Animation
        UIView.animateWithDuration(
            animationDuration,
            delay: 0,
            usingSpringWithDamping: dampingRatio,
            initialSpringVelocity: initialSpringVelocity,
            options: [],
            animations: {
                backgroundView.alpha = 1
                
                imageView.frame = frame
                imageView.contentMode = .ScaleAspectFit
                imageView.alpha = 1
            },
            completion: { (finished: Bool) in
                // Postlayout
                toView.frame = containerView.bounds
                containerView.addSubview(toView)
                
                imageView.removeFromSuperview()
                backgroundView.removeFromSuperview()
                
                // Call completion block
                let cancelled = transitionContext.transitionWasCancelled()
                transitionContext.completeTransition(!cancelled)
            }
        )
    }
    
    private func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView(),
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey),
            let image = self.image else {
                return
        }
        
        // Compute scaled image size
        let scale = min(
            CGRectGetWidth(containerView.frame) / image.size.width,
            CGRectGetHeight(containerView.frame) / image.size.height
        )
        let size = CGSizeMake(image.size.width * scale, image.size.height * scale)
        let frame = CGRectMake(
            (CGRectGetWidth(containerView.frame) - size.width) * 0.5,
            (CGRectGetHeight(containerView.frame) - size.height) * 0.5,
            size.width,
            size.height
        )
        
        // Prelayout
        let backgroundView = UIView(frame: containerView.bounds)
        backgroundView.backgroundColor = fromView.backgroundColor
        containerView.addSubview(backgroundView)
        
        let imageView = UIImageView(image: image)
        imageView.frame = frame
        imageView.contentMode = sourceContentMode
        containerView.addSubview(imageView)
        
        fromView.removeFromSuperview()
        
        // Animation
        UIView.animateWithDuration(
            animationDuration,
            delay: 0,
            usingSpringWithDamping: dampingRatio,
            initialSpringVelocity: initialSpringVelocity,
            options: [],
            animations: {
                backgroundView.alpha = 0
                
                imageView.frame = self.sourceRect
                imageView.alpha = 0
            },
            completion: { (finished: Bool) in
                // Call completion block
                let cancelled = transitionContext.transitionWasCancelled()
                transitionContext.completeTransition(!cancelled)
            }
        )
    }
    
}
