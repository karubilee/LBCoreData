//
//  ViewController.swift
//  LBCoreDataDemo
//
//  Created by liweibin on 2018/02/27.
//  Copyright © 2018年 liweibin. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let db = DataBase.shared
    var people: [NSManagedObject] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let result = selectAll() {
            people = result
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func add(_ sender: Any) {
        let alert = UIAlertController(title: "添加姓名", message: "请输入一个名字", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "保存", style: .default) { (action :UIAlertAction!) in
            let textField = alert.textFields![0] as UITextField
            self.saveName(text: textField.text!)
            let indexPath = IndexPath(row: self.people.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action: UIAlertAction) in
            
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { (textField: UITextField) in
            
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editClick(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    func selectAll() -> [Person]? {
        //步骤一: 获取总代理和托管对象总管
        let managedObjectContext = db.persistentContainer.viewContext
        //步骤二: 建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Person")
        //步骤三:执行请求
        do {
            let fetchedResults = try managedObjectContext.fetch(fetchRequest) as? [Person]
            return fetchedResults
        } catch {
            fatalError("获取失败")
        }
    }
    
    func saveName(text: String) {
        //步骤一: 获取总代理和托管对象总管
        let managedObjectContext = db.persistentContainer.viewContext
        //步骤二: 建立一个entity
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedObjectContext)
        let person = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
        //步骤三: 保存文本框中的值到person
        person.setValue(text, forKey: "name")
        //步骤四: 保存entity到托管对象中.如果失败,进行处理
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("无法保存")
        }
        //步骤五:保存到数组中,更新UI
        people.append(person)
    }
    
    func deleteName(index:Int) {
        //步骤一: 获取总代理的托管对象总管
        let managedObjectContext = db.persistentContainer.viewContext
        //步骤二: 建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        //步骤三: 执行请求
        do {
            if let fetchedResults = try managedObjectContext.fetch(fetchRequest) as? [NSManagedObject] {
                //步骤四:删除联系人
                managedObjectContext.delete(fetchedResults[index])
                try managedObjectContext.save()
                //步骤五: 更新数组
                people.remove(at: index)
                
            } else {
                print("没有符合条件的联系人")
            }
        } catch {
            fatalError("删除失败")
        }
    }
    
    func updateName(index:Int, name:String) {
        //步骤一: 获取总代理和托管对象总管
        let managedObjectContext = db.persistentContainer.viewContext
        //步骤二:建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Person")
        //步骤三:执行请求
        do {
            if let fetchedResults = try managedObjectContext.fetch(fetchRequest) as? [NSManagedObject],let person = fetchedResults[index] as? Person {
                //步骤四:修改联系人
                person.name = name
                try managedObjectContext.save()
                //步骤五:更新数组与UI
                people[index] = person
            } else {
                print("没有符合条件的联系人")
            }
        } catch {
            fatalError("修改失败")
        }
    }
    
    func moveName(sourceIndexPath: IndexPath, destinationIndexPath:IndexPath) {
        //步骤一: 获取总代理和托管对象总管
        let managedObjectContext = db.persistentContainer.viewContext
        //步骤二:建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Person")
        //步骤三:执行请求
        do {
            if var fetchedResults = try managedObjectContext.fetch(fetchRequest) as? [NSManagedObject],let person = fetchedResults[sourceIndexPath.row] as? Person {
                //步骤四 :修改联系人
                fetchedResults.remove(at: sourceIndexPath.row)
                fetchedResults.insert(person, at: destinationIndexPath.row)
                
                try managedObjectContext.save()
                //步骤五 :更新数组
                let targetPerson = people[sourceIndexPath.row]
                if let index = people.index(of: targetPerson) {
                    people.remove(at: index)
                    people.insert(targetPerson, at: destinationIndexPath.row)
                }
            }
        } catch {
            
        }
        
    }
    
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LBCell")
        
        let person = people[indexPath.row]
        cell?.textLabel?.text = person.value(forKey: "name") as? String
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        let oldName = cell?.textLabel?.text ?? ""
        
        let alert = UIAlertController(title: "修改姓名", message: "请输入一个新名字", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "保存", style: .default) { (action: UIAlertAction!) in
            let textField = alert.textFields![0] as UITextField
            var newName: String = ""
            
            if let text = textField.text, text != "" {
                newName = text
            } else {
                newName = oldName
            }
            
            self.updateName(index: indexPath.row, name: newName)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action: UIAlertAction) in
            
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = oldName
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteName(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveName(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }
    
}






























