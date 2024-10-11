import SnapKit
import UIKit

final class CategoryPlaceView: UIControl {
    private let firstLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func drawSelf() {
        backgroundColor = UIColor(hex: "#0E1529")
        layer.cornerRadius = 24

        firstLabel.do { make in
            make.text = L.placeCategory()
            make.font = .systemFont(ofSize: 15, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .center
            make.numberOfLines = 0
            make.isUserInteractionEnabled = false
        }

        addSubviews(firstLabel)
    }

    private func setupConstraints() {
        firstLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
