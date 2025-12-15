import UIKit
import SnapKit
import Combine

class RentalsViewController: UIViewController {
    
    private let viewModel = RentalsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rent a Bike"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        return label
    }()
    

    private let searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1C1C1E")
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let searchIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = .gray
        return iv
    }()
    
    private let searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Find your ride..."
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(
            string: "Find your ride...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        return tf
    }()
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "0A0A0A")
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        
        
        view.addSubview(searchContainer)
        searchContainer.addSubview(searchIcon)
        searchContainer.addSubview(searchTextField)
        
        searchContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        searchIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        searchTextField.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        
        let layout = UICollectionViewFlowLayout()
        let width = view.frame.width
        layout.itemSize = CGSize(width: (width - 48) / 2, height: 240)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 20, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(BikeCardCell.self, forCellWithReuseIdentifier: BikeCardCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchContainer.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        viewModel.$rentals
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension RentalsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.rentals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BikeCardCell.reuseIdentifier, for: indexPath) as! BikeCardCell
        let rental = viewModel.rentals[indexPath.row]
        cell.configure(with: rental)

        cell.onBookTap = { [weak self] in
            let calendarVC = BookingCalendarViewController()
            calendarVC.delegate = self
            if let sheet = calendarVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
            }
            self?.present(calendarVC, animated: true)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rental = viewModel.rentals[indexPath.row]
        let detailVC = RentalDetailViewController(rental: rental)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Booking Logic
extension RentalsViewController: BookingCalendarDelegate {
    func didSelectDateRange(start: Date, end: Date) {

        let paymentVC = PaymentSelectionViewController()
        paymentVC.modalPresentationStyle = .overFullScreen
        paymentVC.modalTransitionStyle = .crossDissolve
        
        paymentVC.onMethodSelected = { [weak self] method in
            self?.showBookingSuccess(method: method)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.present(paymentVC, animated: true)
        }
    }
    
    private func showBookingSuccess(method: String) {
        let alert = UIAlertController(title: "Booking Confirmed", message: "Paid via \(method). Your ride is reserved!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Awesome", style: .default))
        present(alert, animated: true)
    }
}
