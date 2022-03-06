# AlignedCollectionViewFlowLayout

 ![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-E05C43.svg?style=flat)](https://swift.org/package-manager/)
[![License](https://img.shields.io/github/license/Frizlab/AlignedCollectionViewFlowLayout.svg)](License.txt)
[![Frizlab](https://img.shields.io/badge/from-Frizlab-A37264.svg?style=flat)](https://github.com/Frizlab)

A collection view layout that gives you control over the horizontal and vertical alignment of the cells.
You can use it to align the cells like words in a left- or right-aligned text and you can specify how the cells are vertically aligned within their rows.

Other than that, the layout behaves exactly like Apple’s [`UICollectionViewFlowLayout`](https://developer.apple.com/reference/uikit/uicollectionviewflowlayout).
(It is a subclass of it.)

### ℹ️ Important:

`AlignedCollectionViewFlowLayout` was developed with a “**tag view**” in mind, i.e. a collection view that displays a limited number of items with a relatively simple layout.
It works perfectly for this use case.
While it also does its job for a large number of items and more complex cell layouts **scrolling might become laggy** in this case.
This is due to the fact the layout needs to recursively obtain layout attributes from its superclass and cannot be avoided.
If you experience unacceptable lagginess please consider other alternatives.

## Available Alignment Options

You can use _any_ combination of horizontal and vertical alignment to achieve your desired layout.

### Horizontal Alignment:

* `horizontalAlignment = .left`

![Example layout for horizontalAlignment = .left](Docs/Left-aligned-collection-view-layout.png)

* `horizontalAlignment = .right`

![Example layout for horizontalAlignment = .right](Docs/Right-aligned-collection-view-layout.png)

* `horizontalAlignment = .justified`

![Example layout for horizontalAlignment = .justified](Docs/Justified-collection-view-layout.png)

* `horizontalAlignment = .leading`

  Renders as either `.left` or `.right`, depending on the user’s _layout direction_ ([UIApplication.shared.userInterfaceLayoutDirection](https://developer.apple.com/documentation/uikit/uiapplication/1623025-userinterfacelayoutdirection)):
  * `.leftToRight` → `.left` 
  * `.rightToLeft` → `.right` 
 
* `horizontalAlignment = .trailing`

  Renders as either `.left` or `.right`, depending on the user’s _layout direction_ ([UIApplication.shared.userInterfaceLayoutDirection](https://developer.apple.com/documentation/uikit/uiapplication/1623025-userinterfacelayoutdirection)).
  * `.leftToRight` → `.right` 
  * `.rightToLeft` → `.left` 

### Vertical Alignment:

* `verticalAlignment = .top`

![Example layout for verticalAlignment = .top](Docs/Top-aligned-collection-view-layout.png)

* `verticalAlignment = .center`

![Example layout for verticalAlignment = .center](Docs/Vertically-centered-collection-view-layout.png)

* `verticalAlignment = .bottom`

![Example layout for verticalAlignment = .bottom](Docs/Bottom-aligned-collection-view-layout.png)


## Installation

Use SPM.


## Usage

### Setup in Interface Builder

1. You have a collection view in Interface Builder and setup its data source appropriately.
Run the app and make sure everything works as expected (except the cell alignment).

2. In the Document Outline, select the collection view layout object.

    ![Screenshot of the Flow Layout object in Interface Builder](Docs/Screenshot_Interface-Builder_Flow-Layout-Object.png)

3. In the Identity Inspector, set the layout object’s custom class to `AlignedCollectionViewFlowLayout`.

    ![Screenshot: How to set a custom class for the layout object in Interface Builder](Docs/Screenshot_Interface-Builder_Flow-Layout_Custom-Class.png)

4. Add and customize the following code to your view controller’s `viewDidLoad()` method:

    ```Swift
    let alignedFlowLayout = collectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
    alignedFlowLayout?.horizontalAlignment = .left
    alignedFlowLayout?.verticalAlignment = .top
    ```
        
    If you omit any of the last two lines the default alignment will be used (horizontally justified, vertically centered).
    
    💡 **Pro Tip:** Instead of type-casting the layout as shown above you can also drag an outlet from the collection view layout object to your view controller.

### Setup in code

1. Create a new `AlignedCollectionViewFlowLayout` object and specify the alignment you want:

    ```Swift
    let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
    ```

2. Either create a new collection view object and and initialize it with `alignedFlowLayout`:

    ```Swift
    let collectionView = UICollectionView(frame: bounds, collectionViewLayout: alignedFlowLayout)
    ```

    **or** assign `alignedFlowLayout` to the `collectionViewLayout` property of an existing collection view:
    
    ```Swift
    yourExistingCollectionView.collectionViewLayout = alignedFlowLayout
    ```

3. Implement your collection view’s data source.

4. Run the app.

---

### Additional configuration

For the `left` and `right` alignment `AlignedCollectionViewFlowLayout` distributes the cells horizontally with a **constant spacing** which is the same for all rows.
You can control the spacing with the `minimumInteritemSpacing` property.

```Swift
alignedFlowLayout.minimumInteritemSpacing = 10
```

Despite its name (which originates from its superclass `UICollectionViewFlowLayout`) this property doesn’t describe a _minimum_ spacing but the **exact** spacing between the cells.

The vertical spacing between the lines works exactly as in `UICollectionViewFlowLayout`:

```Swift
alignedFlowLayout.minimumLineSpacing = 10
```

---

### Enjoy! 😎

## Author

Originally written by Mischa Hildebrand, web@mischa-hildebrand.de

[![Twitter Follow](https://img.shields.io/twitter/follow/DerHildebrand.svg?style=social&label=Follow)](https://twitter.com/DerHildebrand)
[![GitHub followers](https://img.shields.io/github/followers/mischa-hildebrand.svg?style=social&label=Follow)](https://github.com/mischa-hildebrand)

Forked and modernized by [Frizlab](https://github.com/Frizlab).

[![Follow on Twitter](https://img.shields.io/twitter/follow/Frizlab.svg?style=social)](https://twitter.com/Frizlab)
[![GitHub Followers](https://img.shields.io/github/followers/Frizlab.svg?style=social)](https://github.com/Frizlab)

## License

AlignedCollectionViewFlowLayout is available under the MIT license.
See the [License.txt](License.txt) file for more info.
