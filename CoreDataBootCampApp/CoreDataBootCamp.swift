//
//  CoreDataBootCamp.swift
//  CoreDataBootCampApp
//
//  Created by Rajesh Mani on 24/10/23.
//

import SwiftUI
import CoreData

// 3 Entities
// BusinessEntity
// DepartmentEntity
// EmployeeEntity


class CoreDataManager {
    static let instance = CoreDataManager() //Singleton
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init(){
        container = NSPersistentContainer(name: "CoreDataBootCampApp")
        container.loadPersistentStores{(description, error) in
            if let error = error {
                print("Error loading core data \(error)")
            }
        }
        context = container.viewContext
    }
    
    func save() {
        do {
            try context.save()
            print("Saved sucessfully!")
        } catch let error {
            print("Error saving core date, \(error.localizedDescription)")
        }
    }
}
class CoreDataRelationshipViewModel:ObservableObject {
    let manager = CoreDataManager.instance
    @Published var businesses:[BusinessEntity] = []
    @Published var depaertments:[DepartmentEntity] = []
    @Published var employees:[EmployeeEntity] = []

    init(){
        getBusinesses()
        getDepartments()
        getEmployees()
    }
    func getBusinesses(){
        let request = NSFetchRequest<BusinessEntity>(entityName: "BusinessEntity")
        do {
            businesses = try manager.context.fetch(request)
        } catch let error {
            print("Error fetching\(error.localizedDescription)")
        }
        }
    func getDepartments(){
        let request = NSFetchRequest<DepartmentEntity>(entityName: "DepartmentEntity")
        do {
            depaertments = try manager.context.fetch(request)
        } catch let error {
            print("Error fetching\(error.localizedDescription)")
        }
        }
    func getEmployees(){
        let request = NSFetchRequest<EmployeeEntity>(entityName: "EmployeeEntity")
        do {
            employees = try manager.context.fetch(request)
        } catch let error {
            print("Error fetching\(error.localizedDescription)")
        }
        }

    func addBusiness(){
        let newBusiness = BusinessEntity(context: manager.context)
        newBusiness.name = "FACEBOOK"
//        newBusiness.addToEmployees(employees[1])
//        newBusiness.departments = [depaertments[0], depaertments[1]]
        //newBusiness.employees = []
        //newBusiness.addToDepartments(<#T##value: DepartmentEntity##DepartmentEntity#>)
        //newBusiness.addToEmployees(<#T##value: EmployeeEntity##EmployeeEntity#>)
        
        save()
    }
    
    func addDepartment(){
        let newDepartment = DepartmentEntity(context: manager.context)
        newDepartment.name = "Finance"
//        newDepartment.employees = [employees[1]]
        newDepartment.businesses = [businesses[0], businesses[1], businesses[2]]
        newDepartment.addToEmployees(employees[1])
        save()
    }
    func addEmployee(name: String, age: String, date: Date){
        let newEmployee = EmployeeEntity(context: manager.context)
        newEmployee.name = "Nisha"
        newEmployee.age = Int16(age) ?? 0
        newEmployee.dateJoined = date
//        newEmployee.business = businesses[0]
//        newEmployee.department = depaertments[0]
        save()
    }

    func save(){
        businesses.removeAll()
        depaertments.removeAll()
        employees.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.manager.save()
            self.getBusinesses()
            self.getDepartments()
            self.getEmployees()
        })
    }
}
struct CoreDataBootCamp: View {
    @StateObject var vm = CoreDataRelationshipViewModel()
    @State private var employeeName:String = ""
    @State private var age:String = ""
    @State private var dateOfJoining: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ButtonWithAction(title: "AddBusiness", action: {
                        vm.addBusiness()
                    })
                    ButtonWithAction(title: "AddDepartment", action: {
                        vm.addDepartment()
                    })
                    VStack {
                        TextField(text: $employeeName, label: {
                            Text("Employee Name")
                        })
                        TextField(text: $age, label: {
                            Text("Employee Age")
                        })
                        TextField(text: $dateOfJoining, label: {
                            Text("Employee Joining Date")
                        })
//                        ButtonWithAction(title: "AddEmployee", action: {
//                            vm.addEmployee(name: employeeName, age: age, date: dateOfJoining)
//                        })
                    }
                    ScrollView(.horizontal, showsIndicators: true, content: {
                        HStack(alignment: .top) {
                            ForEach(vm.businesses) { business in
                                BusinessView(entity: business)
                            }
                        }
                        
                    })
                    
                    ScrollView(.horizontal, showsIndicators: true, content: {
                        HStack(alignment: .top) {
                            ForEach(vm.depaertments) { department in
                                DepartmentView(entity: department)
                            }
                        }
                        
                    })
                    
                    ScrollView(.horizontal, showsIndicators: true, content: {
                        HStack(alignment: .top) {
                            ForEach(vm.employees) { employee in
                                EmployeeView(entity: employee)
                            }
                        }
                        
                    })


                }
                .padding()
            }
            .navigationTitle("Relationships")
        }
    }
}

#Preview {
    CoreDataBootCamp()
}
@ViewBuilder
func ButtonWithAction(title: String, action:@escaping () -> ()) -> some View {
    Button(action: {
        action()
    }, label: {
        Text(title)
            .foregroundColor(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color.blue.cornerRadius(10))
    })
}

struct BusinessView: View {
    let entity:BusinessEntity
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Nane: \(entity.name ?? "")")
                .bold()
            if let departments = entity.departments?.allObjects as? [DepartmentEntity] {
                 Text("Departments:")
                    .bold()
                
                ForEach(departments) { department in
                    Text(department.name ?? "")
                }
            }
            
            if let employees = entity.employees?.allObjects as? [EmployeeEntity] {
                Text("Employees:")
                    .bold()
                ForEach(employees) {employee in
                    Text(employee.name ?? "")
                }
            }
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.gray.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct DepartmentView: View {
    let entity:DepartmentEntity
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Name: \(entity.name ?? "")")
                .bold()
            if let businesses = entity.businesses?.allObjects as? [BusinessEntity] {
                 Text("Businesses:")
                    .bold()
                
                ForEach(businesses) { businesses in
                    Text(businesses.name ?? "")
                }
            }
            
            if let employees = entity.employees?.allObjects as? [EmployeeEntity] {
                Text("Employees:")
                    .bold()
                ForEach(employees) {employee in
                    Text(employee.name ?? "")
                }
            }
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.green.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct EmployeeView: View {
    let entity:EmployeeEntity
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            Text("Name: \(entity.name ?? "")")
                .bold()
            Text("Age: \(entity.age)")
            Text("Date Joined: \(entity.dateJoined?.formatted(date: .numeric, time: .shortened) ?? "")")
            Text("Business:")
                .bold()
            Text(entity.business?.name ?? "")
            Text("Department:")
                .bold()
            Text(entity.department?.name ?? "")
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.blue.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}
