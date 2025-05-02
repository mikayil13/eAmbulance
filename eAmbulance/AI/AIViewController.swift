import UIKit
import Alamofire

class AIViewController: UIViewController, UITextViewDelegate, AIViewModelDelegate {
    private var messages: [String] = []
    private let viewModel = AIViewModel()
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let inputContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.masksToBounds = true
        return view
    }()
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        tv.backgroundColor = .clear
        tv.textColor = .black
        return tv
    }()
    
    private let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.text = "Mesajınızı yazın..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        let image = UIImage(systemName: "paperplane.fill", withConfiguration: symbolConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(red: 20/255, green: 109/255, blue: 191/255, alpha: 1)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chat"
        view.backgroundColor = .white
        setupUI()
        viewModel.delegate = self
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(inputContainer)
        inputContainer.addSubview(textView)
        inputContainer.addSubview(placeHolderLabel)
        view.addSubview(sendButton)
        
        textView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        sendButton.addTarget(self, action: #selector(sendMessageButtonTapped), for: .touchUpInside)
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // Table view
            tableView.topAnchor.constraint(equalTo: guide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -8),
            
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -16),
            
            // Input container
            inputContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            inputContainer.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            inputContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            // Text view inside container
            textView.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -8),
            textView.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: -8),
            
            // Placeholder
            placeHolderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5),
            placeHolderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            
            // Send button
            sendButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 50),
            sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor)
        ])
        
        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -8)
        inputContainerBottomConstraint.isActive = true
    }
    
    // MARK: - Button Action
    @objc private func sendMessageButtonTapped() {
        guard let userMessage = textView.text, !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        viewModel.sendMessage(userMessage)
        textView.text = ""
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        placeHolderLabel.isHidden = !textView.text.isEmpty
    }
    
    // MARK: - AIViewModelDelegate Methods
    func didUpdateMessages() {
        self.messages = viewModel.messages
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    func didStartLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.sendButton.isEnabled = false
        }
    }
    
    func didFinishLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.sendButton.isEnabled = true
        }
    }
    
    // MARK: - TableView Scrolling
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

extension AIViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        let sender = (indexPath.row % 2 == 0) ? "Me" : "HelpMe"
        cell.configure(message: message, sender: sender)
        return cell
    }
}
