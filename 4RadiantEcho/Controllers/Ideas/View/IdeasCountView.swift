import SnapKit
import UIKit

final class IdeasCountView: UIControl {
    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
    private let stackView = UIStackView()

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
        
        stackView.do { make in
            make.axis = .vertical
            make.spacing = 0
            make.alignment = .center
            make.distribution = .fillProportionally
        }

        firstLabel.do { make in
            make.text = "0"
            make.font = .systemFont(ofSize: 28, weight: .bold)
            make.textColor = .white
            make.textAlignment = .center
            make.isUserInteractionEnabled = false
        }        
        
        secondLabel.do { make in
            make.text = L.ideasCountLabel()
            make.font = .systemFont(ofSize: 13, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .center
            make.numberOfLines = 0
            make.isUserInteractionEnabled = false
        }
        
        stackView.addArrangedSubviews([firstLabel, secondLabel])
        addSubviews(stackView)
    }

    private func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    func updateFirstLabel(with count: Int) {
        firstLabel.text = "\(count)"  
    }
}
