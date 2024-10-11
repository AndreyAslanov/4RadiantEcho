import UIKit

final class OnboardingViewController: UIViewController {
    // MARK: - Life cycle
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var pagesViewControllers = [UIViewController]()

    private var currentPage: OnboardingPageViewController.Page = .control

    private var trackButtonTapsCount = 0

    private lazy var first = OnboardingPageViewController(page: .control, isIdea: isIdea)
    private lazy var second = OnboardingPageViewController(page: .ideas, isIdea: isIdea)
    private lazy var third = OnboardingPageViewController(page: .manage, isIdea: isIdea)

    private let continueButton = OnboardingButton()
    private let blackView = UIView()
    private let firstCircleView = UIView()
    private let secondCircleView = UIView()
    private let circleStackView = UIStackView()

    private var isIdea: Bool

    init(isIdea: Bool) {
        self.isIdea = isIdea
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pagesViewControllers += [first, second, third]

        drawSelf()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func drawSelf() {
        view.backgroundColor = .clear

        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)

        addChildController(pageViewController, inside: view)
        if let pageFirst = pagesViewControllers.first {
            pageViewController.setViewControllers([pageFirst], direction: .forward, animated: false)
        }
        pageViewController.dataSource = self

        for subview in pageViewController.view.subviews {
            if let subview = subview as? UIScrollView {
                subview.isScrollEnabled = false
                break
            }
        }

        firstCircleView.backgroundColor = UIColor(hex: "#225CEE")
        secondCircleView.backgroundColor = .white.withAlphaComponent(0.3)

        [firstCircleView, secondCircleView].forEach { view in
            view.do { make in
                make.layer.cornerRadius = 5
            }
        }

        circleStackView.do { make in
            make.axis = .horizontal
            make.spacing = 8
            make.distribution = .fillEqually
        }

        blackView.do { make in
            make.backgroundColor = .black
            make.layer.cornerRadius = 20
            make.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            make.isUserInteractionEnabled = true
        }

        circleStackView.addArrangedSubviews([firstCircleView, secondCircleView])
        blackView.addSubview(continueButton)
        view.addSubviews(circleStackView, blackView)

        circleStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(130)
            make.centerX.equalToSuperview()
        }

        [firstCircleView, secondCircleView].forEach { view in
            view.snp.makeConstraints { make in
                make.size.equalTo(10)
            }
        }

        continueButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }

        blackView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(116)
        }
    }
}

// MARK: - OnboardingPageViewControllerDelegate
extension OnboardingViewController {
    @objc private func didTapContinueButton() {
        switch currentPage {
        case .control:
            pageViewController.setViewControllers([second], direction: .forward, animated: true)
            currentPage = .ideas
            firstCircleView.backgroundColor = .white.withAlphaComponent(0.3)
            secondCircleView.backgroundColor = UIColor(hex: "#225CEE")
        case .ideas:
            if isIdea {
                pageViewController.setViewControllers([third], direction: .forward, animated: true)
                circleStackView.isHidden = true
                currentPage = .manage
            } else {
                UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")

                let meetingVC = MeetingsViewController()
                meetingVC.modalPresentationStyle = .fullScreen
                present(meetingVC, animated: true, completion: nil)
            }
        case .manage:
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            AppActions.shared.openWebPage()
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pagesViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        return pagesViewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pagesViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        return pagesViewControllers[index + 1]
    }
}

extension UIViewController {
    func addChildController(_ childViewController: UIViewController, inside containerView: UIView?) {
        childViewController.willMove(toParent: self)
        containerView?.addSubview(childViewController.view)

        addChild(childViewController)

        childViewController.didMove(toParent: self)
    }
}
