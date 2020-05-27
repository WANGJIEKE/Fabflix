//
//  LoadingCell.swift
//  Fabflix
//
//  Created by Tongjie Wang on 5/27/20.
//  Copyright © 2020 wangtongjie. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = false
    }
}
