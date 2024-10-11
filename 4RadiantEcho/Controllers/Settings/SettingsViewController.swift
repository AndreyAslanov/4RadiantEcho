import SnapKit
import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func deleteAllData()
}

final class SettingsViewController: UIViewController {
    private let profileSettingsLabel = UILabel()
    private let profileImageView = UIImageView()
    private let settingsStackView = UIStackView()
    private let editButtonView = OnboardingButton()

    private let nameView = ProfileView(type: .name)
    private let ageView = ProfileView(type: .age)
    private let sexView = ProfileView(type: .sex)

    private let shareAppView: SettingsView
    private let usagePolicyView: SettingsView
    private let rateAppView: SettingsView

    weak var delegate: SettingsViewControllerDelegate?

    init() {
        shareAppView = SettingsView(type: .shareApp)
        usagePolicyView = SettingsView(type: .usagePolicy)
        rateAppView = SettingsView(type: .rateApp)

        super.init(nibName: nil, bundle: nil)

        shareAppView.delegate = self
        usagePolicyView.delegate = self
        rateAppView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(false, animated: false)

        let configuration = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        let backButtonImage = UIImage(systemName: "chevron.left", withConfiguration: configuration)?
            .withTintColor(UIColor(hex: "#225CEE"), renderingMode: .alwaysOriginal)

        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(didTapCancel))
        navigationItem.leftBarButtonItem = backButton

        view.backgroundColor = UIColor(hex: "#070A13")

        drawSelf()

        if let savedProfile = NewProfileDataManager.shared.loadProfile() {
            didAddProfile(savedProfile)
        }
    }

    private func drawSelf() {
        profileSettingsLabel.do { make in
            make.text = L.profileSettings()
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textColor = .white
        }

        profileImageView.do { make in
            make.image = R.image.profile_placeholder()
            make.contentMode = .scaleAspectFill
            make.masksToBounds = true
            make.layer.cornerRadius = 12
        }

        settingsStackView.do { make in
            make.axis = .horizontal
            make.spacing = 8
            make.distribution = .equalSpacing
        }

        editButtonView.do { make in
            make.setTitle(to: L.editInfo())
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editButtonTapped))
            make.addGestureRecognizer(tapGesture)
        }

        settingsStackView.addArrangedSubviews([shareAppView, rateAppView, usagePolicyView])

        view.addSubviews(
            profileSettingsLabel, profileImageView, nameView, ageView, sexView,
            editButtonView, settingsStackView
        )

        profileSettingsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(3)
        }

        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(profileSettingsLabel.snp.bottom).offset(24)
            make.height.equalTo(211)
            make.width.equalTo(164)
        }

        nameView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(65)
        }

        ageView.snp.makeConstraints { make in
            make.top.equalTo(nameView.snp.bottom).offset(8)
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(65)
        }

        sexView.snp.makeConstraints { make in
            make.top.equalTo(ageView.snp.bottom).offset(8)
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(65)
        }

        editButtonView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }

        settingsStackView.snp.makeConstraints { make in
            make.top.equalTo(editButtonView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(106)
        }

        shareAppView.snp.makeConstraints { make in
            make.height.equalTo(106)
            make.width.equalToSuperview().dividedBy(3).offset(-8)
        }

        rateAppView.snp.makeConstraints { make in
            make.height.equalTo(106)
            make.width.equalToSuperview().dividedBy(3).offset(-8)
        }

        usagePolicyView.snp.makeConstraints { make in
            make.height.equalTo(106)
            make.width.equalToSuperview().dividedBy(3).offset(-8)
        }
    }

    @objc private func editButtonTapped() {
        let isEditing: Bool
        let editVC: EditProfileViewController

        if let savedProfile = NewProfileDataManager.shared.loadProfile() {
            editVC = EditProfileViewController(isEditing: true)
            editVC.profile = savedProfile
            editVC.profileId = savedProfile.id
        } else {
            editVC = EditProfileViewController(isEditing: false)
        }

        editVC.delegate = self

        if #available(iOS 15.0, *) {
            if let sheet = editVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.largestUndimmedDetentIdentifier = .large
            }
        } else {
            editVC.modalPresentationStyle = .fullScreen
            editVC.modalTransitionStyle = .coverVertical
        }

        present(editVC, animated: true, completion: nil)
    }

    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - EditProfileDelegate
extension SettingsViewController: EditProfileDelegate {
    func didAddProfile(_ profile: NewProfileModel) {
        nameView.updateText(profile.name)
        ageView.updateText(profile.age)

        if profile.sex == [0] {
            sexView.updateText(L.man())
        } else if profile.sex == [1] {
            sexView.updateText(L.woman())
        } else {
            sexView.updateText(L.text())
        }

        if let imagePath = profile.profileImagePath, let uuid = UUID(uuidString: imagePath) {
            loadImage(for: uuid) { [weak self] image in
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                    if image == nil {
                        print("Failed to load image for UUID: \(imagePath)")
                    }
                }
            }
        }
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

// MARK: - SettingsViewDelegate
extension SettingsViewController: SettingsViewDelegate {
    func didTapView(type: SettingsView.SelfType) {
        switch type {
        case .shareApp:
            AppActions.shared.shareApp()
        case .usagePolicy:
            AppActions.shared.showUsagePolicy()
        case .rateApp:
            AppActions.shared.rateApp()
        }
    }
}
