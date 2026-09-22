
<div align="center">

<br/>

# Vector

### From Vision to Victory.

**The fastest way to find your hackathon team.**

Browse hackathons — discover open teams — connect through requests and invitations — build together.

<br/>

![Flutter](https://img.shields.io/badge/Flutter-3.13%2B-F0A860?style=for-the-badge&logo=flutter&logoColor=white&labelColor=4A3457)
![Dart](https://img.shields.io/badge/Dart-Language-F0A860?style=for-the-badge&logo=dart&logoColor=white&labelColor=4A3457)
![Supabase](https://img.shields.io/badge/Supabase-Backend-F0A860?style=for-the-badge&logo=supabase&logoColor=white&labelColor=4A3457)

![iOS](https://img.shields.io/badge/iOS-supported-F0A860?style=flat-square&logo=apple&logoColor=white&labelColor=4A3457)
![Android](https://img.shields.io/badge/Android-supported-F0A860?style=flat-square&logo=android&logoColor=white&labelColor=4A3457)
![Web](https://img.shields.io/badge/Web-supported-F0A860?style=flat-square&logo=googlechrome&logoColor=white&labelColor=4A3457)
![Made in Saudi Arabia](https://img.shields.io/badge/Made_in-Saudi_Arabia-F0A860?style=flat-square&labelColor=4A3457)

<br/>

*The final project of **Tuwaiq Academy**'s Flutter & Dart Bootcamp.*

</div>

<br/>

---

## 🎬 Demo


<div align="center">



https://github.com/user-attachments/assets/862592c9-7e34-4c48-a99c-9f183468c67a






</div>

---

## 📖 The Story

We lived this problem ourselves. Every hackathon began the same way: capable people searching for a team, strong teams missing one essential skill, and valuable hours lost before the real work could even begin.

Vector was born from that frustration — built on a simple conviction: **if finding your team is the hardest part of a hackathon, it should become the easiest.**

The name carries the idea. In mathematics, a vector holds both magnitude and direction — what you bring, and where you're going. A team works the same way: individual strengths, pointed toward a shared purpose.

> **Vision** — every hackathon and every open team, in one place.
> **Victory** — walk in with your team already formed.

---

## ✨ Features

| | |
|---|---|
| **Hackathon Discovery** | Browse hackathons by field and explore every team competing in each one |
| **Join Requests** | Request to join teams that need your skills, and track the status of every request |
| **Invitations** | Receive, accept, decline, or withdraw team invitations in a single tap |
| **Team Builder** | Create your own team — set its size, define the roles you need, and let people come to you |
| **Verified Profiles** | Email-verified signup via a custom-designed confirmation link and verification page, a curated skills showcase, and certificate uploads stored securely |
| **Integrity by Design** | Uploaded certificates are hashed, eliminating duplicate files at the source |

## 🎨 Design & Details

Vector pays attention to the details that are usually skipped.
- **Instantly reactive** — the app reflects every action in real time: create a team and it appears immediately, accept an invitation and your status updates on the spot — no refresh, no waiting
- **Custom brand loader** — the "V" mark is drawn stroke-by-stroke as a custom animation, used at launch, login, and signup, with a smaller overlay version for long-running operations
- **No dead loading states** — lists load behind skeleton shimmer placeholders, and write actions show progress inside the button itself
- **Custom motion** — animated splash, a flip-style team carousel, and a hand-built bottom navigation bar
- **Centralized design system** — zero inline colors in the codebase; every color, text style, and theme value comes from design tokens (`VectorColors`, `VectorText`, `VectorTheme`)
- **Security in the details** — OTP email verification, credentials kept out of the codebase via `.env`, and certificate uploads hashed to block duplicates at the source

---

## 📱 Screenshots

<div align="center">

<table>
  <tr>
    <th align="center">Splash</th>
    <th align="center">Log In</th>
    <th align="center">Sign Up</th>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/splash.png" width="250" alt="Splash"/></td>

<td align="center"><img src="https://github.com/user-attachments/assets/1d7c18c6-a69b-452d-bf48-b62326e84a0c" width="250" alt="Log In"/></td>
    <td align="center"><img src="screenshots/signup.png" width="250" alt="Sign Up"/></td>
  </tr>
  <tr>
    <th align="center">Home — Hackathons</th>
    <th align="center">Team Details</th>
    <th align="center">Invites</th>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/home.png" width="250" alt="Home — Hackathons"/></td>
    <td align="center"><img src="screenshots/team.png" width="250" alt="Team Details"/></td>
    <td align="center"><img src="screenshots/invites.png" width="250" alt="Invites"/></td>
  </tr>
  <tr>
    <th align="center">Profile</th>
    <th align="center">Settings</th>
    <th align="center">About Us</th>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/profile.png" width="250" alt="Profile"/></td>
    <td align="center"><img src="screenshots/settings.png" width="250" alt="Settings"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/9d123897-c35c-4537-8c6a-0ea2b140afae" width="250" alt="About Us"/></td>
  </tr>
</table>

</div>

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter / Dart (SDK ^3.13.1) — a single codebase for iOS, Android, and Web |
| Backend | Supabase — Postgres, Auth with OTP email verification, and Storage, via `supabase_flutter` |
| Configuration | `flutter_dotenv` — credentials stay out of the codebase |
| Files | `file_selector` — certificate selection and upload |
| Typography | `google_fonts` |
| Integrity | `crypto` — file hashing to prevent duplicate uploads |

## 📂 Project Structure

```
lib/
├── main.dart       # Entry point — initializes Supabase and launches the app
├── screens/        # Splash, auth, home, teams, invites, profile, create team, navigation shell
├── data/           # Supabase-backed repositories with a graceful mock fallback
├── models/         # Hackathon · Team · Member · Invitation · SentRequest
├── services/       # Authentication, account creation, certificate upload, sign out
├── widgets/        # Brand loader, skeleton loaders, cards, dialogs, shared UI
└── theme/          # Design tokens — VectorColors, VectorText, VectorTheme
```

## 🚀 Running Vector

Vector runs out of the box — no configuration needed. The app ships with a built-in mock data layer, so every screen and flow works immediately after `flutter pub get`.

To connect a live backend, add a `.env` file with your Supabase credentials. Authentication, live data, and storage activate automatically — no code changes required.

---

## 👥 Team

<div align="center">

| | |
|:---:|:---:|
| **Sham Albinni** | **Fatimah Bin Mohammed** |
| Computer Science | Information Technology |

*Two students. Different universities. One shared direction.*

</div>

<br/>

<div align="center">

**Vector — From Vision to Victory.**

*Crafted with passion 🤍*

</div>

