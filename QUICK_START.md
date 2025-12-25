# 🚀 Quick Start Guide

## Before You Start

### Step 1: Save the Logo ⚠️ IMPORTANT

Save your Prasanna RMC logo to:
```
c:\Users\Eswar\Desktop\PROJECTS\delivery_challan\assets\images\prasanna_rmc_logo.png
```

**File must be named exactly:** `prasanna_rmc_logo.png`

---

## Running the App

### First Time Setup

```bash
# 1. Navigate to project
cd "c:\Users\Eswar\Desktop\PROJECTS\delivery_challan"

# 2. Clean and get dependencies
flutter clean
flutter pub get

# 3. Run the app
flutter run -d windows
```

### Subsequent Runs

```bash
cd "c:\Users\Eswar\Desktop\PROJECTS\delivery_challan"
flutter run -d windows
```

---

## Login Credentials

```
Username: admin
Password: admin123
```

---

## Creating Your First Challan

### Required Fields (Must fill):
1. **To** - Customer name
2. **DC No** - Delivery challan number
3. **Grade** - Concrete grade (e.g., M20, M25)
4. **Grand Total** - Final amount

### Steps:
1. Login with admin credentials
2. Fill in customer details
3. Add items in the table (click "Add Row" for more)
4. Fill bottom section with totals
5. Click **"GENERATE PDF (3 Copies)"**
6. Success! PDFs saved to Documents folder

---

## Where Files Are Saved

### PDFs Location:
```
C:\Users\YourName\Documents\delivery_challan\pdfs\
```

### Database Location:
```
C:\Users\YourName\Documents\delivery_challan\delivery_challan.db
```

---

## Quick Troubleshooting

### ❌ App won't start
```bash
flutter clean
flutter pub get
flutter run -d windows
```

### ❌ Logo not showing
- Check file is saved as `prasanna_rmc_logo.png`
- Check it's in `assets/images/` folder
- Press `r` in terminal (hot reload)

### ❌ PDF generation fails
- Check all required fields filled
- Check disk space available
- Check write permissions to Documents folder

### ❌ Can't login
- Use: `admin` / `admin123`
- Check Caps Lock is off

### ❌ WhatsApp not opening
- Check WhatsApp Desktop installed
- Or use web.whatsapp.com manually

---

## Common Tasks

### Generate a Challan
1. Fill form → 2. Click Generate → 3. Done!

### Send to WhatsApp
1. Generate PDF → 2. Click "Send to WhatsApp"
3. Manually attach PDF from shown path → 4. Send

### Print a Challan
1. Generate PDF → 2. Click "Print" → 3. Select printer

### Create New Challan
After generating, click **"New Challan"** button

### Logout
Click logout icon in top-right corner

---

## File Structure

```
delivery_challan/
├── lib/
│   ├── main.dart              # App entry
│   ├── models/                # Data models
│   ├── services/              # Business logic
│   │   ├── pdf_service.dart   # PDF generation (Syncfusion)
│   │   ├── database_service.dart
│   │   └── auth_service.dart
│   └── screens/               # UI screens
│       ├── login_screen.dart
│       └── challan_form_screen.dart
├── assets/
│   └── images/
│       └── prasanna_rmc_logo.png  # ⚠️ Add this!
├── README.md                  # Full documentation
├── QUICK_START.md            # This file
├── USAGE_GUIDE.md            # Detailed usage
└── SYNCFUSION_FEATURES.md    # PDF features
```

---

## Features Checklist

✅ User authentication (login/logout)
✅ Editable form with all DC fields
✅ Dynamic table rows (add/remove)
✅ PDF generation (3 copies in A4)
✅ Company logo in PDFs
✅ Local database storage
✅ WhatsApp integration
✅ Print functionality
✅ Professional layout
✅ Desktop window management
✅ Session persistence

---

## Phone Number Format for WhatsApp

**Best format:** `+919876543210` (with country code)
**Works:** `9876543210` (without code, India only)

---

## Keyboard Shortcuts

- **Tab** - Next field
- **Shift+Tab** - Previous field
- **Enter** - Submit (on login screen)
- **r** - Hot reload (in terminal when running)
- **R** - Hot restart (in terminal)
- **q** - Quit app (in terminal)

---

## PDF Features

Your generated PDFs include:
- ✅ Company logo at top
- ✅ Professional borders and layout
- ✅ Customer details section
- ✅ Goods dispatched table
- ✅ Tax details (SGST/CGST)
- ✅ Signature spaces
- ✅ A4 size (perfect for printing)

---

## Need Help?

1. **Quick issues**: Check this guide
2. **Usage details**: See `USAGE_GUIDE.md`
3. **Technical details**: See `README.md`
4. **PDF features**: See `SYNCFUSION_FEATURES.md`
5. **Logo setup**: See `LOGO_INSTRUCTIONS.md`

---

## Production Deployment

### Build Exe for Distribution:

```bash
flutter build windows --release
```

**Exe location:**
```
build\windows\x64\runner\Release\delivery_challan.exe
```

Share the entire `Release` folder to users.

---

## Backup Your Data

**Important files to backup:**

1. **Database:**
   ```
   C:\Users\YourName\Documents\delivery_challan\delivery_challan.db
   ```

2. **PDFs:**
   ```
   C:\Users\YourName\Documents\delivery_challan\pdfs\
   ```

**Tip:** Backup weekly to external drive or cloud!

---

## Tips for Best Results

💡 **Save phone numbers with country code** for WhatsApp
💡 **Use consistent DC numbering** (e.g., DC001, DC002)
💡 **Fill all fields** for professional-looking PDFs
💡 **Test print settings** before printing multiple copies
💡 **Check PDF preview** before sending to customers
💡 **Backup database** regularly

---

## Status Indicators

🟢 **Ready** - Everything working
🟡 **Warning** - Check logo file
🔴 **Error** - See troubleshooting section

---

## Version Info

- **App Version**: 1.0.0
- **Flutter Version**: 3.10.1+
- **PDF Engine**: Syncfusion Flutter PDF 28.2.12
- **Platform**: Windows Desktop

---

**🎉 You're all set! Start generating professional delivery challans!**

For detailed documentation, see `README.md`

