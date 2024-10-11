import UIKit

final class OnboardingPageViewController: UIViewController {
    // MARK: - Types

    enum Page {
        case control, ideas, manage
    }

    private let mainLabel = UILabel()
    private let backgroundImageView = UIImageView()

    private let exitButton = UIButton(type: .custom)

    // MARK: - Properties info

    private let privacyLabel = UILabel()
    private let protectActivityLabel = UILabel()

    private var didAddGradient = false

    private let page: Page
    private var isIdea: Bool

    // MARK: - Init

    init(page: Page, isIdea: Bool) {
        self.page = page
        self.isIdea = isIdea
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        switch page {
        case .control: drawControl()
        case .ideas: drawIdeas()
        case .manage: drawManage()
        }
    }

    // MARK: - Draw

    private func drawControl() {
        backgroundImageView.isUserInteractionEnabled = true
        mainLabel.isHidden = false
        
        if isIdea {
            backgroundImageView.image = R.image.onb_control_idea_background()
            mainLabel.text = L.controlIdeaLabel()
        } else {
            backgroundImageView.image = R.image.onb_control_background()
            mainLabel.text = L.controlLabel()
        }

        mainLabel.do { make in
            make.textColor = .white
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(backgroundImageView, mainLabel)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }

    private func drawIdeas() {
        backgroundImageView.isUserInteractionEnabled = true
        
        if isIdea {
            mainLabel.text = L.ideasIdeaLabel()
            backgroundImageView.image = R.image.onb_ideas_idea_background()
        } else {
            mainLabel.text = L.ideasLabel()
            backgroundImageView.image = R.image.onb_ideas_background()
        }

        mainLabel.do { make in
            make.textColor = .white
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(backgroundImageView, mainLabel)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }    
    
    private func drawManage() {
        backgroundImageView.image = R.image.onb_manage_background()
        backgroundImageView.isUserInteractionEnabled = true

        mainLabel.do { make in
            make.text = L.manageLabel()
            make.textColor = .white
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textAlignment = .center
            make.numberOfLines = 0
        }
        
        exitButton.do { make in
            make.setImage(R.image.onb_closeButton(), for: .normal)
            make.imageView?.contentMode = .scaleAspectFit
            make.imageView?.clipsToBounds = true
            make.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        }

        view.addSubviews(backgroundImageView, mainLabel, exitButton)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        
        exitButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.size.equalTo(60)

            if UIDevice.isIphoneBelowX {
                make.top.equalToSuperview().offset(32)
            } else {
                make.top.equalToSuperview().offset(64)
            }
        }
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
        AppActions.shared.openWebPage()
    }
}
