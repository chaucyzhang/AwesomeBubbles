//
//  ViewController.swift
//  AwesomeBubbles
//
//  Created by chaucyzhang@gmail.com on 09/26/2017.
//  Copyright (c) 2017 chaucyzhang@gmail.com. All rights reserved.
//

import UIKit
import AwesomeBubbles

class ViewController: UIViewController, AwesomeBubbleContainerViewDelegate, AwesomeBubbleContainerViewDataSource {
    
    @IBOutlet weak var contentView: AwesomeBubbleContainerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.delegate = self
        self.contentView.dataSource = self
        self.contentView.reload()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func minimalSizeForBubble(in view: AwesomeBubbleContainerView) -> CGSize {
        return CGSize(width: 60.0, height: 60.0)
    }
    
    func maximumSizeForBubble(in view: AwesomeBubbleContainerView) -> CGSize {
        return CGSize(width: 80.0, height: 80.0)
    }
    
    func AwesomeBubbleContainerView(_ view: AwesomeBubbleContainerView, didSelectItemAt index: Int) {
        
    }
    
    
    func countOfSizes(in view: AwesomeBubbleContainerView) -> Int {
        return 3
    }
    
    func numberOfItems(in view: AwesomeBubbleContainerView) -> Int {
        return 30
    }
    
    func addOrUpdateAwesomeBubble(forItemAt index: Int, currentView: AwesomeBubble?) -> AwesomeBubble {
        var bubble: AwesomeBubble! = currentView
        if bubble == nil {
            if let customizedView = UINib(nibName: "CustomizedBubble", bundle: nil).instantiate(withOwner: nil, options: nil).first as? CustomizedBubble {
                bubble = customizedView
                bubble.backgroundColor = UIColor.clear
                bubble.contentColor = UIColor.clear
                bubble.borderColor = UIColor.darkGray
            }
        }
        
//        let bubble:AwesomeBubble = AwesomeBubble()
        let point = CGPoint(x:drand48() * Double(self.contentView.frame.size.width * 2 / 3), y:drand48() * Double(self.contentView.frame.size.height) * 2 / 3)
       
        bubble.frame = CGRect(origin:point, size:CGSize.zero)
        
        return bubble;
    }
    
}

