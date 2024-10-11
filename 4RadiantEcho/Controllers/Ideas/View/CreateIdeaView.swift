import SnapKit
import UIKit

final class CreateIdeaView: UIControl {
    private let firstLabel = UILabel()
    private let imageView = UIImageView()

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
        backgroundColor = .white.withAlphaComponent(0.05)
        layer.cornerRadius = 24
        
        imageView.image = R.image.meet_icon()

        firstLabel.do { make in
            make.text = L.createIdea()
            make.font = .systemFont(ofSize: 16, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .left
            make.numberOfLines = 0
            make.isUserInteractionEnabled = false
        }
        
        addSubviews(imageView, firstLabel)
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(70)
        }
        
        firstLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
}
