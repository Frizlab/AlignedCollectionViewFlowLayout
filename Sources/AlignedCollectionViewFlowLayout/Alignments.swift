/*
 * Alignments.swift
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

import CoreGraphics
import Foundation



/**
 An abstract protocol that defines an alignment. */
protocol Alignment {}


/**
 Defines a horizontal alignment for UI elements. */
public enum HorizontalAlignment : Alignment {
	
	case left
	case right
	case leading
	case trailing
	case justified
	
}

/**
 Defines a vertical alignment for UI elements. */
public enum VerticalAlignment : Alignment {
	
	case top
	case center
	case bottom
	
}


/* ****************
   MARK: - Internal
   **************** */

/**
 A horizontal alignment used internally by `AlignedCollectionViewFlowLayout` to layout the items, after resolving layout direction specifics. */
internal enum EffectiveHorizontalAlignment : Alignment {
	
	case left
	case right
	case justified
	
}


/**
 Describes an axis with respect to which items can be aligned. */
internal struct AlignmentAxis<A : Alignment> {
	
	/** Determines how items are aligned relative to the axis. */
	let alignment: A
	
	/**
	 Defines the position of the axis.
	 - If the `Alignment` is horizontal, the alignment axis is vertical and this is the position on the `x` axis.
	 - If the `Alignment` is vertical, the alignment axis is horizontal and this is the position on the `y` axis. */
	let position: CGFloat
	
}
