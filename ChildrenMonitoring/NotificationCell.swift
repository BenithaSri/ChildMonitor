//
//  NotificationCell.swift
//  ChildrenMonitoring
//
//  Created by Benitha Sri Panchagiri on 2/16/25.
//

import UIKit
import UserNotifications

class NotificationCell: UITableViewCell {

    // Outlets for UI elements
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    

    override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
        
        private func setupUI() {
            // Configure labels
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            bodyLabel.font = .systemFont(ofSize: 14, weight: .regular)
            bodyLabel.numberOfLines = 0
            dateLabel.font = .systemFont(ofSize: 12, weight: .light)
            dateLabel.textColor = .gray
        }
        
        // Function to configure the cell with notification data
        func configure(with title: String, body: String, date: Date) {
            titleLabel.text = title
            bodyLabel.text = body
            
            // Format the date
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            dateLabel.text = formatter.string(from: date)
        }
        
        // Alternative configure method for backward compatibility
        func configure(with title: String, body: String) {
            titleLabel.text = title
            bodyLabel.text = body
            dateLabel.text = "" // Clear the date label if no date is provided
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            titleLabel.text = nil
            bodyLabel.text = nil
            dateLabel.text = nil
        }
}
