# CGPA Calculator

A Flutter app that helps university students track grades, calculate SGPA and CGPA, and plan the results they need next. Works offline with no sign-up.

## Features

- **Terms and courses:** group courses into terms (semesters or years) with credit hours.
- **Marks or direct grade:** enter assessment marks and the app works out the grade, or enter the letter grade yourself.
- **Weighted assessments:** midterm, quizzes, assignments and final exam. Several quizzes or assignments are combined fairly (7/10 and 15/20 count as 22/30).
- **Labs:** a course can have a lab with its own credit hours and marks.
- **SGPA and CGPA:** credit-weighted results per term and overall, shown on the dashboard.
- **CGPA planner:** the average GPA you need over the next 1 to 4 terms to reach a target CGPA.
- **Final exam planner:** the marks you need in the final to reach a chosen grade, with a table of every grade.
- **Custom grading:** semester or annual system, 4.0 / 10-point / custom GPA scale, adjustable weights and an editable grade table.
- **Light and dark themes** that follow the device setting.
- **Local storage:** all data stays on your device.

## Screens

| Screen | Purpose |
| --- | --- |
| Welcome | Intro and three main benefits |
| Onboarding | First-time setup: academic system, GPA scale, assessment weights |
| Home | CGPA summary and list of terms (add, rename, delete) |
| Term detail | Courses in a term, its SGPA, Add course |
| Course form | Credits, marks or direct grade, optional lab |
| Planner | Target CGPA tab and Final exam needed tab |
| Settings | Academic system, GPA scale, weights, grade table, reset |

## Defaults

- **Weights:** Midterm 25%, Quizzes 12.5%, Assignments 12.5%, Final exam 50%. Quizzes and assignments can be merged into one 25% component.
- **4.0 scale:** A 85+ = 4.0, A- 80 = 3.67, B+ 75 = 3.33, B 70 = 3.0, B- 65 = 2.67, C+ 60 = 2.33, C 55 = 2.0, D 50 = 1.0, F = 0.
- **10-point scale:** O 90+ = 10, A+ 80 = 9, A 70 = 8, B+ 60 = 7, B 55 = 6, C 50 = 5, P 40 = 4, F = 0.

All of these can be changed in Settings.

## How the maths works

- **Component marks:** total obtained divided by total available across all entries, scaled to the component weight.
- **Course grade:** total marks matched against the grade table, unless a grade was entered directly.
- **SGPA / CGPA:** grade points weighted by credit hours. Lab credits are counted separately.
- **Planner:** required average = (target x (current credits + upcoming credits) - current CGPA x current credits) / upcoming credits.
- **Final exam:** share of the final's weight needed = (target marks - marks earned so far) / final weight.

The grade logic is in `lib/core/utils/grade_calculator.dart`, a pure Dart class with no UI code, so it is easy to unit test.

## Project structure

```
lib/
  main.dart                       Entry point, theme, welcome / onboarding / home routing
  core/
    theme/app_theme.dart          Sage palette, light and dark themes
    utils/grade_calculator.dart   Grade, SGPA, CGPA and planner maths
    utils/format.dart             Number formatting
    widgets/                      Shared widgets and assessment editor
  data/
    models.dart                   Grade bands, components, courses, labs, terms
    storage_repository.dart       SQLite storage and migration from older data
  state/
    app_state.dart                App state (Provider)
  features/
    welcome/                      Welcome screen
    onboarding/                   First-time setup
    home/home_shell.dart          Bottom navigation
    dashboard/                    CGPA card and term list
    terms/                        Term detail
    courses/                      Course form
    planner/                      CGPA planner and final exam planner
    settings/                     Settings, GPA scale, grade table
```

## Tech stack

| Area | Package |
| --- | --- |
| Framework | Flutter (Dart), Material 3 |
| State management | `provider` |
| Database | `sqflite` |
| Preferences and migration | `shared_preferences` |

## Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install).
2. Create a project named `cgpa_calculator` (the code imports `package:cgpa_calculator/...`) and replace its `lib/` folder with this one:
   ```
   flutter create cgpa_calculator
   ```
3. Add the dependencies:
   ```
   flutter pub add provider sqflite shared_preferences
   ```
4. Run the app:
   ```
   flutter run
   ```

If you use a different project name, update the `package:cgpa_calculator/` imports to match.

## Roadmap ideas

- Export results as PDF or image
- Charts of GPA over time
- Unit tests for `GradeCalculator`
- Backup and restore

## License

license here.

<img width="1600" height="900" alt="calulator" src="https://github.com/user-attachments/assets/8544d19e-3cbf-4611-b441-0b3b579de8c5" />

