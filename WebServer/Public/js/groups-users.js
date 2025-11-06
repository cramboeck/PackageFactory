// Groups & Users Management
const API_BASE = window.location.origin;
let allGroups = [];
let allUsers = [];

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

// Tab Management
function showTab(tabName) {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));

    event.target.classList.add('active');
    document.getElementById(tabName + 'Tab').classList.add('active');

    if (tabName === 'groups' && allGroups.length === 0) {
        loadGroups();
    } else if (tabName === 'users' && allUsers.length === 0) {
        loadUsers();
    }
}

// Load Groups
async function loadGroups() {
    document.getElementById('groupsLoading').style.display = 'block';
    try {
        const response = await fetch(API_BASE + '/api/intune/groups');
        const data = await response.json();

        if (data.success && data.groups) {
            allGroups = data.groups;
            displayGroups(allGroups);
            document.getElementById('groupCount').textContent = allGroups.length + ' groups';
        }
    } catch (error) {
        console.error('Error loading groups:', error);
        alert('Failed to load groups');
    } finally {
        document.getElementById('groupsLoading').style.display = 'none';
        document.getElementById('groupsContainer').style.display = 'block';
    }
}

// Display Groups
function displayGroups(groups) {
    const tbody = document.getElementById('groupsTableBody');
    tbody.innerHTML = '';

    groups.forEach(group => {
        const row = document.createElement('tr');
        row.innerHTML = '<td><strong>' + escapeHtml(group.displayName) + '</strong></td>' +
            '<td>' + escapeHtml(group.description || 'N/A') + '</td>' +
            '<td><button class="btn btn-secondary btn-sm" onclick="viewGroupMembers(\'' + group.id + '\', \'' + escapeHtml(group.displayName) + '\')">👁️ View Members</button></td>' +
            '<td><button class="btn btn-secondary btn-sm" onclick="addMemberToGroup(\'' + group.id + '\', \'' + escapeHtml(group.displayName) + '\')">➕ Add Member</button> ' +
            '<button class="btn btn-danger btn-sm" onclick="deleteGroup(\'' + group.id + '\', \'' + escapeHtml(group.displayName) + '\')">🗑️ Delete</button></td>';
        tbody.appendChild(row);
    });
}

// Load Users
async function loadUsers() {
    document.getElementById('usersLoading').style.display = 'block';
    try {
        const response = await fetch(API_BASE + '/api/intune/users');
        const data = await response.json();

        if (data.success && data.users) {
            allUsers = data.users;
            displayUsers(allUsers);
            document.getElementById('userCount').textContent = allUsers.length + ' users';
        }
    } catch (error) {
        console.error('Error loading users:', error);
        alert('Failed to load users');
    } finally {
        document.getElementById('usersLoading').style.display = 'none';
        document.getElementById('usersContainer').style.display = 'block';
    }
}

// Display Users
function displayUsers(users) {
    const tbody = document.getElementById('usersTableBody');
    tbody.innerHTML = '';

    users.forEach(user => {
        const row = document.createElement('tr');
        row.innerHTML = '<td><strong>' + escapeHtml(user.displayName) + '</strong></td>' +
            '<td>' + escapeHtml(user.userPrincipalName || user.mail || 'N/A') + '</td>' +
            '<td>' + escapeHtml(user.department || 'N/A') + '</td>' +
            '<td>' + escapeHtml(user.jobTitle || 'N/A') + '</td>' +
            '<td><button class="btn btn-secondary btn-sm" onclick="viewUserGroups(\'' + user.id + '\', \'' + escapeHtml(user.displayName) + '\')">👁️ View Groups</button></td>';
        tbody.appendChild(row);
    });
}

// View Group Members
async function viewGroupMembers(groupId, groupName) {
    const response = await fetch(API_BASE + '/api/intune/groups/' + groupId + '/members');
    const data = await response.json();

    if (data.success) {
        let membersHtml = '<ul>';
        if (data.members.length === 0) {
            membersHtml += '<li>No members yet</li>';
        } else {
            data.members.forEach(member => {
                membersHtml += '<li>' + escapeHtml(member.displayName) + ' (' + escapeHtml(member.userPrincipalName || 'N/A') + ') ' +
                    '<button class="btn btn-danger btn-sm" onclick="removeMember(\'' + groupId + '\', \'' + member.id + '\', \'' + groupName + '\')">Remove</button></li>';
            });
        }
        membersHtml += '</ul>';

        const modal = '<div class="modal" onclick="this.remove()"><div class="modal-content" onclick="event.stopPropagation()">' +
            '<div class="modal-header"><h2>Members of ' + escapeHtml(groupName) + '</h2>' +
            '<button onclick="this.closest(\'.\modal\').remove()" class="close-btn">✕</button></div>' +
            '<div class="modal-body">' + membersHtml + '</div></div></div>';
        document.body.insertAdjacentHTML('beforeend', modal);
    }
}

// View User Groups
async function viewUserGroups(userId, userName) {
    const response = await fetch(API_BASE + '/api/intune/users/' + userId + '/groups');
    const data = await response.json();

    if (data.success) {
        let groupsHtml = '<ul>';
        if (data.groups.length === 0) {
            groupsHtml += '<li>Not a member of any groups</li>';
        } else {
            data.groups.forEach(group => {
                groupsHtml += '<li>' + escapeHtml(group.displayName) + '</li>';
            });
        }
        groupsHtml += '</ul>';

        const modal = '<div class="modal" onclick="this.remove()"><div class="modal-content" onclick="event.stopPropagation()">' +
            '<div class="modal-header"><h2>Groups for ' + escapeHtml(userName) + '</h2>' +
            '<button onclick="this.closest(\'.modal\').remove()" class="close-btn">✕</button></div>' +
            '<div class="modal-body">' + groupsHtml + '</div></div></div>';
        document.body.insertAdjacentHTML('beforeend', modal);
    }
}

// Helper Functions
function escapeHtml(text) {
    if (!text) return '';
    const map = {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;'};
    return text.toString().replace(/[&<>"']/g, m => map[m]);
}

// Init
document.addEventListener('DOMContentLoaded', () => {
    initTheme();
    loadGroups();

    // Search
    document.getElementById('groupSearch').addEventListener('input', e => {
        const filtered = allGroups.filter(g => g.displayName.toLowerCase().includes(e.target.value.toLowerCase()));
        displayGroups(filtered);
    });

    document.getElementById('userSearch').addEventListener('input', e => {
        const filtered = allUsers.filter(u => u.displayName.toLowerCase().includes(e.target.value.toLowerCase()));
        displayUsers(filtered);
    });
});
