import SnapKit
import UIKit

protocol IdeaCellDelegate: AnyObject {
    func didTapEdit(with idea: IdeasModel)
    func didTapOpen(with idea: IdeasModel)
}

class IdeaCell: UICollectionViewCell {
    static let reuseIdentifier = "IdeaCell"
    weak var delegate: IdeaCellDelegate?
    var idea: IdeasModel?
    
    private let firstView = UIView()
    private let secondView = UIView()
    
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let countView = UIView()
    private let countLabel = UILabel()
    private let penImageView = UIImageView()
    
    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear
        layer.cornerRadius = 24
        penImageView.image = R.image.ideas_pen()
        
        firstView.do { make in
            make.backgroundColor = .white.withAlphaComponent(0.05)
            make.layer.cornerRadius = 24
            let tapGestureFirst = UITapGestureRecognizer(target: self, action: #selector(handleTapOpen))
            make.addGestureRecognizer(tapGestureFirst)
            make.isUserInteractionEnabled = true
        }
        
        secondView.do { make in
            make.backgroundColor = UIColor(hex: "#225CEE")
            make.layer.cornerRadius = 17
            let tapGestureSecond = UITapGestureRecognizer(target: self, action: #selector(handleTapEdit))
            make.addGestureRecognizer(tapGestureSecond)
            make.isUserInteractionEnabled = true
        }
        
        nameLabel.do { make in
            make.font = .systemFont(ofSize: 17, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .left
        }
        
        descriptionLabel.do { make in
            make.font = .systemFont(ofSize: 15)
            make.textColor = .white.withAlphaComponent(0.5)
            make.textAlignment = .left
            make.numberOfLines = 0
        }
        
        firstView.addSubviews(nameLabel, descriptionLabel)
        secondView.addSubviews(penImageView)
        contentView.addSubviews(
            firstView, secondView
        )
        
        secondView.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(34)
        }
        
        firstView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(secondView.snp.leading).offset(-8)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(16)
            make.height.equalTo(22)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.bottom.trailing.equalToSuperview().inset(16)
        }
        
        penImageView.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.width.equalTo(20)
            make.center.equalToSuperview()
        }
    }
    
    private func configureAppearance() {
        alpha = isHighlighted ? 0.7 : 1
    }

    @objc private func handleTapOpen() {
        guard let idea = idea else { return }
        delegate?.didTapOpen(with: idea)
    }    
    
    @objc private func handleTapEdit() {
        guard let idea = idea else { return }
        delegate?.didTapEdit(with: idea)
    }

    func configure(with idea: IdeasModel) {
        self.idea = idea
        nameLabel.text = idea.title
        descriptionLabel.text = idea.description
    }
}
