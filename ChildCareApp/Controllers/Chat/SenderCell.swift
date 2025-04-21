//
//  SenderCell.swift
//  ChildCareApp
//
//  Created by Benitha on 11/02/2025.
//

import UIKit

class SenderCell: UITableViewCell {

      
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
        messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        messageView.backgroundColor = .systemYellow
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
        messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        messageView.backgroundColor = .systemYellow
        
        messageLabel.text = chat?.message ?? ""
        messageView.isHidden = false
    }
}
