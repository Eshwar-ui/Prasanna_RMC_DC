# Logo Integration Instructions

## Step 1: Save the Logo

Please save the Prasanna RMC logo image as:
```
c:\Users\Eswar\Desktop\PROJECTS\delivery_challan\assets\images\prasanna_rmc_logo.png
```

**Important:** 
- The file must be named exactly: `prasanna_rmc_logo.png`
- It must be in PNG format
- Save it in the `assets/images/` folder

## Step 2: Hot Reload (if app is running)

If your app is already running, press `r` in the terminal to hot reload and see the logo.

If not, just run:
```bash
flutter run -d windows
```

## Where the Logo Appears

The logo has been integrated in:
1. **Splash Screen** - Shows while app loads
2. **Login Screen** - Displays at the top of the login form
3. **PDF Documents** - Will appear in generated delivery challans (coming next update)

## Fallback

If the logo file is not found, the app will show a truck icon instead (so the app won't crash).

## Next Steps

After saving the logo, you can also customize:
- Logo size in each screen
- Logo color/tint
- Add company tagline below logo

