# Weather-Forecast
A Flutter web application fetches weather data from **WeatherAPI**, allows users to search weather by city or country, displays current and forecasted weather, stores the most recent search temporarily, allowing users to revisit it., and offers a subscription feature for daily weather forecast emails with confirmation.

---

## 🛠 Tech Stack
- **Language**: Flutter (Dart)  
- **Fonts**: [Rubik](https://fonts.google.com/specimen/Rubik) (Google Fonts)  
- **API**: [WeatherAPI](https://www.weatherapi.com) (Free version)  
- **Database**: Firestore (store subscription information)  
- **Email Service**: SendGrid (daily weather emails with confirmation)  
- **State Management**: Cubit  
- **Deployment**: Firebase Hosting  
- **Programming Paradigm**: OOP (Object-Oriented Programming)  
- **Form Validation**: Validates email input for subscriptions  

---

## ⚙️ Prerequisites
To run the project locally, ensure you have:
- Flutter SDK (v3.x or later)  
- Dart  
- Firebase CLI (for deployment)  
- A **WeatherAPI key** ([Sign up here](https://www.weatherapi.com))  
- A **SendGrid API key** ([Sign up here](https://sendgrid.com))  
- A Firebase project with **Firestore** and **Hosting** enabled  

---

## 🚀 Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/minhgaa/Weather

2. **Install Dependencies**
   ```bash
   flutter pub get
3. **Configure API Keys**
   ```bash
   WEATHER_API_KEY=your_weatherapi_key_here
   SENDGRID_API_KEY=your_sendgrid_api_key_here
4. **Run Locally**
   ```bash
   flutter run -d chrome

## 🎥 Demo

Live Demo: https://weatherapp-0101.web.app

## 📬 Contact

For issues or questions, open an issue on this repository or contact the developer:
[bminh.cv@gmail.com]
