//
//  DateExtended.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 6/26/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import Foundation
import UIKit

class DateExtended {
    static func getDateForCollectionViewSchedule(dayOfWeekTuple: (month: String, day: Int, year: Int)) -> String {
        let day = dayOfWeekTuple.day
        let month = dayOfWeekTuple.month
        let year = dayOfWeekTuple.year
        if day < 10 {
            let dayString = "0" + String(day)
            return month + dayString + String(year)
        }
        return month + String(day) + String(year)
    }
    
    static func determineTheDayOfTheWeekNumberMonthAndYear(row: Int) -> (month: String, day: Int, year: Int) {
        var year: Int = Date().year()
        let day: Int = Date().day()
        var month: String = Date().month()
        var thisDay = day + row
        var isLeapYear = false
        //check for leapYear here
        if year % 4 == 0 && year % 100 != 0 {
            isLeapYear = true
        } else if year % 400 == 0 {
            isLeapYear = true
        }
        
        while thisDay > 31  {
            if month == "April" {
                month = "May"
                thisDay = thisDay - 30
                continue
            }
            if month == "June" {
                month = "July"
                thisDay = thisDay - 30
                continue
            }
            if month == "September" {
                month = "October"
                thisDay = thisDay - 30
                continue
            }
            if month == "November" {
                month = "December"
                thisDay = thisDay - 30
                continue
            }
            if month == "January" {
                month = "February"
                thisDay = thisDay - 31
                continue
            }
            if month == "March" {
                month = "April"
                thisDay = thisDay - 31
                continue
            }
            if month == "May" {
                month = "June"
                thisDay = thisDay - 31
                continue
            }
            if month == "July" {
                month = "August"
                thisDay = thisDay - 31
                continue
            }
            if month == "August" {
                month = "September"
                thisDay = thisDay - 31
                continue
            }
            if month == "October" {
                month = "November"
                thisDay = thisDay - 31
                continue
            }
            if month == "December" {
                month = "January"
                year = year + 1
                thisDay = thisDay - 31
                continue
            }
        }
        if month == "February" && thisDay == 29 {
            if !isLeapYear {
                month = "March"
                thisDay = 1
                return (month, thisDay, year)
            } else {
                return (month, thisDay, year)
            }
        }
        if month == "April" && thisDay == 31 {
            month = "May"
            thisDay = 1
            return (month, thisDay, year)
        }
        if month == "June" && thisDay == 31 {
            month = "July"
            thisDay = 1
            return (month, thisDay, year)
        }
        if month == "September" && thisDay == 31 {
            month = "October"
            thisDay = 1
            return (month, thisDay, year)
        }
        if month == "November" && thisDay == 31 {
            month = "December"
            thisDay = 1
            return (month, thisDay, year)
        } else if thisDay <= 31 {
            return (month, thisDay, year)
        }
        return(month, thisDay, year)
    }
}
