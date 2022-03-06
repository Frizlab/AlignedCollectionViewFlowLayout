/*
 * UICollectionViewLayoutAttributes+Utils.swift
 *
 * Created by Frizlab on 2022/03/06.
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

import Foundation
import UIKit



internal extension UICollectionViewLayoutAttributes {
	
	private var currentSection: Int {
		return indexPath.section
	}
	
	private var currentItem: Int {
		return indexPath.item
	}
	
	/**
	 The index path for the item preceding the item represented by this layout attributes object. */
	private var precedingIndexPath: IndexPath {
		return IndexPath(item: currentItem - 1, section: currentSection)
	}
	
	/**
	 The index path for the item following the item represented by this layout attributes object. */
	private var followingIndexPath: IndexPath {
		return IndexPath(item: currentItem + 1, section: currentSection)
	}
	
	/**
	 Checks if the item represetend by this layout attributes object is the first item in the line.
	 
	 - Parameter collectionViewLayout: The layout for which to perform the check.
	 - Returns: `true` if the represented item is the first item in the line, else `false`. */
	func isRepresentingFirstItemInLine(collectionViewLayout: AlignedCollectionViewFlowLayout) -> Bool {
		guard currentItem > 0,
				let layoutAttributesForPrecedingItem = collectionViewLayout.originalLayoutAttribute(forItemAt: precedingIndexPath)
		else {
			return true
		}
		return !collectionViewLayout.isFrame(for: self, inSameLineAsFrameFor: layoutAttributesForPrecedingItem)
	}
	
	/**
	 Checks if the item represetend by this layout attributes object is the last item in the line.
	 
	 - Parameter collectionViewLayout: The layout for which to perform the check.
	 - Returns: `true` if the represented item is the last item in the line, else `false`. */
	func isRepresentingLastItemInLine(collectionViewLayout: AlignedCollectionViewFlowLayout) -> Bool {
		guard let itemCount = collectionViewLayout.collectionView?.numberOfItems(inSection: currentSection) else {
			return false
		}
		
		if currentItem >= itemCount - 1 {
			return true
		}
		
		if let layoutAttributesForFollowingItem = collectionViewLayout.originalLayoutAttribute(forItemAt: followingIndexPath) {
			return !collectionViewLayout.isFrame(for: self, inSameLineAsFrameFor: layoutAttributesForFollowingItem)
		}
		
		return true
	}
	
	/**
	 Moves the layout attributes object's frame so that it is aligned horizontally with the alignment axis. */
	func align(toAlignmentAxis alignmentAxis: AlignmentAxis<HorizontalAlignment>) {
		switch alignmentAxis.alignment {
			case .left:  frame.origin.x = alignmentAxis.position
			case .right: frame.origin.x = alignmentAxis.position - frame.size.width
				
			case .leading, .trailing, .justified: (/*nop*/)
		}
	}
	
	/**
	 Moves the layout attributes object's frame so that it is aligned vertically with the alignment axis. */
	func align(toAlignmentAxis alignmentAxis: AlignmentAxis<VerticalAlignment>) {
		switch alignmentAxis.alignment {
			case .top:    frame.origin.y = alignmentAxis.position
			case .bottom: frame.origin.y = alignmentAxis.position - frame.size.height
			default:            center.y = alignmentAxis.position
		}
	}
	
	/**
	 Positions the frame right of the preceding item's frame,
	 leaving a spacing between the frames as defined by the collection view layout's `minimumInteritemSpacing`.
	 
	 - Parameter collectionViewLayout: The layout on which to perfom the calculations. */
	private func alignToPrecedingItem(collectionViewLayout: AlignedCollectionViewFlowLayout) {
		let itemSpacing = collectionViewLayout.minimumInteritemSpacing
		
		if let precedingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: precedingIndexPath) {
			frame.origin.x = precedingItemAttributes.frame.maxX + itemSpacing
		}
	}
	
	/**
	 Positions the frame left of the following item's frame,
	 leaving a spacing between the frames as defined by the collection view layout's `minimumInteritemSpacing`.
	 
	 - Parameter collectionViewLayout: The layout on which to perfom the calculations. */
	private func alignToFollowingItem(collectionViewLayout: AlignedCollectionViewFlowLayout) {
		let itemSpacing = collectionViewLayout.minimumInteritemSpacing
		
		if let followingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: followingIndexPath) {
			frame.origin.x = followingItemAttributes.frame.minX - itemSpacing - frame.size.width
		}
	}
	
	/**
	 Aligns the frame horizontally as specified by the collection view layout's `horizontalAlignment`.
	 
	 - Parameter collectionViewLayout: The layout providing the alignment information. */
	func alignHorizontally(collectionViewLayout: AlignedCollectionViewFlowLayout) {
		guard let alignmentAxis = collectionViewLayout.alignmentAxis else {
			return
		}
		
		switch collectionViewLayout.effectiveHorizontalAlignment {
			case .left:
				if isRepresentingFirstItemInLine(collectionViewLayout: collectionViewLayout) {
					align(toAlignmentAxis: alignmentAxis)
				} else {
					alignToPrecedingItem(collectionViewLayout: collectionViewLayout)
				}
				
			case .right:
				if isRepresentingLastItemInLine(collectionViewLayout: collectionViewLayout) {
					align(toAlignmentAxis: alignmentAxis)
				} else {
					alignToFollowingItem(collectionViewLayout: collectionViewLayout)
				}
				
			case .justified: (/*nop*/)
		}
	}
	
	/**
	 Aligns the frame vertically as specified by the collection view layout's `verticalAlignment`.
	 
	 - Parameter collectionViewLayout: The layout providing the alignment information. */
	func alignVertically(collectionViewLayout: AlignedCollectionViewFlowLayout) {
		let alignmentAxis = collectionViewLayout.verticalAlignmentAxis(for: self)
		align(toAlignmentAxis: alignmentAxis)
	}
	
}
