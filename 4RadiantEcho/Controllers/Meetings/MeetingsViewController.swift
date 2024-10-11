import SnapKit
import UIKit

final class MeetingsViewController: UIViewController {
    private let meetingsLabel = UILabel()
    private let historyLabel = UILabel()
    private let ideasButtonView = IdeasButtonView()
    private let settingsButtonView = SettingsButtonView()
    private let appointmentButtonView = AppointmentButtonView()
    private let noMeetingsView = NoMeetingsView()

    var meetings: [MeetingModel] = [] {
        didSet {
            saveMeetings(meetings)
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MeetingCell.self, forCellWithReuseIdentifier: MeetingCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor(hex: "#070A13")
        
        drawself()
        updateViewVisibility()

        meetings = loadMeetings()
        updateViewVisibility()
        collectionView.reloadData()
    }

    private func drawself() {
        let tapSettingsGesture = UITapGestureRecognizer(target: self, action: #selector(settingsButtonTapped))
        settingsButtonView.addGestureRecognizer(tapSettingsGesture)        
        
        let tapNewMeetingGesture = UITapGestureRecognizer(target: self, action: #selector(newMeetingsButtonTapped))
        appointmentButtonView.addGestureRecognizer(tapNewMeetingGesture)          
        
        let tapNewIdeasGesture = UITapGestureRecognizer(target: self, action: #selector(newIdeasButtonTapped))
        ideasButtonView.addGestureRecognizer(tapNewIdeasGesture)
        
        meetingsLabel.do { make in
            make.text = L.meetingsLabel()
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textColor = .white
            make.textAlignment = .left
        }        
        
        historyLabel.do { make in
            make.text = L.history()
            make.font = .systemFont(ofSize: 28, weight: .bold)
            make.textColor = .white
            make.textAlignment = .left
        }
        
        view.addSubviews(
            meetingsLabel, ideasButtonView, settingsButtonView,
            appointmentButtonView, historyLabel, noMeetingsView,
            collectionView
        )
        
        meetingsLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(47)
            make.leading.equalToSuperview().offset(16)
        }
        
        ideasButtonView.snp.makeConstraints { make in
            if UIDevice.isIpad {
                make.width.equalToSuperview().dividedBy(3).offset(-20)
            } else {
                make.width.equalTo(61.5)
            }
            
            make.top.equalTo(meetingsLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(settingsButtonView.snp.leading).offset(-8)
            make.height.equalTo(50)
        }
        
        settingsButtonView.snp.makeConstraints { make in
            make.top.height.width.equalTo(ideasButtonView)
            make.leading.equalTo(ideasButtonView.snp.trailing).offset(8)
            make.trailing.equalTo(appointmentButtonView.snp.leading).offset(-8)
        }
        
        appointmentButtonView.snp.makeConstraints { make in
            make.top.height.equalTo(ideasButtonView)
            make.leading.equalTo(settingsButtonView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(16)
        }
        
        historyLabel.snp.makeConstraints { make in
            make.top.equalTo(ideasButtonView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        noMeetingsView.snp.makeConstraints { make in
            make.top.equalTo(historyLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(178)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(historyLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    private func loadMeetings() -> [MeetingModel] {
        return MeetingDataManager.shared.loadMeetings()
    }

    private func saveMeetings(_ meetings: [MeetingModel]) {
        MeetingDataManager.shared.saveMeetings(meetings)
    }
    
    @objc private func settingsButtonTapped() {
        let settingsVC = SettingsViewController()

        let navController = UINavigationController(rootViewController: settingsVC)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .coverVertical
        
        present(navController, animated: true, completion: nil)
    }     
    
    @objc private func newIdeasButtonTapped() {
        let ideasVC = IdeasViewController()

        let navController = UINavigationController(rootViewController: ideasVC)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .coverVertical
        
        present(navController, animated: true, completion: nil)
    }    
    
    @objc private func newMeetingsButtonTapped() {
        let newMeetingsVC: NewMeetingViewController
        newMeetingsVC = NewMeetingViewController(isEditing: false)
        newMeetingsVC.delegate = self

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
    
    @objc private func leftButtonTapped() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    private func updateViewVisibility() {
        let isMeetingsEmpty = meetings.isEmpty
        noMeetingsView.isHidden = !(isMeetingsEmpty)
    }
}

// MARK: - NewMeetingDelegate
extension MeetingsViewController: NewMeetingDelegate {
    func didAddMeeting(_ meeting: MeetingModel) {
        meetings.append(meeting)
        updateViewVisibility()
        collectionView.reloadData()
    }
}

// MARK: - MeetingCellDelegate
extension MeetingsViewController: MeetingCellDelegate {
    func didTapMeetingCell(with meeting: MeetingModel) {
        let meetingProfileVC = MeetingProfileViewController()
        meetingProfileVC.meeting = meeting
        meetingProfileVC.delegate = self
        
        let navController = UINavigationController(rootViewController: meetingProfileVC)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .coverVertical
        
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - MeetingProfileDelegate
extension MeetingsViewController: MeetingProfileDelegate {
    func didUpdateMeeting(_ meeting: MeetingModel) {
        if let index = meetings.firstIndex(where: { $0.id == meeting.id }) {
            meetings[index] = meeting
        } else {
            print("No meeting ID.")
        }
        
        updateViewVisibility()
        collectionView.reloadData()
    }
    
    func didDeleteMeeting(withId id: UUID) {
        if let index = meetings.firstIndex(where: { $0.id == id }) {
            meetings.remove(at: index)
        } else {
            print("No meeting ID.")
        }
        
        updateViewVisibility()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension MeetingsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (meetings.isEmpty) ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return meetings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MeetingCell.reuseIdentifier, for: indexPath) as? MeetingCell else {
            fatalError("Unable to dequeue NewTopicCell")
        }
        
        let meeting = meetings[indexPath.item]
        cell.delegate = self
        cell.configure(with: meeting)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MeetingCell.reuseIdentifier, for: indexPath) as? MeetingCell else {
            return CGSize(width: collectionView.bounds.width, height: 278)
        }
        
        let meeting = meetings[indexPath.item]
        cell.configure(with: meeting)

        let width = collectionView.bounds.width
        
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
