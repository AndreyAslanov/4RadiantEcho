import UIKit

final class OnboardingButton: UIControl {
    // MARK: - Properties

    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }

    private var didAddGradient = false
    private let titleLabel = UILabel()
    let buttonContainer = UIView()

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
        buttonContainer.do { make in
            make.backgroundColor = UIColor(hex: "#225CEE")
            make.layer.cornerRadius = 12
            make.isUserInteractionEnabled = false
        }

        titleLabel.do { make in
            make.text = L.next()
            make.textColor = .white
            make.font = .systemFont(ofSize: 17, weight: .semibold)
            make.isUserInteractionEnabled = false
        }

        buttonContainer.addSubview(titleLabel)
        addSubviews(buttonContainer)

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        buttonContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureAppearance() {
        alpha = isHighlighted ? 0.7 : 1
    }

    func setTitle(to title: String) {
        titleLabel.text = title
    }

    func setBackgroundColor(_ color: UIColor) {
        buttonContainer.backgroundColor = color
    }

    func setTextColor(_ color: UIColor) {
        titleLabel.textColor = color
    }

    func cancelMode() {
        buttonContainer.backgroundColor = .white
        buttonContainer.layer.cornerRadius = 18
        buttonContainer.layer.borderColor = UIColor(hex: "#FFCC48").cgColor
        buttonContainer.layer.borderWidth = 2

        titleLabel.text = L.cancel()
        titleLabel.textColor = UIColor(hex: "#FFCC48")
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
    }
}
