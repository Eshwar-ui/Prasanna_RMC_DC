# Quick Usage Guide - Prasanna RMC Delivery Challan System

## 🚀 Quick Start

### First Time Setup

1. Open terminal/command prompt in project folder
2. Run: `flutter pub get`
3. Run: `flutter run -d windows`

### Login

**Default Credentials:**
- Username: `admin`
- Password: `admin123`

## 📝 Creating a Delivery Challan

### Step-by-Step Process

#### 1. Basic Information
Fill in the top section:
- **To**: Customer/Company name
- **Date**: Delivery date (defaults to today)
- **Invoice No**: Invoice number (optional)
- **DC No**: Delivery Challan number (required)
- **Ref Name**: Reference contact person
- **Cell No**: Customer's phone number (for WhatsApp)
- **Grade**: Grade of concrete (e.g., M20, M25)
- **Purchase Order No**: PO reference number

#### 2. Goods Dispatched Table
Add delivery items:
- Click **"Add Row"** to add more items
- Fill each row:
  - Vehicle Number
  - Time of Removal
  - Grade of Concrete
  - Quantity in Cubic Meters
  - Total Quantity
  - Pump details
  - Dump details
- Click ❌ to remove a row

#### 3. Additional Details
Bottom section:
- **Driver Name** and **Cell No**
- **Amount**: Total amount
- **TM GATE OUT KMS**: Truck meter reading (out)
- **Site in Time**: Arrival time at site
- **SGST %**: State GST percentage
- **TM GATE IN KMS**: Truck meter reading (in)
- **Site Out Time**: Departure time from site
- **CGST %**: Central GST percentage
- **Grand Total**: Final total amount (required)

#### 4. Generate PDF
- Click **"GENERATE PDF (3 Copies)"**
- Wait for processing (usually 2-3 seconds)
- Success dialog will appear

### After Generation

Three options available:

1. **Send to WhatsApp**
   - Opens WhatsApp with customer's number
   - Message is pre-filled with DC details
   - Manually attach the PDF from shown path

2. **Print**
   - Opens system print dialog
   - Select printer and print

3. **New Challan**
   - Clears the form
   - Ready for next challan

## 📍 Where Files Are Saved

### PDFs Location
```
C:\Users\YourName\Documents\delivery_challan\pdfs\
```

File naming format:
```
DC_{DC_NUMBER}_{TIMESTAMP}_copy1.pdf
DC_{DC_NUMBER}_{TIMESTAMP}_copy2.pdf
DC_{DC_NUMBER}_{TIMESTAMP}_copy3.pdf
```

Example:
```
DC_001_20241218_143052_copy1.pdf
DC_001_20241218_143052_copy2.pdf
DC_001_20241218_143052_copy3.pdf
```

### Database Location
```
C:\Users\YourName\Documents\delivery_challan\delivery_challan.db
```

## 💡 Tips & Tricks

### Quick Data Entry
1. Use Tab key to move between fields quickly
2. Date picker: Click calendar icon or click field
3. Phone numbers: Enter with country code for WhatsApp (e.g., +919876543210)

### Required Fields
Only these fields are mandatory:
- To
- Date
- DC No
- Grade
- Grand Total

### Managing Items
- Minimum 1 item row required (can be empty)
- Maximum recommended: 10 items per challan
- Use delete button to remove unwanted rows

### WhatsApp Best Practices
- Enter phone number with country code
- Example: +919876543210 (India)
- No spaces or dashes needed

### PDF Organization
- Each challan gets 3 copies automatically
- Copy 1: Customer
- Copy 2: Office records
- Copy 3: Accounts/Archive

## 🔒 Security Features

### Login
- Session maintained until logout
- Auto-login on next launch if not logged out

### Logout
- Click logout icon in top-right
- Returns to login screen
- Session cleared

### Exit Confirmation
- Confirmation dialog appears when closing app
- Prevents accidental data loss

## ⚙️ Common Scenarios

### Scenario 1: Single Delivery
1. Fill all fields
2. Add one row in table
3. Generate PDF
4. Send to WhatsApp or Print

### Scenario 2: Multiple Vehicles
1. Fill basic information
2. Click "Add Row" for each vehicle
3. Fill vehicle details in each row
4. Total quantity auto-calculated (manual entry)
5. Generate PDF

### Scenario 3: Quick Challan
1. Fill only required fields:
   - To
   - DC No
   - Grade
   - Grand Total
2. Generate PDF

## 📞 WhatsApp Integration

### How it Works
1. Click "Send to WhatsApp" button
2. WhatsApp opens (Desktop or Web)
3. Chat with customer's number opens
4. Message is pre-filled:
   ```
   Hello,
   
   Your Delivery Challan has been generated.
   
   DC No: [NUMBER]
   Date: [DATE]
   Customer: [NAME]
   
   Thank you for your business!
   - Prasanna RMC
   ```
5. Manually attach PDF from shown path
6. Send message

### Note
- Direct PDF attachment from app not supported
- Must attach manually (WhatsApp API limitation)
- PDF path is shown in snackbar/dialog

## 🔄 Starting Fresh

### Clear Single Form
- Click "New Challan" after generation
- Or manually clear and re-enter

### Reset Database (Warning: Deletes all data!)
1. Close application
2. Delete: `C:\Users\YourName\Documents\delivery_challan\delivery_challan.db`
3. Restart application
4. Default admin user recreated

## 📊 Viewing History

Current version stores in database but doesn't have UI viewer.

To view history:
1. Open database file with SQLite browser
2. Query: `SELECT * FROM delivery_challans`

Or check PDF folder for all generated files.

## 🐛 Quick Fixes

### Problem: Can't login
- Try default: admin / admin123
- Check Caps Lock

### Problem: PDF not generating
- Check all required fields filled
- Ensure write permissions to Documents folder
- Check disk space

### Problem: WhatsApp not opening
- Ensure WhatsApp installed
- Or use web.whatsapp.com manually

### Problem: Form not clearing
- Click "New Challan" button
- Or logout and login again

## 🎯 Best Practices

1. **Fill DC No carefully** - Used for file naming
2. **Save phone numbers** - Keep a list for quick entry
3. **Regular backups** - Copy PDF folder weekly
4. **Check PDF** - Verify PDF before sending
5. **Print test** - Test print settings first
6. **Use consistent format** - Same grade naming convention

## 📱 Contact Information Format

### Phone Numbers
- With country code: +919876543210
- Without code: 9876543210 (may not work for WhatsApp)

### Grade Naming
- Standard: M20, M25, M30, M35, M40
- Custom: Follow your company standard

## ⌨️ Keyboard Shortcuts

- **Tab**: Next field
- **Shift+Tab**: Previous field
- **Enter**: Submit login / Focus next
- **Esc**: Cancel dialogs

---

**Need Help?** Refer to README.md for detailed technical documentation.

**Questions?** Contact your system administrator or IT support.


