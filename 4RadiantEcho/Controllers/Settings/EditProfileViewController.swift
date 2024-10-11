import UIKit

protocol EditProfileDelegate: AnyObject {
    func didAddProfile(_ profile: NewProfileModel)
}

final class EditProfileViewController: UIViewController {
    private let profileLabel = UILabel()
    private let imageView = UIImageView()

    private let nameView = AppTextFieldView(type: .text)
    private let ageView = AppTextFieldView(type: .text)
    private let nameLabel = UILabel()
    private let ageLabel = UILabel()

    private let sexSelectionView = SexSelectionView()
    private let saveButton = OnboardingButton()

    private var selectedImagePath: String?
    private var selectedSex: [Int]?

    weak var delegate: EditProfileDelegate?
    var profile: NewProfileModel?
    var profileId: UUID?
    private var isEditingMode: Bool

    init(profileId: UUID? = nil, isEditing: Bool) {
        self.profileId = profileId
        isEditingMode = isEditing
        super.init(nibName: nil, bundle: nil)
        if let profileId = profileId {
            self.profileId = profileId
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

        if isEditingMode {
            configure(with: profile)
        }

        let textFields = [nameView.textField, ageView.textField]
        let textViews = [ageView.textView]
        let textFieldsToMove = [nameView.textField, ageView.textField]
        let textViewsToMove = [ageView.textView]

        KeyboardManager.shared.configureKeyboard(
            for: self,
            targetView: view,
            textFields: textFields,
            textViews: textViews,
            moveFor: textFieldsToMove,
            moveFor: textViewsToMove,
            with: .done
        )

        nameView.delegate = self
        ageView.delegate = self
        sexSelectionView.delegate = self
        imageView.isUserInteractionEnabled = true
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#222223")
        saveButton.setTitle(to: L.save())
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAdd))
        saveButton.addGestureRecognizer(tapGesture)

        profileLabel.do { make in
            make.text = L.profile()
            make.font = .systemFont(ofSize: 20, weight: .semibold)
            make.textColor = .white
            make.textAlignment = .center
        }

        imageView.do { make in
            make.image = R.image.profile_edit_placeholder()
            make.contentMode = .scaleAspectFill
            make.isUserInteractionEnabled = true
            make.layer.cornerRadius = 12
            make.masksToBounds = true
            let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
            make.addGestureRecognizer(tapImageGesture)
        }

        nameLabel.do { make in
            make.text = L.name()
            make.font = .systemFont(ofSize: 13)
            make.textColor = .white.withAlphaComponent(0.7)
        }

        ageLabel.do { make in
            make.text = L.age()
            make.font = .systemFont(ofSize: 13)
            make.textColor = .white.withAlphaComponent(0.7)
        }

        view.addSubviews(
            profileLabel, imageView, nameLabel,
            nameView, ageLabel,
            ageView, sexSelectionView, saveButton
        )

        profileLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(25)
        }

        imageView.snp.makeConstraints { make in
            make.top.equalTo(profileLabel.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
            make.height.equalTo(211)
            make.width.equalTo(164)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
        }

        nameView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(54)
        }

        ageLabel.snp.makeConstraints { make in
            make.top.equalTo(nameView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
        }

        ageView.snp.makeConstraints { make in
            make.top.equalTo(ageLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(54)
        }

        sexSelectionView.snp.makeConstraints { make in
            make.top.equalTo(ageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(44)
        }

        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }

    private func setupTextFields() {
        [nameView.textField].forEach {
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    private func updateAddButtonState() {
        let allFieldsFilled = [
            nameView.textField,
            ageView.textField
        ].allSatisfy {
            $0.text?.isEmpty == false
        }

        let isSexSelected = selectedSex?.isEmpty == false

        saveButton.isEnabled = allFieldsFilled && isSexSelected
        saveButton.alpha = saveButton.isEnabled ? 1.0 : 0.5
    }

    private func saveProfile() {
        guard let name = nameView.textField.text,
              let age = ageView.textField.text,
              let sex = selectedSex else { return }

        let id = UUID()

        let newProfile = NewProfileModel(
            id: id,
            name: name,
            age: age,
            sex: sex,
            profileImagePath: selectedImagePath
        )

        NewProfileDataManager.shared.saveProfile(newProfile)
        profile = newProfile
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateAddButtonState()
    }

    @objc private func didTapBack() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapAdd() {
        saveProfile()

        guard let profile = profile else { return }
        delegate?.didAddProfile(profile)

        didTapBack()
    }

    @objc private func didTapImageView() {
        showImagePickerController()
    }

    // MARK: - Data Persistence Methods
    private func loadProfiles() -> [NewProfileModel] {
        return NewProfileDataManager.shared.loadProfiles()
    }

    private func configure(with profile: NewProfileModel?) {
        guard let profile = profile else { return }
        selectedImagePath = profile.profileImagePath
        nameView.textField.text = profile.name
        ageView.textField.text = profile.age
        sexSelectionView.configureForCell(selectedIndices: profile.sex)

        if let imagePath = profile.profileImagePath, let uuid = UUID(uuidString: imagePath) {
            loadImage(for: uuid) { [weak self] image in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                    if image == nil {
                        print("Failed to load image for UUID: \(imagePath)")
                    }
                }
            }
        }

        updateAddButtonState()
    }

    private func loadImage(for id: UUID, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let image = NewProfileDataManager.shared.loadImage(withId: id)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}

// MARK: - SexSelectionDelegate
extension EditProfileViewController: SexSelectionDelegate {
    func didSelectSex(selectedIndices: [Int]) {
        selectedSex = selectedIndices
        updateAddButtonState()
    }
}

// MARK: - AppTextFieldDelegate
extension EditProfileViewController: AppTextFieldDelegate {
    func didTapTextField(type: AppTextFieldView.TextFieldType) {
        updateAddButtonState()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePickerController() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            selectedImagePath = NewProfileDataManager.shared.saveImage(selectedImage, withId: UUID())
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - KeyBoard Apparance
extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EditProfileViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillShow(notification as Notification)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillHide(notification as Notification)
    }
}
