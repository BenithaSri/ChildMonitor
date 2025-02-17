//
//  ChatViewController.swift
//  ChildrenMonitoring
//
//  Created by Rushika on 2/6/25.
//
//  ChatViewController.swift
//  ChildrenMonitoring
//
//  Created by Rushika on 2/6/25.
//

import UIKit

class ChatViewController: UIViewController {
    
    // UI Elements
    @IBOutlet weak var chatTitleLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messagesScrollView: UIScrollView!
    @IBOutlet weak var messagesStackView: UIStackView!
    
    // Chat Data
    private var messages: [String] = []
    
    // Auto-Reply Timer
    var autoReplyTimer: Timer?

    // Toggle between Parent and Child
    var isParent: Bool = true // Set this to false for Child mode

    // Predefined Messages
    private var parentMessages: [String] = [
        "Parent: How was school today? 😊",
        "Parent: Have you finished your homework? 📚",
        "Parent: Let's get ready for the weekend activities 🏖️.",
        "Parent: Can you please clean your room? 🧹"
    ]
    
    private var childMessages: [String] = [
        "Child: I'm doing good, how about you? 😄",
        "Child: I finished my homework already! 🏆",
        "Child: I want to play a game this weekend! 🎮",
        "Child: My room is messy, but I'll clean it later. 🛏️"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPredefinedMessages()
    }
    
    func setupUI() {
        sendButton.layer.cornerRadius = sendButton.frame.height / 2
    }

    // Load predefined messages for Parent or Child
    func loadPredefinedMessages() {
        if isParent {
            messages.append(contentsOf: parentMessages)
        } else {
            messages.append(contentsOf: childMessages)
        }
        updateMessages()
    }

    @IBAction func sendMessageButtonTapped(_ sender: UIButton) {
        if let message = messageTextField.text, !message.isEmpty {
            sendMessage(message: message)
        }
    }
    
    func sendMessage(message: String) {
        let userRole = isParent ? "[PARENT]" : "[CHILD]"
        messages.append("\(userRole) \(message)")  // Append message
        messageTextField.text = ""  // Clear input field
        updateMessages()
        
        // Reset the auto-reply timer
        autoReplyTimer?.invalidate()
        autoReplyTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(sendAutoReply), userInfo: nil, repeats: false)
    }

    // Auto-Reply if no message is sent within 10 seconds
    @objc func sendAutoReply() {
        let autoReply = isParent ? "[PARENT] I'm busy right now, I'll reply later. 📌" : "[CHILD] I'm not available now, talk later! 🎮"
        messages.append(autoReply)
        updateMessages()
    }

    func updateMessages() {
        // Clear previous messages from stack
        messagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Display all messages
        for (index, message) in messages.enumerated() {
            let messageLabel = UILabel()
            messageLabel.numberOfLines = 0
            messageLabel.isUserInteractionEnabled = true  // Enable user interaction for long press
            
            // Remove [PARENT] or [CHILD] prefix
            messageLabel.text = message
                .replacingOccurrences(of: "[PARENT]", with: "")
                .replacingOccurrences(of: "[CHILD]", with: "")

            // Style messages based on sender
            if message.contains("[PARENT]") {
                messageLabel.backgroundColor = UIColor.blue.withAlphaComponent(0.8)
                messageLabel.textColor = .white
            } else if message.contains("[CHILD]") {
                messageLabel.backgroundColor = UIColor.green.withAlphaComponent(0.8)
                messageLabel.textColor = .white
            } else {
                messageLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.15)
                messageLabel.textColor = .black
            }
            
            messageLabel.layer.cornerRadius = 10
            messageLabel.layer.masksToBounds = true
            messageLabel.textAlignment = .left
            messageLabel.font = UIFont.systemFont(ofSize: 16)
            messageLabel.padding(10, 16, 10, 16) // Apply padding

            // Add long-press gesture for deleting messages
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            messageLabel.addGestureRecognizer(longPressGesture)
            messageLabel.tag = index // Store index to identify message
            
            messagesStackView.addArrangedSubview(messageLabel)
        }
        
        // Scroll to the latest message
        DispatchQueue.main.async {
            let bottomOffset = CGPoint(x: 0, y: self.messagesScrollView.contentSize.height - self.messagesScrollView.bounds.height)
            self.messagesScrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    // Handle long-press to delete a message
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let messageLabel = gesture.view as? UILabel else { return }
        
        let alert = UIAlertController(title: "Delete Message", message: "Are you sure you want to delete this message?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.messages.remove(at: messageLabel.tag)
            self.updateMessages()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
}

// UILabel Extension to Add Padding
extension UILabel {
    func padding(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) {
        self.drawText(in: bounds.insetBy(dx: left, dy: top))
    }
}
