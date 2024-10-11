import UIKit

protocol MeetingProfileDelegate: AnyObject {
    func didUpdateMeeting(_ meeting: MeetingModel)
    func didDeleteMeeting(withId id: UUID)
}

class MeetingProfileViewController: UIViewController {
    private let upperView = UIView()
    private let titleLabel = UILabel()
    private let locationLabel = UILabel()
    
    private let calendarImageView = UIImageView()
    private let clockImageView = UIImageView()
    private let dateLabel = UILabel()
    private let timeLabel = UILabel()
    
    private let descriptionLabel = UILabel()
    private let collectionContainerView = UIView()
    private let deleteButton = OnboardingButton()
    
    var meeting: MeetingModel?
    var participants: [ParticipantModel] = []
    private var newMeetingsVC: NewMeetingViewController?
    weak var delegate: MeetingProfileDelegate?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ParticipantCell.self, forCellWithReuseIdentifier: ParticipantCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#070A13")
        setupNavigationBar()
        setupUI()
        setupConstraints()
        configure(with: meeting)
    }
    
    private func setupNavigationBar() {
        let backButton = UIButton(type: .system)
        backButton.setTitle(L.back(), for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)

        let chevronImage = UIImage(systemName: "chevron.left")
        backButton.setImage(chevronImage, for: .normal)
        
        backButton.tintColor = .systemBlue
        backButton.contentHorizontalAlignment = .left
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        let editButton = UIBarButtonItem(title: L.edit(), style: .plain, target: self, action: #selector(editButtonTapped))
         editButton.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.7), .font: UIFont.systemFont(ofSize: 17, weight: .regular)], for: .normal)

        navigationItem.rightBarButtonItem = editButton
    }
    
    private func setupUI() {
        upperView.do { make in
            make.backgroundColor = .white.withAlphaComponent(0.05)
            make.layer.cornerRadius = 16
        }
        
        collectionContainerView.do { make in
            make.backgroundColor = .white.withAlphaComponent(0.05)
            make.layer.cornerRadius = 16
        }
        
        titleLabel.do { make in
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textColor = .white
            make.textAlignment = .center
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
        
        descriptionLabel.do { make in
            make.font = .systemFont(ofSize: 17)
            make.textColor = .white
            make.textAlignment = .left
            make.numberOfLines = 4
        }
        
        deleteButton.do { make in
            make.setBackgroundColor(.white.withAlphaComponent(0.05))
            make.setTitle(to: L.delete())
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteButtonTapped))
            make.addGestureRecognizer(tapGesture)
        }
        
        upperView.addSubviews(
            locationLabel, calendarImageView, 
            clockImageView, dateLabel, timeLabel
        )
        
        view.addSubviews(
            titleLabel, upperView, descriptionLabel,
            collectionContainerView, collectionView, deleteButton
        )
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(3)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(41)
        }
        
        upperView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(66)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
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
            make.trailing.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(upperView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        collectionContainerView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(deleteButton.snp.top).offset(-16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(collectionContainerView.snp.top).offset(20)
            make.leading.equalTo(collectionContainerView.snp.leading).offset(20)
            make.trailing.equalTo(collectionContainerView.snp.trailing).offset(-20)
            make.bottom.equalTo(collectionContainerView.snp.bottom).offset(-20)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }

    @objc private func backButtonTapped() {
        if let meeting = meeting {
            delegate?.didUpdateMeeting(meeting)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func editButtonTapped() {
        guard let meeting = meeting else { return } 
        
        let newMeetingsVC = NewMeetingViewController(isEditing: true)
        newMeetingsVC.delegate = self
        newMeetingsVC.currentMeeting = meeting
        newMeetingsVC.meetingId = meeting.id

        if #available(iOS 15.0, *) {
            if let sheet = newMeetingsVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.largestUndimmedDetentIdentifier = .large
            }
        } else {
            newMeetingsVC.modalPresentationStyle = .fullScreen
            newMeetingsVC.modalTransitionStyle = .coverVertical
        }

        present(newMeetingsVC, animated: true, completion: nil)
    }
    
    @objc private func deleteButtonTapped() {
        guard let meeting = meeting else { return }
        MeetingDataManager.shared.deleteMeeting(withId: meeting.id)
        delegate?.didDeleteMeeting(withId: meeting.id)
        dismiss(animated: true, completion: nil)
    }
    
    private func configure(with meeting: MeetingModel?) {
        guard let meeting = meeting else { return }
        
        titleLabel.text = meeting.title
        locationLabel.text = meeting.location
        dateLabel.text = meeting.date
        timeLabel.text = "\(meeting.beginning) - \(meeting.ending)"
        descriptionLabel.text = meeting.description
        
        participants = meeting.participants ?? []
        collectionView.reloadData()
    }
}

// MARK: - NewMeetingDelegate
extension MeetingProfileViewController: NewMeetingDelegate {
    func didAddMeeting(_ meeting: MeetingModel) {
    }
    
    func didUpdateMeeting(_ meeting: MeetingModel) {
        configure(with: meeting)
        self.meeting = meeting
    }
    
    func didDeleteMeeting(withId id: UUID) {
    }
}

// MARK: - UICollectionViewDataSource
extension MeetingProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return participants.isEmpty ? 0 : 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParticipantCell.reuseIdentifier, for: indexPath) as? ParticipantCell else {
            fatalError("Unable to dequeue NewTopicCell")
        }

        let participant = participants[indexPath.item]
        cell.configure(with: participant)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 54
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 12, right: 10)
    }
}
