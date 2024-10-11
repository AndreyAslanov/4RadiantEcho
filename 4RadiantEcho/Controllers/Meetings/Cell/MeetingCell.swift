import SnapKit
import UIKit

protocol MeetingCellDelegate: AnyObject {
    func didTapMeetingCell(with meeting: MeetingModel)
}

class MeetingCell: UICollectionViewCell {
    static let reuseIdentifier = "MeetingCell"
    var meetings: MeetingModel?
    
    private let upperView = UIView()
    private let titleLabel = UILabel()
    private let locationLabel = UILabel()
    
    private let calendarImageView = UIImageView()
    private let clockImageView = UIImageView()
    private let dateLabel = UILabel()
    private let timeLabel = UILabel()
    
    private let arrowImageView = UIImageView()
    private let descriptionLabel = UILabel()
    
    private let firstImageView = UIImageView()
    private let secondImageView = UIImageView()
    private let thirdImageView = UIImageView()
    
    weak var delegate: MeetingCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        addGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .white.withAlphaComponent(0.05)
        layer.cornerRadius = 24
        arrowImageView.image = R.image.meet_arrow()
        
        upperView.do { make in
            make.backgroundColor = .white.withAlphaComponent(0.05)
            make.layer.cornerRadius = 16
        }
        
        titleLabel.do { make in
            make.font = .systemFont(ofSize: 17, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .left
        }        
        
        locationLabel.do { make in
            make.font = .systemFont(ofSize: 13)
            make.textColor = .white.withAlphaComponent(0.5)
            make.textAlignment = .left
            make.numberOfLines = 2
        }
        
        calendarImageView.do { make in
            let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
            make.image = UIImage(systemName: "calendar", withConfiguration: configuration)
            make.tintColor = UIColor(hex: "#225CEE")
        }        
        
        clockImageView.do { make in
            let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
            make.image = UIImage(systemName: "clock", withConfiguration: configuration)
            make.tintColor = UIColor(hex: "#225CEE")
        }
        
        [dateLabel, timeLabel].forEach { label in
            label.do { make in
                make.font = .systemFont(ofSize: 13)
                make.textColor = .white.withAlphaComponent(0.7)
                make.textAlignment = .left
            }
        }       
        
        [firstImageView, secondImageView, thirdImageView].forEach { imageView in
            imageView.do { make in
                make.contentMode = .scaleAspectFill
                make.isUserInteractionEnabled = true
                make.layer.cornerRadius = 16
                make.masksToBounds = true
            }
        }
        
        descriptionLabel.do { make in
            make.font = .systemFont(ofSize: 15)
            make.textColor = .white.withAlphaComponent(0.7)
            make.textAlignment = .left
            make.numberOfLines = 4
        }

        upperView.addSubviews(
            titleLabel, locationLabel, arrowImageView,
            calendarImageView, clockImageView, dateLabel,
            timeLabel, firstImageView, secondImageView, thirdImageView
        )
        
        contentView.addSubviews(upperView, descriptionLabel)
        
        upperView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(16)
            make.height.equalTo(154)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-16)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel)
        }
        
        calendarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().inset(12)
            make.size.equalTo(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(calendarImageView.snp.centerY)
            make.leading.equalTo(calendarImageView.snp.trailing).offset(4)
            make.width.equalTo(50)
        }
        
        clockImageView.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel.snp.centerY)
            make.leading.equalTo(dateLabel.snp.trailing).offset(8)
            make.size.equalTo(20)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(clockImageView.snp.centerY)
            make.leading.equalTo(clockImageView.snp.trailing).offset(4)
            make.trailing.equalTo(arrowImageView.snp.leading).inset(16)
        }
        
        firstImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(calendarImageView.snp.top).offset(-8)
            make.size.equalTo(32)
        }
        
        secondImageView.snp.makeConstraints { make in
            make.leading.equalTo(firstImageView.snp.leading).offset(20)
            make.centerY.equalTo(firstImageView.snp.centerY)
            make.size.equalTo(32)
        }
        
        thirdImageView.snp.makeConstraints { make in
            make.leading.equalTo(secondImageView.snp.leading).offset(20)
            make.centerY.equalTo(secondImageView.snp.centerY)
            make.size.equalTo(32)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(upperView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(16)
        }
    }
    
    private func addGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(upperViewTapped))
        upperView.addGestureRecognizer(tapGesture)
        upperView.isUserInteractionEnabled = true
    }
    
    @objc private func upperViewTapped() {
        guard let meeting = meetings else { return }
        delegate?.didTapMeetingCell(with: meeting)
    }

    func configure(with meeting: MeetingModel) {
        meetings = meeting
        
        titleLabel.text = meeting.title
        locationLabel.text = meeting.location
        dateLabel.text = meeting.date
        timeLabel.text = "\(meeting.beginning) - \(meeting.ending)"
        descriptionLabel.text = meeting.description
        
        guard let participants = meeting.participants else {
            firstImageView.isHidden = true
            secondImageView.isHidden = true
            thirdImageView.isHidden = true
            return
        }
        
        let participantCount = participants.count

        firstImageView.isHidden = participantCount == 0
        secondImageView.isHidden = participantCount < 2
        thirdImageView.isHidden = participantCount < 3
        
        if participantCount > 0 {
            setImage(for: firstImageView, participant: participants[0])
        }
        if participantCount > 1 {
            setImage(for: secondImageView, participant: participants[1])
        }
        if participantCount > 2 {
            setImage(for: thirdImageView, participant: participants[2])
        }
    }
    
    private func setImage(for imageView: UIImageView, participant: ParticipantModel) {
        if let imagePath = participant.participantImagePath, let uuid = UUID(uuidString: imagePath) {
            loadImage(for: uuid) { image in
                DispatchQueue.main.async {
                    imageView.image = image ?? R.image.meet_placeholder()
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
