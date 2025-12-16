import UIKit
import SnapKit
import Combine

class MarketplaceViewController: UIViewController {

    // MARK: - Properties
    
    private let viewModel = MarketplaceViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    
    private let headerView = UIView()
    private let titleLabel = UILabel.make(text: "Marketplace", font: .boldSystemFont(ofSize: 28))
    
    private lazy var cartButton: UIButton = createIconButton(icon: "cart", action: #selector(didTapCart))
    private lazy var filterButton: UIButton = createIconButton(icon: "slider.horizontal.3", action: #selector(didTapFilter))
    
    private let searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "2A2A2A") 
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let searchIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = .gray
        return iv
    }()
    
    
    private lazy var searchTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(
            string: "Search motorcycles...",
            attributes: [.foregroundColor: UIColor.gray]
        )
        tf.addTarget(self, action: #selector(searchTermChanged), for: .editingChanged)
        return tf
    }()
    
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .clear
        cv.register(BikeCardCell.self, forCellWithReuseIdentifier: BikeCardCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindViewModel()
    }
    
    // MARK: - Layout Setup
    
    private func setupLayout() {
        view.backgroundColor = .darkBg
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupHeader()
        setupSearch()
        setupCollectionView()
    }
    
    private func setupHeader() {
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(cartButton)
        headerView.addSubview(filterButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
        }
        
        cartButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(44)
        }
        
        filterButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(cartButton.snp.leading).offset(-8)
            make.width.height.equalTo(44)
        }
    }
    
    private func setupSearch() {
        headerView.addSubview(searchContainer)
        searchContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(8)
        }
        
        searchContainer.addSubview(searchIcon)
        searchContainer.addSubview(searchTextField)
        
        searchIcon.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        searchTextField.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon.snp.trailing).offset(8)
            make.trailing.equalTo(-12)
            make.top.bottom.equalToSuperview()
        }
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - ViewModel Binding
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        let productsChange = viewModel.$products.map { _ in () }
        let filterChange = viewModel.$selectedFilter.map { _ in () }
        
        Publishers.Merge(productsChange, filterChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helpers
    
    private func createIconButton(icon: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        button.setImage(UIImage(systemName: icon, withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(240))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 16, trailing: 8)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(240))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 8, bottom: 24, trailing: 8)
            return section
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapCart() {
        let cartVC = CartViewController()
        if let sheet = cartVC.sheetPresentationController {
            sheet.detents = [.large()]
        }
        present(cartVC, animated: true)
    }
    
    @objc private func didTapFilter() {
        let filterVC = FilterViewController(viewModel: viewModel)
        if let sheet = filterVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(filterVC, animated: true)
    }
    
    @objc private func searchTermChanged() {
        viewModel.searchText = searchTextField.text ?? ""
        collectionView.reloadData()
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-140, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        toastLabel.textColor = UIColor.black
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

// MARK: - CollectionView DataSource & Delegate
extension MarketplaceViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BikeCardCell.reuseIdentifier, for: indexPath) as? BikeCardCell else {
            return UICollectionViewCell()
        }
        
        let product = viewModel.filteredProducts[indexPath.row]
        
        let bike = Bike(
            id: product.id,
            name: product.title,
            price: Int(product.priceValue),
            category: product.category,
            type: "sale",
            image_url: product.imageName
        )
        
        cell.configure(with: bike)
        
        cell.onBuyTap = { [weak self] in
            CartViewModel.shared.addToCart(bike.toProduct())
            let cartVC = CartViewController()
            if let sheet = cartVC.sheetPresentationController {
                sheet.detents = [.large()]
            }
            self?.present(cartVC, animated: true)
        }
        
        cell.onCartTap = { [weak self] in
            CartViewModel.shared.addToCart(bike.toProduct())
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
            self?.showToast(message: "Added to Basket: \(bike.name)")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = viewModel.filteredProducts[indexPath.row]
        
        let bike = Bike(
            id: product.id,
            name: product.title,
            price: Int(product.priceValue),
            category: product.category,
            type: "sale",
            image_url: product.imageName
        )
        
        let detailVC = BikeDetailViewController(bike: bike)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
    // MARK: - Public Methods

    /// Применяет фильтр по бренду и переключает на вкладку Motorcycles
    func applyBrandFilter(_ brand: String) {
        print("🔍 Применяем фильтр бренда: \(brand)")
        
        // Переключаемся на категорию Motorcycles
        viewModel.selectedFilter = "Motorcycles"
        
        // Очищаем все предыдущие фильтры
        viewModel.clearAllFilters()
        
        // Выбираем нужный бренд
        viewModel.selectedBrands.insert(brand)
        
        // Обновляем UI
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Перезагружаем коллекцию
            self.collectionView.reloadData()
            
            // Скроллим в начало списка
            if self.collectionView.numberOfItems(inSection: 0) > 0 {
                self.collectionView.scrollToItem(
                    at: IndexPath(item: 0, section: 0),
                    at: .top,
                    animated: true
                )
            }
            
            // Показываем уведомление
            self.showFilterAppliedToast(brand: brand)
        }
    }

    // MARK: - Toast Notification

    private func showFilterAppliedToast(brand: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor(hex: "00FF88").withAlphaComponent(0.95)
        toastLabel.textColor = .black
        toastLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        toastLabel.textAlignment = .center
        toastLabel.text = "🏍️ Filtered by \(brand)"
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        view.addSubview(toastLabel)
        toastLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.width.equalTo(220)
            make.height.equalTo(44)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        }
    }
}
