//
//  GameMenuViewController.swift
//  iOS_UnlimitedCatWorld-swift
//
//  Created by Phil on 2025/5/3.
//

import UIKit
import SpriteKit

class GameMenuViewController: UIViewController {

    @IBOutlet weak var touchMultiImage: UIImageView!
    @IBOutlet weak var zoneImage: UIImageView!
    @IBOutlet weak var BladeImage: UIImageView!
    @IBOutlet weak var touchBtn: UIButton!
    @IBOutlet weak var touchMultiBtn: UIButton!
    @IBOutlet weak var zoneBtn: UIButton!
    @IBOutlet weak var bladeBtn: UIButton!
    @IBOutlet weak var gameTimeLabel: UILabel!

    weak var gameDelegate: GameDelegate?
    var gameType: Int = 0
    var gameScore: Int64 = 0
    weak var scene: MyScene?

    private let backgroundLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupModernUI()
    }

    private func setupModernUI() {
        hideLegacySubviews()

        view.backgroundColor = UIColor(red: 0.98, green: 0.47, blue: 0.08, alpha: 1.0)

        backgroundLayer.colors = [
            UIColor(red: 0.98, green: 0.47, blue: 0.08, alpha: 1.0).cgColor,
            UIColor(red: 0.98, green: 0.26, blue: 0.35, alpha: 1.0).cgColor
        ]
        backgroundLayer.startPoint = CGPoint(x: 0.1, y: 0.0)
        backgroundLayer.endPoint = CGPoint(x: 0.9, y: 1.0)
        backgroundLayer.frame = view.bounds
        view.layer.insertSublayer(backgroundLayer, at: 0)

        let topBar = UIView()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)

        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        backButton.addTarget(self, action: #selector(handleBackTap), for: .touchUpInside)
        topBar.addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Clear Mode"
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 22)
        topBar.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topBar.heightAnchor.constraint(equalToConstant: 44),

            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
        ])

        let gridStack = UIStackView()
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        gridStack.axis = .vertical
        gridStack.spacing = 16
        gridStack.alignment = .fill
        gridStack.distribution = .fillEqually
        view.addSubview(gridStack)

        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = 16
        row1.alignment = .fill
        row1.distribution = .fillEqually

        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 16
        row2.alignment = .fill
        row2.distribution = .fillEqually

        gridStack.addArrangedSubview(row1)
        gridStack.addArrangedSubview(row2)

        NSLayoutConstraint.activate([
            gridStack.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 24),
            gridStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            gridStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            gridStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            gridStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55)
        ])

        let touchCard = buildModeCard(
            titleKey: "touchMode",
            imageName: "touch_btn",
            unlockScore: 0,
            modeValue: TouchClear,
            action: #selector(handleTouchMode)
        )

        let multiCard = buildModeCard(
            titleKey: "touchMultiMode",
            imageName: "touch_multi_btn",
            unlockScore: UnlockTouchMultiClear,
            modeValue: TouchMultiClear,
            action: #selector(handleTouchMultiMode)
        )

        let zoneCard = buildModeCard(
            titleKey: "zoneMode",
            imageName: "zone_btn",
            unlockScore: UnlockZoneClear,
            modeValue: ZoneClear,
            action: #selector(handleZoneMode)
        )

        let bladeCard = buildModeCard(
            titleKey: "bladeMode",
            imageName: "blade_btn",
            unlockScore: UnlockBladeClear,
            modeValue: BladeClear,
            action: #selector(handleBladeMode)
        )

        row1.addArrangedSubview(touchCard)
        row1.addArrangedSubview(multiCard)
        row2.addArrangedSubview(zoneCard)
        row2.addArrangedSubview(bladeCard)
    }

    private func buildModeCard(titleKey: String, imageName: String, unlockScore: Int64, modeValue: Int, action: Selector) -> UIControl {
        let isLocked = !DebugUnlockAllModes && gameScore < unlockScore
        let isSelected = gameType == modeValue

        let card = UIButton(type: .custom)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = isSelected ? UIColor(red: 0.20, green: 0.18, blue: 0.22, alpha: 1.0) : UIColor.white.withAlphaComponent(0.92)
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.12
        card.layer.shadowOffset = CGSize(width: 0, height: 10)
        card.layer.shadowRadius = 18
        card.adjustsImageWhenHighlighted = false
        card.layer.borderWidth = isSelected ? 2 : 0
        card.layer.borderColor = isSelected ? UIColor.white.withAlphaComponent(0.85).cgColor : UIColor.clear.cgColor

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.isUserInteractionEnabled = false

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: isLocked ? "question_mark_horizental_btn" : imageName)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = isSelected ? .white : UIColor(red: 0.20, green: 0.16, blue: 0.16, alpha: 1.0)
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.text = NSLocalizedString(titleKey, comment: "")

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textColor = isSelected ? UIColor.white.withAlphaComponent(0.7) : UIColor(red: 0.35, green: 0.33, blue: 0.34, alpha: 1.0)
        subtitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 12)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2

        if isLocked {
            subtitleLabel.text = String(format: "%d %@", Int(unlockScore), NSLocalizedString("modeUnlock", comment: ""))
            card.alpha = 0.7
        } else {
            subtitleLabel.text = ""
        }

        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)

        card.addSubview(stack)

        if isSelected {
            let badge = UILabel()
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.text = "Selected"
            badge.textColor = .white
            badge.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
            badge.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            badge.textAlignment = .center
            badge.layer.cornerRadius = 10
            badge.layer.masksToBounds = true
            card.addSubview(badge)

            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = UIColor.white
            dot.layer.cornerRadius = 4
            card.addSubview(dot)

            NSLayoutConstraint.activate([
                badge.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
                badge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
                badge.heightAnchor.constraint(equalToConstant: 20),
                badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),

                dot.widthAnchor.constraint(equalToConstant: 8),
                dot.heightAnchor.constraint(equalToConstant: 8),
                dot.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
                dot.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
            ])
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -16),

            imageView.heightAnchor.constraint(equalToConstant: 64),
            imageView.widthAnchor.constraint(equalToConstant: 64)
        ])

        if !isLocked {
            card.addTarget(self, action: action, for: .touchUpInside)
        }

        return card
    }

    private func hideLegacySubviews() {
        for subview in view.subviews {
            subview.isHidden = true
        }

        let legacyViews: [UIView?] = [
            touchMultiImage,
            zoneImage,
            BladeImage,
            touchBtn,
            touchMultiBtn,
            zoneBtn,
            bladeBtn,
            gameTimeLabel
        ]
        for view in legacyViews {
            view?.isHidden = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundLayer.frame = view.bounds
    }

    @objc private func handleBackTap() {
        backClick(self)
    }

    @objc private func handleTouchMode() {
        changeToTouchClick(self)
    }

    @objc private func handleTouchMultiMode() {
        changeToTouchMultiClick(self)
    }

    @objc private func handleZoneMode() {
        changeToZoneClick(self)
    }

    @objc private func handleBladeMode() {
        changeToBladeClick(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // This IBAction was in the Obj-C implementation but not the header
    @IBAction func restartClick(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            self?.gameDelegate?.restartGame()
        }
    }

    @IBAction func changeToTouchClick(_ sender: Any) {
        scene?.setClearType(TouchClear)
        backClick(self)
    }

    @IBAction func changeToTouchMultiClick(_ sender: Any) {
        if !DebugUnlockAllModes && gameScore < UnlockTouchMultiClear { return }
        scene?.setClearType(TouchMultiClear)
        backClick(self)
    }

    @IBAction func changeToZoneClick(_ sender: Any) {
        if !DebugUnlockAllModes && gameScore < UnlockZoneClear { return }
        scene?.setClearType(ZoneClear)
        backClick(self)
    }

    @IBAction func changeToBladeClick(_ sender: Any) {
        if !DebugUnlockAllModes && gameScore < UnlockBladeClear { return }
        scene?.setClearType(BladeClear)
        backClick(self)
    }

    @IBAction func backClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
