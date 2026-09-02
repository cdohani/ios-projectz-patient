//
//  OnBoardingVC.swift
//  DocHyve
//
//  Created by MeshSq on 26/06/2026.
//

import UIKit

class OnBoardingVC: UIViewController {
    
    @IBOutlet weak var imgBackGround: UIImageView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var imgOnboard: UIImageView!
    @IBOutlet weak var imgBee: UIImageView!
    @IBOutlet weak var bottomSpaceImgOnboard: NSLayoutConstraint!
    @IBOutlet weak var viewSheet: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDetail: UILabel!
    @IBOutlet weak var viewOne: UIView!
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewThree: UIView!
    
    private var currentPage = 0
    private let onboardingData: [(bg: UIImage, image: UIImage, title: String, detail: String)] = [
        (
            bg: .onboradBgOne,
            image: .onboradDetailOne,
            title: "Find the Right Doctor, Covered by Your Insurance",
            detail: " Discover trusted doctors by specialty, condition, location, and insurance-all in one place."
        ),
        (
            bg: .onboradBgTwo,
            image: .onboradDetailTwo,
            title: "Personalized Insights for Better Health",
            detail: " Get personalized health insights, preventive-care reminders, and recommendations based on your health profile."
        ),
        (
            bg: .onboradBgThree,
            image: .onboradDetailThree,
            title: "Stay Connected to the Care You Need",
            detail: " Book appointments, manage your doctors, add family members, and keep your healthcare journey organized in one place."
        )
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgBee.isHidden = true
        setupSwipeGestures()
        setupInitialUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewSheet.makeCornersRound(corners: [.topLeft, .topRight], radius: 40)
    }
    
    @IBAction func btnSkipClick() {
        moveToNextScreen()
    }
    
    @IBAction func btnNextClick() {
        if currentPage < onboardingData.count - 1 {
            goToPage(currentPage + 1, direction: .left)
        } else {
            moveToNextScreen()
        }
    }
    
    private func setupInitialUI() {
        updatePage(animated: false)
    }
    
    // MARK: - Swipe Gesture
    
    private func setupSwipeGestures() {
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left: goToPage(currentPage + 1, direction: .left)
        case .right: goToPage(currentPage - 1, direction: .right)
        default: break
        }
    }
    
    private func moveToNextScreen() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        UserDefaults.standard.isOnboardingDone = true
        appDelegate.setLandingScreen()
    }
    
    private func goToPage( _ page: Int, direction: UISwipeGestureRecognizer.Direction) {
        guard page >= 0, page < onboardingData.count, page != currentPage else { return }
        let oldPage = currentPage
        currentPage = page
        animatePageChange(from: oldPage, to: page, direction: direction)
    }
    
    // MARK: - Page Animation
    private func animatePageChange(from oldPage: Int, to newPage: Int, direction: UISwipeGestureRecognizer.Direction) {
        let data = onboardingData[newPage]
        
        // Direction
        let slideDistance: CGFloat = direction == .left ? view.bounds.width : -view.bounds.width
        
        imgOnboard.transform = CGAffineTransform(translationX: slideDistance * 0.35, y: 0)
        imgOnboard.alpha = 0
        lbDetail.transform = CGAffineTransform(translationX: slideDistance * 0.15, y: 0)
        lbDetail.alpha = 0
        lbTitle.transform = CGAffineTransform(translationX: slideDistance * 0.15, y: 0)
        lbTitle.alpha = 0
        
        // Change content
        imgOnboard.image = data.image
        imgBackGround.image = data.bg
        lbDetail.text = data.detail
        lbTitle.text = data.title
        
        // Animate image
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.88, initialSpringVelocity: 0.5, options: [.curveEaseOut]) { [weak self] in
            self?.imgOnboard.transform = .identity
            self?.imgOnboard.alpha = 1
            self?.imgBee.isHidden = (newPage != 2)
            self?.imgLogo.image = newPage == 0 ? .dochyveLogo : .dochyveLogoWhite
            self?.bottomSpaceImgOnboard.constant = (newPage == 2) ? 100 : 20
        }
        
        // Animate detail text
        UIView.animate(withDuration: 0.35, delay: 0.08, options: [.curveEaseOut]) { [weak self] in
            self?.lbDetail.transform = .identity
            self?.lbDetail.alpha = 1
            self?.lbTitle.transform = .identity
            self?.lbTitle.alpha = 1
        }
        
        // Animate page indicators
        animatePageIndicators()
        
        // Optional: animate sheet slightly
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) { [weak self] in
            self?.viewSheet.transform = CGAffineTransform(scaleX: 0.985, y: 0.985)
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.viewSheet.transform = .identity
            })
        }
    }
    
    // MARK: - Update Page
    private func updatePage(animated: Bool) {
        let data = onboardingData[currentPage]
        imgBackGround.image = data.bg
        imgOnboard.image = data.image
        lbTitle.text = data.title
        lbDetail.text = data.detail
        imgBee.isHidden = currentPage != 2
        imgLogo.image = currentPage == 0 ? .dochyveLogo : .dochyveLogoWhite
        bottomSpaceImgOnboard.constant = (currentPage == 2) ? 100 : 20
        animated ? animatePageIndicators() : updatePageIndicators()
    }
    
    // MARK: - Page Indicators
    private func animatePageIndicators() {
        let indicators = [viewOne, viewTwo, viewThree]
        for (index, indicator) in indicators.enumerated() {
            let isSelected = index == currentPage
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.4, options: [.curveEaseInOut]) { [indicator] in
                indicator?.backgroundColor = isSelected ? .customBlue : .customGrayD2D2D2
            }
        }
    }
    
    private func updatePageIndicators() {
        let indicators = [viewOne, viewTwo, viewThree]
        for (index, indicator) in indicators.enumerated() {
            let isSelected = index == currentPage
            indicator?.backgroundColor = isSelected ? .customBlue : .customGrayD2D2D2
        }
    }
    
}
