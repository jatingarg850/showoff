# Admin Store Management - Complete Guide

## Overview
The admin panel store management is now fully functional with the ability to add, edit, delete, and toggle product status.

## What's Been Fixed

### Backend (API Routes)
Added the following endpoints to `/api/admin/products`:

1. **POST /api/admin/products** - Create new product
2. **PUT /api/admin/products/:id** - Update existing product
3. **DELETE /api/admin/products/:id** - Delete product
4. **PUT /api/admin/products/:id/toggle** - Toggle product active status

### Frontend (Admin Panel)
Updated `/admin/store` page with:

1. **Add Product Modal** - Form to create new products
2. **Edit Product** - Click "Edit" button to modify existing products
3. **Toggle Status** - Activate/Deactivate products
4. **Delete Product** - Remove products from the store

## How to Use

### Access Admin Panel
1. Navigate to: `http://localhost:5000/admin/login`
2. Login credentials:
   - Email: `admin@showofflife.com`
   - Password: `admin123`

### Add New Product

1. Click the **"Add Product"** button at the top of the store page
2. Fill in the product details:
   - **Product Name** (required)
   - **Description** (required)
   - **Price in USD** (required)
   - **Original Price** (optional - for showing discounts)
   - **Category** (required): clothing, shoes, accessories, or other
   - **Stock** (required): number of items available
   - **Payment Type** (required):
     - **Mixed**: 50% cash + 50% coins
     - **Coins Only**: Purchase with coins only
     - **UPI Only**: Purchase with real money only
   - **Coin Price** (shown when "Coins Only" is selected)
   - **Badge** (optional): new, sale, hot, or none
   - **Image URL** (optional): Direct URL to product image

3. Click **"Save Product"**
4. Product will appear in the store immediately

### Edit Product

1. Find the product you want to edit
2. Click the **"Edit"** button on the product card
3. Modal will open with pre-filled product data
4. Modify any fields you want to change
5. Click **"Save Product"**
6. Changes will be reflected immediately

### Toggle Product Status

1. Find the product you want to activate/deactivate
2. Click the **"Activate"** or **"Deactivate"** button
3. Confirm the action
4. Product status will update immediately
5. Inactive products won't be visible to users in the app

### Delete Product

1. Find the product you want to delete
2. Click the **trash icon** button
3. Confirm the deletion
4. Product will be permanently removed

## Product Fields Explained

### Payment Types

#### Mixed Payment (50/50)
- User pays 50% in real money (USD)
- User pays 50% in coins
- Example: $10 product = $5 USD + 50 coins
- Automatically calculated based on price (1 USD = 10 coins)

#### Coins Only
- User pays entirely with coins
- You set the coin price manually
- Example: 100 coins for a product

#### UPI Only
- User pays entirely with real money
- Standard e-commerce payment

### Categories
- **Clothing**: T-shirts, pants, dresses, etc.
- **Shoes**: Sneakers, boots, sandals, etc.
- **Accessories**: Bags, jewelry, watches, etc.
- **Other**: Everything else

### Badges
- **New**: Shows "NEW" badge on product
- **Sale**: Shows "SALE" badge (use with originalPrice for discount display)
- **Hot**: Shows "HOT" badge for trending items
- **None**: No badge displayed

## API Endpoints

### Create Product
```http
POST /api/admin/products
Content-Type: application/json

{
  "name": "Cool T-Shirt",
  "description": "A very cool t-shirt",
  "price": 29.99,
  "originalPrice": 39.99,
  "category": "clothing",
  "stock": 100,
  "paymentType": "mixed",
  "badge": "sale",
  "images": ["https://example.com/image.jpg"]
}
```

### Update Product
```http
PUT /api/admin/products/:id
Content-Type: application/json

{
  "name": "Updated T-Shirt",
  "price": 24.99,
  "stock": 50
}
```

### Toggle Product Status
```http
PUT /api/admin/products/:id/toggle
```

### Delete Product
```http
DELETE /api/admin/products/:id
```

## Technical Details

### Files Modified

1. **server/controllers/adminController.js**
   - Added `createProduct()` function
   - Added `updateProduct()` function
   - Added `deleteProduct()` function
   - Added `toggleProductStatus()` function

2. **server/routes/adminRoutes.js**
   - Added POST `/products` route
   - Added PUT `/products/:id` route
   - Added DELETE `/products/:id` route
   - Added PUT `/products/:id/toggle` route

3. **server/views/admin/store.ejs**
   - Added product modal form
   - Added JavaScript functions for CRUD operations
   - Added delete button to product cards
   - Added form validation

### Authentication
All product management endpoints require admin authentication via:
- Session-based auth (for web admin panel)
- JWT token auth (for API calls)

### Validation
- Required fields are validated on both frontend and backend
- Price must be a positive number
- Stock must be a non-negative integer
- Category must be one of: clothing, shoes, accessories, other
- Payment type must be one of: mixed, coins, upi

## Testing

1. **Add a product**: Create a new product with all fields
2. **Edit the product**: Modify some fields and save
3. **Toggle status**: Deactivate and reactivate the product
4. **Delete the product**: Remove it from the store
5. **Check the app**: Verify products appear correctly in the Flutter app

## Troubleshooting

### "Add Product" button doesn't work
- Check browser console for JavaScript errors
- Ensure you're logged in as admin
- Clear browser cache and reload

### Product not saving
- Check server logs for errors
- Verify all required fields are filled
- Check network tab in browser dev tools

### Images not showing
- Ensure image URL is valid and accessible
- Check image URL format (must start with http:// or https://)
- Verify image is not blocked by CORS

### Products not appearing in app
- Check if product is marked as active
- Verify product has valid data
- Check Flutter app API connection

## Future Enhancements

Potential improvements:
- Image upload functionality (instead of URL)
- Multiple image support with gallery
- Bulk product import/export
- Product variants (sizes, colors)
- Inventory tracking
- Sales analytics per product
- Product reviews management
- SEO fields (meta description, keywords)

## Support

If you encounter issues:
1. Check server logs: `npm run dev` output
2. Check browser console for errors
3. Verify admin authentication
4. Test API endpoints directly with Postman/Thunder Client
