// Global variables
let currentPage = 'dashboard';
let authToken = localStorage.getItem('adminToken');
const API_BASE = '/api';

// Initialize admin panel
document.addEventListener('DOMContentLoaded', function() {
    // Check authentication
    if (!authToken) {
        showLoginModal();
        return;
    }
    
    // Initialize navigation
    initializeNavigation();
    
    // Load dashboard data
    loadDashboardData();
    
    // Setup event listeners
    setupEventListeners();
});

// Navigation
function initializeNavigation() {
    const menuItems = document.querySelectorAll('.menu-item');
    menuItems.forEach(item => {
        item.addEventListener('click', function() {
            const page = this.dataset.page;
            switchPage(page);
        });
    });
}

function switchPage(page) {
    // Update active menu item
    document.querySelectorAll('.menu-item').forEach(item => {
        item.classList.remove('active');
    });
    document.querySelector(`[data-page="${page}"]`).classList.add('active');
    
    // Update page title
    const pageTitle = document.querySelector('.page-title');
    pageTitle.textContent = page.charAt(0).toUpperCase() + page.slice(1);
    
    // Show/hide pages
    document.querySelectorAll('.page').forEach(p => {
        p.classList.remove('active');
    });
    document.getElementById(`${page}-page`).classList.add('active');
    
    // Load page data
    loadPageData(page);
    currentPage = page;
}

function loadPageData(page) {
    switch(page) {
        case 'dashboard':
            loadDashboardData();
            break;
        case 'users':
            loadUsersData();
            break;
        case 'kyc':
            loadKYCData();
            break;
        case 'content':
            loadContentData();
            break;
        case 'withdrawals':
            loadWithdrawalsData();
            break;
        case 'subscriptions':
            loadSubscriptionsData();
            break;
        case 'store':
            loadStoreData();
            break;
        case 'talent':
            loadTalentData();
            break;
        case 'notifications':
            loadNotificationsData();
            break;
        case 'fraud':
            loadFraudData();
            break;
        case 'financial':
            loadFinancialData();
            break;
        case 'analytics':
            loadAnalyticsData();
            break;
    }
}

// API calls
async function apiCall(endpoint, options = {}) {
    const config = {
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${authToken}`
        },
        ...options
    };
    
    try {
        const response = await fetch(`${API_BASE}${endpoint}`, config);
        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.message || 'API call failed');
        }
        
        return data;
    } catch (error) {
        console.error('API Error:', error);
        showNotification('Error: ' + error.message, 'error');
        throw error;
    }
}

// Dashboard functions
async function loadDashboardData() {
    try {
        const data = await apiCall('/admin/dashboard');
        updateDashboardStats(data.data);
        updateRecentActivity(data.data.recent);
        createCharts(data.data.analytics);
    } catch (error) {
        console.error('Failed to load dashboard data:', error);
    }
}

function updateDashboardStats(stats) {
    document.getElementById('total-users').textContent = stats.users.total.toLocaleString();
    document.getElementById('total-posts').textContent = stats.content.totalPosts.toLocaleString();
    document.getElementById('total-coins').textContent = stats.financial.coinsInCirculation.toLocaleString();
    document.getElementById('total-orders').textContent = stats.store.totalOrders.toLocaleString();
}

function updateRecentActivity(recent) {
    // Recent users
    const recentUsersList = document.getElementById('recent-users-list');
    recentUsersList.innerHTML = recent.users.map(user => `
        <div class="user-item">
            <img src="${user.profilePicture || 'https://via.placeholder.com/40'}" alt="${user.displayName}" class="user-avatar">
            <div class="user-info">
                <div class="user-name">${user.displayName}</div>
                <div class="user-email">@${user.username}</div>
            </div>
        </div>
    `).join('');
    
    // Recent posts
    const recentPostsList = document.getElementById('recent-posts-list');
    recentPostsList.innerHTML = recent.posts.map(post => `
        <div class="post-item">
            <img src="${post.thumbnailUrl || post.mediaUrl}" alt="Post" class="post-thumbnail">
            <div class="post-info">
                <div class="post-caption">${post.caption || 'No caption'}</div>
                <div class="post-stats">${post.likesCount} likes • ${post.user.displayName}</div>
            </div>
        </div>
    `).join('');
}

function createCharts(analytics) {
    // Revenue Chart
    const revenueCtx = document.getElementById('revenueChart').getContext('2d');
    new Chart(revenueCtx, {
        type: 'line',
        data: {
            labels: analytics.revenue.map(item => item._id),
            datasets: [{
                label: 'Revenue',
                data: analytics.revenue.map(item => item.revenue),
                borderColor: '#667eea',
                backgroundColor: 'rgba(102, 126, 234, 0.1)',
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
    
    // Content Distribution Chart
    const contentCtx = document.getElementById('contentChart').getContext('2d');
    new Chart(contentCtx, {
        type: 'doughnut',
        data: {
            labels: ['Reels', 'Images', 'Videos'],
            datasets: [{
                data: [45, 35, 20], // Sample data
                backgroundColor: ['#667eea', '#f093fb', '#4facfe']
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
}

// Users management
async function loadUsersData() {
    try {
        const data = await apiCall('/admin/users');
        updateUsersTable(data.data);
        updateUsersPagination(data.pagination);
    } catch (error) {
        console.error('Failed to load users data:', error);
    }
}

function updateUsersTable(users) {
    const tbody = document.getElementById('users-table-body');
    tbody.innerHTML = users.map(user => `
        <tr>
            <td>
                <div class="user-item">
                    <img src="${user.profilePicture || 'https://via.placeholder.com/40'}" alt="${user.displayName}" class="user-avatar">
                    <div class="user-info">
                        <div class="user-name">${user.displayName}</div>
                        <div class="user-email">@${user.username}</div>
                    </div>
                </div>
            </td>
            <td>${user.email || 'N/A'}</td>
            <td><span class="status-badge status-${user.accountStatus || 'active'}">${user.accountStatus || 'active'}</span></td>
            <td><span class="status-badge ${user.isVerified ? 'status-verified' : ''}">${user.isVerified ? 'Verified' : 'Unverified'}</span></td>
            <td>${user.coinBalance || 0} coins</td>
            <td>${new Date(user.createdAt).toLocaleDateString()}</td>
            <td>
                <button class="btn btn-sm btn-primary" onclick="viewUser('${user._id}')">View</button>
                <button class="btn btn-sm btn-warning" onclick="suspendUser('${user._id}')">Suspend</button>
            </td>
        </tr>
    `).join('');
}

function updateUsersPagination(pagination) {
    const paginationEl = document.getElementById('users-pagination');
    let paginationHTML = '';
    
    for (let i = 1; i <= pagination.pages; i++) {
        paginationHTML += `
            <button class="btn ${i === pagination.page ? 'btn-primary' : ''}" onclick="loadUsersPage(${i})">
                ${i}
            </button>
        `;
    }
    
    paginationEl.innerHTML = paginationHTML;
}

// Content moderation
async function loadContentData() {
    try {
        const data = await apiCall('/admin/posts');
        updateContentGrid(data.data);
    } catch (error) {
        console.error('Failed to load content data:', error);
    }
}

function updateContentGrid(posts) {
    const grid = document.getElementById('content-grid');
    grid.innerHTML = posts.map(post => `
        <div class="content-item">
            <img src="${post.thumbnailUrl || post.mediaUrl}" alt="Content" class="content-media">
            <div class="content-info">
                <p><strong>@${post.user.username}</strong></p>
                <p>${post.caption || 'No caption'}</p>
                <p>Type: ${post.type} • Likes: ${post.likesCount}</p>
                <div class="content-actions">
                    <button class="btn btn-sm btn-success" onclick="moderatePost('${post._id}', 'approve')">Approve</button>
                    <button class="btn btn-sm btn-danger" onclick="moderatePost('${post._id}', 'reject')">Reject</button>
                </div>
            </div>
        </div>
    `).join('');
}

// Store management
async function loadStoreData() {
    try {
        const [productsData, dashboardData] = await Promise.all([
            apiCall('/products'),
            apiCall('/admin/dashboard')
        ]);
        
        updateStoreStats(dashboardData.data.store);
        updateProductsGrid(productsData.data);
    } catch (error) {
        console.error('Failed to load store data:', error);
    }
}

function updateStoreStats(stats) {
    document.getElementById('store-total-products').textContent = stats.totalProducts;
    document.getElementById('store-active-products').textContent = stats.activeProducts;
    document.getElementById('store-total-orders').textContent = stats.totalOrders;
    document.getElementById('store-pending-orders').textContent = stats.pendingOrders;
}

function updateProductsGrid(products) {
    const grid = document.getElementById('products-grid');
    grid.innerHTML = products.map(product => `
        <div class="content-item">
            <img src="${product.images[0] || 'https://via.placeholder.com/300'}" alt="${product.name}" class="content-media">
            <div class="content-info">
                <h4>${product.name}</h4>
                <p>${product.description}</p>
                <p><strong>Price: ${product.paymentType === 'coins' ? product.coinPrice + ' coins' : '$' + product.price}</strong></p>
                <p>Category: ${product.category} • Stock: ${product.stock}</p>
                <div class="content-actions">
                    <button class="btn btn-sm btn-primary" onclick="editProduct('${product._id}')">Edit</button>
                    <button class="btn btn-sm ${product.isActive ? 'btn-warning' : 'btn-success'}" onclick="toggleProduct('${product._id}')">
                        ${product.isActive ? 'Deactivate' : 'Activate'}
                    </button>
                </div>
            </div>
        </div>
    `).join('');
}

// Financial management
async function loadFinancialData() {
    try {
        const data = await apiCall('/admin/financial');
        updateFinancialStats(data.data);
        updateWithdrawalsTable(data.data.withdrawalRequests);
    } catch (error) {
        console.error('Failed to load financial data:', error);
    }
}

function updateFinancialStats(data) {
    const coinsInCirculation = data.transactionStats.reduce((total, stat) => {
        return stat._id === 'add_money' ? total + stat.totalAmount : total;
    }, 0);
    
    document.getElementById('coins-circulation').textContent = coinsInCirculation.toLocaleString();
    document.getElementById('pending-withdrawals').textContent = data.withdrawalRequests.length;
    
    const totalWithdrawals = data.withdrawalRequests.reduce((total, req) => {
        return req.status === 'completed' ? total + req.amount : total;
    }, 0);
    document.getElementById('total-withdrawals').textContent = '$' + totalWithdrawals.toLocaleString();
}

function updateWithdrawalsTable(withdrawals) {
    const tbody = document.getElementById('withdrawals-table-body');
    tbody.innerHTML = withdrawals.map(withdrawal => `
        <tr>
            <td>
                <div class="user-info">
                    <div class="user-name">${withdrawal.user.displayName}</div>
                    <div class="user-email">@${withdrawal.user.username}</div>
                </div>
            </td>
            <td>$${withdrawal.amount}</td>
            <td>${withdrawal.method}</td>
            <td>${new Date(withdrawal.createdAt).toLocaleDateString()}</td>
            <td><span class="status-badge status-${withdrawal.status}">${withdrawal.status}</span></td>
            <td>
                ${withdrawal.status === 'pending' ? `
                    <button class="btn btn-sm btn-success" onclick="processWithdrawal('${withdrawal._id}', 'approve')">Approve</button>
                    <button class="btn btn-sm btn-danger" onclick="processWithdrawal('${withdrawal._id}', 'reject')">Reject</button>
                ` : 'Processed'}
            </td>
        </tr>
    `).join('');
}

// Action functions
async function moderatePost(postId, action) {
    try {
        await apiCall(`/admin/posts/${postId}/moderate`, {
            method: 'PUT',
            body: JSON.stringify({ action, reason: `${action}d by admin` })
        });
        showNotification(`Post ${action}d successfully`, 'success');
        loadContentData();
    } catch (error) {
        console.error('Failed to moderate post:', error);
    }
}

async function processWithdrawal(withdrawalId, action) {
    try {
        await apiCall(`/admin/withdrawals/${withdrawalId}`, {
            method: 'PUT',
            body: JSON.stringify({ action, reason: `${action}d by admin` })
        });
        showNotification(`Withdrawal ${action}d successfully`, 'success');
        loadFinancialData();
    } catch (error) {
        console.error('Failed to process withdrawal:', error);
    }
}

async function suspendUser(userId) {
    if (!confirm('Are you sure you want to suspend this user?')) return;
    
    try {
        await apiCall(`/admin/users/${userId}/status`, {
            method: 'PUT',
            body: JSON.stringify({ status: 'suspended', reason: 'Suspended by admin' })
        });
        showNotification('User suspended successfully', 'success');
        loadUsersData();
    } catch (error) {
        console.error('Failed to suspend user:', error);
        showNotification('Failed to suspend user', 'error');
    }
}

async function viewUser(userId) {
    try {
        const response = await apiCall(`/admin/users/${userId}`);
        if (response.success) {
            const user = response.data;
            alert(`User Details:\n\nUsername: ${user.username}\nEmail: ${user.email}\nPhone: ${user.phone || 'N/A'}\nCoins: ${user.coinBalance}\nStatus: ${user.status}\nCreated: ${new Date(user.createdAt).toLocaleDateString()}`);
        }
    } catch (error) {
        console.error('Failed to view user:', error);
        showNotification('Failed to load user details', 'error');
    }
}

async function editProduct(productId) {
    showNotification('Product editing feature coming soon', 'info');
    // TODO: Implement product editing modal
}

async function toggleProduct(productId) {
    if (!confirm('Are you sure you want to toggle this product status?')) return;
    
    try {
        await apiCall(`/admin/products/${productId}/toggle`, {
            method: 'PUT'
        });
        showNotification('Product status updated successfully', 'success');
        loadProductsData();
    } catch (error) {
        console.error('Failed to toggle product:', error);
        showNotification('Failed to update product status', 'error');
    }
}

// Utility functions
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    // Add styles
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 1rem 1.5rem;
        border-radius: 0.5rem;
        color: white;
        font-weight: 500;
        z-index: 3000;
        animation: slideIn 0.3s ease;
        background: ${type === 'success' ? '#10b981' : type === 'error' ? '#ef4444' : '#3b82f6'};
    `;
    
    document.body.appendChild(notification);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.remove();
    }, 3000);
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('active');
}

function logout() {
    localStorage.removeItem('adminToken');
    window.location.reload();
}

// Event listeners
function setupEventListeners() {
    // Sidebar toggle for mobile
    document.querySelector('.sidebar-toggle').addEventListener('click', function() {
        document.querySelector('.sidebar').classList.toggle('open');
    });
    
    // Close modals when clicking outside
    document.querySelectorAll('.modal').forEach(modal => {
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                modal.classList.remove('active');
            }
        });
    });
}

// Search and filter functions
function searchUsers() {
    const searchTerm = document.getElementById('user-search').value;
    // Implement search logic
    loadUsersData();
}

function filterUsers() {
    const status = document.getElementById('user-status-filter').value;
    const verified = document.getElementById('user-verified-filter').value;
    // Implement filter logic
    loadUsersData();
}

function filterContent() {
    const type = document.getElementById('content-type-filter').value;
    const status = document.getElementById('content-status-filter').value;
    // Implement filter logic
    loadContentData();
}

// KYC Management
async function loadKYCData() {
    try {
        const data = await apiCall('/admin/kyc');
        updateKYCTable(data.data || []);
    } catch (error) {
        console.error('Failed to load KYC data:', error);
        document.getElementById('kyc-table-body').innerHTML = '<tr><td colspan="5" class="loading">Failed to load KYC data</td></tr>';
    }
}

function updateKYCTable(kycRequests) {
    const tbody = document.getElementById('kyc-table-body');
    tbody.innerHTML = kycRequests.map(kyc => `
        <tr>
            <td>
                <div class="user-info">
                    <div class="user-name">${kyc.user?.displayName || 'N/A'}</div>
                    <div class="user-email">@${kyc.user?.username || 'N/A'}</div>
                </div>
            </td>
            <td>${kyc.documentType || 'N/A'}</td>
            <td><span class="status-badge status-${kyc.status || 'pending'}">${kyc.status || 'pending'}</span></td>
            <td>${new Date(kyc.createdAt).toLocaleDateString()}</td>
            <td>
                <button class="btn btn-sm btn-primary" onclick="viewKYC('${kyc._id}')">View</button>
                <button class="btn btn-sm btn-success" onclick="approveKYC('${kyc._id}')">Approve</button>
                <button class="btn btn-sm btn-danger" onclick="rejectKYC('${kyc._id}')">Reject</button>
            </td>
        </tr>
    `).join('');
}

function filterKYC() {
    loadKYCData();
}

// Withdrawals Management
async function loadWithdrawalsData() {
    try {
        const data = await apiCall('/admin/withdrawals');
        updateWithdrawalsTable(data.data || []);
    } catch (error) {
        console.error('Failed to load withdrawals data:', error);
        document.getElementById('withdrawals-table-body').innerHTML = '<tr><td colspan="6" class="loading">Failed to load withdrawals</td></tr>';
    }
}

function filterWithdrawals() {
    loadWithdrawalsData();
}

// Subscriptions Management
async function loadSubscriptionsData() {
    try {
        const data = await apiCall('/admin/subscriptions');
        updateSubscriptionsStats(data.stats || {});
        updateSubscriptionsTable(data.data || []);
    } catch (error) {
        console.error('Failed to load subscriptions data:', error);
        document.getElementById('subscriptions-table-body').innerHTML = '<tr><td colspan="6" class="loading">Failed to load subscriptions</td></tr>';
    }
}

function updateSubscriptionsStats(stats) {
    document.getElementById('active-subscriptions').textContent = stats.active || 0;
    document.getElementById('subscription-revenue').textContent = (stats.revenue || 0).toLocaleString();
    document.getElementById('churn-rate').textContent = (stats.churnRate || 0) + '%';
}

function updateSubscriptionsTable(subscriptions) {
    const tbody = document.getElementById('subscriptions-table-body');
    tbody.innerHTML = subscriptions.map(sub => `
        <tr>
            <td>
                <div class="user-info">
                    <div class="user-name">${sub.user?.displayName || 'N/A'}</div>
                    <div class="user-email">@${sub.user?.username || 'N/A'}</div>
                </div>
            </td>
            <td>${sub.plan || 'N/A'}</td>
            <td><span class="status-badge status-${sub.status || 'active'}">${sub.status || 'active'}</span></td>
            <td>${new Date(sub.startDate).toLocaleDateString()}</td>
            <td>${new Date(sub.endDate).toLocaleDateString()}</td>
            <td>
                <button class="btn btn-sm btn-primary" onclick="viewSubscription('${sub._id}')">View</button>
            </td>
        </tr>
    `).join('');
}

// Talent/SYT Management
async function loadTalentData() {
    try {
        const data = await apiCall('/admin/syt');
        updateSYTTable(data.data || []);
    } catch (error) {
        console.error('Failed to load SYT data:', error);
        document.getElementById('syt-table-body').innerHTML = '<tr><td colspan="6" class="loading">Failed to load SYT entries</td></tr>';
    }
}

function updateSYTTable(sytEntries) {
    const tbody = document.getElementById('syt-table-body');
    tbody.innerHTML = sytEntries.map(syt => `
        <tr>
            <td>${syt.title || 'N/A'}</td>
            <td>
                <div class="user-info">
                    <div class="user-name">${syt.creator?.displayName || 'N/A'}</div>
                </div>
            </td>
            <td>${syt.entries || 0}</td>
            <td><span class="status-badge status-${syt.status || 'active'}">${syt.status || 'active'}</span></td>
            <td>${new Date(syt.endDate).toLocaleDateString()}</td>
            <td>
                <button class="btn btn-sm btn-primary" onclick="viewSYT('${syt._id}')">View</button>
                <button class="btn btn-sm btn-warning" onclick="toggleSYT('${syt._id}')">Toggle</button>
            </td>
        </tr>
    `).join('');
}

function filterSYT() {
    loadTalentData();
}

// Notifications Management
async function loadNotificationsData() {
    try {
        const data = await apiCall('/admin/notifications');
        updateNotificationsTable(data.data || []);
    } catch (error) {
        console.error('Failed to load notifications data:', error);
        document.getElementById('notifications-table-body').innerHTML = '<tr><td colspan="5" class="loading">Failed to load notifications</td></tr>';
    }
}

function updateNotificationsTable(notifications) {
    const tbody = document.getElementById('notifications-table-body');
    tbody.innerHTML = notifications.map(notif => `
        <tr>
            <td>${notif.title || 'N/A'}</td>
            <td>${notif.recipientCount || 0}</td>
            <td>${new Date(notif.sentDate).toLocaleDateString()}</td>
            <td><span class="status-badge status-${notif.status || 'sent'}">${notif.status || 'sent'}</span></td>
            <td>
                <button class="btn btn-sm btn-primary" onclick="viewNotification('${notif._id}')">View</button>
            </td>
        </tr>
    `).join('');
}

function showSendNotificationModal() {
    showNotification('Send notification feature coming soon', 'info');
}

// Fraud Detection
async function loadFraudData() {
    try {
        const data = await apiCall('/admin/fraud');
        updateFraudStats(data.stats || {});
        updateFraudTable(data.data || []);
    } catch (error) {
        console.error('Failed to load fraud data:', error);
        document.getElementById('fraud-table-body').innerHTML = '<tr><td colspan="5" class="loading">Failed to load fraud alerts</td></tr>';
    }
}

function updateFraudStats(stats) {
    document.getElementById('suspicious-accounts').textContent = stats.suspiciousAccounts || 0;
    document.getElementById('flagged-transactions').textContent = stats.flaggedTransactions || 0;
    document.getElementById('blocked-users').textContent = stats.blockedUsers || 0;
}

function updateFraudTable(fraudAlerts) {
    const tbody = document.getElementById('fraud-table-body');
    tbody.innerHTML = fraudAlerts.map(alert => `
        <tr>
            <td>
                <div class="user-info">
                    <div class="user-name">${alert.user?.displayName || 'N/A'}</div>
                </div>
            </td>
            <td><span class="status-badge status-${alert.riskLevel || 'low'}">${alert.riskLevel || 'low'}</span></td>
            <td>${alert.reason || 'N/A'}</td>
            <td>${new Date(alert.detectedAt).toLocaleDateString()}</td>
            <td>
                <button class="btn btn-sm btn-primary" onclick="viewFraudAlert('${alert._id}')">View</button>
                <button class="btn btn-sm btn-danger" onclick="blockUser('${alert.user?._id}')">Block</button>
            </td>
        </tr>
    `).join('');
}

// Analytics
async function loadAnalyticsData() {
    try {
        const data = await apiCall('/admin/analytics');
        createAnalyticsCharts(data.data || {});
        updateTopPerformers(data.topPerformers || []);
    } catch (error) {
        console.error('Failed to load analytics data:', error);
    }
}

function createAnalyticsCharts(analyticsData) {
    const engagementCtx = document.getElementById('engagementChart');
    if (engagementCtx) {
        new Chart(engagementCtx.getContext('2d'), {
            type: 'line',
            data: {
                labels: analyticsData.labels || [],
                datasets: [{
                    label: 'Engagement',
                    data: analyticsData.engagement || [],
                    borderColor: '#667eea',
                    backgroundColor: 'rgba(102, 126, 234, 0.1)',
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false
            }
        });
    }
}

function updateTopPerformers(performers) {
    const list = document.getElementById('top-performers-list');
    list.innerHTML = performers.map(performer => `
        <div class="performer-item" style="padding: 1rem; border-bottom: 1px solid #e5e7eb;">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <strong>${performer.displayName}</strong>
                    <p style="color: #6b7280; font-size: 0.875rem;">@${performer.username}</p>
                </div>
                <span style="font-weight: 600; color: #667eea;">${performer.score || 0} points</span>
            </div>
        </div>
    `).join('');
}

// Action functions for new pages
async function approveKYC(kycId) {
    if (!confirm('Approve this KYC request?')) return;
    try {
        await apiCall(`/admin/kyc/${kycId}/approve`, { method: 'PUT' });
        showNotification('KYC approved successfully', 'success');
        loadKYCData();
    } catch (error) {
        showNotification('Failed to approve KYC', 'error');
    }
}

async function rejectKYC(kycId) {
    if (!confirm('Reject this KYC request?')) return;
    try {
        await apiCall(`/admin/kyc/${kycId}/reject`, { method: 'PUT' });
        showNotification('KYC rejected successfully', 'success');
        loadKYCData();
    } catch (error) {
        showNotification('Failed to reject KYC', 'error');
    }
}

async function viewKYC(kycId) {
    showNotification('KYC details view coming soon', 'info');
}

async function viewSubscription(subId) {
    showNotification('Subscription details view coming soon', 'info');
}

async function viewSYT(sytId) {
    showNotification('SYT details view coming soon', 'info');
}

async function toggleSYT(sytId) {
    if (!confirm('Toggle this SYT entry status?')) return;
    try {
        await apiCall(`/admin/syt/${sytId}/toggle`, { method: 'PUT' });
        showNotification('SYT status updated successfully', 'success');
        loadTalentData();
    } catch (error) {
        showNotification('Failed to update SYT status', 'error');
    }
}

async function viewNotification(notifId) {
    showNotification('Notification details view coming soon', 'info');
}

async function viewFraudAlert(alertId) {
    showNotification('Fraud alert details view coming soon', 'info');
}

async function blockUser(userId) {
    if (!confirm('Block this user?')) return;
    try {
        await apiCall(`/admin/users/${userId}/block`, { method: 'PUT' });
        showNotification('User blocked successfully', 'success');
        loadFraudData();
    } catch (error) {
        showNotification('Failed to block user', 'error');
    }
}

// Login modal (simplified)
function showLoginModal() {
    const loginHTML = `
        <div class="login-container" style="
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
        ">
            <div class="login-form" style="
                background: white;
                padding: 2rem;
                border-radius: 1rem;
                box-shadow: 0 20px 40px rgba(0,0,0,0.1);
                width: 400px;
            ">
                <h2 style="text-align: center; margin-bottom: 2rem; color: #1e293b;">Admin Login</h2>
                <form onsubmit="handleLogin(event)">
                    <div style="margin-bottom: 1rem;">
                        <label style="display: block; margin-bottom: 0.5rem; color: #374151;">Email</label>
                        <input type="email" id="admin-email" required style="
                            width: 100%;
                            padding: 0.75rem;
                            border: 1px solid #e5e7eb;
                            border-radius: 0.5rem;
                            font-size: 1rem;
                        ">
                    </div>
                    <div style="margin-bottom: 2rem;">
                        <label style="display: block; margin-bottom: 0.5rem; color: #374151;">Password</label>
                        <input type="password" id="admin-password" required style="
                            width: 100%;
                            padding: 0.75rem;
                            border: 1px solid #e5e7eb;
                            border-radius: 0.5rem;
                            font-size: 1rem;
                        ">
                    </div>
                    <button type="submit" style="
                        width: 100%;
                        padding: 0.75rem;
                        background: linear-gradient(135deg, #667eea, #764ba2);
                        color: white;
                        border: none;
                        border-radius: 0.5rem;
                        font-size: 1rem;
                        font-weight: 600;
                        cursor: pointer;
                    ">Login</button>
                </form>
            </div>
        </div>
    `;
    
    document.body.innerHTML = loginHTML;
}

async function handleLogin(event) {
    event.preventDefault();
    
    const email = document.getElementById('admin-email').value;
    const password = document.getElementById('admin-password').value;
    
    try {
        const response = await fetch('/api/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ emailOrPhone: email, password })
        });
        
        const data = await response.json();
        
        if (data.success && data.data.user.role === 'admin') {
            localStorage.setItem('adminToken', data.data.token);
            window.location.reload();
        } else {
            alert('Invalid admin credentials');
        }
    } catch (error) {
        alert('Login failed: ' + error.message);
    }
}