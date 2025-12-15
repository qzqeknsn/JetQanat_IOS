import UIKit
import SnapKit
import Combine

class ProfileViewController: UIViewController {

    // MARK: - Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()
    
    private let headerView = UIView()
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = UIColor(hex: "FFB800").withAlphaComponent(0.2)
        iv.layer.cornerRadius = 50
        iv.clipsToBounds = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "John Doe" 
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let verificationBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1E2836")
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let verificationStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "0A0A0A")
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(100)
        }
        
        setupHeader()
        setupMenuSections()
    }
    
    private func setupHeader() {
        let container = UIView()
        
        container.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        container.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        
        container.addSubview(verificationBadge)
        verificationBadge.addSubview(verificationStack)
        
        let icon = UIImageView(image: UIImage(systemName: "checkmark.shield.fill"))
        icon.tintColor = UIColor(hex: "FFB800")
        
        let label = UILabel()
        label.text = "Verified Rider"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "FFB800")
        
        verificationStack.addArrangedSubview(icon)
        verificationStack.addArrangedSubview(label)
        
        verificationBadge.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        
        verificationStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        stackView.addArrangedSubview(container)
    }
    

    
    private let viewModel = UserViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Logic
    
    private func loadData() {
        bindViewModel()
        viewModel.loadUser()
    }
    
    private func bindViewModel() {
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self, let user = user else { return }
                self.nameLabel.text = user.fullName
                self.verificationBadge.isHidden = !user.isVerified
            }
            .store(in: &cancellables)
    }
    
    private func addSectionTitle(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        stackView.addArrangedSubview(label)
    }
    
    private func addMenuItem(icon: String, title: String, badge: String? = nil, action: @escaping () -> Void) {
        let item = ProfileMenuItem(icon: icon, title: title, badge: badge)
        item.addAction(UIAction(handler: { _ in action() }), for: .touchUpInside)
        stackView.addArrangedSubview(item)
    }
    
    private func setupMenuSections() {
        
        addSectionTitle("My Motor-Hub")
        addMenuItem(icon: "cart.fill", title: "My Ads & Purchases") { [weak self] in self?.navigationController?.pushViewController(PurchaseHistoryViewController(), animated: true) }
        addMenuItem(icon: "wrench.fill", title: "Service History") { [weak self] in self?.navigationController?.pushViewController(ServiceHistoryViewController(), animated: true) }
        addMenuItem(icon: "shippingbox.fill", title: "Order Tracking") { [weak self] in self?.navigationController?.pushViewController(OrderTrackingViewController(), animated: true) }
        
        
        addSectionTitle("Settings & Support")
        addMenuItem(icon: "gearshape.fill", title: "Account Settings") { [weak self] in self?.navigationController?.pushViewController(AccountSettingsViewController(), animated: true) }
        addMenuItem(icon: "lock.shield.fill", title: "Security & Privacy") { [weak self] in self?.navigationController?.pushViewController(SecurityPrivacyViewController(), animated: true) }
        addMenuItem(icon: "creditcard.fill", title: "Payment Methods") { [weak self] in self?.navigationController?.pushViewController(PaymentMethodsViewController(), animated: true) }
        addMenuItem(icon: "questionmark.circle.fill", title: "Help & Support") { [weak self] in self?.navigationController?.pushViewController(HelpSupportViewController(), animated: true) }
        
        
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.setTitleColor(.systemRed, for: .normal)
        logoutButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        logoutButton.backgroundColor = UIColor(hex: "1E2836")
        logoutButton.layer.cornerRadius = 12
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        
        stackView.addArrangedSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    @objc private func didTapLogout() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            
            AuthenticationViewModel.shared.logout()
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let welcomeVC = UINavigationController(rootViewController: WelcomeViewController())
                window.rootViewController = welcomeVC
                window.makeKeyAndVisible()
                
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }))
        present(alert, animated: true)
    }
}
