<template>
  <div class="customers">
    <div class="customers-header">
      <h2>👥 Customers</h2>
      <button class="btn btn-primary">+ Add Customer</button>
    </div>

    <div class="customers-list">
      <div class="customer-card">
        <h3>John Doe</h3>
        <p>📧 john.doe@email.com</p>
        <p>📱 (555) 123-4567</p>
        <p class="customer-stats">Total Purchases: $125.45</p>
        <div class="customer-actions">
          <button class="btn btn-secondary">Edit</button>
          <button class="btn btn-primary">View History</button>
        </div>
      </div>

      <div class="customer-card">
        <h3>Jane Smith</h3>
        <p>📧 jane.smith@email.com</p>
        <p>📱 (555) 987-6543</p>
        <p class="customer-stats">Total Purchases: $89.99</p>
        <div class="customer-actions">
          <button class="btn btn-secondary">Edit</button>
          <button class="btn btn-primary">View History</button>
        </div>
      </div>

      <div class="customer-card">
        <h3>Mike Johnson</h3>
        <p>📧 mike.j@email.com</p>
        <p>📱 (555) 456-7890</p>
        <p class="customer-stats">Total Purchases: $267.80</p>
        <div class="customer-actions">
          <button class="btn btn-secondary">Edit</button>
          <button class="btn btn-primary">View History</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Customers logic will be implemented here
</script>

<style scoped>
.customers-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.customers-header h2 {
  color: #495057;
  margin: 0;
}

.customers-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 1rem;
}

.customer-card {
  background: white;
  border-radius: 0.5rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  padding: 1.5rem;
}

.customer-card h3 {
  margin-bottom: 1rem;
  color: #495057;
}

.customer-card p {
  margin-bottom: 0.5rem;
  color: #6c757d;
}

.customer-stats {
  font-weight: bold;
  color: #ffc107;
  margin-top: 1rem;
  margin-bottom: 1rem;
}

.customer-actions {
  display: flex;
  gap: 0.5rem;
}
</style>