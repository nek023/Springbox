//
//  SpringboxViewController.swift
//  Springbox
//
//  Created by Katsuma Tanaka on 2015/10/11.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit

public class SpringboxViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    
    public let scrollView = UIScrollView()
    public let imageView = UIImageView()
    
    public let panGestureRecognizer = UIPanGestureRecognizer()
    public let doubleTapGestureRecognizer = UITapGestureRecognizer()
    public let tapGestureRecognizer = UITapGestureRecognizer()
    
    private var scaledImageSize: CGSize = CGSizeZero
    private var backgroundColor: UIColor?
    
    public private(set) var image: UIImage?
    
    public var animationDuration: NSTimeInterval = 0.45
    public var dampingRatio: CGFloat = 1
    public var initialSpringVelocity: CGFloat = 0
    
    public var dismissalTranslationThreshold: CGFloat = 150
    public var dismissalVelocityThreshold: CGFloat = 600
    public var dismissalDistance: CGFloat = 200
    
    public var doubleTapZoomThreshold: CGFloat = 1.5
    public var doubleTapZoomScale: CGFloat = 3.0
    
    public var dismissOnTap: Bool = true
    
    
    // MARK: - View Lifecycle
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public convenience init(image: UIImage) {
        self.init(nibName: nil, bundle: nil)
        
        self.image = image
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor()
        
        panGestureRecognizer.addTarget(self, action: "handlePanGesture:")
        view.addGestureRecognizer(panGestureRecognizer)
        
        doubleTapGestureRecognizer.addTarget(self, action: "handleDoubleTapGesture:")
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGestureRecognizer)
        
        tapGestureRecognizer.addTarget(self, action: "handleTapGesture:")
        tapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
        view.addGestureRecognizer(tapGestureRecognizer)
        
        setUpScrollView()
        setUpImageView()
    }
    
    private func setUpScrollView() {
        scrollView.delegate = self
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        view.addSubview(scrollView)
    }
    
    private func setUpImageView() {
        guard let image = self.image else {
            return
        }
        
        // Compute scaled image size
        let scale = min(
            CGRectGetWidth(view.frame) / image.size.width,
            CGRectGetHeight(view.frame) / image.size.height
        )
        let size = CGSizeMake(image.size.width * scale, image.size.height * scale)
        scaledImageSize = size
        let frame = CGRectMake(
            (CGRectGetWidth(view.frame) - size.width) * 0.5,
            (CGRectGetHeight(view.frame) - size.height) * 0.5,
            size.width,
            size.height
        )
        
        // Configure image view
        imageView.frame = frame
        imageView.image = image
        
        scrollView.contentSize = size
        scrollView.addSubview(imageView)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let image = self.image else {
            return
        }
        
        // Compute scaled image size
        let scale = min(
            CGRectGetWidth(view.frame) / image.size.width,
            CGRectGetHeight(view.frame) / image.size.height
        )
        let size = CGSizeMake(image.size.width * scale, image.size.height * scale)
        scaledImageSize = size
        let frame = CGRectMake(
            (CGRectGetWidth(view.frame) - size.width) * 0.5,
            (CGRectGetHeight(view.frame) - size.height) * 0.5,
            size.width,
            size.height
        )
        
        scrollView.setZoomScale(1.0, animated: true)
        scrollView.contentSize = size
        imageView.frame = frame
    }
    
    
    // MARK: - Handling Gestures
   
    func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translationInView(view)
        let progress = fabs(translation.y) / dismissalTranslationThreshold
        
        switch gestureRecognizer.state {
        case .Began:
            backgroundColor = view.backgroundColor
            
        case .Changed:
            let alpha = 0.6 + max(0, 1 - progress * 0.25) * 0.4
            view.backgroundColor = backgroundColor?.colorWithAlphaComponent(alpha)
            
            scrollView.frame = CGRectMake(
                0,
                translation.y,
                CGRectGetWidth(view.frame),
                CGRectGetHeight(view.frame)
            )
        
        case .Cancelled, .Ended, .Failed:
            let velocity = gestureRecognizer.velocityInView(view)
            let size = scaledImageSize
            
            if progress >= 1.0 || fabs(velocity.y) >= dismissalVelocityThreshold {
                let towardTop = (translation.y < 0)
                
                UIView.animateWithDuration(
                    animationDuration,
                    delay: 0,
                    usingSpringWithDamping: dampingRatio,
                    initialSpringVelocity: initialSpringVelocity,
                    options: [],
                    animations: {
                        self.view.backgroundColor = UIColor.clearColor()
                        
                        if towardTop {
                            self.scrollView.frame = CGRectMake(
                                0,
                                -((CGRectGetHeight(self.view.frame) - size.height) * 0.5 + size.height + self.dismissalDistance),
                                CGRectGetWidth(self.view.frame),
                                CGRectGetHeight(self.view.frame)
                            )
                        } else {
                            self.scrollView.frame = CGRectMake(
                                0,
                                CGRectGetMaxY(self.view.frame) - (CGRectGetHeight(self.view.frame) - size.height) * 0.5 + self.dismissalDistance,
                                CGRectGetWidth(self.view.frame),
                                CGRectGetHeight(self.view.frame)
                            )
                        }
                    },
                    completion: { (finished: Bool) in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }
                )
                
            } else {
                UIView.animateWithDuration(
                    animationDuration,
                    delay: 0,
                    usingSpringWithDamping: dampingRatio,
                    initialSpringVelocity: initialSpringVelocity,
                    options: [.AllowUserInteraction],
                    animations: {
                        self.view.backgroundColor = self.backgroundColor
                        
                        self.scrollView.frame = CGRectMake(
                            0,
                            0,
                            CGRectGetWidth(self.view.frame),
                            CGRectGetHeight(self.view.frame)
                        )
                    },
                    completion: nil
                )
            }
            
        default:
            break
        }
    }
    
    func handleDoubleTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .Ended else {
            return
        }
        
        if scrollView.zoomScale >= doubleTapZoomThreshold {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let zoomRect = zoomRectForScrollView(
                scrollView,
                scale: doubleTapZoomScale,
                center: gestureRecognizer.locationInView(nil)
            )
            scrollView.zoomToRect(zoomRect, animated: true)
        }
    }
    
    func handleTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .Ended && dismissOnTap && scrollView.zoomScale == 1.0 else {
            return
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func zoomRectForScrollView(scrollView: UIScrollView, scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRectZero
        
        zoomRect.size.width = scrollView.frame.size.width / scale
        zoomRect.size.height = scrollView.frame.size.height / scale
        
        zoomRect.origin.x = center.x - zoomRect.size.width * 0.5
        zoomRect.origin.y = center.y - zoomRect.size.height * 0.5
        
        return zoomRect
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        let offsetX = max((CGRectGetWidth(scrollView.bounds) - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((CGRectGetHeight(scrollView.bounds) - scrollView.contentSize.height) * 0.5, 0.0)
        
        imageView.center = CGPointMake(
            scrollView.contentSize.width * 0.5 + offsetX,
            scrollView.contentSize.height * 0.5 + offsetY
        )
    }
    
}
