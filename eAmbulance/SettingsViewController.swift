import UIKit

class SettingsViewController: UITableViewController {
    
    private let sections = ["Hesab", "Bildirişlər", "Əlaqə"]
    private let items = [
        ["Hesab Detalları", "Şifrəni Dəyiş", "Çıxış Et"],
        ["Bildirişləri Aktiv Et", "Səsli Bildirişlər", "Xəbərlər"],
        ["Bizimlə Əlaqə", "Yardım Mərkəzi", "Əlaqə Forması"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ayarlar"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.section][indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.section][indexPath.row]
        
        switch selectedItem {
        case "Hesab Detalları":
            // Hesab detallarını göstər
            print("Hesab Detalları seçildi")
        case "Şifrəni Dəyiş":
            // Şifrəni dəyişmək üçün yönləndir
            print("Şifrəni Dəyiş seçildi")
        case "Çıxış Et":
            // Çıxış etmək üçün yönləndir
            print("Çıxış Et seçildi")
        case "Bildirişləri Aktiv Et":
            // Bildirişləri aktiv etmək
            print("Bildirişlər Aktiv Et seçildi")
        case "Səsli Bildirişlər":
            // Səsli bildirişləri aktiv etmək
            print("Səsli Bildirişlər seçildi")
        case "Xəbərlər":
            // Xəbərləri göstərmək
            print("Xəbərlər seçildi")
        case "Bizimlə Əlaqə":
            // Əlaqə forması
            print("Bizimlə Əlaqə seçildi")
        case "Yardım Mərkəzi":
            // Yardım mərkəzinə keçid
            print("Yardım Mərkəzi seçildi")
        case "Əlaqə Forması":
            // Əlaqə forması
            print("Əlaqə Forması seçildi")
        default:
            break
        }
    }
}


