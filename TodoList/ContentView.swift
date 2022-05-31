//
//  ContentView.swift
//  TodoList
//
//  Created by 母智超 on 2022/5/30.
//


//属性装饰器 @State, @Binding, @ObservedObject, @EnvironmentObject
/*
 @State
 通过使用 @State 装饰器我们可以关联出 View 的状态. SwiftUI 将会把使用过 @State 修饰器的属性存储到一个特殊的内存区域，并且这个区域和 View struct 是隔离的. 当 @State 装饰过的属性发生了变化，SwiftUI 会根据新的属性值重新创建视图
 */

/*
 @Binding
 有时候我们会把一个视图的属性传至子节点中，但是又不能直接的传递给子节点，因为在 Swift 中值的传递形式是值类型传递方式，也就是传递给子节点的是一个拷贝过的值。但是通过 @Binding 修饰器修饰后，属性变成了一个引用类型，传递变成了引用传递，这样父子视图的状态就能关联起来了。
 */

/*
 @ObservedObject
 @ObservedObject 的用处和 @State 非常相似，从名字看来它是来修饰一个对象的，这个对象可以给多个独立的 View 使用。如果你用 @ObservedObject 来修饰一个对象，那么那个对象必须要实现 ObservableObject 协议，然后用 @Published 修饰对象里属性，表示这个属性是需要被 SwiftUI 监听的
 */

/*
 @EnvironmentObject
 从名字上可以看出，这个修饰器是针对全局环境的。通过它，我们可以避免在初始 View 时创建 ObservableObject, 而是从环境中获取 ObservableObject
 */

import SwiftUI

func initUserData () -> [SingleTodo] {
    var output: [SingleTodo] = []
    if let dataStored = UserDefaults.standard.object(forKey: "ToDoList") as? Data {
        //[SingleTodo].self SingleTodo数组类型
        let data = try! decoder.decode([SingleTodo].self, from: dataStored)
        for item in data {
            if !item.deleted {
                output.append(SingleTodo(title: item.title, duedata: item.duedata, isChecked: item.isChecked, id: output.count))
            }
        }
    }
    return output
}

struct ContentView: View {

    @ObservedObject var UserData: Todo = Todo(data: initUserData())

    @State var showEditingPage = false
    
    @State var isEditingMode = false
    
    @State var selection: [Int] = []

    var body: some View {
        
        ZStack {
            NavigationView {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        ForEach(self.UserData.TodoList) {item in
                            if !item.deleted {
                                SingleCarView(index: item.id, isEditingMode: self.$isEditingMode, selection: self.$selection)
                                    .environmentObject(self.UserData)
                                    .padding(.top)
                                    .animation(.spring(), value: 1)
                                    .transition(.slide)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            .navigationBarTitle("提醒事项")
            .navigationBarItems(trailing:
                HStack {
                    if self.isEditingMode {
                        DeleteButton(selection: self.$selection)
                            .environmentObject(self.UserData)
                    }
                    EditingButton(isEditingMode: self.$isEditingMode, selection:self.$selection)
                })
            }
            
            //底部按钮
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Button {
                        self.showEditingPage = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable() //改变大小
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80)
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: self.$showEditingPage) {
                        EditingPage()
                            .environmentObject(self.UserData)
                    }
                }
            }
        }
    }
}

struct EditingButton: View {
    
    //@Binding 不能也不需要初始化
    @Binding var isEditingMode: Bool
    @Binding var selection: [Int]

    var body: some View {
        Button {
            self.isEditingMode.toggle()
            self.selection.removeAll()
        } label: {
            Image(systemName: "gear")
                .imageScale(.large)
        }
    }
}

struct DeleteButton: View {
        
    @Binding var selection: [Int]
    @EnvironmentObject var UserData: Todo

    var body: some View {
        Button {
            for i in selection {
                self.UserData.delete(id: i)
            }
        } label: {
            Image(systemName: "trash")
                .imageScale(.large)
        }
    }
}

struct SingleCarView: View {
    
    @EnvironmentObject var UserData: Todo
    var index: Int
    
    @State var showEditingPage = false
    @Binding var isEditingMode: Bool
    @Binding var selection: [Int]

    var body: some View {
        //HStack 水平方向显示
        //VStack 垂直方向显示
        //ZStack 垂直于屏幕的Z轴方向显示
        HStack {
            Rectangle() //创建矩形
                .frame(width: 6)
                .foregroundColor(.blue)
            
            //删除按钮
            if self.isEditingMode {
                Button  {
                    self.UserData.delete(id: self.index)
                } label: {
                    Image(systemName: "trash")
                        .imageScale(.large)
                        .padding(.leading)
                }
            }
            
            //添加按钮
            Button {
                if !self.isEditingMode {
                    self.showEditingPage = true
                }
            } label: {
                Group {
                    VStack(alignment: .leading, spacing: 8, content: {
                        Text(self.UserData.TodoList[index].title)
                            .font(.headline) //字体 加粗
                            .fontWeight(.heavy) //字重 加粗
                            .foregroundColor(.black)
                        Text(self.UserData.TodoList[index].duedata.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    })
                        .padding(.leading)
                    
                    Spacer() //占位view 将上面Rectangle、VStack挤到左边
                }
            }
            .sheet(isPresented: self.$showEditingPage) {
                EditingPage(title: self.UserData.TodoList[self.index].title,
                            duedate: self.UserData.TodoList[self.index].duedata,
                            id: self.index)
                    .environmentObject(self.UserData)
            }
            
            //选择框
            if !self.isEditingMode {
                Image(systemName: self.UserData.TodoList[index].isChecked ? "checkmark.square.fill" : "square")
                    .imageScale(.large)
                    .padding(.trailing)
                    .onTapGesture { //点击事件
                        self.UserData.check(id: self.index)
                    }
            } else {
                Image(systemName: self.selection.firstIndex(where: {$0 == self.index}) == nil ? "circle" : "checkmark.circle.fill")
                    .imageScale(.large)
                    .padding(.trailing)
                    .onTapGesture {
                        //在selection中寻找index 有返回ture
                        if self.selection.firstIndex(where: {
                            $0 == self.index
                        }) == nil {
                            self.selection.append(self.index)
                        }
                        else {
                            self.selection.remove(at: self.selection.firstIndex(where: {
                                $0 == self.index
                            })!)
                        }
                    }
            }
        }
        .frame(height: 80)
        .background(Color.white)
        .cornerRadius(10) //必须先设置背景再切圆角
        .shadow(radius: 10, x: 0, y: 10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(UserData: Todo(data: [SingleTodo(title: "写作业", duedata: Date()),
                                          SingleTodo(title: "复习", duedata: Date())]
                                  )
                    )
    }
}
