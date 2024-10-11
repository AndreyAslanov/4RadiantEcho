import SnapKit
import UIKit

final class ProfileView: UIControl {
    enum SelfType {
        case name
        case age
        case sex

        var title: String {
            switch self {
            case .name: return L.text()
            case .age: return "0 years old"
            case .sex: return L.text()
            }
        }

        var image: UIImage? {
            switch self {
            case .name: return UIImage(systemName: "person.fill")
            case .age: return UIImage(systemName: "die.face.6.fill")
            case .sex: return UIImage(systemName: "leaf.fill")
            }
        }
    }

    private let titleLabel = UILabel()
    private let imageView = UIImageView()

    private let type: SelfType

    init(type: SelfType) {
        self.type = type
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = UIColor(hex: "#0E1529")
        layer.cornerRadius = 12
        clipsToBounds = true

        imageView.image = type.image
        imageView.tintColor = UIColor(hex: "#225CEE")

        titleLabel.do { make in
            make.text = type.title
            make.textColor = .white
            make.font = .systemFont(ofSize: 13, weight: .semibold)
            make.numberOfLines = 2
            make.isUserInteractionEnabled = false
        }

        addSubviews(imageView, titleLabel)

        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.centerY.equalToSuperview()
        }
    }

    func updateText(_ newText: String) {
        titleLabel.text = newText
        if type == .age {
            titleLabel.text = "\(newText) years old"
        } else {
            titleLabel.text = newText
        }
    }
}
