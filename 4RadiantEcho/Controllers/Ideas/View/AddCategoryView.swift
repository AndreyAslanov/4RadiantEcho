import SnapKit
import UIKit

protocol AddCategoryViewDelegate: AnyObject {
    func didTapAddCategory()
}

final class AddCategoryView: UIControl {
    private let plusIconImageView = UIImageView()
    private let firstLabel = UILabel()
    private let stackView = UIStackView()
    
    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }
    
    weak var delegate: AddCategoryViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func drawSelf() {
        backgroundColor = .white.withAlphaComponent(0.05)
        layer.cornerRadius = 24
        
        plusIconImageView.do { make in
            let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
            make.image = UIImage(systemName: "plus", withConfiguration: configuration)
            make.tintColor = .white
            make.isUserInteractionEnabled = false
        }
        
        stackView.do { make in
            make.axis = .vertical
            make.spacing = 8
            make.alignment = .center
            make.distribution = .fillProportionally
            make.isUserInteractionEnabled = false
        }

        firstLabel.do { make in
            make.text = L.addCategory()
            make.font = .systemFont(ofSize: 15, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .center
            make.isUserInteractionEnabled = false
        }
        
        stackView.addArrangedSubviews([plusIconImageView, firstLabel])
        addSubviews(stackView)
    }

    private func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func configureAppearance() {
        alpha = isHighlighted ? 0.7 : 1
    }
    
    @objc private func handleTap() {
        delegate?.didTapAddCategory()
    }
}
