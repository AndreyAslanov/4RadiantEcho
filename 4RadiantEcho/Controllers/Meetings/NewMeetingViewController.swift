import UIKit

protocol NewMeetingDelegate: AnyObject {
    func didAddMeeting(_ meeting: MeetingModel)
    func didUpdateMeeting(_ meeting: MeetingModel)
    func didDeleteMeeting(withId id: UUID)
}

final class NewMeetingViewController: UIViewController {
    private let addEntryLabel = UILabel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleView = AppTextFieldView(type: .text)
    private let descriptionView = AppTextFieldView(type: .description)
    private let dateView = AppTextFieldView(type: .text)
    private let beginningView = AppTextFieldView(type: .text)
    private let endingView = AppTextFieldView(type: .text)
    private let locationView = AppTextFieldView(type: .text)
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let beginningLabel = UILabel()
    private let endingLabel = UILabel()
    private let locationLabel = UILabel()
    
    private let collectionContainerView = UIView()
    private let addParticipantView = AddParticipantView()
    private var selectedImagePath: String?
    
    private let saveButton = OnboardingButton()
    
    weak var delegate: NewMeetingDelegate?
    
    var currentMeeting: MeetingModel?
    var selectedParticipant: ParticipantModel?
    var participants: [ParticipantModel] = []
    
    var meetingId: UUID?
    private var isEditingMode: Bool
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(NewParticipantCell.self, forCellWithReuseIdentifier: NewParticipantCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    init(meetingId: UUID? = nil, isEditing: Bool) {
        self.meetingId = meetingId
        isEditingMode = isEditing
        super.init(nibName: nil, bundle: nil)
        if let meetingId = meetingId {
            self.meetingId = meetingId
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        updateAddButtonState()
        updateCollectionViewHeight()

        if isEditingMode {
            configure(with: currentMeeting)
        }

        let textFields = [
            titleView.textField,
            dateView.textField,
            beginningView.textField,
            endingView.textField,
            locationView.textField
        ]
        
        let textViews = [descriptionView.textView]
        
        let textFieldsToMove = [
            titleView.textField,
            dateView.textField,
            beginningView.textField,
            endingView.textField,
            locationView.textField
        ]
        let textViewsToMove = [descriptionView.textView]

        KeyboardManager.shared.configureKeyboard(
            for: self,
            targetView: view,
            textFields: textFields,
            textViews: textViews,
            moveFor: textFieldsToMove,
            moveFor: textViewsToMove,
            with: .done
        )

        descriptionView.delegate = self
        titleView.delegate = self
        dateView.delegate = self
        beginningView.delegate = self
        endingView.delegate = self
        locationView.delegate = self
        
        addParticipantView.delegate = self
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#070A13")
        addParticipantView.isUserInteractionEnabled = true
        
        saveButton.do { make in
            make.setTitle(to: L.save())
            let tapGesture = UITapGestureRecognizer(target: self, action: isEditingMode ? #selector(didTapEdit) : #selector(didTapAdd))
            make.addGestureRecognizer(tapGesture)
        }
        
        addEntryLabel.do { make in
            make.text = L.addEntry()
            make.font = .systemFont(ofSize: 20, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .center
        }
        
        [titleLabel, descriptionLabel, dateLabel,
         beginningLabel, endingLabel, locationLabel].forEach { label in
            label.do { make in
                make.font = .systemFont(ofSize: 13)
                make.textColor = .white.withAlphaComponent(0.7)
                make.textAlignment = .left
            }
        }
        
        titleLabel.text = L.title()
        descriptionLabel.text = L.description()
        dateLabel.text = L.date()
        beginningLabel.text = L.beginning()
        endingLabel.text = L.ending()
        locationLabel.text = L.location()
        
        collectionContainerView.do { make in
            make.backgroundColor = .white.withAlphaComponent(0.05)
            make.layer.cornerRadius = 16
            make.isUserInteractionEnabled = false
        }

        view.addSubviews(
            addEntryLabel, scrollView, saveButton
        )
        
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            titleLabel, descriptionLabel, dateLabel,
            beginningLabel, endingLabel, locationLabel,
            
            descriptionView, titleView, dateView,
            beginningView, endingView, locationView,
            
            addParticipantView, collectionContainerView, 
            collectionView
        )

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(addEntryLabel.snp.bottom).offset(11)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        addEntryLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(25)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        titleView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(54)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        descriptionView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(160)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        dateView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(54)
        }
        
        beginningLabel.snp.makeConstraints { make in
            make.top.equalTo(dateView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        beginningView.snp.makeConstraints { make in
            make.top.equalTo(beginningLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(endingView.snp.leading).offset(-16)
            make.width.equalToSuperview().dividedBy(2).offset(-24)
            make.height.equalTo(54)
        }
        
        endingView.snp.makeConstraints { make in
            make.top.equalTo(beginningLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.leading.equalTo(beginningView.snp.trailing).offset(16)
            make.width.equalToSuperview().dividedBy(2).offset(-24)
            make.height.equalTo(54)
        }
        
        endingLabel.snp.makeConstraints { make in
            make.bottom.equalTo(endingView.snp.top).offset(-8)
            make.leading.equalTo(endingView.snp.leading)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(beginningView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        locationView.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(54)
        }
        
        collectionContainerView.snp.makeConstraints { make in
            make.top.equalTo(locationView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(contentView.snp.bottom).offset(-100)
        }
        
        addParticipantView.snp.makeConstraints { make in
            make.top.equalTo(collectionContainerView.snp.top).offset(20)
            make.leading.equalTo(collectionContainerView.snp.leading).offset(20)
            make.trailing.equalTo(collectionContainerView.snp.trailing).inset(20)
            make.height.equalTo(50)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(addParticipantView.snp.bottom).offset(8)
            make.bottom.equalTo(collectionContainerView.snp.bottom).offset(-20)
            make.leading.trailing.equalTo(addParticipantView)
            make.height.equalTo(0)
        }
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(54)
        }
    }

    private func setupTextFields() {
        [titleView.textField,
        dateView.textField,
        beginningView.textField,
        endingView.textField,
        locationView.textField].forEach {
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    private func updateAddButtonState() {
        let allFieldsFilled = [
            titleView.textField,
            dateView.textField,
            beginningView.textField,
            endingView.textField,
            locationView.textField
        ].allSatisfy {
            $0.text?.isEmpty == false
        }

        let allTextViewsFilled = !descriptionView.textView.text.isEmpty

        saveButton.isEnabled = allFieldsFilled && allTextViewsFilled
        saveButton.alpha = saveButton.isEnabled ? 1.0 : 0.5
    }

    private func saveMeeting() {
        guard let title = titleView.textField.text,
        let description = descriptionView.textView.text,
        let date = dateView.textField.text,
        let beginning = beginningView.textField.text,
        let ending = endingView.textField.text,
        let location = locationView.textField.text else { return }
        let id = UUID()

        currentMeeting = MeetingModel(
            id: id,
            title: title,
            description: description,
            date: date,
            beginning: beginning,
            ending: ending,
            location: location,
            participants: participants
        )
    }
    
    private func updateCollectionViewHeight() {
        let numberOfItems = participants.count
        let itemHeight: CGFloat = 54
        let spacing: CGFloat = 8
        
        let totalHeight: CGFloat
        if numberOfItems == 0 {
            totalHeight = 0
        } else {
            totalHeight = (itemHeight * CGFloat(numberOfItems)) + (spacing * CGFloat(numberOfItems - 1)) + 20
        }
        
        let updatedHeight = max(0, totalHeight)

        collectionView.snp.updateConstraints { make in
            make.height.equalTo(updatedHeight)
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateAddButtonState()
    }
    
    @objc private func didTapBack() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapAdd() {
        saveMeeting()
        if let meeting = currentMeeting {
            if let existingMeetingIndex = loadMeetings().firstIndex(where: { $0.id == meeting.id }) {
                delegate?.didAddMeeting(meeting)
            } else {
                delegate?.didAddMeeting(meeting)
            }
        }
        didTapBack()
    }

    @objc private func didTapEdit() {
        guard let meetingId = meetingId else { return }

        let updatedMeeting = MeetingModel(
            id: meetingId,
            title: titleView.textField.text ?? "",
            description: descriptionView.textView.text ?? "",
            date: dateView.textField.text ?? "",
            beginning: beginningView.textField.text ?? "",
            ending: endingView.textField.text ?? "",
            location: locationView.textField.text ?? "",
            participants: participants
        )
        
        MeetingDataManager.shared.saveMeeting(updatedMeeting)

        if let savedMeeting = MeetingDataManager.shared.loadMeeting() {
            delegate?.didUpdateMeeting(savedMeeting)
        } else {
            print("Failed to load updated meeting")
        }

        didTapBack()
    }

    // MARK: - Data Persistence Methods
    private func loadMeetings() -> [MeetingModel] {
        return MeetingDataManager.shared.loadMeetings()
    }

    private func configure(with meeting: MeetingModel?) {
        guard let meeting = currentMeeting else { return }
        
        titleView.textField.text = meeting.title
        dateView.textField.text = meeting.date
        beginningView.textField.text = meeting.beginning
        endingView.textField.text = meeting.ending
        locationView.textField.text = meeting.location
        
        descriptionView.textView.text = meeting.description
        descriptionView.placeholderLabel.isHidden = !(meeting.description.isEmpty)

        participants = meeting.participants ?? []
        collectionView.reloadData()
        
        updateAddButtonState()
        updateCollectionViewHeight()
    }
}

// MARK: - AddParticipantViewDelegate
extension NewMeetingViewController: AddParticipantViewDelegate {
    func didTapButton() {
        let alertController = UIAlertController(title: L.addParticipant(), message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = L.name()
        }
        
        let cancelAction = UIAlertAction(title: L.cancel(), style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: L.add(), style: .default) { _ in
            guard let participantName = alertController.textFields?[0].text, !participantName.isEmpty else { return }
            let newParticipant = ParticipantModel(id: UUID(), name: participantName, participantImagePath: "")
            self.participants.append(newParticipant)
            self.collectionView.reloadData()
            self.updateCollectionViewHeight()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - NewParticipantCellDelegate
extension NewMeetingViewController: NewParticipantCellDelegate {
    func didTapImageView(with participant: ParticipantModel) {
        selectedParticipant = participant
        showImagePickerController(for: participant)
    }

    func didTapEditParticipant(with participant: ParticipantModel) {
        let alertController = UIAlertController(title: L.editParticipant(), message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = L.name()
            textField.text = participant.name
        }
        
        let cancelAction = UIAlertAction(title: L.cancel(), style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: L.save(), style: .default) { _ in
            guard let newName = alertController.textFields?[0].text, !newName.isEmpty else {
                return
            }
            
            if let index = self.participants.firstIndex(where: { $0.id == participant.id }) {
                self.participants[index].name = newName
                self.collectionView.reloadData()
            } else {
                print("Participant with id \(participant.id) not found in the participants array.")
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }

    func didTapDeleteParticipant(with participant: ParticipantModel) {
        if let index = participants.firstIndex(where: { $0.id == participant.id }) {
            participants.remove(at: index)
            
            guard var meeting = currentMeeting else {
                collectionView.reloadData()
                updateCollectionViewHeight()
                return
            }
            
            MeetingDataManager.shared.removeParticipant(fromMeeting: &meeting, participantId: participant.id)
            collectionView.reloadData()
            updateCollectionViewHeight()
        } else {
            print("Participant with id \(participant.id) not found in the participants array.")
        }
    }
}

// MARK: - AppTextFieldDelegate
extension NewMeetingViewController: AppTextFieldDelegate {
    func didTapTextField(type: AppTextFieldView.TextFieldType) {
        updateAddButtonState()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension NewMeetingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePickerController(for participant: ParticipantModel) {
        self.selectedParticipant = participant
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage,
           let participant = selectedParticipant {
            
            if let imagePath = MeetingDataManager.shared.saveImage(selectedImage, withId: participant.id) {
                
                if let index = participants.firstIndex(where: { $0.id == participant.id }) {
                    participants[index].participantImagePath = imagePath
                    
                    let indexPath = IndexPath(item: index, section: 0)
                    collectionView.reloadItems(at: [indexPath])
                }
                
                var updatedMeeting = MeetingDataManager.shared.loadMeeting() ?? MeetingModel(id: UUID(), title: "", description: "", date: "", beginning: "", ending: "", location: "", participants: participants)
                MeetingDataManager.shared.updateParticipant(inMeeting: &updatedMeeting, participantId: participant.id, image: selectedImage)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension NewMeetingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return participants.isEmpty ? 0 : 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewParticipantCell.reuseIdentifier, for: indexPath) as? NewParticipantCell else {
            fatalError("Unable to dequeue NewTopicCell")
        }

        let participant = participants[indexPath.item]
        cell.delegate = self
        cell.configure(with: participant)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 54
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 12, right: 10)
    }
}

// MARK: - KeyBoard Apparance
extension NewMeetingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewMeetingViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillShow(notification as Notification)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillHide(notification as Notification)
    }
}
