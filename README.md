# GigaCharge

Have you ever been stuck waiting for an electric car charging port? Many people take a “set and forget” approach to charging their E-car. Leaving a phone number on your dash can lead to privacy issues and the potential for private information leaks. Say goodbye to the past with GigaCharge!

GigaCharge is a proof-of-concept mobile application designed to streamline the electric car charging experience by enabling private messaging, parking spot swapping, and real-time charging station tracking.

## Key Features
- **Private Messaging**: Contact other drivers securely using a personalized QR code displayed on your dashboard.
- **Incentive System**: Earn points for swapping parking spots and redeem them for rewards like gift cards, charging time, or leaderboard ranking.
- **Real-Time Maps**: View available charging spots and manage queues efficiently.
- **Community Engagement**: Built for the University of Hawaii (UH) community, fostering collaboration and coordination among electric vehicle users.

## What is GigaCharge?

GigaCharge is an innovative proof-of-concept mobile application designed to make electric vehicle charging more efficient and community-driven. With GigaCharge, users can:

- **Connect Privately**: Use a personalized QR code placed on your dashboard to enable a private messaging system with other drivers, eliminating the need to share personal information.
- **Earn and Redeem Points**: Gain points for swapping parking spots as an incentive to move your car when it’s fully charged. Redeem points for gift cards, additional charging time, or climb your way to the top of the leaderboard.
- **Real-Time Map**: View available charging spots in real time, so you know where to park next.
- **Join the Queue**: Save your place in the swapping chain and manage your turn efficiently.

## Additional Resources

For a detailed write-up on GigaCharge, [click here to view the PDF](./GigaCharge%20WhitePaper.pdf).

## Development

This project is built using Flutter and follows best practices for state management. To set up and start using GigaCharge:

1. Clone the repository.
2. Run `flutter pub get` to fetch dependencies.
3. Use `flutter run` to launch the app on an emulator or a connected device.

For more information on Flutter development, check out the [official documentation](https://docs.flutter.dev).

## Assets

The `assets` directory contains all the resources used in the app:
- **Images**: Resolution-aware images for UI elements are located in `assets/images`.
- **Localization Files**: ARB files for multi-language support are located in `lib/src/localization`.

To learn more about handling assets, refer to [Flutter's asset documentation](https://flutter.dev/to/resolution-aware-images).

## Localization

This project supports localization to deliver a personalized user experience. To add support for new languages:
1. Add the appropriate ARB files in `lib/src/localization`.
2. Follow [Flutter's internationalization guide](https://flutter.dev/to/internationalization) to integrate them into the app.

---

Thank you for supporting GigaCharge! Let's drive the future of electric vehicle charging coordination together.
