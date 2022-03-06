/*
 * AlignedCollectionViewFlowLayout.swift
 *
 * Created by Mischa Hildebrand on 2017/04/12.
 * Copyright © 2017 Mischa Hildebrand.
 * Copyright © 2022 Frizlab.
 *
 * Licensed under the terms of the MIT license:
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit



/**
 A `UICollectionViewFlowLayout` subclass that gives you control over the horizontal and vertical alignment of the cells.
 You can use it to align the cells like words in a left- or right-aligned text and you can specify how the cells are vertically aligned in their row. */
open class AlignedCollectionViewFlowLayout : UICollectionViewFlowLayout {
	
	/* *********************
	   MARK: - 🔶 Properties
	   ********************* */
	
	/**
	 Determines how the cells are horizontally aligned in a row.
	 
	 - Note: The default is `.justified`. */
	public var horizontalAlignment: HorizontalAlignment = .justified
	
	/**
	 Determines how the cells are vertically aligned in a row.
	 
	 - Note: The default is `.center`. */
	public var verticalAlignment: VerticalAlignment = .center
	
	/**
	 The `horizontalAlignment` with its layout direction specifics resolved,
	 i.e. `.leading` and `.trailing` alignments are mapped to `.left` or `right`,
	 depending on the current layout direction. */
	internal var effectiveHorizontalAlignment: EffectiveHorizontalAlignment {
		var trivialMapping: [HorizontalAlignment: EffectiveHorizontalAlignment] {
			return [
				.left: .left,
				.right: .right,
				.justified: .justified
			]
		}
		
		let layoutDirection = UIApplication.shared.userInterfaceLayoutDirection
		
		switch layoutDirection {
			case .leftToRight:
				switch horizontalAlignment {
					case .leading:  return .left
					case .trailing: return .right
					case .left, .right, .justified: (/*nop*/)
				}
				
			case .rightToLeft:
				switch horizontalAlignment {
					case .leading:  return .right
					case .trailing: return .left
					case .left, .right, .justified: (/*nop*/)
				}
				
			@unknown default:
				(/*TODO: Log unknown case */)
		}
		
		/* It's safe to force-unwrap as `.leading` and `.trailing` are covered above and the `trivialMapping` dictionary contains all other keys. */
		return trivialMapping[horizontalAlignment]!
	}
	
	/**
	 The vertical axis with respect to which the cells are horizontally aligned.
	 For a `justified` alignment the alignment axis is not defined and this value is `nil`. */
	internal var alignmentAxis: AlignmentAxis<HorizontalAlignment>? {
		switch effectiveHorizontalAlignment {
			case .left:
				return AlignmentAxis(alignment: HorizontalAlignment.left, position: sectionInset.left)
				
			case .right:
				guard let collectionViewWidth = collectionView?.frame.size.width else {
					return nil
				}
				return AlignmentAxis(alignment: HorizontalAlignment.right, position: collectionViewWidth - sectionInset.right)
				
			case .justified:
				return nil
		}
	}
	
	/**
	 The width of the area inside the collection view that can be filled with cells. */
	private var contentWidth: CGFloat? {
		guard let collectionViewWidth = collectionView?.frame.size.width else {
			return nil
		}
		return collectionViewWidth - sectionInset.left - sectionInset.right
	}
	
	/* *************************
	   MARK: - 👶 Initialization
	   ************************* */
	
	/**
	 The designated initializer.
	 
	 - Parameters:
	   - horizontalAlignment: Specifies how the cells are horizontally aligned in a row. Defaults to `.justified`.
	   - verticalAlignment:   Specified how the cells are vertically aligned in a row. Defaults `.center`. */
	public init(horizontalAlignment: HorizontalAlignment = .justified, verticalAlignment: VerticalAlignment = .center) {
		super.init()
		
		self.horizontalAlignment = horizontalAlignment
		self.verticalAlignment = verticalAlignment
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	
	/* *********************
	   MARK: - 🅾️ Overrides
	   ********************* */
	
	override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		/* 💡 IDEA:
		 * The approach for computing a cell's frame is to create a rectangle that covers the current line.
		 * Then we check if the preceding cell's frame intersects with this rectangle.
		 * If it does, the current item is not the first item in the line. Otherwise it is.
		 * (Vice-versa for right-aligned cells.)
		 *
		 * +---------+----------------------------------------------------------------+---------+
		 * |         |                                                                |         |
		 * |         |     +------------+                                             |         |
		 * |         |     |            |                                             |         |
		 * | section |- - -|- - - - - - |- - - - +---------------------+ - - - - - - -| section |
		 * |  inset  |     |intersection|        |                     |   line rect  |  inset  |
		 * |         |- - -|- - - - - - |- - - - +---------------------+ - - - - - - -|         |
		 * | (left)  |     |            |             current item                    | (right) |
		 * |         |     +------------+                                             |         |
		 * |         |     previous item                                              |         |
		 * +---------+----------------------------------------------------------------+---------+
		 *
		 * ℹ️ We need this rather complicated approach because the first item in a line
		 *    is not always left-aligned and the last item in a line is not always right-aligned:
		 *    If there is only one item in a line UICollectionViewFlowLayout will center it. */
		
		/* We may not change the original layout attributes or UICollectionViewFlowLayout might complain. */
		guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
			return nil
		}
		
		/* For a justified layout there's nothing to do here as UICollectionViewFlowLayout justifies the items in a line by default. */
		if horizontalAlignment != .justified {
			layoutAttributes.alignHorizontally(collectionViewLayout: self)
		}
		
		/* For a vertically centered layout there's nothing to do here as UICollectionViewFlowLayout center-aligns the items in a line by default. */
		if verticalAlignment != .center {
			layoutAttributes.alignVertically(collectionViewLayout: self)
		}
		
		return layoutAttributes
	}
	
	override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		/* We may not change the original layout attributes or UICollectionViewFlowLayout might complain. */
		let layoutAttributesObjects = copy(super.layoutAttributesForElements(in: rect))
		layoutAttributesObjects?.forEach({ (layoutAttributes) in
			setFrame(forLayoutAttributes: layoutAttributes)
		})
		return layoutAttributesObjects
	}
	
	
	/* **********************************
	   MARK: - 👷 Private layout helpers
	   ********************************** */
	
	/**
	 Sets the frame for the passed layout attributes object by calling the `layoutAttributesForItem(at:)` function. */
	private func setFrame(forLayoutAttributes layoutAttributes: UICollectionViewLayoutAttributes) {
		if layoutAttributes.representedElementCategory == .cell { // Do not modify header views etc.
			let indexPath = layoutAttributes.indexPath
			if let newFrame = layoutAttributesForItem(at: indexPath)?.frame {
				layoutAttributes.frame = newFrame
			}
		}
	}
	
	/**
	 A function to access the `super` implementation of `layoutAttributesForItem(at:)` externally.
	 
	 - Parameter indexPath: The index path of the item for which to return the layout attributes.
	 - Returns: The unmodified layout attributes for the item at the specified index path as computed by `UICollectionViewFlowLayout`. */
	internal func originalLayoutAttribute(forItemAt indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return super.layoutAttributesForItem(at: indexPath)
	}
	
	/**
	 Determines if the `firstItemAttributes`' frame is in the same line as the `secondItemAttributes`' frame.
	 
	 - Parameters:
	   - firstItemAttributes:  The first layout attributes object to be compared.
	   - secondItemAttributes: The second layout attributes object to be compared.
	 - Returns: `true` if the frames of the two layout attributes are in the same line, else `false`.
	            `false` is also returned when the layout's `collectionView` property is `nil`. */
	internal func isFrame(for firstItemAttributes: UICollectionViewLayoutAttributes, inSameLineAsFrameFor secondItemAttributes: UICollectionViewLayoutAttributes) -> Bool {
		guard let lineWidth = contentWidth else {
			return false
		}
		let firstItemFrame = firstItemAttributes.frame
		let lineFrame = CGRect(
			x: sectionInset.left,
			y: firstItemFrame.origin.y,
			width: lineWidth,
			height: firstItemFrame.size.height
		)
		return lineFrame.intersects(secondItemAttributes.frame)
	}
	
	/**
	 Determines the layout attributes objects for all items displayed in the same line as the item represented by the passed `layoutAttributes` object.
	 
	 - Parameter layoutAttributes: The layout attributed that represents the reference item.
	 - Returns: The layout attributes objects representing all other items in the same line.
	            The passed `layoutAttributes` object itself is always contained in the returned array. */
	internal func layoutAttributes(forItemsInLineWith layoutAttributes: UICollectionViewLayoutAttributes) -> [UICollectionViewLayoutAttributes] {
		guard let lineWidth = contentWidth else {
			return [layoutAttributes]
		}
		var lineFrame = layoutAttributes.frame
		lineFrame.origin.x = sectionInset.left
		lineFrame.size.width = lineWidth
		return super.layoutAttributesForElements(in: lineFrame) ?? []
	}
	
	/**
	 Computes the alignment axis with which to align the items represented by the `layoutAttributes` objects vertically.
	 
	 - Parameter layoutAttributes: The layout attributes objects to be vertically aligned.
	 - Returns: The axis with respect to which the layout attributes can be aligned or `nil` if the `layoutAttributes` array is empty. */
	private func verticalAlignmentAxisForLine(with layoutAttributes: [UICollectionViewLayoutAttributes]) -> AlignmentAxis<VerticalAlignment>? {
		
		guard let firstAttribute = layoutAttributes.first else {
			return nil
		}
		
		switch verticalAlignment {
			case .top:
				let minY = layoutAttributes.reduce(CGFloat.greatestFiniteMagnitude) { min($0, $1.frame.minY) }
				return AlignmentAxis(alignment: .top, position: minY)
				
			case .bottom:
				let maxY = layoutAttributes.reduce(0) { max($0, $1.frame.maxY) }
				return AlignmentAxis(alignment: .bottom, position: maxY)
				
			default:
				let centerY = firstAttribute.center.y
				return AlignmentAxis(alignment: .center, position: centerY)
		}
	}
	
	/**
	 Computes the axis with which to align the item represented by the `currentLayoutAttributes` vertically.
	 
	 - Parameter currentLayoutAttributes: The layout attributes representing the item to be vertically aligned.
	 - Returns: The axis with respect to which the item can be aligned. */
	internal func verticalAlignmentAxis(for currentLayoutAttributes: UICollectionViewLayoutAttributes) -> AlignmentAxis<VerticalAlignment> {
		let layoutAttributesInLine = layoutAttributes(forItemsInLineWith: currentLayoutAttributes)
		/* It’s okay to force-unwrap here because we pass a non-empty array. */
		return verticalAlignmentAxisForLine(with: layoutAttributesInLine)!
	}
	
	/**
	 Creates a deep copy of the passed array by copying all its items.
	 
	 - Parameter layoutAttributesArray: The array to be copied.
	 - Returns: A deep copy of the passed array. */
	private func copy(_ layoutAttributesArray: [UICollectionViewLayoutAttributes]?) -> [UICollectionViewLayoutAttributes]? {
		return layoutAttributesArray?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
	}
	
}
