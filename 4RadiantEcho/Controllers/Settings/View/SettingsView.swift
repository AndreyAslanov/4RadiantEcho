import SnapKit
import UIKit

protocol SettingsViewDelegate: AnyObject {
    func didTapView(type: SettingsView.SelfType)
}

final class SettingsView: UIControl {
    enum SelfType {
        case shareApp
        case usagePolicy
        case rateApp

        var title: String {
            switch self {
            case .shareApp: return L.shareApp()
            case .usagePolicy: return L.usagePolicy()
            case .rateApp: return L.rateApp()
            }
        }

        var image: UIImage? {
            switch self {
            case .shareApp: return UIImage(systemName: "heart.fill")
            case .rateApp: return UIImage(systemName: "star.fill")
            case .usagePolicy: return UIImage(systemName: "leaf.fill")
            }
        }
    }

    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let stackView = UIStackView()

    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }

    private let type: SelfType
    weak var delegate: SettingsViewDelegate?

    init(type: SelfType) {
        self.type = type
        super.init(frame: .zero)
        setupView()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white.withAlphaComponent(0.05)
        layer.cornerRadius = 12
        clipsToBounds = true

        imageView.image = type.image

        titleLabel.do { make in
            make.text = type.title
            make.textColor = .white
            make.font = .systemFont(ofSize: 16, weight: .semibold)
            make.numberOfLines = 2
            make.textAlignment = .center
            make.isUserInteractionEnabled = false
        }

        stackView.do { make in
            make.axis = .vertical
            make.spacing = 8
            make.alignment = .center
            make.distribution = .fillProportionally
        }

        stackView.addArrangedSubviews([imageView, titleLabel])
        addSubviews(stackView)

        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.width.equalTo(65)
            make.centerX.equalToSuperview()
        }
    }

    private func configureAppearance() {
        alpha = isHighlighted ? 0.5 : 1
    }

    @objc private func didTapView() {
        delegate?.didTapView(type: type)
    }
}
