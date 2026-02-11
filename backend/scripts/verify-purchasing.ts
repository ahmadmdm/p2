
const API_URL = 'http://localhost:3001';

async function main() {
  try {
    console.log('--- Starting Purchasing Flow Verification ---');

    // 1. Login
    console.log('1. Logging in...');
    let token = '';
    const email = `admin_${Date.now()}@test.com`;
    const password = 'password';
    
    // Register
    await fetch(`${API_URL}/auth/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, name: 'Admin User', role: 'admin' }),
    });

    // Login
    const loginRes = await fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
    });
    
    if (loginRes.ok) {
        const data = await loginRes.json();
        token = data.access_token;
    } else {
        throw new Error('Login failed');
    }
    console.log('Logged in.');

    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
    };

    // 2. Create Supplier
    console.log('2. Creating Supplier...');
    const supplierRes = await fetch(`${API_URL}/suppliers`, {
        method: 'POST',
        headers,
        body: JSON.stringify({ 
            name: `Supplier ${Date.now()}`,
            email: 'supplier@test.com'
        }),
    });
    const supplier = await supplierRes.json();
    console.log(`Supplier created: ${supplier.id}`);

    // 3. Create Ingredient
    console.log('3. Creating Ingredient...');
    const ingredientRes = await fetch(`${API_URL}/inventory/ingredients`, {
        method: 'POST',
        headers,
        body: JSON.stringify({ 
            name: `Coffee Beans ${Date.now()}`,
            unit: 'kg'
        }),
    });
    const ingredient = await ingredientRes.json();
    console.log(`Ingredient created: ${ingredient.id}`);

    // 4. Create Purchase Order (Draft)
    console.log('4. Creating Purchase Order (Draft)...');
    const poRes = await fetch(`${API_URL}/purchasing/orders`, {
        method: 'POST',
        headers,
        body: JSON.stringify({ 
            supplierId: supplier.id,
            notes: 'Weekly coffee supply'
        }),
    });
    const po = await poRes.json();
    console.log(`PO created: ${po.id}, Status: ${po.status}`);

    // 5. Add Item to PO
    console.log('5. Adding Item to PO...');
    const itemRes = await fetch(`${API_URL}/purchasing/orders/${po.id}/items`, {
        method: 'POST',
        headers,
        body: JSON.stringify({ 
            ingredientId: ingredient.id,
            quantity: 10,
            unitPrice: 15.50
        }),
    });
    const poUpdated = await itemRes.json();
    console.log(`Item added. PO Total: ${poUpdated.totalAmount}`);

    // 6. Receive PO
    console.log('6. Receiving PO...');
    const statusRes = await fetch(`${API_URL}/purchasing/orders/${po.id}/status`, {
        method: 'PUT',
        headers,
        body: JSON.stringify({ 
            status: 'received'
        }),
    });
    const poReceived = await statusRes.json();
    console.log(`PO Status: ${poReceived.status}`);

    // 7. Verify Inventory
    console.log('7. Verifying Inventory...');
    const ingredientsRes = await fetch(`${API_URL}/inventory/ingredients`, { headers });
    const ingredients = await ingredientsRes.json();
    const targetIngredient = ingredients.find((i: any) => i.id === ingredient.id);
    
    // Check stock quantity
    // Stock is in 'stock' array relation
    const stockQty = targetIngredient.stock.reduce((sum: number, s: any) => sum + Number(s.quantity), 0);
    console.log(`Ingredient Stock: ${stockQty}`);

    if (stockQty === 10) {
        console.log('SUCCESS: Stock updated correctly.');
    } else {
        console.error(`FAILURE: Expected stock 10, got ${stockQty}`);
    }

  } catch (err) {
    console.error('Error:', err);
  }
}

main();
