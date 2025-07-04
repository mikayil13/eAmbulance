//
//  HelpSupportViewController.swift
//  eAmbulance
//
//  Created by Mikayil on 25.06.25.
//

import UIKit

  class  HelpSupportViewController: UIViewController {
      
          private let scrollView = UIScrollView()
          private let contentStackView = UIStackView()

      private var faqData: [(String, String)] = [
             ("Ambulans çağırmaq üçün nə etməliyəm?",
              "Tətbiqi açın və əsas ekrandakı “Ambulans çağır” düyməsinə toxunun. Tətbiq avtomatik olaraq yerinizi təyin edəcək və ən yaxın təcili yardım xidmətinə çağırış göndərəcək."),
             ("Ambulans neçə dəqiqəyə gələcək?",
              "Ambulansın gəlmə müddəti yerləşdiyiniz əraziyə, yol vəziyyətinə və xidmətin yüklənməsinə görə dəyişə bilər. Orta hesabla 10-15 dəqiqə ərzində gəlməsi gözlənilir."),
             ("Ambulansı səhvən çağırmışamsa, nə \netməliyəm?",
              "Əgər səhvən çağırış etmisinizsə, dərhal Təcili Yardım Xidmətinə zəng edərək vəziyyəti izah edin və çağırışı ləğv etdiyinizi bildirin."),
             ("Nə üçün tətbiq GPS icazəsi istəyir?",
              "Tətbiq sizin yerinizi avtomatik təyin edərək ən yaxın təcili yardım xidmətini çağırmaq üçün GPS məlumatına ehtiyac duyur."),
             ("Tətbiq işləmirsə, nə etməliyəm?",
              "Tətbiqi bağlayıb yenidən açın. Əgər problem davam edirsə, cihazınızın internet bağlantısını yoxlayın və ya tətbiqi silib yenidən quraşdırın. Hələ də işləmirsə, dəstək emailinə müraciət edin.")
         ]


          private var expandedFAQIndex: Int?

          override func viewDidLoad() {
              super.viewDidLoad()
              view.backgroundColor = .systemGroupedBackground
              setupScrollView()
              setupSOSCard()
              setupFAQSection()
              setupContactSection()
          }

          private func setupScrollView() {
              view.addSubview(scrollView)
              scrollView.translatesAutoresizingMaskIntoConstraints = false
              NSLayoutConstraint.activate([
                  scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                  scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                  scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                  scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
              ])

              scrollView.addSubview(contentStackView)
              contentStackView.axis = .vertical
              contentStackView.spacing = 16
              contentStackView.translatesAutoresizingMaskIntoConstraints = false
              NSLayoutConstraint.activate([
                  contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
                  contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
                  contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
                  contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                  contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
              ])
          }

          private func setupSOSCard() {
              let container = UIView()
              container.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
              container.layer.cornerRadius = 12
              container.layer.borderWidth = 1
              container.layer.borderColor = UIColor.systemRed.cgColor

              let title = UILabel()
              title.text = "Təcili hal"
              title.font = UIFont.boldSystemFont(ofSize: 16)
              title.textColor = .systemRed

              let subtitle = UILabel()
              subtitle.text = "Həyati təhlükəsi varsa tətbiqdəki SOS düyməsinə basın"
              subtitle.font = UIFont.systemFont(ofSize: 14)
              subtitle.textColor = .systemRed
              subtitle.numberOfLines = 0

              let vStack = UIStackView(arrangedSubviews: [title, subtitle])
              vStack.axis = .vertical
              vStack.spacing = 4

              container.addSubview(vStack)
              vStack.translatesAutoresizingMaskIntoConstraints = false
              NSLayoutConstraint.activate([
                  vStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
                  vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
                  vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                  vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
              ])

              contentStackView.addArrangedSubview(container)
          }

          private func setupFAQSection() {
              let faqTitle = UILabel()
              faqTitle.text = "Tez-tez verilən suallar"
              faqTitle.font = UIFont.boldSystemFont(ofSize: 18)
              contentStackView.addArrangedSubview(faqTitle)

              for (index, item) in faqData.enumerated() {
                  let card = createFAQCard(index: index, question: item.0, answer: item.1)
                  contentStackView.addArrangedSubview(card)
              }
          }

          private func createFAQCard(index: Int, question: String, answer: String) -> UIView {
              let container = UIView()
              container.backgroundColor = .white
              container.layer.cornerRadius = 12
              container.layer.borderWidth = 1
              container.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
              container.tag = index

              let questionLabel = UILabel()
              questionLabel.text = question
              questionLabel.font = UIFont.systemFont(ofSize: 15)
              questionLabel.numberOfLines = 0

              let arrow = UIImageView(image: UIImage(systemName: expandedFAQIndex == index ? "chevron.up" : "chevron.down"))
              arrow.tintColor = .gray

              let topRow = UIStackView(arrangedSubviews: [questionLabel, arrow])
              topRow.axis = .horizontal
              topRow.alignment = .center
              topRow.distribution = .equalSpacing

              let answerLabel = UILabel()
              answerLabel.text = answer
              answerLabel.font = UIFont.systemFont(ofSize: 14)
              answerLabel.textColor = .darkGray
              answerLabel.numberOfLines = 0
              answerLabel.isHidden = expandedFAQIndex != index

              let fullStack = UIStackView(arrangedSubviews: [topRow, answerLabel])
              fullStack.axis = .vertical
              fullStack.spacing = 8
              fullStack.isLayoutMarginsRelativeArrangement = true
              fullStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

              container.addSubview(fullStack)
              fullStack.translatesAutoresizingMaskIntoConstraints = false
              NSLayoutConstraint.activate([
                  fullStack.topAnchor.constraint(equalTo: container.topAnchor),
                  fullStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                  fullStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                  fullStack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
              ])

              let tap = UITapGestureRecognizer(target: self, action: #selector(faqTapped(_:)))
              container.addGestureRecognizer(tap)

              return container
          }

          @objc private func faqTapped(_ sender: UITapGestureRecognizer) {
              guard let index = sender.view?.tag else { return }
              expandedFAQIndex = (expandedFAQIndex == index) ? nil : index
              contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
              setupSOSCard()
              setupFAQSection()
              setupContactSection()
          }

          private func setupContactSection() {
              let title = UILabel()
              title.text = "Sürətli əlaqə"
              title.font = UIFont.boldSystemFont(ofSize: 18)
              contentStackView.addArrangedSubview(title)

              contentStackView.addArrangedSubview(createContactCard(title: "Email", subtitle: "support@e-health.gov.az\nBir neçə saat ərzində cavab", icon: "paperplane"))
              contentStackView.addArrangedSubview(createContactCard(title: "Telefon", subtitle: "814 qısa nömrəsi\n7/24 açıq", icon: "phone"))
              contentStackView.addArrangedSubview(createContactCard(title: "Website", subtitle: "https://e-health.gov.az", icon: "globe"))
          }

          private func createContactCard(title: String, subtitle: String, icon: String) -> UIView {
              let container = UIView()
              container.backgroundColor = UIColor(red: 75/255, green: 117/255, blue: 233/255, alpha: 0.03)
              container.layer.cornerRadius = 12
              container.layer.borderWidth = 1
              container.layer.borderColor = UIColor.systemBlue.cgColor

              let titleLabel = UILabel()
              titleLabel.text = title
              titleLabel.font = UIFont.boldSystemFont(ofSize: 15)

              let subtitleLabel = UILabel()
              subtitleLabel.text = subtitle
              subtitleLabel.font = UIFont.systemFont(ofSize: 14)
              subtitleLabel.textColor = .darkGray
              subtitleLabel.numberOfLines = 0

              let iconView = UIImageView(image: UIImage(systemName: icon))
              iconView.tintColor = .systemBlue

              let hStack = UIStackView(arrangedSubviews: [titleLabel, iconView])
              hStack.axis = .horizontal
              hStack.distribution = .equalSpacing

              let vStack = UIStackView(arrangedSubviews: [hStack, subtitleLabel])
              vStack.axis = .vertical
              vStack.spacing = 4
              vStack.isLayoutMarginsRelativeArrangement = true
              vStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

              container.addSubview(vStack)
              vStack.translatesAutoresizingMaskIntoConstraints = false
              NSLayoutConstraint.activate([
                  vStack.topAnchor.constraint(equalTo: container.topAnchor),
                  vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                  vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                  vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
              ])

              return container
          }
      }
