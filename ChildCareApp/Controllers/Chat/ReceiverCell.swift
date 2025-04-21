//
//  ReceiverCell.swift
//  ChildCareApp
//
//  Created by Benitha on 11/02/2025.
//

import UIKit

class ReceiverCell: UITableViewCell {

    @IBOutlet var messageView: UIView!
    @IBOutlet var messageLabel: UILabel!

    var chat: Chat?{
        didSet {
            
            self.configureCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        //self.contantView.backgroundColor = .clear
        
        messageView.layer.cornerRadius = 12
        messageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner ,.layerMaxXMaxYCorner]
        messageView.backgroundColor = .systemOrange
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() -> Void {
        
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        //self.contantView.backgroundColor = .clear
        
        messageView.layer.cornerRadius = 12
        messageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner ,.layerMaxXMaxYCorner]
        messageView.backgroundColor = .systemOrange
        
        messageLabel.text = chat?.message ?? ""
        messageView.isHidden = false
    }
}
