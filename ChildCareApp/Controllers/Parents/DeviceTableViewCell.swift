//
//  DeviceTableViewCell.swift
//  ChildCareApp
//
//  Created by Benitha on 25/02/2025.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLBL: UILabel!
    @IBOutlet weak var deviceLBL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
