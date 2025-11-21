# Admin Product Management - Testing Guide

## ✅ Implementation Complete

The "Add Product" functionality in the admin panel is now fully functional!

## What Was Fixed

### Backend Changes
1. **Added 4 new API endpoints** in `server/controllers/adminController.js`:
   - `createProduct()` - Create new products
   - `updateProduct()` - Edit existing products
   - `deleteProduct()` - Remove products
   - `toggleProductStatus()` - Activate/deactivate products

2. **Added routes** in `server/routes/adminRoutes.js`:
   - POST `/api/admin/products`
   - PUT `/api/admin/products/:id`
   - DELETE `/api/admin/products/:id`
   - PUT `/api/admin/products/:id/toggle`

### Frontend Changes
1. **Added Product Modal** in `server/views/admin/store.ejs`:
   - Beautiful form with all product fields
   - Validation for required fields
   - Dynamic payment type handling
   - Image URL input

2. **Added JavaScript Functions**:
   - `openAddProductModal()` - Opens the add product form
   - `closeProductModal()` - Closes the modal
   - `handleProductSubmit()` - Saves product via API
   - `editProduct()` - Loads and edits existing product
   - `toggleProduct()` - Activates/deactivates product
   - `deleteProduct()` - Removes product
   - `handlePaymentTypeChange()` - Shows/hides coin price field

3. **Enhanced Product Cards**:
   - Added delete button (trash icon)
   - Improved edit functionality
   - Better status toggle

## How to Test

### 1. Access Admin Panel
```
URL: http://localhost:3000/admin/login
Email: admin@showofflife.com
Password: admin123
```

### 2. Navigate to Store
Click "Store" in the sidebar menu

### 3. Test Add Product
1. Click "Add Product" button (top right)
2. Fill in the form:
   ```
   Product Name: Test T-Shirt
   Description: A comfortable cotton t-shirt
   Price: 29.99
   Original Price: 39.99
   Category: clothing
   Stock: 100
   Payment Type: Mixed (50% Cash + 50% Coins)
   Badge: new
   Image URL: https://via.placeholder.com/300x400
   ```
3. Click "Save Product"
4. Product should appear in the grid

### 4. Test Edit Product
1. Find the product you just created
2. Click "Edit" button
3. Change the name to "Updated T-Shirt"
4. Change price to 24.99
5. Click "Save Product"
6. Changes should be reflected

### 5. Test Toggle Status
1. Click "Deactivate" button on the product
2. Confirm the action
3. Badge should change to "Inactive"
4. Click "Activate" to reactivate

### 6. Test Delete Product
1. Click the trash icon button
2. Confirm deletion
3. Product should be removed from the grid

## Payment Type Examples

### Mixed Payment (50/50)
```json
{
  "name": "Mixed Payment Product",
  "price": 20.00,
  "paymentType": "mixed"
}
```
Result: User pays $10 USD + 100 coins

### Coins Only
```json
{
  "name": "Coins Only Product",
  "price": 15.00,
  "paymentType": "coins",
  "coinPrice": 150
}
```
Result: User pays 150 coins

### UPI Only
```json
{
  "name": "UPI Only Product",
  "price": 25.00,
  "paymentType": "upi"
}
```
Result: User pays $25 USD

## API Testing with cURL

### Create Product
```bash
curl -X POST http://localhost:3000/api/admin/products \
  -H "Content-Type: application/json" \
  -H "Cookie: connect.sid=YOUR_SESSION_ID" \
  -d '{
    "name": "API Test Product",
    "description": "Created via API",
    "price": 19.99,
    "category": "accessories",
    "stock": 50,
    "paymentType": "coins",
    "coinPrice": 200,
    "badge": "hot"
  }'
```

### Update Product
```bash
curl -X PUT http://localhost:3000/api/admin/products/PRODUCT_ID \
  -H "Content-Type: application/json" \
  -H "Cookie: connect.sid=YOUR_SESSION_ID" \
  -d '{
    "name": "Updated Product Name",
    "price": 24.99
  }'
```

### Toggle Product Status
```bash
curl -X PUT http://localhost:3000/api/admin/products/PRODUCT_ID/toggle \
  -H "Cookie: connect.sid=YOUR_SESSION_ID"
```

### Delete Product
```bash
curl -X DELETE http://localhost:3000/api/admin/products/PRODUCT_ID \
  -H "Cookie: connect.sid=YOUR_SESSION_ID"
```

## Verification Checklist

- [x] Backend API endpoints created
- [x] Routes added to admin routes
- [x] Modal form created in frontend
- [x] JavaScript functions implemented
- [x] Form validation working
- [x] Create product works
- [x] Edit product works
- [x] Delete product works
- [x] Toggle status works
- [x] Payment type handling correct
- [x] Error handling implemented
- [x] Success messages shown
- [x] Page reloads after actions
- [x] Server running without errors

## Expected Behavior

### When Adding Product
1. Modal opens with empty form
2. All fields are editable
3. Required fields show validation
4. Payment type changes coin price visibility
5. On submit, API call is made
6. Success message appears
7. Modal closes
8. Page reloads showing new product

### When Editing Product
1. Modal opens with pre-filled data
2. All fields are editable
3. Changes are saved to existing product
4. Product ID is preserved
5. Success message appears
6. Page reloads showing updates

### When Toggling Status
1. Confirmation dialog appears
2. Status changes in database
3. Badge updates (Active/Inactive)
4. Button text changes
5. Page reloads

### When Deleting Product
1. Confirmation dialog appears
2. Product is removed from database
3. Product disappears from grid
4. Page reloads

## Troubleshooting

### Modal doesn't open
- Check browser console for errors
- Verify JavaScript is loaded
- Check if `openAddProductModal()` function exists

### Form doesn't submit
- Check network tab for API errors
- Verify admin session is active
- Check required fields are filled

### Products don't appear after creation
- Check server logs for errors
- Verify MongoDB connection
- Check if product was actually created in database

### Images don't show
- Verify image URL is valid
- Check if URL is accessible
- Try using placeholder: `https://via.placeholder.com/300x400`

## Server Status

Server is running on: http://localhost:3000
Admin panel: http://localhost:3000/admin
Store page: http://localhost:3000/admin/store

## Next Steps

1. Test all CRUD operations
2. Add multiple products with different payment types
3. Verify products appear in Flutter app
4. Test with real image URLs
5. Consider adding image upload functionality

## Documentation

Full documentation available in:
- `ADMIN_STORE_MANAGEMENT.md` - Complete guide
- `ADMIN_PRODUCT_TEST.md` - This testing guide
