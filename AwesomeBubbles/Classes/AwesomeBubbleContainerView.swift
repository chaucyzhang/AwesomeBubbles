import UIKit
import CoreMotion

@available(iOS 9.0, *)
open class AwesomeBubbleContainerView: UIView {
    
    @IBOutlet public weak var delegate: AwesomeBubbleContainerViewDelegate?
    @IBOutlet public weak var dataSource: AwesomeBubbleContainerViewDataSource?
    var motionManager:CMMotionManager?
    
    open lazy var dynamicAnimator: UIDynamicAnimator = {
        return UIDynamicAnimator(referenceView: self)
    }()
    
    open lazy var dynamicItemBehavior: UIDynamicItemBehavior = {
        let itemBehavior = UIDynamicItemBehavior()
        itemBehavior.allowsRotation = false
        itemBehavior.density = 3
        itemBehavior.resistance = 0.4
        itemBehavior.friction = 0
        itemBehavior.elasticity = 0
        return itemBehavior
    }()
    
    open lazy var gravityBehavior: UIGravityBehavior = {
        let radialGravity: UIGravityBehavior = UIGravityBehavior()
        radialGravity.magnitude = 0.4
        return radialGravity
    }()
    
    open lazy var collisionBehavior: UICollisionBehavior = {
        let collision = UICollisionBehavior()
        collision.collisionMode = UICollisionBehaviorMode.everything
        collision.translatesReferenceBoundsIntoBoundary = true
        return collision
    }()
    
    open lazy var pushGravityBehavior: UIFieldBehavior = {
        let radialGravity: UIFieldBehavior = UIFieldBehavior.radialGravityField(position: self.center)
        radialGravity.region = UIRegion(radius: self.bounds.height * 5)
        radialGravity.minimumRadius = self.bounds.height * 5
        radialGravity.strength = -BubbleConstants.pushGravityStrength
        radialGravity.animationSpeed = 4
        radialGravity.falloff = 0.1
        return radialGravity
    }()
    
    
    open lazy var elasticityBehavior: UIDynamicItemBehavior = {
        let elasticityBehavior:UIDynamicItemBehavior  = UIDynamicItemBehavior()
        elasticityBehavior.elasticity = 0.7
        return elasticityBehavior
    }()
    
    
    open override var center: CGPoint {
        didSet {
//                gravityBehavior.position = center
        }
    }
    open var tapEnabled: Bool = true {
        didSet {
            updateTapState()
        }
    }
    
    open lazy var minimalSizeForItem: CGSize = BubbleConstants.minimalSizeForItem
    open lazy var maximumSizeForItem: CGSize = BubbleConstants.maximumSizeForItem
    open lazy var countOfSizes: Int = 3
    
    open var bubbleViews: [AwesomeBubble] = []
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        addBehaviors()
        updateTapState()
    }
    
    open func addBehaviors() {
        [dynamicItemBehavior,
         gravityBehavior,
         collisionBehavior,
         elasticityBehavior,
         pushGravityBehavior].forEach { dynamicAnimator.addBehavior($0) }
    }
    
    open func reload(randomizePosition: Bool = false) {
        guard let dataSource = dataSource else {
            removeViewsFromBehaviors()
            removeViews()
            return
        }
        
        countOfSizes = dataSource.countOfSizes?(in: self) ?? 3
        minimalSizeForItem = delegate?.minimalSizeForBubble?(in: self) ?? BubbleConstants.minimalSizeForItem
        maximumSizeForItem = delegate?.maximumSizeForBubble?(in: self) ?? BubbleConstants.maximumSizeForItem
        
        let countOfItems = dataSource.numberOfItems(in: self)
        removeOddViews(for: countOfItems)
        addOrReloadNeededViews(for: countOfItems)
        startAccelerometer()
        updateTapState()
        
        if randomizePosition {
            self.randomizePosition()
        }
        
        bubbleViews.forEach { $0.layoutIfNeeded() }
    }
    
    open func startAccelerometer() -> Void
    {
        self.motionManager = CMMotionManager();
        
        if (self.motionManager?.isDeviceMotionAvailable)! {
            let queue = OperationQueue.current
            self.motionManager?.startAccelerometerUpdates(to: queue!, withHandler: { (CMAccelerometerData, Error) in
                let gravity:CMAcceleration = (CMAccelerometerData?.acceleration)!
                DispatchQueue.main.async{
                    self.gravityBehavior.gravityDirection = CGVector(dx:gravity.x, dy:-gravity.y)
                }
            })
        }
    }
}

//MARK: - Items positioning and sizes
@available(iOS 9.0, *)
extension AwesomeBubbleContainerView {
    func calculateSize(for size: Int) -> CGSize {
        assert(size > 0, "Size must be greater than or equal 1")
        
        let maxW = maximumSizeForItem.width
        let maxH = maximumSizeForItem.height
        
        let minW = minimalSizeForItem.width
        let minH = minimalSizeForItem.height
        
        let multiplier = CGFloat(size) / CGFloat(countOfSizes)
        
        let calculatedWidth = minW + (maxW - minW) * multiplier
        let calculatedHeight = minH + (maxH - minH) * multiplier
        
        return CGSize(width: calculatedWidth,
                      height: calculatedHeight)
    }
    
    func randomizeSize() {
        bubbleViews.forEach { (view) in
            let randomSize = Int(arc4random_uniform(UInt32(countOfSizes))) % countOfSizes + 1
            let size = calculateSize(for: randomSize)
            view.frame = CGRect(origin: view.frame.origin,
                                size: size)
        }
    }
    
    func randomizeSize(for view:AwesomeBubble){
        let randomSize = Int(arc4random_uniform(UInt32(countOfSizes))) % countOfSizes + 1
        let size = calculateSize(for: randomSize)
        view.frame = CGRect(origin: view.frame.origin,
                            size: size)
    }
    
    func randomizePosition() {
        if bubbleViews.count == 1 {
            let position = randomPosition(for: .center)
            bubbleViews[0].frame.origin = position
            return
        }
        
        let leftBubbles = bubbleViews[0..<bubbleViews.count / 2]
        let rightBubbles = bubbleViews[bubbleViews.count / 2..<bubbleViews.count]
        
        leftBubbles.forEach { (view) in
            let position = randomPosition(for: .left)
            view.frame.origin = position
        }
        
        rightBubbles.forEach { (view) in
            let position = randomPosition(for: .right)
            view.frame.origin = position
        }
    }
    
    enum BubblePosition {
        case left, right, center
    }
    
    func randomPosition(for position: BubblePosition) -> CGPoint {
        let xRand = drand48()
        let yRand = drand48()
        
        let deltaRandY = yRand - drand48()
        switch position {
        case .center:
            let deltaRandX = xRand - drand48()
            return CGPoint(x: Double(center.x) + deltaRandX * 50,
                           y: Double(center.y) + deltaRandY * 50)
        case .left:
            return CGPoint(x: Double(frame.origin.x) - xRand * Double(bounds.width),
                           y: Double(center.y) + deltaRandY * Double(bounds.height / 2))
        case .right:
            return CGPoint(x: Double(frame.origin.x + frame.width) + xRand * Double(bounds.width),
                           y: Double(center.y) + deltaRandY * Double(bounds.height / 2))
        }
    }
}

//MARK: - Items processing

extension AwesomeBubbleContainerView {
    
    internal func addOrReloadNeededViews(for count: Int) {
        guard let dataSource = dataSource else {
            fatalError("No dataSource for content view")
        }
        
        (0..<count).forEach { (index) in
            let currentView: AwesomeBubble? = index < bubbleViews.count
                ? bubbleViews[index]
                : nil
            
            let bubbleView = dataSource.addOrUpdateAwesomeBubble(forItemAt: index, currentView: currentView)
            
            if bubbleView.frame.size == .zero {
                let newSize = calculateSize(for: bubbleView.currentSize)
                let currentOrigin = bubbleView.frame.origin
                
                bubbleView.frame = CGRect(origin: currentOrigin,
                                          size: newSize)
            }
            self.randomizeSize(for: bubbleView)
            addIfNeeded(bubbleView)
            
            if !bubbleViews.contains(bubbleView) {
                bubbleViews.append(bubbleView)
            }
        }
    }
    
    internal func addIfNeeded(_ item: AwesomeBubble) {
        if item.superview == nil {
            addSubview(item)
        }
        
        dynamicItemBehavior.addItem(item)
        gravityBehavior.addItem(item)
        collisionBehavior.addItem(item)
        elasticityBehavior.addItem(item)
        
        if item.tapGestureRecognizer == nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            item.addGestureRecognizer(tap)
            item.tapGestureRecognizer = tap
        }
    }
    
    internal func removeOddViews(for count: Int) {
        if count >= bubbleViews.count { return }
        let countToDelete = count - bubbleViews.count
        
        (1...countToDelete).forEach { (_) in
            let viewToRemove = bubbleViews.removeLast()
            removeBehaviors(for: viewToRemove)
            viewToRemove.removeFromSuperview()
        }
    }
    
    internal func removeBehaviors(for view: AwesomeBubble) {
        dynamicItemBehavior.removeItem(view)
        gravityBehavior.removeItem(view)
        collisionBehavior.removeItem(view)
        elasticityBehavior.removeItem(view)
        pushGravityBehavior.removeItem(view)
    }
    
    internal func removeViewsFromBehaviors() {
        bubbleViews.forEach {
            removeBehaviors(for: $0)
        }
    }
    
    internal func removeViews() {
        bubbleViews.forEach { $0.removeFromSuperview() }
        bubbleViews.removeAll()
    }
}

//MARK: - Gestures handling

public extension AwesomeBubbleContainerView {
    
    
    internal func updateTapState() {
        bubbleViews.forEach{ $0.tapGestureRecognizer?.isEnabled = tapEnabled }
    }
    
    public func handleTap(_ tap: UITapGestureRecognizer) {
        guard let bubbleView = tap.view as? AwesomeBubble else {
            return
        }
        
        guard let index = bubbleViews.index(of: bubbleView) else {
            fatalError("No such bubbleView in content View")
        }
        
        delegate?.AwesomeBubbleContainerView?(self, didSelectItemAt: index)
    }
}
