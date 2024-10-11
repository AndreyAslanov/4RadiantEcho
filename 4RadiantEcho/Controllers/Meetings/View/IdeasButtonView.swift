import UIKit

final class IdeasButtonView: UIControl {
    // MARK: - Properties

    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }

    private let buttonContainer = UIView()
    private let buttonImageView = UIImageView()

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
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        buttonImageView.image = UIImage(systemName: "scroll.fill", withConfiguration: configuration)
        buttonImageView.tintColor = .white
        
        buttonContainer.do { make in
            make.backgroundColor = UIColor(hex: "#225CEE")
            make.layer.cornerRadius = 12
            make.isUserInteractionEnabled = false
        }

        buttonContainer.addSubview(buttonImageView)
        addSubviews(buttonContainer)

        buttonImageView.snp.makeConstraints { make in
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
