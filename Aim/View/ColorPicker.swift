//
//  UIEntryPickerView.swift
//  UINumberPicker
//
//  Created by Erick Sanchez on 5/14/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//
import UIKit

public protocol EntryDescriptor {
    var type: UIEntryPickerView.EntryType { get }
    var color: UIColor? { get }
    var photoName: String? { get }
}

open class UIEntryPickerView: UIView {
    
    public enum EntryType {
        case Major
        case Minor
    }
    
    public struct Entry: EntryDescriptor {
        
        public let type: EntryType
        public let color: UIColor?
        public let photoName: String?
        
        public static func major(with color: UIColor, andPhoto photoName: String) -> Entry {
            return Entry(type: .Major, color: color, photoName: photoName)
        }
        
        public static func minor(with color: UIColor, andPhoto photoName: String) -> Entry {
            return Entry(type: .Minor, color: color, photoName: photoName)
        }
    }
    
    public var selectedPage: Int {
        set {
            let pageSize = self.scrollView.frame.size
            
            self.scrollView.setContentOffset(CGPoint(x: CGFloat(newValue) * pageSize.width, y: 0), animated: true)
        }
        get {
            let pageSize = self.scrollView.frame.size
            
            return Int(self.scrollView.contentOffset.x / pageSize.width)
        }
    }
    
    public var scrollView: UIScrollView {
        return self._scrollView
    }
    
    private lazy var _scrollView: ScrollView = {
        let sv = ScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        sv.widthAnchor.constraint(equalToConstant: self.focusSize.width).isActive = true
        sv.heightAnchor.constraint(equalToConstant: self.focusSize.height).isActive = true
        
        sv.clipsToBounds = false
        sv.showsHorizontalScrollIndicator = false
        sv.isPagingEnabled = true
        
        return sv
    }()
    
    private lazy var scrollViewSelectedLayer: CAShapeLayer = {
        let selectedLayer = CAShapeLayer()
        selectedLayer.frame = self.scrollView.frame
        selectedLayer.cornerRadius = self.scrollView.bounds.width / 2.0
        selectedLayer.borderColor = entries[selectedPage].color?.cgColor ?? UIColor.darkGray.cgColor
        selectedLayer.borderWidth = 1.0
        
        self.layer.addSublayer(selectedLayer)
        
        return selectedLayer
    }()
    
    public var entries: [EntryDescriptor] {
        didSet {
            self.reloadData()
        }
    }
    
    public var focusSize: CGSize
    public private(set) var majorAttributes: [NSAttributedString.Key: Any]
    public private(set) var minorAttributes: [NSAttributedString.Key: Any]
    
    public init(
        frame: CGRect = CGRect.zero,
        focusSize: CGSize,
        majorAttributes: [NSAttributedString.Key: Any] = [:],
        minorAttributes: [NSAttributedString.Key: Any] = [:],
        entries: [EntryDescriptor]) {
        self.entries = entries
        self.focusSize = focusSize
        self.majorAttributes = majorAttributes
        self.minorAttributes = minorAttributes
        
        super.init(frame: frame)
        
        self.initLayout()
    }
    
    public convenience init(frame: CGRect = CGRect.zero, focusSize: CGSize, entries: EntryDescriptor...) {
        self.init(frame: frame, focusSize: focusSize, entries: entries)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        entries = []
        self.focusSize = CGSize.zero
        self.majorAttributes = [:]
        self.minorAttributes = [:]
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    public func reloadData() {
        self.scrollView.subviews.forEach { $0.removeFromSuperview() }
        self.initLayout()
    }
    
    private func initLayout() {
        
        clipsToBounds = true
        
        /** contains the labels to be scroll horizontally */
        let horzStackView = UIStackView()
        horzStackView.axis = .horizontal
        horzStackView.alignment = .fill
        horzStackView.distribution = .fill
        horzStackView.translatesAutoresizingMaskIntoConstraints = false
        
        //create uilabels with entry type
        for anEntry in self.entries {
            
            let colorImageView = UIImageView()
            if let name = anEntry.photoName {
                colorImageView.image = UIImage(named: name)
            }
            
            colorImageView.translatesAutoresizingMaskIntoConstraints = false
            
            colorImageView.layer.cornerRadius = Constant.Layer.cornerRadius
            colorImageView.layer.masksToBounds = false
            
            colorImageView.heightAnchor.constraint(equalToConstant: focusSize.height).isActive = true
            colorImageView.widthAnchor.constraint(equalToConstant: focusSize.width).isActive = true
            colorImageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
            
            horzStackView.addArrangedSubview(colorImageView)
        }
        
        //layout scroll view
        self.scrollView.addSubview(horzStackView)
        horzStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        horzStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        horzStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        horzStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        horzStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        let widthConstraint = horzStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        widthConstraint.priority = UILayoutPriority(rawValue: 999)
        widthConstraint.isActive = true
        
        addSubview(self.scrollView)
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        scrollView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.2)
        scrollView.delegate = self
        
        //fade sides
        let gradientShape = CAGradientLayer()
        let colors: [UIColor] = [.clear, .white, .white, .clear]
        gradientShape.colors = colors.map { $0.cgColor }
        gradientShape.locations = [0.0, 0.3, 0.7, 1.0]
        gradientShape.startPoint = CGPoint(x: 0, y: 0.5)
        gradientShape.endPoint = CGPoint(x: 1, y: 0.5)
        gradientShape.frame = bounds
        layer.mask = gradientShape
        
    }
    
    /**
     delegate the touches made in self to the scroll view. Since the frame of the
     scroll view does not expand to the bounds of self, touches are limited to the
     frame of the scroll view. This will expand touches made inside self to pan
     the scroll view
     */
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        
        if view === self, self.subviews.count > 0 {
            return self.subviews[0] as! UIScrollView
        } else {
            return view
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollViewSelectedLayer.frame = scrollView.frame
        layer.mask!.frame = layer.bounds
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}

extension UIEntryPickerView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if selectedPage >= 0 && selectedPage < entries.count  {
            if let color = entries[selectedPage].color?.cgColor {
                scrollViewSelectedLayer.borderColor =  color
            }
        }
        
    }
}

fileprivate class ScrollView: UIScrollView {
    
    // MARK: - RETURN VALUES
    
    private var horizontalStackView: UIStackView {
        return self.subviews.first! as! UIStackView
    }
    
    // MARK: - VOID METHODS
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tap(_ gesture: UITapGestureRecognizer) {
        let pageSize = bounds.size
        let location = gesture.location(in: self)
        
        guard location.x <= self.contentSize.width, location.x > 0 else {
            return
        }
        
        let tappedPageIndex = Int(location.x / pageSize.width)
        self.setContentOffset(CGPoint(x: pageSize.width * CGFloat(tappedPageIndex), y: 0), animated: true)
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
}
