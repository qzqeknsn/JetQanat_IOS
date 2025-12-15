import UIKit
import SnapKit

protocol BookingCalendarDelegate: AnyObject {
    func didSelectDateRange(start: Date, end: Date)
}

class BookingCalendarViewController: UIViewController {
    
    weak var delegate: BookingCalendarDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Dates"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let calendarView: UICalendarView = {
        let view = UICalendarView()
        view.calendar = Calendar(identifier: .gregorian)
        view.locale = .current
        view.fontDesign = .rounded
        view.tintColor = UIColor(hex: "F4B400")
        view.backgroundColor = .clear
        return view
    }()
    
    private let confirmButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Confirm Dates", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = UIColor(hex: "F4B400")
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return btn
    }()
    
    private var selectionBehavior: UICalendarSelectionMultiDate?
    private var selectedDates: [DateComponents] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "1C1C1E")
        setupUI()
        setupCalendar()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(calendarView)
        view.addSubview(confirmButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(350)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
            make.bottom.lessThanOrEqualToSuperview().inset(34)
        }
        
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }
    
    private func setupCalendar() {
        let selection = UICalendarSelectionMultiDate(delegate: self)
        calendarView.selectionBehavior = selection
        self.selectionBehavior = selection
        
        // Disable past dates
        calendarView.availableDateRange = DateInterval(start: Date(), end: Date().addingTimeInterval(86400 * 365))
    }
    
    @objc private func didTapConfirm() {
        guard selectedDates.count >= 2 else { return }
        
        let sortedDates = selectedDates.compactMap { Calendar.current.date(from: $0) }.sorted()
        if let start = sortedDates.first, let end = sortedDates.last {
            delegate?.didSelectDateRange(start: start, end: end)
            dismiss(animated: true)
        }
    }
}

extension BookingCalendarViewController: UICalendarSelectionMultiDateDelegate {
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
        selectedDates.append(dateComponents)
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
        selectedDates.removeAll { $0 == dateComponents }
    }
}
