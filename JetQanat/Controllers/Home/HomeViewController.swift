//
//  HomeViewController.swift
//  JetQanat
//
//  Created by Zholdibay Abylay on 15.12.2025.
//

import UIKit
import SnapKit
import Combine

class HomeViewController: UIViewController {

    // MARK: - Properties
    
    private let viewModel = HomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private var collectionView: UICollectionView!
    
    private let heroItems: [(title: String, subtitle: String, image: String, color: String)] = [
        ("Kawasaki H2R", "The Supercharged Beast", "h2r", "00FF88"),
        ("Kawasaki ZX-10R", "WorldSBK Champion", "zx10", "00D4FF"),
        ("Ducati Panigale", "Italian Masterpiece", "penigale", "FF0044")
    ]
    
    private let brandItems: [(name: String, icon: String)] = [
        ("Yamaha", "y.circle.fill"),
        ("Honda", "h.circle.fill"),
        ("Kawasaki", "k.circle.fill"),
        ("Suzuki", "s.circle.fill"),
        ("BMW", "b.circle.fill"),
        ("Ducati", "d.circle.fill"),
        ("Harley", "h.circle.fill"),
        ("More", "ellipsis.circle.fill")
    ]
    
    private let filterBrands = ["All", "Yamaha", "Honda", "Kawasaki", "Suzuki"]
    private var selectedBrandIndex = 0
    
    // MARK: - Lifecycle
    
    // MARK: - Lifecycle
    
    private let wishlistViewModel = WishlistViewModel.shared
    private let userViewModel = UserViewModel.shared
    
    private let headerView = HomeHeaderView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        bindViewModel()
        bindUser()
        
        userViewModel.loadUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userViewModel.loadUser()
    }
    
    private func bindUser() {
        userViewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.headerView.configure(user: user)
            }
            .store(in: &cancellables)
    }


    // ... (rest of setupUI/setupCollectionView unchanged)
    
    // Inside cellForItemAt for BikeCardCell:
    /*
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BikeCardCell.reuseIdentifier, for: indexPath) as! BikeCardCell
            let bike = viewModel.bikes[indexPath.row]
            let isFavorite = wishlistViewModel.isInWishlist(bikeId: bike.id)
            
            cell.configure(with: bike, isFavorite: isFavorite)
            
            cell.onWishlistTap = { [weak self] in
                self?.wishlistViewModel.toggleWishlist(bikeId: bike.id)
            }
            return cell
    */
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "0A0A0A") // Theme.Colors.background
        
        // Navigation / Header setup would go here if not using standard NavBar
        // Hiding NavBar to match custom header design from SwiftUI
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Custom Header (Profile, notifications etc)
        // For brevity, skipping the full custom header implementation to focus on the main scrollable content
        // In a real app, I'd add a HeaderView above the CollectionView or as a supplementary view of the first section
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        headerView.onAvatarTap = { [weak self] in
            // Navigate to profile or menu
            self?.tabBarController?.selectedIndex = 3 // Switch to Profile tab
        }
        
        headerView.onNotificationTap = { [weak self] in
            let notificationsVC = NotificationsViewController()
            self?.navigationController?.pushViewController(notificationsVC, animated: true)
        }
        
        
    }
    
    private func setupCollectionView() {
        let layout = createCompositionalLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        

        collectionView.register(HeroBannerCell.self, forCellWithReuseIdentifier: HeroBannerCell.reuseIdentifier)
        collectionView.register(BrandCell.self, forCellWithReuseIdentifier: BrandCell.reuseIdentifier)
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: FilterCell.reuseIdentifier)
        collectionView.register(BikeCardCell.self, forCellWithReuseIdentifier: BikeCardCell.reuseIdentifier)
        
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        viewModel.$bikes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Layout
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            switch sectionIndex {
            case 0: // Hero
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(240))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.interGroupSpacing = 16
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 24, trailing: 0)
                
                // Header (Example "Featured")
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
                
            case 1: // Brands (2 rows grid)
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .absolute(90))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(90))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 24, trailing: 16)
                
                return section
                
            case 2: // Filters
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(80), heightDimension: .absolute(40))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(500), heightDimension: .absolute(40))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
                
                // Header "Top Deals"
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
                
            case 3: // Bike Grid
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(240)) // estimated height
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 16, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(240))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item]) // 2 items per row
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 24, trailing: 8)
                
                return section
                
            default:
                return nil
            }
        }
    }
}

// MARK: - DataSource & Delegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4 // Hero, Brands, Filters, Grid
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return heroItems.count
        case 1: return brandItems.count
        case 2: return filterBrands.count
        case 3: return viewModel.bikes.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeroBannerCell.reuseIdentifier, for: indexPath) as! HeroBannerCell
            let item = heroItems[indexPath.row]
            cell.configure(title: item.title, subtitle: item.subtitle, imageName: item.image, accentColor: UIColor(hex: item.color))
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrandCell.reuseIdentifier, for: indexPath) as! BrandCell
            let item = brandItems[indexPath.row]
            cell.configure(name: item.name, iconName: item.icon)
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.reuseIdentifier, for: indexPath) as! FilterCell
            let item = filterBrands[indexPath.row]
            cell.configure(title: item, isSelected: indexPath.row == selectedBrandIndex)
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BikeCardCell.reuseIdentifier, for: indexPath) as! BikeCardCell
            let bike = viewModel.bikes[indexPath.row]
            
            // Updated configuration without isFavorite
            cell.configure(with: bike)
            
            cell.onBuyTap = { [weak self] in
                print("Buy tapped for \(bike.name)")
                CartViewModel.shared.addToCart(bike.toProduct())
                
                let cartVC = CartViewController()
                if let sheet = cartVC.sheetPresentationController {
                    sheet.detents = [.large()]
                }
                self?.present(cartVC, animated: true)
            }
            
            cell.onCartTap = { [weak self] in
                print("Cart tapped for \(bike.name)")
                CartViewModel.shared.addToCart(bike.toProduct())
                let feedback = UINotificationFeedbackGenerator()
                feedback.notificationOccurred(.success)
                self?.showToast(message: "Added to Basket: \(bike.name)")
            }
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as! SectionHeaderView
        
        switch indexPath.section {
        case 0:
            header.configure(title: "Featured")
        case 2:
            header.configure(title: "Top Deals")
        default:
            header.configure(title: "")
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // Hero
            // Future logic: Navigate to featured promo detail
            print("Hero selected: \(heroItems[indexPath.row].title)")
            
        case 2: // Filters
            selectedBrandIndex = indexPath.row
            collectionView.reloadSections(IndexSet(integer: 2))
            // Trigger filtering in ViewModel if implemented
            print("Filter selected: \(filterBrands[indexPath.row])")
            
        case 3:
            let bike = viewModel.bikes[indexPath.row]
            print("Selected bike details: \(bike.name)")
            // Navigation logic handles detail view
            let detailVC = BikeDetailViewController(bike: bike)
            detailVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(detailVC, animated: true)
            
        default:
            break
        }
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
