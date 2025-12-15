import UIKit
import SnapKit
import MapKit
import Combine

class ServicesViewController: UIViewController {
    private let viewModel = ServicesViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        return map
    }()
    
    private let sosButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SOS", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .heavy)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 40 
        button.layer.shadowColor = UIColor.red.cgColor
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 15
        button.layer.shadowOpacity = 0.7
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Ready to help"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        startBlinking()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "0A0A0A")
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(sosButton)
        sosButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.width.height.equalTo(80)
        }
        
        view.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        sosButton.addTarget(self, action: #selector(didTapSOS), for: .touchUpInside)
    }
    
    private func startBlinking() {
        UIView.animate(withDuration: 0.8, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
            self.sosButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.sosButton.alpha = 0.8
        }, completion: nil)
    }
    
    private func bindViewModel() {
        mapView.setRegion(viewModel.region, animated: false)
        
        viewModel.$requestStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.updateStatusUI(status)
            }
            .store(in: &cancellables)
            
        viewModel.$isRequesting
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRequesting in
                self?.sosButton.isEnabled = !isRequesting
                if isRequesting {
                    self?.sosButton.layer.removeAllAnimations()
                    self?.sosButton.transform = .identity
                    self?.sosButton.alpha = 0.6
                } else {
                    self?.startBlinking()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateStatusUI(_ status: ServicesViewModel.RequestStatus) {
        switch status {
        case .idle:
            statusLabel.text = "Ready to help"
            statusLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            sosButton.setTitle("SOS", for: .normal)
        case .searching:
            statusLabel.text = "Searching..."
            statusLabel.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.9)
        case .confirmed:
            statusLabel.text = "Help coming!"
            statusLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
            sosButton.setTitle("Done", for: .normal)
        case .arrived:
            statusLabel.text = "Mechanic Arrived"
        }
    }
    
    @objc private func didTapSOS() {
        if viewModel.requestStatus == .idle {
            viewModel.requestAssistance()
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
}
