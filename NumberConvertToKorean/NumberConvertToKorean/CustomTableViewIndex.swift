//
//  CustomTableViewIndex.swift
//  NumberConvertToKorean
//
//  Created by 정해영 on 2020/05/14.
//  Copyright © 2020 sunzero. All rights reserved.
//

import UIKit
/// CustomTableViewIndex
/// titles 에 원하는 Key 또는 image file명을 넣으면 자동으로 분류한다
/// 기존 tableView dataSource 는 section기반으로 돌아가기때문에 section을 구분하지 않을 경우 쓸수 없다.
/// 그래서 원하는 IndexPath를 지정해줘야함
/// 테이블뷰 데이터가 변경될때마다 update(titles:) 함수를 호출해줘서 최신 인데스 위치로 업데이트 해야함
///
/// 사용예시
/*
    var index = CustomTableViewIndex()
 
    override func viewDidLoad() {
        super.viewDidLoad()

        let titles = [
            "search":IndexPath(row: 0, section: 0),
            "ㄱ":IndexPath(row: 1, section: 0),
            "ㄴ":IndexPath(row: 10, section: 0),
            "ㄷ":IndexPath(row: 20, section: 0),
            "ㄹ":IndexPath(row: 30, section: 0),
            "ㅁ":IndexPath(row: 40, section: 0),
            "ㅂ":IndexPath(row: 50, section: 0),
            "ㅅ":IndexPath(row: 60, section: 0),
            "ㅇ":IndexPath(row: 70, section: 0)
        ]
        
        index.setTitles(titles, tableView: tableView)
        index.inset.top = 100
        index.inset.bottom = 100
        index.inset.right = 10
        index.width = 30
        index.contentInset.top = 10
        index.contentInset.bottom = 10
        index.spacing = 20
        index.fontSize = 20
        index.fontColor = .yellow
        index.backgroundColor = .lightGray
        index.layer.cornerRadius = 10
        index.layer.masksToBounds = true
    }
 */
final class CustomTableViewIndex: UIView {

    var inset: UIEdgeInsets = .zero {
        didSet {
            topConstraint?.constant = inset.top
            bottomConstraint?.constant = -inset.bottom
            trailingConstraint?.constant = -inset.right
        }
    }
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            containerTopConstraint?.constant = contentInset.top
            containerBottomConstraint?.constant = -contentInset.bottom
            containerleadingConstraint?.constant = contentInset.left
            containerTrailingConstraint?.constant = -contentInset.right
        }
    }
    
    var width: CGFloat = 30 {
        didSet {
            widthConstraint?.constant = width
        }
    }
    var fontSize: CGFloat = 12 {
        didSet {
            updateContainer()
        }
    }
    var fontColor: UIColor = .black {
        didSet {
             updateContainer()
        }
    }
    var spacing: CGFloat = 8 {
        didSet {
            continerStackView.spacing = spacing
        }
    }
    
    weak var tableView: UITableView?
    private var continerStackView = UIStackView()
    private var titles: [String: IndexPath] = [:]
    
    private var widthConstraint : NSLayoutConstraint?
    private var topConstraint : NSLayoutConstraint?
    private var bottomConstraint : NSLayoutConstraint?
    private var trailingConstraint : NSLayoutConstraint?
    
    private var containerTopConstraint : NSLayoutConstraint?
    private var containerBottomConstraint : NSLayoutConstraint?
    private var containerleadingConstraint : NSLayoutConstraint?
    private var containerTrailingConstraint : NSLayoutConstraint?
    

    func setTitles(_ titles: [String: IndexPath], tableView: UITableView) {
       
        if self.tableView == nil {
            setup(tableView: tableView)
        }
        
        update(titles)
    }

    func update(_ titles: [String: IndexPath]) {
        self.titles = titles
        
        continerStackView.removeAllArrangedSubviews()
        addTitileButtons()
    }
    
    
    private func setup(tableView: UITableView) {
        self.tableView = tableView
        /// 1. initIndex 인데스를 tableView 의 부모뷰에 추가
        /// 2. initContinerStackView 타이틀을 가지고 있을 컨테이너를 인데스에 추가
        /// 3. initPanGesture  팬 제스쳐를 추가
        initIndex()
        initContinerStackView()
        initPanGesture()
    }
    
    private func initIndex() {
        guard let tableView = tableView, let superView = tableView.superview else { return }
        superView.addSubview(self)

        self.translatesAutoresizingMaskIntoConstraints = false
        widthConstraint = widthAnchor.constraint(equalToConstant: width)
        widthConstraint?.isActive = true
        topConstraint = topAnchor.constraint(equalTo: tableView.topAnchor, constant: inset.top)
        topConstraint?.isActive = true
        bottomConstraint = bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -inset.bottom)
        bottomConstraint?.isActive = true
        trailingConstraint = trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -inset.right)
        trailingConstraint?.isActive = true
        
    }
    
    private func initContinerStackView() {
        addSubview(continerStackView)
        continerStackView.translatesAutoresizingMaskIntoConstraints = false
        continerStackView.axis = .vertical
        continerStackView.spacing = spacing
        continerStackView.alignment = .fill
        continerStackView.distribution = .fillEqually
        
        
        containerTopConstraint = continerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        containerTopConstraint?.isActive = true
        containerBottomConstraint = continerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        containerBottomConstraint?.isActive = true
        containerleadingConstraint = continerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        containerleadingConstraint?.isActive = true
        containerTrailingConstraint = continerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        containerTrailingConstraint?.isActive = true
        
    }
    
    private func initPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        addGestureRecognizer(pan)
    }

    
    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        
        let position = gesture.location(in: continerStackView)
        
        switch gesture.state {
        case .changed:
            for view in continerStackView.subviews {
                let point = CGPoint(x: 0, y: position.y)
                if view.frame.contains(point), let button = view as? UIButton  {
                    scrollToRow(by: button)
                    break
                }
            }
            
        default:
            break
        }
    }
    

    
    private func addTitileButtons() {
        let titleTexts = titles.sorted { (prev, next) -> Bool in
            prev.value.compare(next.value) == .orderedAscending
        }
          
        titleTexts.forEach {
            let button = UIButton(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 30, height: 30)))
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(indexerScroll(button:)), for: .allTouchEvents)
            button.accessibilityIdentifier = $0
            
            if let titleImage = UIImage(named: $0) {
                button.contentHorizontalAlignment = .fill
                button.contentVerticalAlignment = .fill
                button.imageView?.contentMode = .scaleAspectFit
                button.setImage(titleImage, for: .normal)
                
            } else {
                button.setTitle($0, for: .normal)
                button.setTitleColor(fontColor, for: .normal)
                
                let font = UIFont(name: button.titleLabel?.font.fontName ?? "", size: fontSize)
                button.titleLabel?.font = font
            }
            
            
            button.tag = $1.row
            continerStackView.addArrangedSubview(button)
        }

    }
    
    private func updateContainer() {
        for view in continerStackView.subviews {
            guard let button = view as? UIButton else { return }
            
            button.setTitleColor(fontColor, for: .normal)
            let font = UIFont(name: button.titleLabel?.font.fontName ?? "", size: fontSize)
            button.titleLabel?.font = font
        }
    }
    
    @objc func indexerScroll(button: UIButton) {
      scrollToRow(by: button)
    }
    
    func scrollToRow(by button: UIButton) {
        guard let title = button.accessibilityIdentifier, let indexPath = titles[title] else { return }
        tableView?.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
}

extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
            NSLayoutConstraint.deactivate($0.constraints)
            $0.removeFromSuperview()
        }
    }
}

