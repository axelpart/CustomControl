//
//  CustomControl.swift
//  Pods
//
//  Created by Alexandros Partonas on 07/03/2017.
//
//

import Foundation

public protocol CustomControlDelegate: class {
    func controlSelected(_ index: Int)
    func controlSelectedButton(_ text: String)
}

@IBDesignable open class CustomControl: UIControl {
    
    fileprivate var labels = [UILabel]()
    fileprivate let slider = UIView()
    
    fileprivate var sliderWidth: CGFloat = 0.0
    
    weak public var delegate: CustomControlDelegate?
    
    public var titles: [String] = ["1", "2"] {
        didSet {
            setupLabels()
        }
    }
    
    public var selectedIndex: Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    
    @IBInspectable public var selectedTextColor: UIColor = .white {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable public var unselectedTextColor: UIColor = .black {
        didSet {
            setSelectedColors()
        }
    }

    @IBInspectable public var selectedBackgroundColor: UIColor = .black {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable public var unselectedBackgroundColor: UIColor = .white {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable public var borderColor: UIColor = .white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable public var selectedFont: UIFont! = .systemFont(ofSize: 18) {
        didSet {
            setFont()
        }
    }
    
    @IBInspectable public var unselectedFont: UIFont! = .systemFont(ofSize: 14) {
        didSet {
            setFont()
        }
    }
    
    @IBInspectable public var sliderHeight: CGFloat = 2.0
    
    @IBInspectable public var sliderColor: UIColor = UIColor.red {
        didSet {
            slider.backgroundColor = sliderColor
        }
    }
    
    @IBInspectable public var hideSlider: Bool = false {
        didSet {
            slider.removeFromSuperview()
        }
    }
    
    @IBInspectable public var sliderAnimationDuration: Double = 0.25
    
    // MARK: - View lifecycle
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabels()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabels()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        var selectFrame = bounds
        let newWidth = selectFrame.width / CGFloat(titles.count)
        selectFrame.size.width = newWidth
        addTopAndBottomBorders()
        
        if let sDelegate = delegate {
            sDelegate.controlSelected(selectedIndex)
        }
        
        displayNewSelectedIndex()
    }
    
    fileprivate func addTopAndBottomBorders() {
        let topBorder = CALayer()
        let bottomBorder = CALayer()
        let width = CGFloat(0.3)
        
        topBorder.borderColor = UIColor.lightGray.cgColor
        topBorder.borderWidth = width
        topBorder.frame = CGRect(x: 0, y: 0, width:  frame.size.width, height: width)
        
        bottomBorder.borderColor = UIColor.lightGray.cgColor
        bottomBorder.borderWidth = width
        bottomBorder.frame = CGRect(x: 0, y: frame.size.height - width, width:  frame.size.width, height: frame.size.height)
        
        layer.addSublayer(topBorder)
        layer.addSublayer(bottomBorder)
        layer.masksToBounds = true
    }
    
    // MARK: - User interaction
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        var calculatedIndex: Int?
        
        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
            if let sDelegate = delegate {
                sDelegate.controlSelected(selectedIndex)
            }
        }
        return false
    }
    
    fileprivate func displayNewSelectedIndex(){
        for (_, item) in labels.enumerated() {
            item.textColor = unselectedTextColor
            item.font = unselectedFont
            item.backgroundColor = unselectedBackgroundColor
        }
        
        let label = labels[selectedIndex]
        label.textColor = selectedTextColor
        label.font = selectedFont
        label.backgroundColor = selectedBackgroundColor
        
        if let sText = label.text, let sDelegate = delegate {
            sDelegate.controlSelectedButton(sText)
        }
        
        if !hideSlider {
            displaySliderNewIndex()
        }
    }
    
    fileprivate func displaySliderNewIndex() {
        let label = labels[selectedIndex]
        let screen = UIScreen.main
        if sliderWidth == 0 {
            sliderWidth = screen.bounds.size.width / CGFloat(labels.count)
            
            slider.backgroundColor = sliderColor
            slider.frame = CGRect(x: 0, y: bounds.height - sliderHeight, width: label.bounds.width, height: sliderHeight)
        }
        
        UIView.animate(withDuration: sliderAnimationDuration, delay: 0.0, options: UIViewAnimationOptions(), animations: { [weak self] in
            guard let safe = self else { return }
            safe.slider.frame = CGRect(x: safe.leftOffset(for: safe.selectedIndex), y: safe.slider.frame.origin.y, width: label.bounds.width, height: safe.sliderHeight)
        }, completion: nil)
    }
    
    // MARK: - Private: Autolayout
    fileprivate func addIndividualItemConstraints(_ items: [UIView], mainView: UIView, padding: CGFloat) {
        
        _ = mainView.constraints
        
        for (index, button) in items.enumerated() {
            let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: .top, multiplier: 1.0, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1.0, constant: 0)
            var rightConstraint: NSLayoutConstraint!
            var leftConstraint: NSLayoutConstraint!
            
            if index == items.count - 1 {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: mainView, attribute: .right, multiplier: 1.0, constant: -padding)
                
            } else {
                let nextButton = items[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: nextButton, attribute: .left, multiplier: 1.0, constant: -padding)
            }
            
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: mainView, attribute: .left, multiplier: 1.0, constant: padding)
            } else {
                let prevButton = items[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: prevButton, attribute: .right, multiplier: 1.0, constant: padding)
                
                let firstItem = items[0]
                
                let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: firstItem, attribute: .width, multiplier: 1.0  , constant: 0)
                
                mainView.addConstraint(widthConstraint)
            }
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    // MARK: - Private labels setup
    fileprivate func setupLabels() {
        labels.forEach( { $0.removeFromSuperview() })
        
        labels.removeAll(keepingCapacity: true)
        createLabels()
        addSubview(slider)
        
        addIndividualItemConstraints(labels, mainView: self, padding: 0)
    }
    
    fileprivate func createLabels() {
        for index in 1...titles.count {
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
            label.text = titles[index - 1]
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.font = index == 1 ? selectedFont : unselectedFont
            label.textColor = index == 1 ? selectedTextColor : unselectedTextColor
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            labels.append(label)
        }
    }
    
    fileprivate func setSelectedColors(){
        labels.forEach({ $0.textColor = unselectedTextColor })
        
        if labels.count > 0 {
            labels[0].textColor = selectedTextColor
        }
    }
    
    fileprivate func setFont() {
        labels.forEach({ $0.font = unselectedFont })
        
        if labels.count > 0 {
            labels[0].font = selectedFont
        }
    }
    
    // MARK: - Slider
    fileprivate func leftOffset(for index: Int) -> CGFloat {
        return sliderWidth * CGFloat(index)
    }
}
