//
//  EditingPage.swift
//  TodoList
//
//  Created by 母智超 on 2022/5/30.
//

import SwiftUI

struct EditingPage: View {
    
    @EnvironmentObject var UserData: Todo

    @State var title: String = ""
    @State var duedate: Date = Date()

    var id: Int? = nil
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationView {
            Form {
                Section (header: Text("事项")) {
                    TextField("事项内容", text: self.$title)
                    DatePicker(selection: self.$duedate, label: { Text("截止时间") })
                }
                
                Section {
                    Button {
                        if self.id == nil {
                            self.UserData.add(data: SingleTodo(title: self.title, duedata: self.duedate))
                        } else {
                            //self.id! 强制解空
                            self.UserData.edit(id: self.id!, data: SingleTodo(title: self.title, duedata: self.duedate))
                        }
                        self.presentation.wrappedValue.dismiss()
                    } label: {
                        Text("确认")
                    }

                    Button {
                        self.presentation.wrappedValue.dismiss()
                    } label: {
                        Text("取消")
                    }
                }
            }
        .navigationBarTitle("添加")
        }

    }
}

struct EditingPage_Previews: PreviewProvider {
    static var previews: some View {
        EditingPage()
    }
}
