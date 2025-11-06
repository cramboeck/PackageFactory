// ==========================================
// Intune Apps Dashboard - Phase 3
// ==========================================

const API_BASE = window.location.origin;
let allApps = [];
let currentApp = null;

// Theme Management
function initTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.body.setAttribute('data-theme', savedTheme);
    updateThemeButton(savedTheme);
}

function toggleTheme() {
    const currentTheme = document.body.getAttribute('data-theme') || 'light';
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';

    document.body.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    updateThemeButton(newTheme);
}

function updateThemeButton(theme) {
    const icon = document.getElementById('theme-icon');
    const text = document.getElementById('theme-text');

    if (theme === 'dark') {
        icon.textContent = '☀️';
        text.textContent = 'Light';
    } else {
        icon.textContent = '🌙';
        text.textContent = 'Dark';
    }
}

// Load apps on page load
document.addEventListener('DOMContentLoaded', function() {
    initTheme();
    loadApps();

    // Setup refresh button
    document.getElementById('refreshBtn').addEventListener('click', function() {
        loadApps(true);
    });

    // Setup search
    document.getElementById('searchInput').addEventListener('input', function(e) {
        filterApps(e.target.value);
    });
});

// Load apps from API
async function loadApps(forceRefresh = false) {
    const loadingState = document.getElementById('loadingState');
    const errorState = document.getElementById('errorState');
    const emptyState = document.getElementById('emptyState');
    const appsContainer = document.getElementById('appsContainer');

    // Show loading
    loadingState.style.display = 'block';
    errorState.style.display = 'none';
    emptyState.style.display = 'none';
    appsContainer.style.display = 'none';

    try {
        const response = await fetch(`${API_BASE}/api/intune/apps`);
        const data = await response.json();

        if (!data.success) {
            throw new Error(data.error || 'Failed to load apps');
        }

        // Ensure apps is always an array (handle PowerShell single-item serialization issue)
        allApps = Array.isArray(data.apps) ? data.apps : (data.apps ? [data.apps] : []);

        // Hide loading
        loadingState.style.display = 'none';

        if (allApps.length === 0) {
            emptyState.style.display = 'block';
        } else {
            appsContainer.style.display = 'block';
            displayApps(allApps);
            updateAppCount(allApps.length);
            updateLastSync(data.timestamp);
        }

    } catch (error) {
        console.error('Error loading apps:', error);
        loadingState.style.display = 'none';
        errorState.style.display = 'block';
        document.querySelector('#errorState .error-message').textContent = error.message;
    }
}

// Display apps in table
function displayApps(apps) {
    const tbody = document.getElementById('appsTableBody');
    tbody.innerHTML = '';

    if (apps.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="text-center">No apps match your search</td></tr>';
        return;
    }

    apps.forEach(app => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>
                <strong>${escapeHtml(app.displayName)}</strong>
                ${app.description ? `<br><small class="text-muted">${escapeHtml(app.description.substring(0, 60))}${app.description.length > 60 ? '...' : ''}</small>` : ''}
            </td>
            <td>${escapeHtml(app.publisher || 'N/A')}</td>
            <td><code>${escapeHtml(app.fileName || 'N/A')}</code></td>
            <td>${formatFileSize(app.size)}</td>
            <td>${formatDate(app.lastModifiedDateTime)}</td>
            <td>
                <button onclick="viewAppDetails('${app.id}')" class="btn-icon" title="View Details">👁️</button>
                <a href="https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsWindowsMenu/~/windowsApps"
                   target="_blank" class="btn-icon" title="Open in Intune Portal">🔗</a>
            </td>
        `;
        tbody.appendChild(row);
    });
}

// Filter apps by search query
function filterApps(query) {
    const filtered = allApps.filter(app => {
        const searchStr = query.toLowerCase();
        return (
            app.displayName.toLowerCase().includes(searchStr) ||
            (app.publisher && app.publisher.toLowerCase().includes(searchStr)) ||
            (app.fileName && app.fileName.toLowerCase().includes(searchStr))
        );
    });

    displayApps(filtered);
    updateAppCount(filtered.length, allApps.length);
}

// View app details in side panel
async function viewAppDetails(appId) {
    const panel = document.getElementById('detailsPanel');
    const content = document.getElementById('detailsContent');

    // Show panel with loading state
    panel.classList.add('open');
    content.innerHTML = '<div class="loading-spinner"><div class="spinner"></div><p>Loading details...</p></div>';

    try {
        // Fetch app details and deployment status in parallel
        const [detailsResponse, statusResponse] = await Promise.all([
            fetch(`${API_BASE}/api/intune/apps/${appId}`),
            fetch(`${API_BASE}/api/intune/apps/${appId}/status`)
        ]);

        const detailsData = await detailsResponse.json();
        const statusData = await statusResponse.json();

        if (!detailsData.success) {
            throw new Error(detailsData.error || 'Failed to load app details');
        }

        currentApp = detailsData.app;
        const deploymentStatus = statusData.success ? statusData.summary : null;
        renderAppDetails(detailsData.app, detailsData.assignments, deploymentStatus);

    } catch (error) {
        console.error('Error loading app details:', error);
        content.innerHTML = `<div class="error-message">Failed to load app details: ${error.message}</div>`;
    }
}

// Render app details in side panel
function renderAppDetails(app, assignments, deploymentStatus) {
    const content = document.getElementById('detailsContent');

    const assignmentCount = assignments ? assignments.length : 0;
    const hasAssignments = assignmentCount > 0;

    // Deployment Status Section
    let deploymentHTML = '';
    if (deploymentStatus) {
        const total = deploymentStatus.installed + deploymentStatus.failed + deploymentStatus.notInstalled + deploymentStatus.pending;
        deploymentHTML = `
            <div class="detail-section">
                <h4>📊 Deployment Status</h4>
                ${total > 0 ? `
                    <div class="status-summary">
                        <div class="status-item status-success">
                            <span class="status-icon">✅</span>
                            <span class="status-label">Installed</span>
                            <span class="status-count">${deploymentStatus.installed}</span>
                        </div>
                        <div class="status-item status-danger">
                            <span class="status-icon">❌</span>
                            <span class="status-label">Failed</span>
                            <span class="status-count">${deploymentStatus.failed}</span>
                        </div>
                        <div class="status-item status-warning">
                            <span class="status-icon">⏳</span>
                            <span class="status-label">Pending</span>
                            <span class="status-count">${deploymentStatus.pending}</span>
                        </div>
                        <div class="status-item status-info">
                            <span class="status-icon">📭</span>
                            <span class="status-label">Not Installed</span>
                            <span class="status-count">${deploymentStatus.notInstalled}</span>
                        </div>
                    </div>
                ` : '<p>No deployment data available yet</p>'}
            </div>
        `;
    }

    content.innerHTML = `
        <div class="detail-section">
            <h4>ℹ️ Basic Information</h4>
            <table class="detail-table">
                <tr><td><strong>Display Name:</strong></td><td>${escapeHtml(app.displayName)}</td></tr>
                <tr><td><strong>Publisher:</strong></td><td>${escapeHtml(app.publisher || 'N/A')}</td></tr>
                <tr><td><strong>Description:</strong></td><td>${escapeHtml(app.description || 'N/A')}</td></tr>
                <tr><td><strong>File Name:</strong></td><td><code>${escapeHtml(app.fileName || 'N/A')}</code></td></tr>
                <tr><td><strong>Size:</strong></td><td>${formatFileSize(app.size)}</td></tr>
                <tr><td><strong>Content Version:</strong></td><td>${escapeHtml(app.committedContentVersion || 'N/A')}</td></tr>
            </table>
        </div>

        ${deploymentHTML}

        <div class="detail-section">
            <h4>⚙️ Installation Settings</h4>
            <table class="detail-table">
                <tr><td><strong>Setup File:</strong></td><td><code>${escapeHtml(app.setupFilePath || 'N/A')}</code></td></tr>
                <tr><td><strong>Install Command:</strong></td><td><code>${escapeHtml(app.installCommandLine || 'N/A')}</code></td></tr>
                <tr><td><strong>Uninstall Command:</strong></td><td><code>${escapeHtml(app.uninstallCommandLine || 'N/A')}</code></td></tr>
            </table>
        </div>

        <div class="detail-section">
            <h4>📋 Requirements</h4>
            <table class="detail-table">
                <tr><td><strong>Architecture:</strong></td><td>${app.applicability?.architecture || 'N/A'}</td></tr>
                <tr><td><strong>Min OS Version:</strong></td><td>${getMinOSVersion(app.applicability)}</td></tr>
            </table>
        </div>

        <div class="detail-section">
            <h4>👥 Assignments</h4>
            <p>${hasAssignments ? `Assigned to <strong>${assignmentCount}</strong> group(s)` : 'Not assigned to any groups yet'}</p>
            ${hasAssignments ? `
                <ul class="assignment-list">
                    ${assignments.map(a => `<li><strong>${a.intent}</strong>: ${a.targetGroupId || 'All Users/Devices'}</li>`).join('')}
                </ul>
            ` : ''}
            <button onclick="showAssignmentModal('${app.id}')" class="btn btn-primary" style="margin-top: 15px;">
                ➕ Assign to Group
            </button>
        </div>

        <div class="detail-section">
            <h4>🔧 Metadata</h4>
            <table class="detail-table">
                <tr><td><strong>App ID:</strong></td><td><code>${app.id}</code></td></tr>
                <tr><td><strong>Created:</strong></td><td>${formatDate(app.createdDateTime)}</td></tr>
                <tr><td><strong>Last Modified:</strong></td><td>${formatDate(app.lastModifiedDateTime)}</td></tr>
            </table>
        </div>

        <div class="detail-actions">
            <a href="https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppDetailsMenuBlade/overviewMenuItemKey/~/quickViewAppId/${app.id}"
               target="_blank" class="btn btn-primary">🔗 Open in Intune Portal</a>
        </div>
    `;
}

// Show assignment modal
async function showAssignmentModal(appId) {
    // Create modal HTML
    const modalHTML = `
        <div class="modal" id="assignmentModal" onclick="closeAssignmentModal(event)">
            <div class="modal-content" onclick="event.stopPropagation()">
                <div class="modal-header">
                    <h2>➕ Assign App to Group</h2>
                    <button onclick="closeAssignmentModal()" class="close-btn">✕</button>
                </div>
                <div class="modal-body">
                    <div id="assignmentForm">
                        <div class="form-group">
                            <label for="groupSelect">Select Group *</label>
                            <select id="groupSelect" class="form-control">
                                <option value="">Loading groups...</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="intentSelect">Deployment Intent *</label>
                            <select id="intentSelect" class="form-control">
                                <option value="required">Required (Auto-install)</option>
                                <option value="available">Available (User can install)</option>
                                <option value="uninstall">Uninstall</option>
                            </select>
                        </div>
                        <div style="margin-top: 20px; display: flex; gap: 10px;">
                            <button onclick="assignAppToGroup('${appId}')" class="btn btn-primary">Assign App</button>
                            <button onclick="closeAssignmentModal()" class="btn btn-secondary">Cancel</button>
                        </div>
                    </div>
                    <div id="assignmentStatus" style="display: none; margin-top: 20px;"></div>
                </div>
            </div>
        </div>
    `;

    // Add modal to page
    document.body.insertAdjacentHTML('beforeend', modalHTML);

    // Load groups
    try {
        const response = await fetch(`${API_BASE}/api/intune/groups`);
        const data = await response.json();

        if (data.success && data.groups) {
            const select = document.getElementById('groupSelect');
            select.innerHTML = '<option value="">Select a group...</option>' +
                data.groups.map(g => `<option value="${g.id}">${escapeHtml(g.displayName)}</option>`).join('');
        }
    } catch (error) {
        console.error('Error loading groups:', error);
        document.getElementById('groupSelect').innerHTML = '<option value="">Error loading groups</option>';
    }
}

// Close assignment modal
function closeAssignmentModal(event) {
    if (!event || event.target.className === 'modal') {
        const modal = document.getElementById('assignmentModal');
        if (modal) modal.remove();
    }
}

// Assign app to group
async function assignAppToGroup(appId) {
    const groupId = document.getElementById('groupSelect').value;
    const intent = document.getElementById('intentSelect').value;
    const statusDiv = document.getElementById('assignmentStatus');

    if (!groupId) {
        alert('Please select a group');
        return;
    }

    statusDiv.style.display = 'block';
    statusDiv.innerHTML = '<div class="spinner"></div><p>Creating assignment...</p>';

    try {
        const response = await fetch(`${API_BASE}/api/intune/apps/${appId}/assign`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ groupId, intent })
        });

        const data = await response.json();

        if (data.success) {
            statusDiv.innerHTML = '<p style="color: var(--success-color);">✅ App assigned successfully!</p>';
            setTimeout(() => {
                closeAssignmentModal();
                // Refresh details panel
                viewAppDetails(appId);
            }, 1500);
        } else {
            throw new Error(data.error || 'Failed to assign app');
        }
    } catch (error) {
        console.error('Error assigning app:', error);
        statusDiv.innerHTML = `<p style="color: var(--danger-color);">❌ ${error.message}</p>`;
    }
}

// Close details panel
function closeDetailsPanel() {
    document.getElementById('detailsPanel').classList.remove('open');
    currentApp = null;
}

// Update app count badge
function updateAppCount(showing, total = null) {
    const badge = document.getElementById('appCount');
    if (total && showing !== total) {
        badge.textContent = `${showing} of ${total} apps`;
    } else {
        badge.textContent = `${showing} app${showing !== 1 ? 's' : ''}`;
    }
}

// Update last sync timestamp
function updateLastSync(timestamp) {
    const elem = document.getElementById('lastSync');
    if (timestamp) {
        const date = new Date(timestamp);
        elem.textContent = `Last synced: ${date.toLocaleTimeString()}`;
    }
}

// Helper: Format file size
function formatFileSize(bytes) {
    if (!bytes || bytes === 0) return 'N/A';
    const units = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + units[i];
}

// Helper: Format date
function formatDate(dateStr) {
    if (!dateStr) return 'N/A';
    const date = new Date(dateStr);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}

// Helper: Get minimum OS version
function getMinOSVersion(applicability) {
    if (!applicability?.minimumSupportedOperatingSystem) return 'N/A';
    const os = applicability.minimumSupportedOperatingSystem;

    // Find the first true value
    for (const [key, value] of Object.entries(os)) {
        if (value === true && key.startsWith('v')) {
            // Convert v10_1809 to "Windows 10 1809"
            const version = key.replace('v', '').replace('_', ' ');
            return `Windows ${version}`;
        }
    }
    return 'N/A';
}

// Helper: Escape HTML
function escapeHtml(text) {
    if (!text) return '';
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.toString().replace(/[&<>"']/g, m => map[m]);
}
