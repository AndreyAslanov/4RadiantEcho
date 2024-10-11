import SnapKit
import UIKit

protocol AddParticipantViewDelegate: AnyObject {
    func didTapButton()
}

final class AddParticipantView: UIControl {
    weak var delegate: AddParticipantViewDelegate?

    private let addImageView = UIImageView()
    private let addStackview = UIStackView()
    private let buttonLabel = UILabel()
    
    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func drawSelf() {
        backgroundColor = .white.withAlphaComponent(0.05)
        layer.cornerRadius = 12
        isUserInteractionEnabled = true
        
        addImageView.image = R.image.meet_plus_icon()
        addImageView.isUserInteractionEnabled = false

        buttonLabel.do { make in
            make.text = L.addParticipant()
            make.font = .systemFont(ofSize: 17)
            make.textColor = .white
            make.textAlignment = .center
            make.isUserInteractionEnabled = false
        }
        
        addStackview.do { make in
            make.axis = .horizontal
            make.spacing = 4
            make.alignment = .center
            make.distribution = .fillProportionally
            make.isUserInteractionEnabled = false
        }

        addStackview.addArrangedSubviews([addImageView, buttonLabel])
        addSubviews(addStackview)
    }

    private func setupConstraints() {
        addStackview.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func configureAppearance() {
        alpha = isHighlighted ? 0.7 : 1
    }
    
    @objc private func didTapView() {
        delegate?.didTapButton()
    }
}
