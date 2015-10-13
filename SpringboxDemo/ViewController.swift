//
//  ViewController.swift
//  SpringboxDemo
//
//  Created by Katsuma Tanaka on 2015/10/11.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit
import Springbox

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    // MARK: - Properties
    
    @IBOutlet private weak var landscapeImageView: UIImageView!
    @IBOutlet private weak var portraitImageView: UIImageView!
    
    private let animatedTransition = SpringboxAnimatedTransition()
    private weak var tappedImageView: UIImageView?
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let tappedImageView = self.tappedImageView {
            animatedTransition.sourceRect = tappedImageView.frame
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func showSpringbox(gestureRecognizer: UITapGestureRecognizer) {
        let fileName = (gestureRecognizer.view == landscapeImageView) ? "landscape" : "portrait"
        
        guard let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "jpg"),
            let data = NSData(contentsOfFile: filePath),
            let image = UIImage(data: data) else {
                return
        }
        
        tappedImageView = gestureRecognizer.view as? UIImageView
        
        let springboxViewController = SpringboxViewController(image: image)
        springboxViewController.modalPresentationStyle = .OverFullScreen
        springboxViewController.transitioningDelegate = self
        
        presentViewController(springboxViewController, animated: true, completion: nil)
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let tappedImageView = self.tappedImageView else {
            return nil
        }
        
        animatedTransition.presenting = true
        animatedTransition.image = tappedImageView.image
        animatedTransition.sourceRect = tappedImageView.frame
        
        return animatedTransition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animatedTransition.presenting = false
        
        return animatedTransition
    }

}
