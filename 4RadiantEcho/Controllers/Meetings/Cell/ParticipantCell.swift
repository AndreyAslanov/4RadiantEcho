import SnapKit
import UIKit

class ParticipantCell: UICollectionViewCell {
    static let reuseIdentifier = "ParticipantCell"
    var participant: ParticipantModel?
    
    private let nameView = UIView()
    private let imageView = UIImageView()
    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear
        
        nameView.do { make in
            make.backgroundColor = .white.withAlphaComponent(0.05)
            make.layer.cornerRadius = 12
        }
        
        imageView.do { make in
            make.image = R.image.meet_placeholder()
            make.contentMode = .scaleAspectFill
            make.isUserInteractionEnabled = true
            make.layer.cornerRadius = 27
            make.masksToBounds = true
        }
        
        nameLabel.do { make in
            make.font = .systemFont(ofSize: 17)
            make.textColor = .white
            make.textAlignment = .left
        }

        nameView.addSubview(nameLabel)
        contentView.addSubviews(nameView, imageView)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(54)
        }
        
        nameView.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
    }

    func configure(with model: ParticipantModel) {
        participant = model
        nameLabel.text = model.name
        
        if let imagePath = model.participantImagePath, let uuid = UUID(uuidString: imagePath) {
            loadImage(for: uuid) { [weak self] image in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                    if image == nil {
                        print("Не удалось загрузить изображение для UUID: \(imagePath)")
                    }
                }
            }
        } else {
            imageView.image = R.image.meet_placeholder()
        }
    }
    
    private func loadImage(for id: UUID, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let image = MeetingDataManager.shared.loadImage(withId: id)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
