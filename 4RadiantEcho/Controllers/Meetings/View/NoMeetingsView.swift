import SnapKit
import UIKit

final class NoMeetingsView: UIControl {
    
    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
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
            make.text = L.empty()
            make.font = .systemFont(ofSize: 28, weight: .bold)
            make.textColor = .white
            make.textAlignment = .center
            make.numberOfLines = 0
            make.isUserInteractionEnabled = false
        }        
        
        secondLabel.do { make in
            make.text = L.noEntries()
            make.font = .systemFont(ofSize: 13)
            make.textColor = .white.withAlphaComponent(0.7)
            make.textAlignment = .center
            make.numberOfLines = 0
            make.isUserInteractionEnabled = false
        }
        
        addSubviews(imageView, firstLabel, secondLabel)
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(70)
        }
        
        firstLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        secondLabel.snp.makeConstraints { make in
            make.top.equalTo(firstLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
    }
}
