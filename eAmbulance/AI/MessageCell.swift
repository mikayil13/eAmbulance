import UIKit

class MessageCell: UITableViewCell {

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var gradientLayer: CAGradientLayer?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 250/255, alpha: 1)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)

        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)

        bubbleView.layer.cornerRadius = 22
        bubbleView.layer.masksToBounds = true
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOpacity = 0.05
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleView.layer.shadowRadius = 6

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 14),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -14),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 18),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -18),

            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 280)
        ])

        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bubbleView.bounds
    }

    func configure(message: String, sender: String) {
        messageLabel.text = message

        if sender == "Me" {
            // Gradient Layer
            gradientLayer?.removeFromSuperlayer()
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.frame = bubbleView.bounds
            gradient.cornerRadius = 22
            bubbleView.layer.insertSublayer(gradient, at: 0)
            gradientLayer = gradient

            messageLabel.textColor = .white
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
        } else {
            // Remove gradient if exists
            gradientLayer?.removeFromSuperlayer()
            bubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
            messageLabel.textColor = .black

            trailingConstraint.isActive = false
            leadingConstraint.isActive = true
        }
    }
}

