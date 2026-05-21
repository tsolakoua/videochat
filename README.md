# Simple iOS Videochat App

A simple iOS videochat app built with Vonage Video APIs.

**Features**
- Connect to a session
- Leave a session
- Toggle microphone on/off
- Toggle camera on/off

---

## How to run the app 

### Step 1. Create a Vonage Account and get your credentials

- Sign up at [Vonage](https://developer.vonage.com/en/home) and create a new app. Then copy your **App ID**.
- Open the [Playground](https://tools.vonage.com/video/playground), start a session, and copy the **Session ID** and **Token**.

[Check out this guide](https://developer.vonage.com/en/tutorials/basic-video-chat/step-3/swift) for a detailed explanation of how you can create the account and get your **App ID**, **Session ID** and **Token**.

### Step 2. Clone the Repo

```bash
git clone https://github.com/tsolakoua/videochat
```

### Step 3. Install the Vonage Video API iOS SDK in Xcode

Add the Vonage Video API iOS SDK by adding the `https://github.com/opentok/vonage-client-sdk-video.git` repository as a Swift Package Dependency.

To add a dependency in your Xcode project, go to **File** > **Swift Packages** > **Add Package Dependency** and enter its repository URL.

### Step 4. Configure Secrets in Xcode

Secret keys are not committed to the repo. You'll need to create a local config file manually.

**Create `Secrets.xcconfig`** in the project root and add:

```xcconfig
APP_ID = your-app-id
SESSION_ID = your-session-id
SESSION_TOKEN = your-token
```

**Attach it to your build configurations**

1. Click the **project** in the Xcode navigator.
2. Go to **Info** > **Configurations**.
3. Expand **Debug** and **Release** and assign `Secrets.xcconfig` to your app target in both.

**Add the keys to Target Properties**

1. Click your **app target** > **Info** tab.
2. Under **Custom iOS Target Properties**, click **+** and add:

| Key | Type | Value |
|---|---|---|
| `APP_ID` | String | `$(APP_ID)` |
| `SESSION_ID` | String | `$(SESSION_ID)` |
| `SESSION_TOKEN` | String | `$(SESSION_TOKEN)` |

### Step 5. Build and run the app
Choose the simulator and run it.
