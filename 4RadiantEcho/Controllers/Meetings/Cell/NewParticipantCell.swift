import SnapKit
import UIKit

protocol NewParticipantCellDelegate: AnyObject {
    func didTapEditParticipant(with participant: ParticipantModel)
    func didTapDeleteParticipant(with participant: ParticipantModel)
    func didTapImageView(with participant: ParticipantModel)
}

class NewParticipantCell: UICollectionViewCell {
    static let reuseIdentifier = "NewParticipantCell"
    weak var delegate: NewParticipantCellDelegate?
    var participant: ParticipantModel?
    
    private let nameView = UIView()
    private let imageView = UIImageView()
    private let editButton = UIButton()
    private let deleteButton = UIButton()
    
    private let nameLabel = UILabel()
    private let editImageView = UIImageView()
    private let deleteImageView = UIImageView()

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
            let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
            make.addGestureRecognizer(tapImageGesture)
        }
        
        nameLabel.do { make in
            make.font = .systemFont(ofSize: 17)
            make.textColor = .white
            make.textAlignment = .left
        }
        
        editImageView.image = R.image.profile_black_edit()?.withRenderingMode(.alwaysTemplate)
        editImageView.tintColor = UIColor(hex: "#225CEE")
        editImageView.isUserInteractionEnabled = true
        let tapEditGesture = UITapGestureRecognizer(target: self, action: #selector(didTapEditButton))
        editImageView.addGestureRecognizer(tapEditGesture)
        
        deleteImageView.image = R.image.profile_black_delete()?.withRenderingMode(.alwaysTemplate)
        deleteImageView.tintColor = UIColor(hex: "#225CEE")
        deleteImageView.isUserInteractionEnabled = true
        let tapDeleteGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDeleteButton))
        deleteImageView.addGestureRecognizer(tapDeleteGesture)

        nameView.addSubview(nameLabel)
        contentView.addSubviews(nameView, imageView, deleteImageView, editImageView)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(54)
        }
        
        nameView.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(editImageView.snp.leading).offset(-12)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        
        editImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(deleteImageView.snp.leading).offset(-6)
            make.size.equalTo(32)
        }
        
        deleteImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.size.equalTo(32)
        }
    }

    @objc private func didTapEditButton() {
        guard let participant = participant else { return }
        delegate?.didTapEditParticipant(with: participant)
    }
    
    @objc private func didTapDeleteButton() {
        guard let participant = participant else { return }
        delegate?.didTapDeleteParticipant(with: participant)
    }
    
    @objc private func didTapImageView() {
        guard let participant = participant else { return }
        delegate?.didTapImageView(with: participant)
    }

    func configure(with model: ParticipantModel) {
        participant = model
        nameLabel.text = model.name
        
        if let imagePath = model.participantImagePath, let uuid = UUID(uuidString: imagePath) {
            loadImage(for: uuid) { [weak self] image in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                    if image == nil {
                        print("Can't load image for UUID: \(imagePath)")
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
