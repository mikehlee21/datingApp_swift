//
//  CheckInImageCell.swift
//  TestApp2
//
//  Created by macos on 12/2/14.
//  Copyright (c) 2014 Ravi. All rights reserved.
//

import UIKit


@objc protocol RemoveCheckInPhotoDelegate{
    optional func removePhotoAtIndexPath(indexPath : NSIndexPath)
}

class CheckInImageCell: UITableViewCell {

    @IBOutlet weak var m_imgCheckIn: UIImageView!
    var indexPath : NSIndexPath!
    var delegate : RemoveCheckInPhotoDelegate?

    @IBAction func btnRemoveClicked(sender: AnyObject) {
        if(delegate != nil){
            delegate?.removePhotoAtIndexPath!(indexPath)
        }
    }
}
