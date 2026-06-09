// Activity History
const API_BASE = window.location.origin;

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

// Load Activities
async function loadActivities() {
    document.getElementById('loadingState').style.display = 'block';
    try {
        const response = await fetch(API_BASE + '/api/activity/history?limit=100');
        const data = await response.json();

        if (data.success) {
            displayTimeline(data.activities);
            document.getElementById('activityCount').textContent = data.activities.length + ' activities';
        }
    } catch (error) {
        console.error('Error loading activities:', error);
        document.getElementById('timelineContainer').innerHTML = '<p class="error-message">Failed to load activity history</p>';
    } finally {
        document.getElementById('loadingState').style.display = 'none';
    }
}

// Display Timeline
function displayTimeline(activities) {
    const container = document.getElementById('timelineContainer');
    container.innerHTML = '';

    if (activities.length === 0) {
        container.innerHTML = '<p>No activities yet</p>';
        return;
    }

    // Group by date
    const grouped = {};
    activities.forEach(activity => {
        const date = new Date(activity.timestamp).toLocaleDateString();
        if (!grouped[date]) grouped[date] = [];
        grouped[date].push(activity);
    });

    // Render timeline
    Object.keys(grouped).forEach(date => {
        const dateGroup = document.createElement('div');
        dateGroup.className = 'timeline-date-group';
        dateGroup.innerHTML = '<h3>' + date + '</h3>';

        grouped[date].forEach(activity => {
            const item = document.createElement('div');
            item.className = 'timeline-item' + (activity.success ? '' : ' timeline-item-error');

            const icon = getActionIcon(activity.action_type);
            const time = new Date(activity.timestamp).toLocaleTimeString();
            const message = formatActivityMessage(activity);

            item.innerHTML = '<div class="timeline-icon">' + icon + '</div>' +
                '<div class="timeline-content">' +
                '<div class="timeline-time">' + time + '</div>' +
                '<div class="timeline-message">' + message + '</div>' +
                (activity.error_message ? '<div class="timeline-error">❌ ' + activity.error_message + '</div>' : '') +
                '</div>';

            dateGroup.appendChild(item);
        });

        container.appendChild(dateGroup);
    });
}

// Get Action Icon
function getActionIcon(actionType) {
    const icons = {
        'app_upload': '📦',
        'app_assign': '✅',
        'group_create': '🏢',
        'group_delete': '🗑️',
        'member_add': '➕',
        'member_remove': '➖',
        'server_start': '🚀'
    };
    return icons[actionType] || '📋';
}

// Format Activity Message
function formatActivityMessage(activity) {
    switch (activity.action_type) {
        case 'app_upload':
            return '<strong>App uploaded:</strong> ' + activity.app_name;
        case 'app_assign':
            return '<strong>App assigned:</strong> ' + activity.app_name + ' to ' + activity.group_name + ' (' + activity.intent + ')';
        case 'group_create':
            return '<strong>Group created:</strong> ' + activity.group_name;
        case 'group_delete':
            return '<strong>Group deleted:</strong> ' + activity.group_name;
        case 'member_add':
            return '<strong>Member added:</strong> ' + activity.user_name + ' to ' + activity.group_name;
        case 'member_remove':
            return '<strong>Member removed:</strong> ' + activity.user_name + ' from ' + activity.group_name;
        case 'server_start':
            return '<strong>Server started</strong>';
        default:
            return activity.action_type;
    }
}

// Init
document.addEventListener('DOMContentLoaded', () => {
    initTheme();
    loadActivities();
});
