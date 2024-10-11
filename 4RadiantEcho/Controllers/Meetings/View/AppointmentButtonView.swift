import UIKit

final class AppointmentButtonView: UIControl {
    // MARK: - Properties

    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }

    private let buttonContainer = UIView()
    private let buttonImageView = UIImageView()
    private let buttonLabel = UILabel()
    private let buttonStackView = UIStackView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func drawSelf() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        buttonImageView.image = UIImage(systemName: "plus", withConfiguration: configuration)
        buttonImageView.tintColor = .white
        
        buttonLabel.do { make in
            make.text = L.addAppointment()
            make.font = .systemFont(ofSize: 17)
            make.textColor = .white
            make.isUserInteractionEnabled = false
        }
        
        buttonStackView.do { make in
            make.axis = .horizontal
            make.spacing = 4
            make.alignment = .center
            make.distribution = .fillProportionally
            make.isUserInteractionEnabled = true
        }
        
        buttonContainer.do { make in
            make.backgroundColor = UIColor(hex: "#225CEE")
            make.layer.cornerRadius = 12
            make.isUserInteractionEnabled = false
        }

        buttonStackView.addArrangedSubviews([buttonImageView, buttonLabel])
        buttonContainer.addSubview(buttonStackView)
        addSubviews(buttonContainer)

        buttonStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        buttonContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureAppearance() {
        alpha = isHighlighted ? 0.7 : 1
    }
}
