//
//  ChatViewController.swift
//  ChildrenMonitoring
//
//  Created by Rushika on 2/6/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
 
class ChatViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messagesScrollView: UIScrollView!
    @IBOutlet weak var messagesStackView: UIStackView!
    
    private var db: Firestore!
    private var messages: [String] = []
    private var documentIDs: [String] = []
    private var keyboardHeight: CGFloat = 0
    private var bottomConstraint: NSLayoutConstraint!
    var isParent: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        db = Firestore.firestore()
        configureViews()
        loadMessages()
    }
    
    private func setupUI() {
        messageTextField.delegate = self
        messageTextField.layer.cornerRadius = 20
        messageTextField.layer.borderWidth = 1
        messageTextField.layer.borderColor = UIColor.systemGray4.cgColor
        messageTextField.backgroundColor = .systemBackground
        messageTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: messageTextField.frame.height))
        messageTextField.leftViewMode = .always

        sendButton.layer.cornerRadius = sendButton.frame.height / 2
        sendButton.backgroundColor = .systemBlue
        sendButton.tintColor = .white

        bottomConstraint = messageTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        bottomConstraint.isActive = true
    }
    
    private func configureViews() {
        messagesScrollView.backgroundColor = .systemBackground
        messagesStackView.axis = .vertical
        messagesStackView.alignment = .fill
        messagesStackView.distribution = .fill
        messagesStackView.spacing = 8
        messagesStackView.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        messagesStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            UIView.animate(withDuration: 0.3) {
                self.bottomConstraint.constant = -keyboardFrame.height - 8
                self.view.layoutIfNeeded()
                self.scrollToBottom()
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = -8
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Message Handling
    private func loadMessages() {
        db.collection("messages").order(by: "timestamp").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching messages: \(error)")
                return
            }
            self.messages.removeAll()
            self.documentIDs.removeAll()
            for document in snapshot?.documents ?? [] {
                if let message = document.data()["message"] as? String {
                    self.messages.append(message)
                    self.documentIDs.append(document.documentID)
                }
            }
            self.updateMessages()
        }
    }
    
    @IBAction func sendMessageButtonTapped(_ sender: UIButton) {
        sendMessageIfNotEmpty()
    }
    
    private func sendMessageIfNotEmpty() {
        guard let message = messageTextField.text, !message.isEmpty else { return }
        let userRole = isParent ? "[PARENT]" : "[CHILD]"
        let messageData: [String: Any] = [
            "message": "\(userRole) \(message)",
            "timestamp": FieldValue.serverTimestamp()
        ]
        db.collection("messages").addDocument(data: messageData) { [weak self] error in
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                self?.messageTextField.text = ""
            }
        }
    }
    
    private func updateMessages() {
        messagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, message) in messages.enumerated() {
            let messageView = createMessageView(for: message, at: index)
            messagesStackView.addArrangedSubview(messageView)
        }
        scrollToBottom()
    }
    
    private func createMessageView(for message: String, at index: Int) -> UIView {
        let containerView = UIView()
        let bubbleView = UIView()
        let messageLabel = UILabel()

        messageLabel.numberOfLines = 0
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 16)

        containerView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)

        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds = true

        setupMessageConstraints(containerView: containerView, bubbleView: bubbleView, messageLabel: messageLabel, isParentMessage: message.contains("[PARENT]"))
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        bubbleView.addGestureRecognizer(longPress)
        bubbleView.isUserInteractionEnabled = true
        bubbleView.tag = index
        
        return containerView
    }
    
    private func setupMessageConstraints(containerView: UIView, bubbleView: UIView, messageLabel: UILabel, isParentMessage: Bool) {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.preferredMaxLayoutWidth = view.frame.width * 0.75

        bubbleView.backgroundColor = isParentMessage ? .systemBlue : .systemGray5
        messageLabel.textColor = isParentMessage ? .white : .black

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),

            bubbleView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 0.75)
        ])

        if isParentMessage {
            bubbleView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).isActive = true
        } else {
            bubbleView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8).isActive = true
        }
    }

    // MARK: - Scroll to Bottom
    private func scrollToBottom() {
        DispatchQueue.main.async {
            let bottomOffset = CGPoint(x: 0, y: max(0, self.messagesScrollView.contentSize.height - self.messagesScrollView.bounds.height))
            self.messagesScrollView.setContentOffset(bottomOffset, animated: true)
        }
    }

    // MARK: - Handle Message Deletion
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let bubbleView = gesture.view else { return }
        let index = bubbleView.tag
        let documentID = documentIDs[index]
        db.collection("messages").document(documentID).delete()
    }
}
