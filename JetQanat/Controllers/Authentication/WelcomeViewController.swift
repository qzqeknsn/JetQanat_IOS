import UIKit
import SnapKit
import Combine

// MARK: - Theme Configuration
fileprivate struct WelcomeTheme {
    static let neonAccent = UIColor(hex: "FFB800")
    static let backgroundTop = UIColor.black
    static let backgroundBottom = UIColor.black
    static let textPrimary = UIColor.white
    static let textSecondary = UIColor.systemGray2
}

class WelcomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: AuthenticationViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let logoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = WelcomeTheme.backgroundTop
        view.layer.shadowColor = WelcomeTheme.neonAccent.cgColor
        view.layer.shadowOpacity = 0.7
        view.layer.shadowRadius = 40
        view.layer.shadowOffset = .zero
        view.layer.cornerRadius = 80 
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "logo_preview")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor = WelcomeTheme.neonAccent.withAlphaComponent(0.3).cgColor
        iv.layer.cornerRadius = 80 
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ready to Ride?"
        label.textColor = WelcomeTheme.textPrimary
        label.textAlignment = .center
        
        if let descriptor = UIFont.systemFont(ofSize: 34, weight: .heavy).fontDescriptor.withDesign(.rounded) {
            label.font = UIFont(descriptor: descriptor, size: 34)
        } else {
            label.font = .systemFont(ofSize: 34, weight: .heavy)
        }
        
        let attrString = NSMutableAttributedString(string: label.text!)
        attrString.addAttribute(.kern, value: 0.5, range: NSRange(location: 0, length: attrString.length))
        label.attributedText = attrString
        
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Premium Motorcycle Rentals"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = WelcomeTheme.textSecondary
        label.textAlignment = .center
        
        let attrString = NSMutableAttributedString(string: label.text!)
        attrString.addAttribute(.kern, value: 0.3, range: NSRange(location: 0, length: attrString.length))
        label.attributedText = attrString
        
        return label
    }()
    
    private lazy var featuresStack: UIStackView = {
        let f1 = createFeatureItem(icon: "checkmark.seal.fill", text: "Verified")
        let f2 = createFeatureItem(icon: "bolt.fill", text: "Fast")
        let f3 = createFeatureItem(icon: "headphones", text: "Support")
        
        let stack = UIStackView(arrangedSubviews: [f1, f2, f3])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()
    
    private let backgroundPatternLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = WelcomeTheme.neonAccent.withAlphaComponent(0.15).cgColor // Very pale neon
        layer.lineWidth = 1.5
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        return layer
    }()
    
    private let bottomGlowLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            WelcomeTheme.neonAccent.withAlphaComponent(0.1).cgColor,
            WelcomeTheme.neonAccent.withAlphaComponent(0.35).cgColor
        ]
        layer.locations = [0.0, 0.5, 1.0]
        return layer
    }()

    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = WelcomeTheme.neonAccent
        button.layer.cornerRadius = 28
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        
        button.layer.shadowColor = WelcomeTheme.neonAccent.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 15
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        return button
    }()
    
    private let logInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(WelcomeTheme.neonAccent, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 28
        button.layer.borderWidth = 2
        button.layer.borderColor = WelcomeTheme.neonAccent.cgColor
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
    private let noiseOverlayView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "noise_texture")
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0.07
        return iv
    }()

    // MARK: - Lifecycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let bgGradient = view.layer.sublayers?.first as? CAGradientLayer {
            bgGradient.frame = view.bounds
        }
        
        backgroundPatternLayer.frame = view.bounds
        setupBackgroundPattern()
        
        let glowHeight = view.bounds.height * 0.35
        bottomGlowLayer.frame = CGRect(x: 0,
                                       y: view.bounds.height - glowHeight,
                                       width: view.bounds.width,
                                       height: glowHeight)
    }
    
    // ...
    private func setupBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [WelcomeTheme.backgroundTop.cgColor, WelcomeTheme.backgroundBottom.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        
        view.layer.insertSublayer(backgroundPatternLayer, at: 1)
        
        view.addSubview(noiseOverlayView)
        noiseOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.layer.insertSublayer(bottomGlowLayer, at: 2)
        
        view.sendSubviewToBack(noiseOverlayView) 
    }
    
    private func setupBackgroundPattern() {
        let path = UIBezierPath()
        let width = view.bounds.width
        let height = view.bounds.height
        
        path.move(to: CGPoint(x: -width * 0.2, y: height * 0.7))
        path.addCurve(to: CGPoint(x: width * 1.2, y: height * 0.2),
                      controlPoint1: CGPoint(x: width * 0.4, y: height * 0.8),
                      controlPoint2: CGPoint(x: width * 0.8, y: height * 0.3))
        
        path.move(to: CGPoint(x: width * 0.1, y: height))
        path.addLine(to: CGPoint(x: width * 0.8, y: 0))
        
        path.move(to: CGPoint(x: -width * 0.1, y: height * 0.85))
        path.addQuadCurve(to: CGPoint(x: width * 1.1, y: height * 0.9),
                          controlPoint: CGPoint(x: width * 0.5, y: height * 0.75))

        backgroundPatternLayer.path = path.cgPath
    }
    

    

    
    // MARK: - Init
    
    init(viewModel: AuthenticationViewModel = AuthenticationViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
        setupActions()
    }
    

    
    // MARK: - Setup UI
    
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(logoContainerView)
        logoContainerView.addSubview(logoImageView)
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(featuresStack)
        
        let buttonStack = UIStackView(arrangedSubviews: [signUpButton, logInButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        view.addSubview(buttonStack)
        
        
        logoContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(160)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoContainerView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        featuresStack.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(70)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(featuresStack.snp.bottom).offset(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }
    }
    
    // MARK: - Helpers
    
    private func createFeatureItem(icon: String, text: String) -> UIView {
        let container = UIView()
        
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let iconIV = UIImageView(image: UIImage(systemName: icon, withConfiguration: config))
        iconIV.tintColor = WelcomeTheme.neonAccent
        iconIV.contentMode = .center
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = WelcomeTheme.textSecondary
        label.textAlignment = .center
        
        container.addSubview(iconIV)
        container.addSubview(label)
        
        iconIV.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(iconIV.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        return container
    }
    
    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        logInButton.addTarget(self, action: #selector(didTapLogIn), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapSignUp() {
        print("Sign Up")
        let registrationVC = RegistrationViewController(viewModel: viewModel)
        navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    @objc private func didTapLogIn() {
        print("Log In")
        let loginVC = LoginViewController(viewModel: viewModel)
        navigationController?.pushViewController(loginVC, animated: true)
    }
}
