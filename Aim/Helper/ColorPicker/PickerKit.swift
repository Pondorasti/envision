//
//  PickerKit.swift
//  PickerKit
//
//  Created by Alexandru Turcanu on 31 May 2019.
//  Copyright © 2019 PickerKit. All rights reserved.
//

// Include Foundation
import UIKit
import SwiftUI

open class PickerView: UIView {
    // MARK: - Properties

    private let itemWidth: CGFloat = 44

    /// A floating-point value that determines the spacing between each entry view.
    private let itemSpacing: CGFloat = 12

    /// A floating-point value that determines the radius difference between the entry item and the focus ring.
    private let focusRingRadiusDelta: CGFloat = 10

    /// A Boolean value that controls whether the fade out gradient is visible.
    var shouldFadeOutView: Bool = true {
        didSet {
            layer.mask = shouldFadeOutView ? fadeOutGradientLayer : nil
        }
    }

    /// Decelaration rate for the scroll view.
    var decelerationRate: UIScrollView.DecelerationRate = UIScrollView.DecelerationRate(rawValue: 0.5) {
        didSet {
            entriesPickerCollectionView.decelerationRate = decelerationRate
        }
    }

    /// An integer value representing the selected entry.
    /// Setting this property with a value will automatically scroll to the entry that has that index.
    private(set) var selectedEntry: Int {
        get {
            return getSelectedColorIndex(for: entriesPickerCollectionView.contentOffset)
        }

        set {
            entriesPickerCollectionView.scrollToItem(
                at: IndexPath(row: newValue, section: 0),
                at: .centeredHorizontally,
                animated: true
            )
        }
    }

    private(set) var collectionViewSize = CGSize()
    private(set) var colorEntries = [UIColor]()

    private(set) lazy var entriesPickerCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: CGRect(origin: CGPoint(), size: self.collectionViewSize),
                                              collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.5)

        return collectionView
    }()

    private lazy var focusRingLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.borderWidth = 2
        layer.borderColor = self.colorEntries.first?.cgColor

        return layer
    }()

    private lazy var fadeOutGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()

        let backgroundColor = self.backgroundColor ?? .white

        let colors: [UIColor] = [.clear, backgroundColor, backgroundColor, .clear]
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = [0.0, 0.25, 0.75, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        return gradientLayer
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(entriesPickerCollectionView)
        entriesPickerCollectionView.register(
            ColorCircleCollectionViewCell.self,
            forCellWithReuseIdentifier: ColorCircleCollectionViewCell.identifier
        )

        entriesPickerCollectionView.dataSource = self
        entriesPickerCollectionView.delegate = self
    }

    /// Initializes and returns a new PickerView object with the specified color entries.
    public init(colorEntries: [UIColor], size: CGSize) {
        self.init()

        self.collectionViewSize = size
        self.colorEntries = colorEntries

        entriesPickerCollectionView.frame.size = collectionViewSize
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override open func updateConstraints() {
        if entriesPickerCollectionView.constraints.isEmpty {
            entriesPickerCollectionView.translatesAutoresizingMaskIntoConstraints = false

            entriesPickerCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            entriesPickerCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            entriesPickerCollectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            entriesPickerCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }

        super.updateConstraints()
    }

    override open func draw(_ rect: CGRect) {
        configureFocusRingLayer()

        fadeOutGradientLayer.frame = bounds
        layer.mask = fadeOutGradientLayer
    }

    // MARK: - Methods
    private func getSelectedColorIndex(for contentOffset: CGPoint) -> Int {
        let actualItemWidth = self.itemWidth + itemSpacing
        let rawIndex = Int((contentOffset.x / actualItemWidth).rounded())
        let index: Int

        switch rawIndex {
        case ..<0: // underflow
            index = 0
        case colorEntries.count...: // overflow
            index = colorEntries.count - 1
        default: // index in range
            index = rawIndex
        }

        return index
    }

    private func configureFocusRingLayer() {
        let radius = (itemWidth + focusRingRadiusDelta) / 2

        let xPos = self.bounds.midX - radius
        let yPos = self.bounds.midY - radius
        focusRingLayer.frame = CGRect(x: xPos, y: yPos,
                                      width: radius * 2, height: radius * 2)
        focusRingLayer.cornerRadius = radius

        self.layer.addSublayer(focusRingLayer)
    }
}

// MARK: - UICollectionViewDataSource
extension PickerView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorEntries.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = entriesPickerCollectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCircleCollectionViewCell.identifier,
            for: indexPath
            ) as? ColorCircleCollectionViewCell else {
                fatalError()
        }

        cell.backgroundColor = colorEntries[indexPath.row]

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PickerView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PickerView: UICollectionViewDelegateFlowLayout {
    fileprivate func getItemSize(for collectionView: UICollectionView) -> CGSize {
        let size = itemWidth
        return CGSize(width: size, height: size)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return getItemSize(for: collectionView)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return itemSpacing
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sideInsets = (collectionView.frame.width - itemWidth) / 2

        return UIEdgeInsets(top: 0, left: sideInsets, bottom: 0, right: sideInsets)
    }
}

// MARK: - UIScrollViewDelegate
extension PickerView: UIScrollViewDelegate {
    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let indexOfItem = CGFloat(getSelectedColorIndex(for: targetContentOffset.pointee))
        let itemWidth = getItemSize(for: entriesPickerCollectionView).width + itemSpacing

        targetContentOffset.pointee = CGPoint(
            x: itemWidth * indexOfItem,
            y: targetContentOffset.pointee.y
        )
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let selectedColorIndex = getSelectedColorIndex(for: scrollView.contentOffset)
        focusRingLayer.borderColor = colorEntries[selectedColorIndex].cgColor
    }
}

// MARK: - ColorCircleCollectionViewCell
class ColorCircleCollectionViewCell: UICollectionViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.height / 2
    }
}

extension ColorCircleCollectionViewCell: IdentifiableCell {
    static var identifier: String {
        return String(describing: self)
    }
}

protocol IdentifiableCell {
    static var identifier: String { get }
}


