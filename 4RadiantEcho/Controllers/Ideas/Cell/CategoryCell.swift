import SnapKit
import UIKit

protocol CategoryCellDelegate: AnyObject {
    func didTapButton(with category: CategoryModel)
}

class CategoryCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryCell"
    weak var delegate: CategoryCellDelegate?
    var category: CategoryModel?
    
    private let countView = UIView()
    private let countLabel = UILabel()
    private let nameLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = UIColor(hex: "#0E1529")
        layer.cornerRadius = 24
        arrowImageView.image = R.image.meet_arrow()
        
        countView.do { make in
            make.backgroundColor = UIColor(hex: "#225CEE")
            make.layer.cornerRadius = 13
        }
        
        countLabel.do { make in
            make.text = "0"
            make.textColor = .white
            make.font = .systemFont(ofSize: 13, weight: .semibold)
            make.textAlignment = .center
        }
        
        nameLabel.do { make in
            make.font = .systemFont(ofSize: 17, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .left
            make.numberOfLines = 0
        }
        
        countView.addSubviews(countLabel)
        contentView.addSubviews(
            countView, nameLabel, arrowImageView
        )
        
        countView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(16)
            make.height.equalTo(26)
            make.width.equalTo(39)
        }
        
        countLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(countView.snp.centerY)
        }
    }
    
    private func configureAppearance() {
        alpha = isHighlighted ? 0.7 : 1
    }
    
    private func updateCountLabel() {
        if let ideasCount = category?.ideas?.count {
            countLabel.text = "\(ideasCount)"
        } else {
            countLabel.text = "0"
        }
    }

    @objc private func handleTap() {
        guard let category = category else { return }
        delegate?.didTapButton(with: category)
    }

    func configure(with category: CategoryModel) {
        self.category = category
        nameLabel.text = category.name
        updateCountLabel()
    }
}
