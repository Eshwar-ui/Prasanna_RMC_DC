# Prasanna RMC - Delivery Challan System

A professional desktop application for generating and managing delivery challans for ready-mix concrete business.

## Features

### ✅ All Requirements Implemented

1. **PDF Generation** - Generates 3 copies of delivery challan in A4 size
2. **Database Storage** - All PDFs and challan data stored locally in SQLite database
3. **A4 Format** - Professional A4-sized PDF output
4. **WhatsApp Integration** - Send delivery challans via WhatsApp
5. **Desktop Application** - Windows/Linux/macOS support with window management
6. **User Authentication** - Secure login system with multiple user support
7. **Desktop Lock Feature** - Confirmation dialog on exit for security

### 📋 Core Functionality

- **Editable Form Fields**: All fields from the delivery challan are editable
  - Customer information (To, Date, Invoice No, DC No)
  - Reference details (Ref Name, Cell No)
  - Product details (Grade of Concrete, Purchase Order No)
  - Dynamic table for goods dispatched (Vehicle Number, Time, Quantity, etc.)
  - Driver information
  - Tax details (SGST, CGST)
  - Payment information

- **PDF Generation**:
  - Automatically generates 3 copies of each challan
  - Saved in: `Documents/delivery_challan/pdfs/`
  - Format: `DC_{DC_NO}_{TIMESTAMP}_copy{1-3}.pdf`
  - Professional layout matching the provided template

- **Database Management**:
  - SQLite database for local storage
  - Located in: `Documents/delivery_challan/delivery_challan.db`
  - Stores all challan history with PDF paths
  - User management system

- **WhatsApp Integration**:
  - Opens WhatsApp with pre-filled message
  - Provides PDF path for manual attachment
  - Uses customer's cell number from the form

## Installation & Setup

### Prerequisites

- Flutter SDK 3.10.1 or higher
- Windows/Linux/macOS operating system

### Installation Steps

1. **Clone or extract the project**

2. **Add the company logo**:
   - Save your Prasanna RMC logo as: `assets/images/prasanna_rmc_logo.png`
   - Must be in PNG format
   - See `LOGO_INSTRUCTIONS.md` for details

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the application**:
   ```bash
   flutter run -d windows  # For Windows
   flutter run -d linux    # For Linux
   flutter run -d macos    # For macOS
   ```

4. **Build release version** (optional):
   ```bash
   flutter build windows --release
   # The executable will be in: build/windows/runner/Release/
   ```

## Default Login Credentials

- **Username**: `admin`
- **Password**: `admin123`

## Usage Guide

### 1. Login
- Launch the application
- Enter username and password
- Click LOGIN

### 2. Create Delivery Challan

1. Fill in customer details:
   - To (Customer name)
   - Date (auto-filled with current date)
   - Invoice No and DC No
   - Reference Name and Cell No

2. Enter product details:
   - Grade of Concrete
   - Purchase Order No

3. Add goods dispatched items:
   - Click "Add Row" to add more items
   - Fill vehicle details, time, quantities
   - Click delete icon to remove items

4. Fill bottom section:
   - Driver information
   - Gate timings
   - Tax percentages (SGST, CGST)
   - Grand Total

5. Click **"GENERATE PDF (3 Copies)"**

### 3. After PDF Generation

A dialog will appear with options:
- **Send to WhatsApp**: Opens WhatsApp with the customer's number
- **Print**: Opens print dialog for the PDF
- **New Challan**: Clears the form for a new entry

### 4. Viewing Generated PDFs

All PDFs are saved in:
```
C:\Users\{YourUsername}\Documents\delivery_challan\pdfs\
```

### 5. Database Location

The database is stored at:
```
C:\Users\{YourUsername}\Documents\delivery_challan\delivery_challan.db
```

## User Management

### Adding New Users

Currently, users can be added by modifying the database directly or through code. 

To add users programmatically, you can use:
```dart
await AuthService.instance.createUser(
  username: 'newuser',
  password: 'password123',
  fullName: 'Full Name',
  role: 'user',
);
```

## Technical Details

### Technology Stack

- **Framework**: Flutter 3.10.1
- **Language**: Dart
- **Database**: SQLite (via sqflite_common_ffi)
- **PDF Generation**: Syncfusion Flutter PDF
- **PDF Printing**: printing package
- **Window Management**: window_manager
- **Local Storage**: shared_preferences
- **URL Handling**: url_launcher

### Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/
│   ├── delivery_challan.dart # Challan data model
│   └── user.dart            # User model
├── services/
│   ├── auth_service.dart    # Authentication service
│   ├── database_service.dart # Database operations
│   ├── pdf_service.dart     # PDF generation
│   └── whatsapp_service.dart # WhatsApp integration
└── screens/
    ├── login_screen.dart    # Login UI
    └── challan_form_screen.dart # Main form UI
```

### Dependencies

```yaml
dependencies:
  syncfusion_flutter_pdf: ^28.1.33  # Professional PDF generation
  printing: ^5.13.2                  # PDF printing
  sqflite_common_ffi: ^2.3.3        # Desktop SQLite
  path_provider: ^2.1.4             # File paths
  path: ^1.9.0                      # Path utilities
  shared_preferences: ^2.3.2        # Simple storage
  intl: ^0.19.0                     # Date formatting
  url_launcher: ^6.3.1              # WhatsApp/URL opening
  window_manager: ^0.4.2            # Desktop window control
```

## Security Features

1. **User Authentication**: Required login for access
2. **Session Management**: Remembers logged-in user
3. **Exit Confirmation**: Prevents accidental closure
4. **User Tracking**: Each challan records creator username

## Backup & Data Management

### Backing Up Data

To backup your data, copy these folders:

1. **Database**:
   ```
   C:\Users\{YourUsername}\Documents\delivery_challan\delivery_challan.db
   ```

2. **PDFs**:
   ```
   C:\Users\{YourUsername}\Documents\delivery_challan\pdfs\
   ```

### Restoring Data

Simply copy the backed-up files back to the original location.

## Troubleshooting

### Issue: PDFs not generating
- Check if you have write permissions to Documents folder
- Ensure all required fields are filled

### Issue: WhatsApp not opening
- Ensure WhatsApp Desktop is installed or use WhatsApp Web in browser
- Check if the phone number is in correct format

### Issue: Database errors
- Delete the database file and restart the app (will lose data)
- Ensure no other instance is running

## Future Enhancements (Optional)

- [ ] Google Drive integration for cloud backup
- [ ] Email challan functionality
- [ ] Advanced user management UI
- [ ] Challan history viewer
- [ ] Search and filter challans
- [ ] Export to Excel
- [ ] Digital signature support
- [ ] Barcode/QR code generation

## Support

For issues or questions, please refer to the code comments or contact the development team.

## License

Proprietary - Prasanna RMC

---

**Built with Flutter** 💙
