import UIKit

protocol NewIdeaDelegate: AnyObject {
    func didAddIdea(_ idea: IdeasModel)
    func didUpdateIdea(_ idea: IdeasModel)
}

final class NewIdeaViewController: UIViewController {
    private let addEntryLabel = UILabel()
    
    private let titleView = AppTextFieldView(type: .text)
    private let descriptionView = AppTextFieldView(type: .description)
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let saveButton = OnboardingButton()
    
    weak var delegate: NewIdeaDelegate?
    
    var currentIdea: IdeasModel?
    var currentCategory: CategoryModel?
    
    var selectedParticipant: ParticipantModel?
    var participants: [ParticipantModel] = []
    
    var categoryId: UUID?
    private var isEditingMode: Bool

    init(categoryId: UUID? = nil, isEditing: Bool) {
        self.categoryId = categoryId
        isEditingMode = isEditing
        super.init(nibName: nil, bundle: nil)
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
            configure(with: currentIdea)
        }

        let textFields = [titleView.textField]
        let textViews = [descriptionView.textView]
        let textFieldsToMove = [titleView.textField]
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
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#070A13")
        
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
        
        [titleLabel, descriptionLabel].forEach { label in
            label.do { make in
                make.font = .systemFont(ofSize: 13)
                make.textColor = .white.withAlphaComponent(0.7)
                make.textAlignment = .left
            }
        }
        
        titleLabel.text = L.title()
        descriptionLabel.text = L.description()

        view.addSubviews(
            addEntryLabel, titleLabel, descriptionLabel,descriptionView, titleView, saveButton
        )
        
        addEntryLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(25)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(addEntryLabel.snp.top).offset(27)
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
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(54)
        }
    }

    private func setupTextFields() {
        [titleView.textField].forEach {
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    private func updateAddButtonState() {
        let allFieldsFilled = [
            titleView.textField
        ].allSatisfy {
            $0.text?.isEmpty == false
        }

        let allTextViewsFilled = !descriptionView.textView.text.isEmpty

        saveButton.isEnabled = allFieldsFilled && allTextViewsFilled
        saveButton.alpha = saveButton.isEnabled ? 1.0 : 0.5
    }

    private func saveIdea() {
        guard let title = titleView.textField.text,
              let description = descriptionView.textView.text,
              let currentCategory = currentCategory else { return }

        let id = currentIdea?.id ?? UUID()

        currentIdea = IdeasModel(
            id: id,
            title: title,
            description: description
        )

        var updatedCategory = currentCategory
        if updatedCategory.ideas == nil {
            updatedCategory.ideas = []
        }

        if let currentIdea = currentIdea {
            updatedCategory.ideas?.append(currentIdea)
        }

        CategoryDataManager.shared.saveCategory(updatedCategory)
    }

    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateAddButtonState()
    }
    
    @objc private func didTapBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapAdd() {
        saveIdea()
        if let idea = currentIdea {
            delegate?.didAddIdea(idea)
        } else {
        }
        didTapBack()
    }

    @objc private func didTapEdit() {
        guard let categoryId = categoryId,
              let ideaId = currentIdea?.id else { return }

        let updatedTitle = titleView.textField.text ?? ""
        let updatedDescription = descriptionView.textView.text ?? ""

        let updatedIdea = IdeasModel(
            id: ideaId,
            title: updatedTitle,
            description: updatedDescription
        )

        CategoryDataManager.shared.updateIdea(inCategoryId: categoryId, ideaId: ideaId, title: updatedTitle, description: updatedDescription)

        delegate?.didUpdateIdea(updatedIdea)
        didTapBack()
    }

    // MARK: - Data Persistence Methods
    private func loadIdea() -> IdeasModel? {
        guard let categoryId = categoryId, let currentIdea = currentIdea else { return nil }
        return CategoryDataManager.shared.loadIdea(fromCategoryId: categoryId, ideaId: currentIdea.id)
    }
    
    private func configure(with idea: IdeasModel?) {
        guard let idea = idea else { return }

        titleView.textField.text = idea.title
        descriptionView.textView.text = idea.description
        descriptionView.placeholderLabel.isHidden = !idea.description.isEmpty

        updateAddButtonState()
    }
}

// MARK: - AppTextFieldDelegate
extension NewIdeaViewController: AppTextFieldDelegate {
    func didTapTextField(type: AppTextFieldView.TextFieldType) {
        updateAddButtonState()
    }
}

// MARK: - KeyBoard Apparance
extension NewIdeaViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewIdeaViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillShow(notification as Notification)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillHide(notification as Notification)
    }
}
