//
//  MyUICollectionView.swift
//  BlackJack
//
//  Created by Hayden Schmackpfeffer on 2/19/16.
//  Copyright © 2016 CBC. All rights reserved.
//

import Foundation
import UIKit

let ITEM_WIDTH: CGFloat = 20
let ITEM_HEIGH: CGFloat = 50

class MyUICollectionView : UICollectionViewLayout {
    var cellCount: Int = Int()

    override func collectionViewContentSize() -> CGSize {
        return self.collectionView!.frame.size
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.size = CGSizeMake(ITEM_WIDTH, ITEM_HEIGH)
        
//        let i = indexPath.row
        
//        attributes.center = CGPointMake(CGFloat(i * 30), 0)
        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes : [UICollectionViewLayoutAttributes] = []
        
        for i in 0..<self.cellCount {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            attributes.append(self.layoutAttributesForItemAtIndexPath(indexPath)!)
        }
        return attributes
    }
    
}