import UIKit
import SnapKit

class RentalDetailViewController: UIViewController {

    // MARK: - Properties
    private let rental: RentalBike
    private var bookingStart: Date?
    private var bookingEnd: Date?

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()
    
    private let contentView = UIView()


    private let heroImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .darkGray
        return iv
    }()
    
   private let topGradient: UIView = {
        let view = UIView()
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0.6).cgColor, UIColor.clear.cgColor]
        view.layer.addSublayer(gradient)
        return view
    }()

    private lazy var backButton: UIButton = {
        let btn = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.left", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        blur.layer.cornerRadius = 22
        blur.clipsToBounds = true
        blur.isUserInteractionEnabled = false 
        
        btn.insertSubview(blur, at: 0)
        btn.layer.cornerRadius = 22
        return btn
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let priceContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "F4B400").withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .heavy)
        label.textColor = UIColor(hex: "F4B400")
        return label
    }()

    private let specsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 15
        return stack
    }()

    private lazy var dateSelectionView: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor(white: 1, alpha: 0.05)
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
        return btn
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Dates"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let calendarIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "calendar"))
        iv.tintColor = UIColor(hex: "F4B400")
        iv.isUserInteractionEnabled = false // Pass touches to button
        return iv
    }()

    // 6. ОПИСАНИЕ
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Unleash your inner rider with this premium machine. Perfect for weekend getaways or city cruising. Includes helmet and insurance."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.setLineHeight(lineHeight: 1.5) // Чуть раздвигаем строки
        return label
    }()

    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "0A0A0A") 
        
        let line = UIView()
        line.backgroundColor = UIColor(white: 1, alpha: 0.1)
        view.addSubview(line)
        line.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        return view
    }()

    private let rentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Rent Now", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.backgroundColor = UIColor(hex: "F4B400")
        btn.layer.cornerRadius = 14
        
        btn.layer.shadowColor = UIColor(hex: "F4B400").cgColor
        btn.layer.shadowOpacity = 0.4
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 10
        return btn
    }()

    // MARK: - Lifecycle

    init(rental: RentalBike) {
        self.rental = rental
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureData()
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        rentButton.addTarget(self, action: #selector(didTapRent), for: .touchUpInside)
        
        dateSelectionView.addTarget(self, action: #selector(openCalendar), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topGradient.layer.sublayers?.first?.frame = topGradient.bounds
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "0A0A0A")
        
        view.addSubview(scrollView)
        view.addSubview(bottomContainer)
        view.addSubview(backButton) 
        view.addSubview(topGradient)
        
        scrollView.addSubview(contentView)
        bottomContainer.addSubview(rentButton)
        
        view.bringSubviewToFront(topGradient)
        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(bottomContainer)
        
        // --- Constraints ---
        
        bottomContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        
        rentButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(54)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomContainer.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        topGradient.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(0)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        
        contentView.addSubview(heroImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceContainer)
        priceContainer.addSubview(priceLabel)
        contentView.addSubview(specsStack)
        contentView.addSubview(dateSelectionView)
        contentView.addSubview(descriptionLabel)
        
        dateSelectionView.addSubview(dateLabel)
        dateSelectionView.addSubview(calendarIcon)
        
        heroImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(320) // Большое фото
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(heroImageView.snp.bottom).offset(24)
            make.leading.equalToSuperview().inset(20)
            make.trailing.lessThanOrEqualTo(priceContainer.snp.leading).offset(-10)
        }
        
        priceContainer.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        specsStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(70)
        }
        
        dateSelectionView.snp.makeConstraints { make in
            make.top.equalTo(specsStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        calendarIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(calendarIcon.snp.trailing).offset(12)
        }
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .gray
        chevron.isUserInteractionEnabled = false
        dateSelectionView.addSubview(chevron)
        chevron.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(14)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(dateSelectionView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40) 
        }
    }

    // MARK: - Configuration

    private func configureData() {
        titleLabel.text = rental.model
        priceLabel.text = "$\(Int(rental.pricePerPeriod))/day"
        
        if let image = UIImage(named: rental.imageName) {
            heroImageView.image = image
        }
        
        configureSpecs()
    }
    
    private func configureSpecs() {
        let spec1 = createSpecView(icon: "speedometer", title: "Max Speed", value: "299 km/h")
        let spec2 = createSpecView(icon: "timer", title: "0-100", value: "2.9s")
        let spec3 = createSpecView(icon: "fuelpump.fill", title: "Tank", value: "17L")
        
        specsStack.addArrangedSubview(spec1)
        specsStack.addArrangedSubview(spec2)
        specsStack.addArrangedSubview(spec3)
    }
    
    private func createSpecView(icon: String, title: String, value: String) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.05)
        view.layer.cornerRadius = 12
        
        let iconIV = UIImageView(image: UIImage(systemName: icon))
        iconIV.tintColor = .gray
        iconIV.contentMode = .scaleAspectFit
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 10, weight: .medium)
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .center
        
        view.addSubview(iconIV)
        view.addSubview(valueLabel)
        view.addSubview(titleLabel)
        
        iconIV.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview().inset(4)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)
            make.leading.trailing.equalToSuperview().inset(4)
        }
        
        return view
    }

    // MARK: - Actions

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapRent() {
        if bookingStart != nil && bookingEnd != nil {
            print("Rent initiated for dates")
            
            let paymentVC = PaymentSelectionViewController()
            paymentVC.modalPresentationStyle = .overFullScreen
            paymentVC.modalTransitionStyle = .crossDissolve
            
            paymentVC.onMethodSelected = { [weak self] method in
                if method == "Card" {
                    let cardsVC = PaymentMethodsViewController()
                    if let sheet = cardsVC.sheetPresentationController {
                        sheet.detents = [.medium(), .large()]
                    }
                    self?.present(cardsVC, animated: true)
                } else {
                    self?.showBookingSuccess(method: method)
                }
            }
            present(paymentVC, animated: true)
            
        } else {
            openCalendar()
        }
    }
    
    private func showBookingSuccess(method: String) {
        let alert = UIAlertController(title: "Booking Confirmed", message: "Paid via \(method). Your ride is reserved!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Awesome", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func openCalendar() {
        let calendarVC = BookingCalendarViewController()
        calendarVC.delegate = self
        if let sheet = calendarVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(calendarVC, animated: true)
    }
    
    // MARK: - Updates
    
    private func updateBookingInfo() {
        guard let start = bookingStart, let end = bookingEnd else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        dateLabel.text = "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        dateLabel.textColor = .white
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        let dayCount = max(1, components.day ?? 1)
        
        let totalPrice = Double(dayCount) * rental.pricePerPeriod
        priceLabel.text = "$\(Int(totalPrice)) Total"
        rentButton.setTitle("Book for $\(Int(totalPrice))", for: .normal)
    }
}

// MARK: - BookingCalendarDelegate
extension RentalDetailViewController: BookingCalendarDelegate {
    func didSelectDateRange(start: Date, end: Date) {
        self.bookingStart = start
        self.bookingEnd = end
        updateBookingInfo()
    }
}
