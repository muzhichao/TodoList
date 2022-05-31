//
//  UserData.swift
//  TodoList
//
//  Created by 母智超 on 2022/5/30.
//

import Foundation

var encoder = JSONEncoder()
var decoder = JSONDecoder()

//ObservableObject 协议
//默认情况下，合成器将在其任何属性更改之前发出更改后的值的发布程序。
class Todo: ObservableObject {
    
    @Published var TodoList: [SingleTodo]
    var count = 0
    
    //初始化空数组
    init() {
        self.TodoList = []
    }
    
    //用已有数据数组 去初始化
    init(data: [SingleTodo]) {
        self.TodoList = []
        for item in data {
            self.TodoList.append(SingleTodo(title: item.title, duedata: item.duedata, isChecked: item.isChecked, id: self.count))
            count += 1
        }
    }
    
    //通过id改变获取SingleTodo并改变isChecked
    func check(id: Int) {
        self.TodoList[id].isChecked.toggle() //BOOL类型切换
        
        self.dataStore()
    }
    
    func add(data: SingleTodo) {
        self.TodoList.append(SingleTodo(title: data.title, duedata: data.duedata, id: self.count))
        self.count += 1
        
        self.sort()
        
        self.dataStore()
    }
    
    func edit(id: Int, data: SingleTodo) {
        self.TodoList[id].title = data.title
        self.TodoList[id].duedata = data.duedata
        self.TodoList[id].isChecked = false
        
        self.sort()
        
        self.dataStore()
    }
    
    func delete(id: Int) {
        self.TodoList[id].deleted = true
        
        self.sort()
        
        self.dataStore()
    }
    
    func sort() {
        self.TodoList.sort(by: {(date1, date2) in
            return date1.duedata.timeIntervalSince1970 < date2.duedata.timeIntervalSince1970
        })
        for i in 0..<self.TodoList.count {
            self.TodoList[i].id = i
        }
    }
    
    func dataStore() {
        let dataStored = try! encoder.encode(self.TodoList)
        UserDefaults.standard.set(dataStored, forKey: "ToDoList")
    }
}

//Identifiable 可变式协议 需要id
struct SingleTodo: Identifiable, Codable {
    
    var title: String = ""
    var duedata: Date = Date()
    var isChecked: Bool = false
    
    var deleted = false
    
    var id: Int = 0
}
