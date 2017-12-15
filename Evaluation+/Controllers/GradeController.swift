//--- Biblioteques du code
import UIKit
import Foundation

//--- Class viewController et les declarations du code
class GradeController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //--- Constant user defaults
    let userDefaultsObj = UserDefaultsManager()
    
    //--- Outlet qui va lier à tableView, textField, label,
    @IBOutlet weak var gradeField: UITextField!
    @IBOutlet weak var courseField: UITextField!
    @IBOutlet weak var student_name_label: UILabel!
    @IBOutlet weak var course_grade_tableview: UITableView!
    @IBOutlet weak var average: UILabel!
    
    //--- typealias qui va renommer les types de variables.
    typealias studentName = String
    typealias courseName = String
    typealias gradeCourse = Double
    
    //--- Section de tableau de dictionaires studentGrades et tableau arrayOfCourse et arrayOfGrades.
    var studentGrades: [studentName: [courseName: gradeCourse]]!
    var arrayOfCourse: [courseName]!
    var arrayOfGrades: [gradeCourse]!
    
    //--- Section viewDidLoad qui appellera les fonctions du code.
    override func viewDidLoad() {
        super.viewDidLoad()
        student_name_label.text = userDefaultsObj.getValue(theKey: "name") as? String
        loadUserDefaults()
        fillUpArray()
        average.text = consulterAverage(dictionnaireNotes: moyenneNotes(), ruleOfThree:{ $0 * 100.0 / $1})
    }
    
    //--- Fonction tableview qui indique à la source de données de renvoyer le nombre de lignes dans une section donnée d'une vue de table. Retourne à arrayOfCourse.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfCourse.count
    }
    
    //--- Fonction qui demande la source de données pour une cellule à insérer dans un emplacement particulier de la vue de table.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = course_grade_tableview.dequeueReusableCell(withIdentifier: "proto")!
        if let aCourse = cell.viewWithTag(100) as! UILabel! {
            aCourse.text = arrayOfCourse[indexPath.row]
        }
        if let aGrade = cell.viewWithTag(101) as! UILabel! {
            aGrade.text = String(arrayOfGrades[indexPath.row])
        }
        return cell
    }
    
    //--- Fonction pour effacer la cell du tableView. Le contrôle d'édition utilisé par une cellule.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let name = student_name_label.text
            var courses_and_grades = studentGrades[name!]!
            let note = [courseName](courses_and_grades.keys)[indexPath.row]
            courses_and_grades[note] = nil
            studentGrades[name!] = courses_and_grades
            userDefaultsObj.setKey(theValue: studentGrades as AnyObject, theKey: "gradeCourse")
            fillUpArray()
            average.text = consulterAverage(dictionnaireNotes: moyenneNotes(), ruleOfThree:{ $0 * 100.0 / $1})
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    //--- Fonction qui remplit la table avec les informations saisies par l'utilisateur.
    func fillUpArray() {
        let name = student_name_label.text
        let courses_and_grades = studentGrades[name!]
        arrayOfCourse = [courseName](courses_and_grades!.keys)
        arrayOfGrades = [gradeCourse](courses_and_grades!.values)
    }
    
    //--- Function pour garder les informations
    func loadUserDefaults() {
        if userDefaultsObj.doesKeyExist(theKey: "gradeCourse") {
            studentGrades = userDefaultsObj.getValue(theKey: "gradeCourse") as! [studentName: [courseName: gradeCourse]]
        } else {
            studentGrades = [studentName: [courseName: gradeCourse]]()
        }
    }
    //--- Bounton pour ajouter les informations disciplines et notes d'élève.
    @IBAction func addCourseAndGrade(_ sender: UIButton) {
        let name = student_name_label.text!
        var student_courses = studentGrades[name]!
        student_courses[courseField.text!] = gradeCourse(gradeField.text!)
        studentGrades[name] = student_courses
        userDefaultsObj.setKey(theValue: studentGrades as AnyObject, theKey: "gradeCourse")
        fillUpArray()
        course_grade_tableview.reloadData()
        average.text = consulterAverage(dictionnaireNotes: moyenneNotes(), ruleOfThree: { $0 * 100.0 / $1 })
    }
    
    //--- Fonction qui calcule les notes et les moyennes des étudiants chaque fois qu'ils sont entrés par l'utilisateur.
    func averageNotes(tableauDeNotes: [Double], moyenne: (_ sum: Double, _ nombreDeNotes: Double) -> Double) -> Double {
        let somme = tableauDeNotes.reduce(0, +)
        let resultat = moyenne(somme, Double(tableauDeNotes.count))
        return resultat
    }
    // Consulte la moynne
    func consulterAverage(dictionnaireNotes: [Double: Double], ruleOfThree: (_ somme: Double, _ sur: Double) -> Double) -> String{
        let sommeNotes = [Double](dictionnaireNotes.keys).reduce(0, +)
        let sommeSur = [Double](dictionnaireNotes.values).reduce(0, +)
        let conversion = ruleOfThree(sommeNotes, sommeSur)
        let stringToReturn = String(format: "%0.1f/%0.1f or %0.1f/100", Float(sommeNotes), Float(sommeSur), Float(conversion))
        if stringToReturn == "nan/10.0 or nan/100" {
            return ""
        }
        return stringToReturn
    }
    // Calcule la moyenne
    func moyenneNotes() ->  [Double: Double] {
        let average = arrayOfGrades.reduce(0, +)
        let somme = arrayOfGrades.count
        let moyenneNotes = Double(average/Double(somme))
        let dictionnaireGrades = [moyenneNotes: 10.0]
        return dictionnaireGrades
    }
    //------ Fonction pour déclencher l'activité de retour du clavier.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    //----
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
//----
