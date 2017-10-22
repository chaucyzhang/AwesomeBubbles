//
//  AwesomeBubbleProtocols.swift
//  Pods
//
//  Created by xi zhang on 9/26/17.
//
//

import Foundation
import UIKit

@objc public protocol AwesomeBubbleContainerViewDelegate: class {
    @objc optional func minimalSizeForBubble(in view: AwesomeBubbleContainerView) -> CGSize
    @objc optional func maximumSizeForBubble(in view: AwesomeBubbleContainerView) -> CGSize
    @objc optional func AwesomeBubbleContainerView(_ view: AwesomeBubbleContainerView, didSelectItemAt index: Int)
}

@objc public protocol AwesomeBubbleContainerViewDataSource: class {
    @objc optional func countOfSizes(in view: AwesomeBubbleContainerView) -> Int
    
    func numberOfItems(in view: AwesomeBubbleContainerView) -> Int
    func addOrUpdateAwesomeBubble(forItemAt index: Int, currentView: AwesomeBubble?) -> AwesomeBubble
}
