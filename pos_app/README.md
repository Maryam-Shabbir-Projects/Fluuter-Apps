# POS App Documentation

Welcome to the POS App documentation! Use the sections below to quickly navigate and explore different parts of the app.

---

## 📑 Table of Contents
- [Modules & Components](#modules--components)
- [Data Models](#data-models)
- [Features Summary](#features-summary)
- [Usage Examples](#usage-examples)
- [Navigation Routes](#navigation-routes)

---

## Modules & Components

<details>
<summary><strong>InventoryController</strong></summary>

- **Purpose:** Manage inventory items (add, update, delete, filter by category).  
- **Key Properties:**  
  - `inventoryList` (observable list of InventoryItem)  
- **Key Methods:**  
  - `addInventoryItem(item)`  
  - `updateInventoryItem(item)`  
  - `deleteInventoryItem(productId)`  
  - `getInventoryByCategory(categoryId)`  
- **UI:** Backing controller for the Inventory page enabling reactive inventory display.  
</details>

<details>
<summary><strong>BillsController</strong></summary>

- **Purpose:** Manage bills creation, deletion, and querying.  
- **Key Properties:**  
  - `bills` (observable list of Bill)  
- **Key Methods:**  
  - `addBill(bill)`  
  - `deleteBill(id)`  
  - `getBillsByCustomer(customerId)`  
- **UI:** Drives the Bills page with filtered views by customer.  
</details>

<details>
<summary><strong>CustomersController</strong></summary>

- **Purpose:** Manage customer data, addition, deletion, and search.  
- **Key Properties:**  
  - `customers` (observable list of Customer)  
- **Key Methods:**  
  - `addCustomer(customer)`  
  - `deleteCustomer(id)`  
  - `searchCustomers(query)`  
- **UI:** Supports Customers page with search and summary charts.  
</details>

<details>
<summary><strong>DashboardPage</strong></summary>

- **Purpose:** Overview dashboard showing sales, purchase, and stock summaries with quick actions.  
- **UI Elements:**  
  - Summary cards with icons and values  
  - Quick actions buttons (New Sale, Add Product)  
- **Navigation:** Tapping cards navigates to detailed reports.  
</details>

---

## Data Models

| Model          | Description                                      | Key Fields                                  |
|----------------|------------------------------------------------|---------------------------------------------|
| **Product**    | Product with pricing and stock info             | id, name, categoryId, purchasePrice, salePrice, quantity |
| **Bill**       | Sales invoice with items and total              | id, customerId, customerName, date, items, totalAmount |
| **BillItem**   | Single item in a bill                            | productId, productName, quantity, price, total |
| **Customer**   | Customer contact details                         | id, name, phone, email                      |
| **InventoryItem** | Inventory tracking of product stock           | productId, productName, categoryId, inStock, prices, lastPurchaseDate |

---

## Features Summary

- **Dynamic Inventory List:** Search and category filtering.  
- **Billing System:** Create, view, filter bills by customer.  
- **Customer Management:** Searchable, filterable customers with date-based summaries.  
- **Dashboard Overview:** Sales, purchase, stock insights with quick action buttons.  
- **Navigation Drawer:** Easy app-wide access to key sections.  
- **Reactive UI:** Live updates using GetX state management.

---

## Usage Examples

```dart
// Add inventory item
inventoryController.addInventoryItem(newItem);

// Search customers by query
customerController.searchCustomers('john');

// Create new bill
billsController.addBill(bill);

// Navigate to inventory page
Get.toNamed('/inventory');
Navigation Routes
Route	Screen	Description
/dashboard	DashboardPage	App overview
/inventory	InventoryPage	Inventory management
/bills	BillsPage	Bill management
/customers	CustomersPage	Customer management
/reports	ReportsPage	Analytics and reports
/tax_discount	TaxAndDiscountPage	Manage taxes and discounts (optional)
/login	LoginPage	User authentication

Quick Navigation
Go to Dashboard

Go to Inventory

Go to Bills

Go to Customers