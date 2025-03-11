# Reachu Demo App

A demo iOS application showcasing integration with Reachu.io GraphQL API and a livestream platform API.

## Features

- **Home Feed**: Browse articles with categories and trending content
- **Livestreams**: View and join live streaming sessions
- **Clean Architecture**: MVVM pattern with clear separation of concerns
- **Reusable Components**: Modular UI components for consistent design

## Project Structure

```
reachudemo/
├── Models/
│   ├── Article.swift
│   └── (Other model files)
├── Views/
│   ├── HomeView.swift
│   ├── LivestreamView.swift
│   ├── MainTabView.swift
│   └── (Other view files)
├── ViewModels/
│   ├── ArticleViewModel.swift
│   ├── LivestreamViewModel.swift
│   └── (Other viewmodel files)
├── Components/
│   ├── FeaturedArticlesView.swift
│   ├── CategoryCard.swift
│   ├── TrendingArticleRow.swift
│   └── (Other component files)
├── Services/
│   ├── NetworkService.swift
│   ├── ReachuService.swift
│   ├── LivestreamService.swift
│   └── (Other service files)
└── Utils/
    └── (Utility files)
```

## API Integration

The app is designed to work with two main APIs:

1. **Reachu.io GraphQL API**: For fetching articles, categories, and other content
2. **Livestream Platform API**: For accessing and joining live streaming sessions

## Getting Started

1. Clone the repository
2. Open `reachudemo.xcodeproj` in Xcode
3. Update the API keys in `ReachuService.swift` and `LivestreamService.swift`
4. Build and run the project

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Future Enhancements

- User authentication
- Commenting system
- Offline support
- Push notifications for live events 