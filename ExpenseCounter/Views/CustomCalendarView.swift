//
//  CustomCalendarView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import SwiftUI

struct CustomCalendarView: View {
    @Binding var showCalendar: Bool
    @Binding var date: Date
    @State var currentDate: Date
    @State var selectedDate: Date
    let customCalendarViewModel = CustomCalendarViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("\(currentDate.formatted(.dateTime.year()))")
                    .foregroundStyle(.black)
                Spacer()
                CurrentDateView(currentDate: $currentDate, customCalendarViewModel: customCalendarViewModel)
            }
            .padding([.leading, .trailing, .bottom])

            
            MonthGridView(currentDate: $currentDate, selectedDate: $selectedDate, date: $date, customCalendarViewModel: customCalendarViewModel)

            Button("Done") {
                showCalendar = false
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

struct CurrentDateView: View {
    @Binding var currentDate: Date
    var customCalendarViewModel: CustomCalendarViewModel
    
    var body: some View {
        HStack(spacing: 30) {
            Button(action: {
                if let newDate = customCalendarViewModel.decrementYear(date: currentDate) {
                    currentDate = newDate
                }
            }, label: {
                Image(systemName: "chevron.left")
            })
            
            Button(action: {
                if let newDate = customCalendarViewModel.incrementYear(date: currentDate) {
                    currentDate = newDate
                }
            }, label: {
                Image(systemName: "chevron.right")
            })
        }
        .font(.title2)
    }
}

struct MonthGridView: View {
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()),
        GridItem(.flexible()), GridItem(.flexible())
    ]
    @Binding var currentDate: Date
    @Binding var selectedDate: Date
    @Binding var date: Date
    let customCalendarViewModel: CustomCalendarViewModel
    let calendar = Calendar.current
    let months = Calendar.current.monthSymbols
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(0..<12, id: \.self) { index in
                let monthDate = customCalendarViewModel.dateFrom(year: calendar.component(.year, from: currentDate), month: index + 1)
                let isDisabled = customCalendarViewModel.isMonthOutOfBounds(from: monthDate)
                
                let isSelected = customCalendarViewModel.sameMonthAndYear(selectedDate, monthDate)
                
                Text(months[index])
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .foregroundStyle(isDisabled ? Color.gray : Color.black)
                    .monthOverlay(isSelected: isSelected, isDisabled: isDisabled)
                    .onTapGesture {
                        if !isDisabled,
                           let newDate = customCalendarViewModel.updateMonth(
                               date: selectedDate,
                               newMonth: index + 1,
                               newYear: calendar.component(.year, from: currentDate)
                           ) {
                            selectedDate = newDate
                            date = newDate
                        }
                    }
                    .disabled(isDisabled)
            }
            .padding(.vertical)
        }
        .padding(.horizontal)
    }
}

struct MonthOverlayModifier: ViewModifier {
    let isSelected: Bool
    let isDisabled: Bool

    func body(content: Content) -> some View {
        if isDisabled {
            content
        } else {
            content.overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.white, lineWidth: 1)
            )
        }
    }
}
extension View {
    func monthOverlay(isSelected: Bool, isDisabled: Bool) -> some View {
        self.modifier(MonthOverlayModifier(isSelected: isSelected, isDisabled: isDisabled))
    }
}
