//
//  HealthRiskScoreView.swift
//  DocHyve Patient
//

import UIKit

enum HealthRiskLevel: Int {
    case low = 0
    case moderate = 1
    case high = 2
    
    var title: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        }
    }
    
    var color: UIColor {
        switch self {
        case .low: return HealthRiskScoreView.Colors.low
        case .moderate: return HealthRiskScoreView.Colors.moderate
        case .high: return HealthRiskScoreView.Colors.high
        }
    }
    
    var defaultProgress: CGFloat {
        switch self {
        case .low: return 1.0 / 6.0
        case .moderate: return 0.5
        case .high: return 5.0 / 6.0
        }
    }
}

final class HealthRiskScoreView: UIView {
    
    enum Colors {
        static let low = UIColor(red: 0.30, green: 0.82, blue: 0.58, alpha: 1)
        static let moderate = UIColor(red: 0.95, green: 0.68, blue: 0.25, alpha: 1)
        static let high = UIColor(red: 0.93, green: 0.38, blue: 0.38, alpha: 1)
        static let needle = UIColor(red: 0.16, green: 0.22, blue: 0.36, alpha: 1)
        static let title = UIColor(red: 0.48, green: 0.50, blue: 0.55, alpha: 1)
        static let badge = UIColor(red: 0.45, green: 0.76, blue: 0.55, alpha: 1)
        static let tipBG = UIColor(red: 0.94, green: 0.95, blue: 0.96, alpha: 1)
        static let tipText = UIColor(red: 0.42, green: 0.44, blue: 0.48, alpha: 1)
        static let subtext = UIColor(red: 0.62, green: 0.64, blue: 0.68, alpha: 1)
        static let pillBG = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)
        static let cardBG = UIColor.white
    }
    
    /// Used by HealthCheckVC to size the table header without layout loops.
    static let preferredHeight: CGFloat = 410
    
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let badgeLabel = PaddingLabel()
    private let gaugeView = HealthRiskGaugeView()
    private let riskLabel = UILabel()
    private let scoreLabel = UILabel()
    private let estimateLabel = UILabel()
    private let legendStack = UIStackView()
    private let tipContainer = UIView()
    private let tipLabel = UILabel()
    
    private var legendPills: [LegendPillView] = []
    private var currentLevel: HealthRiskLevel = .moderate
    private var currentProgress: CGFloat = 0.5
    private var currentZones: [HealthRiskGaugeZone] = []
    private var gaugeMin: Double = 0
    private var gaugeMax: Double = 100
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Self.preferredHeight)
    }
    
    /// Apply API response to meter UI.
    func configure(with data: HealthRiskScoreData, badgeText: String = "Updated today", animated: Bool = true) {
        currentLevel = data.riskLevel
        currentProgress = data.needleProgress
        gaugeMin = data.gauge.min
        gaugeMax = data.gauge.max
        currentZones = data.gauge.zones
        
        badgeLabel.text = badgeText
        riskLabel.text = data.displayRiskTitle
        riskLabel.textColor = data.riskUIColor
        scoreLabel.text = data.scoreDisplayText
        scoreLabel.textColor = data.riskUIColor
        estimateLabel.text = data.estimateText
        tipLabel.text = data.tipText
        
        if currentZones.count >= 3 {
            rebuildLegend(from: currentZones)
            updateLegendSelection(level: currentLevel, zones: currentZones)
            gaugeView.setZones(currentZones, minValue: gaugeMin, maxValue: gaugeMax)
        } else {
            updateLegendSelection(currentLevel)
            gaugeView.setDefaultZones()
        }
        
        if animated {
            gaugeView.animateNeedle(to: currentProgress)
        } else {
            gaugeView.setNeedle(progress: currentProgress, animated: false)
        }
    }
    
    func configure(
        level: HealthRiskLevel = .moderate,
        progress: CGFloat? = nil,
        badgeText: String = "Updated today",
        estimatedItemCount: Int = 21,
        tipText: String = "A few selected conditions overlap. A specialist review within the next month is recommended.",
        animated: Bool = true
    ) {
        currentLevel = level
        currentProgress = min(max(progress ?? level.defaultProgress, 0), 1)
        
        badgeLabel.text = badgeText
        riskLabel.text = level.title
        riskLabel.textColor = level.color
        scoreLabel.text = ""
        estimateLabel.text = "Estimated from \(estimatedItemCount) selected items"
        tipLabel.text = tipText
        updateLegendSelection(level)
        gaugeView.setDefaultZones()
        
        if animated {
            gaugeView.animateNeedle(to: currentProgress)
        } else {
            gaugeView.setNeedle(progress: currentProgress, animated: false)
        }
    }
    
    func playAnimation() {
        gaugeView.animateNeedle(to: currentProgress)
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        cardView.backgroundColor = Colors.cardBG
        cardView.layer.cornerRadius = 14
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = "HEALTH RISK SCORE"
        titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = Colors.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        badgeLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = Colors.badge
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 11
        badgeLabel.clipsToBounds = true
        badgeLabel.insets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        gaugeView.translatesAutoresizingMaskIntoConstraints = false
        gaugeView.setContentCompressionResistancePriority(.required, for: .vertical)
        gaugeView.setContentHuggingPriority(.required, for: .vertical)
        
        riskLabel.font = .systemFont(ofSize: 30, weight: .bold)
        riskLabel.textAlignment = .center
        riskLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scoreLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = Colors.subtext
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        estimateLabel.font = .systemFont(ofSize: 13, weight: .regular)
        estimateLabel.textColor = Colors.subtext
        estimateLabel.textAlignment = .center
        estimateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        legendStack.axis = .horizontal
        legendStack.alignment = .fill
        legendStack.distribution = .equalSpacing
        legendStack.spacing = 8
        legendStack.translatesAutoresizingMaskIntoConstraints = false
        
        tipContainer.backgroundColor = Colors.tipBG
        tipContainer.layer.cornerRadius = 10
        tipContainer.translatesAutoresizingMaskIntoConstraints = false
        
        tipLabel.font = .systemFont(ofSize: 12, weight: .regular)
        tipLabel.textColor = Colors.tipText
        tipLabel.numberOfLines = 0
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(cardView)
        tipContainer.addSubview(tipLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(badgeLabel)
        cardView.addSubview(gaugeView)
        cardView.addSubview(riskLabel)
        cardView.addSubview(scoreLabel)
        cardView.addSubview(estimateLabel)
        cardView.addSubview(legendStack)
        cardView.addSubview(tipContainer)
        
        buildLegend()
        
        let gaugeHeight = gaugeView.heightAnchor.constraint(equalToConstant: 140)
        gaugeHeight.priority = .required
        
        tipLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            
            badgeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            badgeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            badgeLabel.heightAnchor.constraint(equalToConstant: 22),
            
            gaugeView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            gaugeView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            gaugeView.widthAnchor.constraint(equalToConstant: 250),
            gaugeHeight,
            
            riskLabel.topAnchor.constraint(equalTo: gaugeView.bottomAnchor, constant: 2),
            riskLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            riskLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            scoreLabel.topAnchor.constraint(equalTo: riskLabel.bottomAnchor, constant: 2),
            scoreLabel.leadingAnchor.constraint(equalTo: riskLabel.leadingAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: riskLabel.trailingAnchor),
            
            estimateLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 4),
            estimateLabel.leadingAnchor.constraint(equalTo: riskLabel.leadingAnchor),
            estimateLabel.trailingAnchor.constraint(equalTo: riskLabel.trailingAnchor),
            
            legendStack.topAnchor.constraint(equalTo: estimateLabel.bottomAnchor, constant: 14),
            legendStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            legendStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            legendStack.heightAnchor.constraint(equalToConstant: 30),
            
            tipContainer.topAnchor.constraint(equalTo: legendStack.bottomAnchor, constant: 12),
            tipContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            tipContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            tipContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),
            
            tipLabel.topAnchor.constraint(equalTo: tipContainer.topAnchor, constant: 10),
            tipLabel.leadingAnchor.constraint(equalTo: tipContainer.leadingAnchor, constant: 12),
            tipLabel.trailingAnchor.constraint(equalTo: tipContainer.trailingAnchor, constant: -12),
            tipLabel.bottomAnchor.constraint(equalTo: tipContainer.bottomAnchor, constant: -10)
        ])
        
        configure(animated: false)
    }
    
    private func buildLegend() {
        let defaults: [(String, UIColor, HealthRiskLevel)] = [
            ("Low", Colors.low, .low),
            ("Moderate", Colors.moderate, .moderate),
            ("High", Colors.high, .high)
        ]
        legendPills.removeAll()
        legendStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in defaults {
            let pill = LegendPillView(title: item.0, color: item.1, level: item.2)
            legendPills.append(pill)
            legendStack.addArrangedSubview(pill)
        }
    }
    
    private func rebuildLegend(from zones: [HealthRiskGaugeZone]) {
        legendPills.removeAll()
        legendStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let levels: [HealthRiskLevel] = [.low, .moderate, .high]
        for (index, zone) in zones.prefix(3).enumerated() {
            let level = levels[index]
            let pill = LegendPillView(title: zone.shortLabel, color: zone.color, level: level)
            legendPills.append(pill)
            legendStack.addArrangedSubview(pill)
        }
    }
    
    private func updateLegendSelection(_ selected: HealthRiskLevel) {
        legendPills.forEach { $0.setSelected($0.level == selected) }
    }
    
    private func updateLegendSelection(level: HealthRiskLevel, zones: [HealthRiskGaugeZone]) {
        legendPills.forEach { $0.setSelected($0.level == level) }
    }
}

// MARK: - Legend pill
private final class LegendPillView: UIView {
    let level: HealthRiskLevel
    private let contentStack = UIStackView()
    private let dot = UIView()
    private let titleLabel = UILabel()
    private let accentColor: UIColor
    
    init(title: String, color: UIColor, level: HealthRiskLevel) {
        self.level = level
        self.accentColor = color
        super.init(frame: .zero)
        setup(title: title)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setSelected(_ selected: Bool) {
        backgroundColor = selected ? .white : HealthRiskScoreView.Colors.pillBG
        layer.borderWidth = selected ? 1.5 : 0
        layer.borderColor = selected ? accentColor.cgColor : UIColor.clear.cgColor
        titleLabel.textColor = selected ? accentColor : HealthRiskScoreView.Colors.title
        titleLabel.font = .systemFont(ofSize: 12, weight: selected ? .semibold : .medium)
    }
    
    private func setup(title: String) {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 15
        clipsToBounds = true
        backgroundColor = HealthRiskScoreView.Colors.pillBG
        
        dot.backgroundColor = accentColor
        dot.layer.cornerRadius = 4
        dot.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = HealthRiskScoreView.Colors.title
        
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 6
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        contentStack.addArrangedSubview(dot)
        contentStack.addArrangedSubview(titleLabel)
        addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 30),
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: - Padding label
private final class PaddingLabel: UILabel {
    var insets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
}

// MARK: - Gauge (true half-circle: green → yellow → red)
private final class HealthRiskGaugeView: UIView {
    
    private let trackWidth: CGFloat = 26
    private let lowLayer = CAShapeLayer()
    private let moderateLayer = CAShapeLayer()
    private let highLayer = CAShapeLayer()
    private let startTipLayer = CAShapeLayer()
    private let endTipLayer = CAShapeLayer()
    private let needleView = UIView()
    private let needleShape = CAShapeLayer()
    private let hubView = UIView()
    
    private var targetProgress: CGFloat = 0.5
    private var displayedProgress: CGFloat = 0
    private var isAnimatingNeedle = false
    private var pendingAnimateToTarget = false
    private var lastLayoutSize: CGSize = .zero
    private var needleDisplayLink: CADisplayLink?
    private var needleAnimStartTime: CFTimeInterval = 0
    private var needleAnimFrom: CGFloat = 0
    private var needleAnimTo: CGFloat = 0
    private let needleAnimDuration: CFTimeInterval = 1.25
    private var zoneSegments: [(start: CGFloat, end: CGFloat, color: UIColor)] = [
        (0.0, 1.0 / 3.0, HealthRiskScoreView.Colors.low),
        (1.0 / 3.0, 2.0 / 3.0, HealthRiskScoreView.Colors.moderate),
        (2.0 / 3.0, 1.0, HealthRiskScoreView.Colors.high)
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setZones(_ zones: [HealthRiskGaugeZone], minValue: Double, maxValue: Double) {
        // Visual meter uses equal thirds (design), colors from API zones.
        // Needle position still uses real score on min...max scale.
        let sorted = zones.sorted { $0.from < $1.from }
        if sorted.count >= 3 {
            zoneSegments = [
                (0.0, 1.0 / 3.0, sorted[0].color),
                (1.0 / 3.0, 2.0 / 3.0, sorted[1].color),
                (2.0 / 3.0, 1.0, sorted[2].color)
            ]
        } else if !sorted.isEmpty {
            let span = maxValue - minValue
            guard span > 0 else {
                setDefaultZones()
                return
            }
            zoneSegments = sorted.map { zone in
                let start = CGFloat((zone.from - minValue) / span)
                let end = CGFloat((zone.to - minValue) / span)
                return (Swift.min(Swift.max(start, 0), 1), Swift.min(Swift.max(end, 0), 1), zone.color)
            }
        } else {
            setDefaultZones()
            return
        }
        updateArcPaths()
    }
    
    func setDefaultZones() {
        zoneSegments = [
            (0.0, 1.0 / 3.0, HealthRiskScoreView.Colors.low),
            (1.0 / 3.0, 2.0 / 3.0, HealthRiskScoreView.Colors.moderate),
            (2.0 / 3.0, 1.0, HealthRiskScoreView.Colors.high)
        ]
        updateArcPaths()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        isOpaque = false
        clipsToBounds = false
        
        configureArcLayer(lowLayer, color: HealthRiskScoreView.Colors.low)
        configureArcLayer(moderateLayer, color: HealthRiskScoreView.Colors.moderate)
        configureArcLayer(highLayer, color: HealthRiskScoreView.Colors.high)
        
        startTipLayer.fillColor = HealthRiskScoreView.Colors.low.cgColor
        endTipLayer.fillColor = HealthRiskScoreView.Colors.high.cgColor
        
        // Tips under arcs: only soft round at green start & red end.
        [startTipLayer, endTipLayer, lowLayer, moderateLayer, highLayer].forEach {
            layer.addSublayer($0)
        }
        
        needleView.translatesAutoresizingMaskIntoConstraints = true
        needleView.backgroundColor = .clear
        addSubview(needleView)
        
        needleShape.fillColor = HealthRiskScoreView.Colors.needle.cgColor
        needleView.layer.addSublayer(needleShape)
        
        hubView.translatesAutoresizingMaskIntoConstraints = true
        hubView.backgroundColor = HealthRiskScoreView.Colors.needle
        hubView.layer.cornerRadius = 7
        hubView.bounds = CGRect(x: 0, y: 0, width: 14, height: 14)
        addSubview(hubView)
    }
    
    private func configureArcLayer(_ shape: CAShapeLayer, color: UIColor) {
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = color.cgColor
        shape.lineWidth = trackWidth
        shape.lineCap = .butt
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 1, bounds.height > 1 else { return }
        
        let sizeChanged = abs(bounds.width - lastLayoutSize.width) > 0.5
            || abs(bounds.height - lastLayoutSize.height) > 0.5
        if sizeChanged {
            lastLayoutSize = bounds.size
            updateArcPaths()
        }
        
        layoutNeedle()
        applyNeedleRotation(progress: displayedProgress)
        
        if pendingAnimateToTarget {
            startNeedleAnimationIfReady()
        }
    }
    
    func animateNeedle(to progress: CGFloat) {
        let clamped = min(max(progress, 0), 1)
        targetProgress = clamped
        pendingAnimateToTarget = true
        stopNeedleDisplayLink()
        isAnimatingNeedle = false
        
        if bounds.width > 1 {
            updateArcPaths()
            layoutNeedle()
            applyNeedleRotation(progress: displayedProgress)
            startNeedleAnimationIfReady()
        }
    }
    
    func setNeedle(progress: CGFloat, animated: Bool) {
        let clamped = min(max(progress, 0), 1)
        targetProgress = clamped
        pendingAnimateToTarget = false
        stopNeedleDisplayLink()
        
        if animated {
            beginNeedleDisplayAnimation(from: displayedProgress, to: clamped)
        } else {
            displayedProgress = clamped
            isAnimatingNeedle = false
            applyNeedleRotation(progress: clamped)
        }
    }
    
    private func startNeedleAnimationIfReady() {
        guard pendingAnimateToTarget, bounds.width > 1 else { return }
        pendingAnimateToTarget = false
        beginNeedleDisplayAnimation(from: displayedProgress, to: targetProgress)
    }
    
    private func beginNeedleDisplayAnimation(from start: CGFloat, to end: CGFloat) {
        stopNeedleDisplayLink()
        needleAnimFrom = start
        needleAnimTo = end
        needleAnimStartTime = CACurrentMediaTime()
        isAnimatingNeedle = true
        displayedProgress = start
        applyNeedleRotation(progress: start)
        
        let link = CADisplayLink(target: self, selector: #selector(handleNeedleDisplayTick))
        link.add(to: .main, forMode: .common)
        needleDisplayLink = link
    }
    
    @objc private func handleNeedleDisplayTick() {
        let elapsed = CACurrentMediaTime() - needleAnimStartTime
        let t = min(max(elapsed / needleAnimDuration, 0), 1)
        // Smooth ease-in-ease-out
        let eased = t < 0.5
            ? 2 * t * t
            : 1 - pow(-2 * t + 2, 2) / 2
        
        displayedProgress = needleAnimFrom + (needleAnimTo - needleAnimFrom) * CGFloat(eased)
        applyNeedleRotation(progress: displayedProgress)
        
        if t >= 1 {
            displayedProgress = needleAnimTo
            applyNeedleRotation(progress: displayedProgress)
            stopNeedleDisplayLink()
            isAnimatingNeedle = false
        }
    }
    
    private func stopNeedleDisplayLink() {
        needleDisplayLink?.invalidate()
        needleDisplayLink = nil
    }
    
    deinit {
        stopNeedleDisplayLink()
    }
    
    /// Pivot at the bottom of the view; half-arc opens upward (arch, not smile).
    private var gaugeCenter: CGPoint {
        CGPoint(x: bounds.midX, y: bounds.maxY - trackWidth / 2 - 4)
    }
    
    private var gaugeRadius: CGFloat {
        let byWidth = (bounds.width - trackWidth) / 2 - 4
        let byHeight = bounds.height - trackWidth - 8
        return max(min(byWidth, byHeight), 50)
    }
    
    /// Upper half-circle: left → top → right.
    /// Flat joins between colors; round tip only at green start and red end.
    private func updateArcPaths() {
        guard bounds.width > 1, bounds.height > 1 else { return }
        
        let center = gaugeCenter
        let radius = gaugeRadius
        let layers = [lowLayer, moderateLayer, highLayer]
        let overlap: CGFloat = 0.003
        
        for layer in layers {
            layer.path = nil
            layer.isHidden = true
        }
        
        let sorted = zoneSegments.sorted { $0.start < $1.start }
        
        for (index, segment) in sorted.prefix(3).enumerated() {
            let shape = layers[index]
            shape.isHidden = false
            
            var startProgress = segment.start
            var endProgress = segment.end
            if index > 0 { startProgress = max(0, startProgress - overlap) }
            if index < sorted.count - 1 { endProgress = min(1, endProgress + overlap) }
            
            guard endProgress > startProgress else { continue }
            
            let path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: angle(for: startProgress),
                endAngle: angle(for: endProgress),
                clockwise: true
            )
            shape.path = path.cgPath
            shape.lineWidth = trackWidth
            shape.lineCap = .butt
            shape.strokeColor = segment.color.cgColor
        }
        
        // Soft round tips ONLY at outer ends (green start + red end).
        let tipDiameter = trackWidth
        let tipRadius = tipDiameter / 2
        let startColor = sorted.first?.color ?? HealthRiskScoreView.Colors.low
        let endColor = sorted.last?.color ?? HealthRiskScoreView.Colors.high
        let startPoint = point(on: center, radius: radius, progress: 0)
        let endPoint = point(on: center, radius: radius, progress: 1)
        
        startTipLayer.fillColor = startColor.cgColor
        startTipLayer.path = UIBezierPath(
            ovalIn: CGRect(
                x: startPoint.x - tipRadius,
                y: startPoint.y - tipRadius,
                width: tipDiameter,
                height: tipDiameter
            )
        ).cgPath
        
        endTipLayer.fillColor = endColor.cgColor
        endTipLayer.path = UIBezierPath(
            ovalIn: CGRect(
                x: endPoint.x - tipRadius,
                y: endPoint.y - tipRadius,
                width: tipDiameter,
                height: tipDiameter
            )
        ).cgPath
    }
    
    /// 0 = left (π), 0.5 = top (3π/2), 1 = right (2π).
    private func angle(for progress: CGFloat) -> CGFloat {
        .pi + min(max(progress, 0), 1) * .pi
    }
    
    private func point(on center: CGPoint, radius: CGFloat, progress: CGFloat) -> CGPoint {
        let a = angle(for: progress)
        return CGPoint(
            x: center.x + radius * cos(a),
            y: center.y + radius * sin(a)
        )
    }
    
    private func layoutNeedle() {
        let center = gaugeCenter
        let length = max(gaugeRadius - 12, 28)
        let width: CGFloat = 4
        
        // Rebuild geometry without wipe; rotation reapplied by caller/layout.
        let current = needleView.transform
        needleView.transform = .identity
        needleView.bounds = CGRect(x: 0, y: 0, width: width, height: length)
        needleView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        needleView.center = center
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width * 0.85, y: length))
        path.addLine(to: CGPoint(x: width * 0.15, y: length))
        path.close()
        needleShape.path = path.cgPath
        needleShape.frame = needleView.bounds
        
        hubView.center = center
        needleView.transform = current
    }
    
    private func applyNeedleRotation(progress: CGFloat) {
        // Needle points up at identity.
        // progress 0 = left (-π/2), 0.5 = up (0), 1 = right (+π/2).
        let rotation = angle(for: progress) - (3 * .pi / 2)
        needleView.transform = CGAffineTransform(rotationAngle: rotation)
    }
}
