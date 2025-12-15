import UIKit
import SnapKit

class VerificationViewController: UIViewController {

    // MARK: - Component: Document Upload Card (Internal)
    
    class DocumentUploadCard: UIView {
        
        var isSelectedCard: Bool = false {
            didSet {
                updateSelectionState()
            }
        }
        
        var onTap: (() -> Void)?
        
        private let containerButton: UIButton = {
            let btn = UIButton()
            return btn
        }()
        
        private let iconCircle: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(hex: "2A3544")
            view.layer.cornerRadius = 25
            view.isUserInteractionEnabled = false
            return view
        }()
        
        private let iconImageView: UIImageView = {
            let iv = UIImageView()
            iv.tintColor = .gray
            iv.contentMode = .scaleAspectFit
            return iv
        }()
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .semibold)
            label.textColor = .white
            return label
        }()
        
        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 13, weight: .regular)
            label.textColor = .gray
            return label
        }()
        
        private let checkmarkIcon: UIImageView = {
            let iv = UIImageView()
            iv.image = UIImage(systemName: "circle")
            iv.tintColor = .gray
            iv.contentMode = .scaleAspectFit
            return iv
        }()
        
        init(icon: String, title: String, subtitle: String) {
            super.init(frame: .zero)
            
            backgroundColor = UIColor(hex: "1E2836")
            layer.cornerRadius = 16
            
            addSubview(containerButton)
            containerButton.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            containerButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)
            
            // Layout (non-interactive elements on top of button but allowing touches to go through if needed, 
            // or we just rely on containerButton covering them. Actually button covers them)
            // Wait, if I put subviews on top of button, button won't get touches unless I set isUserInteractionEnabled=false on subviews.
            
            addSubview(iconCircle)
            iconCircle.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(50)
                make.top.bottom.equalToSuperview().inset(16)
            }
            
            iconCircle.addSubview(iconImageView)
            iconImageView.image = UIImage(systemName: icon)
            iconImageView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(24)
            }
            
            let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            textStack.axis = .vertical
            textStack.spacing = 4
            textStack.isUserInteractionEnabled = false
            
            titleLabel.text = title
            subtitleLabel.text = subtitle
            
            addSubview(textStack)
            textStack.snp.makeConstraints { make in
                make.leading.equalTo(iconCircle.snp.trailing).offset(16)
                make.centerY.equalToSuperview()
                make.trailing.lessThanOrEqualToSuperview().inset(40)
            }
            
            addSubview(checkmarkIcon)
            checkmarkIcon.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(16)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(24)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc private func didTap() {
            onTap?()
        }
        
        private func updateSelectionState() {
            if isSelectedCard {
                iconImageView.tintColor = UIColor(hex: "FFB800")
                checkmarkIcon.image = UIImage(systemName: "checkmark.circle.fill")
                checkmarkIcon.tintColor = UIColor(hex: "FFB800")
                backgroundColor = UIColor(hex: "2A3544")
                layer.borderWidth = 2
                layer.borderColor = UIColor(hex: "FFB800").cgColor
            } else {
                iconImageView.tintColor = .gray
                checkmarkIcon.image = UIImage(systemName: "circle")
                checkmarkIcon.tintColor = .gray
                backgroundColor = UIColor(hex: "1E2836")
                layer.borderWidth = 0
            }
        }
    }

    // MARK: - Properties
    
    private var cards: [DocumentUploadCard] = []
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Verify Your Identity"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let stepLabel: UILabel = {
        let label = UILabel()
        label.text = "Step 2 of 3"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let progressStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let infoCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1E2836")
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(hex: "FFB800")
        config.baseForegroundColor = .black
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 0, bottom: 18, trailing: 0)
        
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        config.attributedTitle = AttributedString("Submit Documents", attributes: titleContainer)
        
        button.configuration = config
        button.layer.cornerRadius = 16
        
        return button
    }()
    
    // MARK: - Lifecycle

    private let viewModel: AuthenticationViewModel
    
    // MARK: - Lifecycle
    
    init(viewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "0F1419")
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        // Header
        let headerStack = UIStackView(arrangedSubviews: [headerLabel, stepLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 8
        contentView.addSubview(headerStack)
        
        headerStack.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        // Progress
        contentView.addSubview(progressStack)
        progressStack.addArrangedSubview(createProgressView(isActive: true))
        progressStack.addArrangedSubview(createProgressView(isActive: true)) // Step 2
        progressStack.addArrangedSubview(createProgressView(isActive: false))
        
        progressStack.snp.makeConstraints { make in
            make.top.equalTo(headerStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        // Info Card
        setupInfoCard()
        contentView.addSubview(infoCard)
        infoCard.snp.makeConstraints { make in
            make.top.equalTo(progressStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        // Document Cards
        let cardsStack = UIStackView()
        cardsStack.axis = .vertical
        cardsStack.spacing = 16
        contentView.addSubview(cardsStack)
        
        let card1 = DocumentUploadCard(icon: "doc.text.fill", title: "Driver's License", subtitle: "Category A/A1")
        let card2 = DocumentUploadCard(icon: "person.text.rectangle.fill", title: "ID / Passport", subtitle: "Government-issued")
        let card3 = DocumentUploadCard(icon: "camera.fill", title: "Live Selfie", subtitle: "For verification")
        
        cards = [card1, card2, card3]
        
        for card in cards {
            cardsStack.addArrangedSubview(card)
            card.onTap = { [weak self] in
                self?.selectCard(card)
            }
        }
        
        cardsStack.snp.makeConstraints { make in
            make.top.equalTo(infoCard.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        // Submit Button
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(cardsStack.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(40)
        }
        
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
    }
    
    private func setupInfoCard() {
        let icon = UIImageView(image: UIImage(systemName: "checkmark.shield.fill"))
        icon.tintColor = UIColor(hex: "FFB800")
        
        let headerLabel = UILabel()
        headerLabel.text = "Why we need this"
        headerLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        headerLabel.textColor = .white
        
        let headerStack = UIStackView(arrangedSubviews: [icon, headerLabel])
        headerStack.spacing = 8
        
        let bodyLabel = UILabel()
        bodyLabel.text = "We verify all users to ensure a safe marketplace for everyone."
        bodyLabel.font = .systemFont(ofSize: 14)
        bodyLabel.textColor = .gray
        bodyLabel.numberOfLines = 0
        
        let timerLabel = UILabel()
        timerLabel.text = "⏱ Verification takes <24 hours"
        timerLabel.font = .systemFont(ofSize: 12)
        timerLabel.textColor = UIColor(hex: "FFB800")
        
        let vStack = UIStackView(arrangedSubviews: [headerStack, bodyLabel, timerLabel])
        vStack.axis = .vertical
        vStack.spacing = 12
        vStack.alignment = .leading
        
        infoCard.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
    }
    
    private func createProgressView(isActive: Bool) -> UIView {
        let view = UIView()
        view.backgroundColor = isActive ? UIColor(hex: "FFB800") : UIColor.gray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 2
        view.snp.makeConstraints { make in
            make.height.equalTo(4)
        }
        return view
    }
    
    private func selectCard(_ selected: DocumentUploadCard) {
        for card in cards {
            card.isSelectedCard = (card == selected)
        }
    }
    
    @objc private func didTapSubmit() {
        viewModel.submitVerification()
        
        let pendingVC = PendingViewController(viewModel: viewModel)
        navigationController?.pushViewController(pendingVC, animated: true)
    }
}
