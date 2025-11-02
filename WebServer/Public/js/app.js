// Package Factory v2.0 - Frontend Logic

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    loadConfig();
    initTheme();
});

// API Base URL
const API_BASE = '';

// HTML Escape helper function
function escapeHtml(text) {
    if (!text) return '';
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;',
        '\\': '&#92;'
    };
    return String(text).replace(/[&<>"'\\]/g, m => map[m]);
}

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

// Installer Type Field Management
function updateInstallerFields() {
    const installerType = document.getElementById('installerType').value;

    // MSI Groups
    const msiFilenameGroup = document.getElementById('msi-filename-group');
    const msiParamsGroup = document.getElementById('msi-params-group');
    const msiFilenameInput = document.getElementById('msiFilename');
    const msiParamsInput = document.getElementById('msiSilentParams');

    // EXE Groups
    const exeFilenameGroup = document.getElementById('exe-filename-group');
    const exeParamsGroup = document.getElementById('exe-params-group');
    const exeFilenameInput = document.getElementById('exeFilename');
    const exeParamsInput = document.getElementById('exeSilentParams');

    if (installerType === 'msi') {
        // Show MSI fields
        msiFilenameGroup.style.display = 'flex';
        msiParamsGroup.style.display = 'flex';
        msiFilenameInput.required = false;
        msiParamsInput.required = false;

        // Hide EXE fields
        exeFilenameGroup.style.display = 'none';
        exeParamsGroup.style.display = 'none';
        exeFilenameInput.required = false;
        exeParamsInput.required = false;
    } else {
        // Hide MSI fields
        msiFilenameGroup.style.display = 'none';
        msiParamsGroup.style.display = 'none';
        msiFilenameInput.required = false;
        msiParamsInput.required = false;

        // Show EXE fields
        exeFilenameGroup.style.display = 'flex';
        exeParamsGroup.style.display = 'flex';
        exeFilenameInput.required = true;
        exeParamsInput.required = true;
    }
}

// Load configuration
async function loadConfig() {
    try {
        const response = await fetch(`${API_BASE}/api/config`);
        const config = await response.json();

        // Apply config to form defaults
        document.getElementById('companyPrefix').value = config.CompanyPrefix || 'MSP';
        document.getElementById('appArch').value = config.DefaultArch || 'x64';
        document.getElementById('appLang').value = config.DefaultLang || 'EN';
        document.getElementById('includePSADT').checked = config.IncludePSADT !== false;

        // Store config for settings modal
        window.currentConfig = config;
    } catch (error) {
        console.error('Failed to load config:', error);
    }
}

// Create package
async function createPackage(event) {
    event.preventDefault();

    const form = document.getElementById('package-form');
    const createBtn = document.getElementById('create-btn');
    const resultBox = document.getElementById('result');
    const resultContent = document.getElementById('result-content');

    // Get form data
    const installerType = document.getElementById('installerType').value;

    const data = {
        appVendor: document.getElementById('appVendor').value.trim(),
        appName: document.getElementById('appName').value.trim(),
        appVersion: document.getElementById('appVersion').value.trim(),
        companyPrefix: document.getElementById('companyPrefix').value.trim() || 'MSP',
        appArch: document.getElementById('appArch').value,
        appLang: document.getElementById('appLang').value.trim() || 'EN',
        installerType: installerType,
        msiFilename: installerType === 'msi' ? document.getElementById('msiFilename').value.trim() : '',
        msiSilentParams: installerType === 'msi' ? document.getElementById('msiSilentParams').value.trim() : '',
        exeFilename: installerType === 'exe' ? document.getElementById('exeFilename').value.trim() : '',
        exeSilentParams: installerType === 'exe' ? document.getElementById('exeSilentParams').value.trim() : '',
        processesToClose: document.getElementById('processesToClose').value.trim(),
        includePSADT: document.getElementById('includePSADT').checked
    };

    // Disable button and show loading
    createBtn.disabled = true;
    createBtn.innerHTML = '<span class="spinner"></span> Creating...';

    try {
        const response = await fetch(`${API_BASE}/api/create-package`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });

        const result = await response.json();

        // Show result
        resultBox.style.display = 'block';

        if (result.Success) {
            // Hide result box
            resultBox.style.display = 'none';

            // Show Package Details Modal
            showPackageDetails({
                PackageName: result.PackageName,
                PackagePath: result.PackagePath,
                AppName: data.appName,
                CompanyPrefix: data.companyPrefix,
                IncludePSADT: data.includePSADT
            });

            // Reset form
            form.reset();
            loadConfig(); // Reload defaults
        } else {
            resultBox.className = 'result-box error';
            resultContent.innerHTML = `
                <h3>❌ Error Creating Package</h3>
                <p>${result.Error || 'Unknown error occurred'}</p>
            `;
        }
    } catch (error) {
        resultBox.style.display = 'block';
        resultBox.className = 'result-box error';
        resultContent.innerHTML = `
            <h3>❌ Connection Error</h3>
            <p>Failed to communicate with server: ${error.message}</p>
        `;
    } finally {
        // Re-enable button
        createBtn.disabled = false;
        createBtn.innerHTML = '🎉 Create Package';
    }
}

// Reset form
function resetForm() {
    document.getElementById('package-form').reset();
    document.getElementById('result').style.display = 'none';
    loadConfig(); // Reload defaults
}

// Show settings modal
function showSettings() {
    const modal = document.getElementById('settings-modal');
    modal.style.display = 'flex';

    // Load current config into settings form
    if (window.currentConfig) {
        document.getElementById('settingsCompanyPrefix').value = window.currentConfig.CompanyPrefix || 'MSP';
        document.getElementById('settingsDefaultArch').value = window.currentConfig.DefaultArch || 'x64';
        document.getElementById('settingsDefaultLang').value = window.currentConfig.DefaultLang || 'EN';
        document.getElementById('settingsOutputPath').value = window.currentConfig.OutputPath || './Output';
        document.getElementById('settingsIncludePSADT').checked = window.currentConfig.IncludePSADT !== false;
    }
}

// Close settings modal
function closeSettings() {
    document.getElementById('settings-modal').style.display = 'none';
}

// Save settings
async function saveSettings(event) {
    event.preventDefault();

    const config = {
        CompanyPrefix: document.getElementById('settingsCompanyPrefix').value.trim() || 'MSP',
        DefaultArch: document.getElementById('settingsDefaultArch').value,
        DefaultLang: document.getElementById('settingsDefaultLang').value.trim() || 'EN',
        OutputPath: document.getElementById('settingsOutputPath').value.trim() || './Output',
        IncludePSADT: document.getElementById('settingsIncludePSADT').checked,
        AutoOpenBrowser: true
    };

    try {
        const response = await fetch(`${API_BASE}/api/config`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(config)
        });

        const result = await response.json();

        if (result.success) {
            window.currentConfig = config;
            loadConfig(); // Reload form defaults
            closeSettings();

            // Show success message
            alert('Settings saved successfully!');
        }
    } catch (error) {
        alert('Failed to save settings: ' + error.message);
    }
}

// Show packages modal
async function showPackages() {
    const modal = document.getElementById('packages-modal');
    const packagesList = document.getElementById('packages-list');

    modal.style.display = 'flex';
    packagesList.innerHTML = '<div class="spinner"></div>';

    try {
        const response = await fetch(`${API_BASE}/api/packages`);
        const packages = await response.json();

        if (packages.length === 0) {
            packagesList.innerHTML = '<p class="text-center">No packages created yet.</p>';
        } else {
            packagesList.innerHTML = packages.map(pkg => `
                <div class="package-item">
                    <div class="package-info">
                        <h3>${pkg.name}</h3>
                        <p>Created: ${pkg.created}</p>
                        <p>Path: ${pkg.path}</p>
                    </div>
                    <div class="package-actions">
                        <button class="btn-icon btn-icon-primary" onclick="viewPackageDetails('${pkg.name}')" title="View Details">
                            📋
                        </button>
                        <button class="btn-icon btn-icon-secondary" onclick="useAsTemplate('${pkg.name}')" title="Use as Template">
                            📑
                        </button>
                        <button class="btn-icon btn-icon-danger" onclick="deletePackage('${pkg.name}')" title="Delete Package">
                            🗑️
                        </button>
                    </div>
                </div>
            `).join('');
        }
    } catch (error) {
        packagesList.innerHTML = `<p class="text-center error">Failed to load packages: ${error.message}</p>`;
    }
}

// Close packages modal
function closePackages() {
    document.getElementById('packages-modal').style.display = 'none';
}

// Delete package
async function deletePackage(packageName) {
    if (!confirm(`Are you sure you want to delete package: ${packageName}?`)) {
        return;
    }

    try {
        const response = await fetch(`${API_BASE}/api/packages/${encodeURIComponent(packageName)}`, {
            method: 'DELETE'
        });

        const result = await response.json();

        if (result.success) {
            alert('Package deleted successfully!');
            showPackages(); // Refresh list
        } else {
            alert('Failed to delete package: ' + (result.error || 'Unknown error'));
        }
    } catch (error) {
        alert('Failed to delete package: ' + error.message);
    }
}

// View package details from existing package
async function viewPackageDetails(packageName) {
    try {
        const response = await fetch(`${API_BASE}/api/packages/${encodeURIComponent(packageName)}/details`);
        const result = await response.json();

        if (!result.success) {
            alert('Failed to load package details: ' + (result.error || 'Unknown error'));
            return;
        }

        const pkg = result.package;

        // Close packages modal first
        closePackages();

        // Show details in the package details modal
        const modal = document.getElementById('package-details-modal');
        const content = document.getElementById('package-details-content');

        const appNameNoSpaces = pkg.appName ? pkg.appName.replace(/ /g, '') : 'App';
        const detectionKeyPath = pkg.detectionKey || `HKLM:\\SOFTWARE\\${pkg.companyPrefix}_IntuneAppInstall\\Apps\\${pkg.name}`;

        // Escape all values for safe HTML insertion
        const safeValues = {
            name: escapeHtml(pkg.name),
            vendor: escapeHtml(pkg.vendor || 'N/A'),
            appName: escapeHtml(pkg.appName || 'N/A'),
            version: escapeHtml(pkg.version || 'N/A'),
            architecture: escapeHtml(pkg.architecture || 'N/A'),
            language: escapeHtml(pkg.language || 'N/A'),
            installerType: escapeHtml(pkg.installerType).toUpperCase(),
            path: escapeHtml(pkg.path),
            detectionKey: escapeHtml(detectionKeyPath),
            detectionScript: escapeHtml(pkg.detectionScript || ''),
            installCommand: escapeHtml(pkg.installCommand),
            uninstallCommand: escapeHtml(pkg.uninstallCommand)
        };

        // Build details HTML (similar to creation success, but adapted for existing packages)
        content.innerHTML = `
            <div class="success-banner">
                <h3>📦 Package Details</h3>
                <p><strong>${safeValues.name}</strong></p>
                <p>View and copy deployment information</p>
            </div>

            <div class="details-grid">
                <div class="details-card">
                    <h3>📦 Package Information</h3>
                    <div class="details-row">
                        <span class="details-label">Vendor:</span>
                        <span class="details-value">${safeValues.vendor}</span>
                    </div>
                    <div class="details-row">
                        <span class="details-label">Application:</span>
                        <span class="details-value">${safeValues.appName}</span>
                    </div>
                    <div class="details-row">
                        <span class="details-label">Version:</span>
                        <span class="details-value">${safeValues.version}</span>
                    </div>
                    <div class="details-row">
                        <span class="details-label">Architecture:</span>
                        <span class="details-value">${safeValues.architecture}</span>
                    </div>
                    <div class="details-row">
                        <span class="details-label">Language:</span>
                        <span class="details-value">${safeValues.language}</span>
                    </div>
                    <div class="details-row">
                        <span class="details-label">Installer Type:</span>
                        <span class="details-value">${safeValues.installerType}</span>
                    </div>
                    <div class="details-row">
                        <span class="details-label">Location:</span>
                        <span class="details-value" style="font-size: 11px;">${safeValues.path}</span>
                    </div>
                </div>

                <div class="details-card">
                    <h3>🔍 Registry Detection</h3>
                    <div class="details-row">
                        <span class="details-label">Registry Path:</span>
                    </div>
                    <div class="command-block" style="margin-top: 10px;">
                        <button class="copy-btn" data-copy-text="${safeValues.detectionKey}">📋 Copy</button>
                        <pre>${safeValues.detectionKey}</pre>
                    </div>
                    ${pkg.detectionScript ? `
                    <div class="details-row" style="margin-top: 10px;">
                        <span class="details-label">Detection Script:</span>
                        <span class="details-value">${safeValues.detectionScript}</span>
                    </div>
                    ` : ''}
                </div>
            </div>

            <div class="details-card">
                <h3>⚙️ Installation Commands</h3>
                <strong>Install Command (Interactive):</strong>
                <div class="command-block">
                    <button class="copy-btn" data-copy-text=".\\Invoke-AppDeployToolkit.ps1 -DeploymentType Install -DeployMode Interactive">📋 Copy</button>
                    <pre>.\\Invoke-AppDeployToolkit.ps1 -DeploymentType Install -DeployMode Interactive</pre>
                </div>
                <strong>Install Command (Silent):</strong>
                <div class="command-block">
                    <button class="copy-btn" data-copy-text=".\\Invoke-AppDeployToolkit.ps1 -DeploymentType Install -DeployMode Silent">📋 Copy</button>
                    <pre>.\\Invoke-AppDeployToolkit.ps1 -DeploymentType Install -DeployMode Silent</pre>
                </div>
                <strong>Uninstall Command:</strong>
                <div class="command-block">
                    <button class="copy-btn" data-copy-text=".\\Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall -DeployMode Silent">📋 Copy</button>
                    <pre>.\\Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall -DeployMode Silent</pre>
                </div>
            </div>

            <div class="details-card">
                <h3>☁️ Microsoft Intune Commands</h3>
                <strong>Install Command:</strong>
                <div class="command-block">
                    <button class="copy-btn" data-copy-text="${safeValues.installCommand}">📋 Copy</button>
                    <pre>${safeValues.installCommand}</pre>
                </div>
                <strong>Uninstall Command:</strong>
                <div class="command-block">
                    <button class="copy-btn" data-copy-text="${safeValues.uninstallCommand}">📋 Copy</button>
                    <pre>${safeValues.uninstallCommand}</pre>
                </div>
                ${pkg.detectionScript ? `
                <strong>Detection Script:</strong>
                <div class="command-block">
                    <button class="copy-btn" data-copy-text="${safeValues.detectionScript}">📋 Copy</button>
                    <pre>${safeValues.detectionScript}</pre>
                </div>
                ` : ''}
            </div>

            <div class="quick-actions">
                <button class="btn btn-primary" data-folder-path="${safeValues.path}" onclick="openPackageFolder(this.getAttribute('data-folder-path'))">📂 Open Package Folder</button>
                <button class="btn btn-secondary" onclick="closePackageDetails()">✅ Done</button>
            </div>
        `;

        // Add event listeners for copy buttons with data-copy-text
        content.querySelectorAll('.copy-btn[data-copy-text]').forEach(btn => {
            btn.addEventListener('click', function() {
                const text = this.getAttribute('data-copy-text');
                copyToClipboard(this, text);
            });
        });

        modal.style.display = 'flex';
    } catch (error) {
        alert('Failed to load package details: ' + error.message);
    }
}

// Use existing package as template
async function useAsTemplate(packageName) {
    try {
        const response = await fetch(`${API_BASE}/api/packages/${encodeURIComponent(packageName)}/details`);
        const result = await response.json();

        if (!result.success) {
            alert('Failed to load package details: ' + (result.error || 'Unknown error'));
            return;
        }

        const pkg = result.package;

        // Close packages modal
        closePackages();

        // Pre-fill the main form with package data
        document.getElementById('app-vendor').value = pkg.vendor || '';
        document.getElementById('app-name').value = pkg.appName || '';
        document.getElementById('app-version').value = pkg.version || '';
        document.getElementById('app-arch').value = pkg.architecture || 'x64';
        document.getElementById('app-lang').value = pkg.language || 'EN';
        document.getElementById('app-revision').value = pkg.revision || '01';

        // Set installer type
        const installerType = pkg.installerType.toLowerCase();
        if (installerType === 'msi' || installerType === 'exe') {
            document.getElementById('installer-type').value = installerType;
            toggleInstallerOptions();
        }

        // Scroll to top of form
        window.scrollTo({ top: 0, behavior: 'smooth' });

        // Show success notification
        alert(`Template loaded from: ${pkg.name}\n\nPlease update the version number and adjust other fields as needed before creating the new package.`);
    } catch (error) {
        alert('Failed to load template: ' + error.message);
    }
}

// Show logs modal
async function showLogs() {
    const modal = document.getElementById('logs-modal');
    modal.style.display = 'flex';
    await loadLogs();
}

// Close logs modal
function closeLogs() {
    document.getElementById('logs-modal').style.display = 'none';
}

// Load logs from API
async function loadLogs() {
    const logsContainer = document.getElementById('logs-container');
    const logsCount = document.getElementById('logs-count');
    const level = document.getElementById('logLevelFilter').value;
    const limit = document.getElementById('logLimitFilter').value;

    logsContainer.innerHTML = '<div class="spinner"></div>';

    try {
        const params = new URLSearchParams();
        if (level && level !== 'All') params.append('level', level);
        if (limit) params.append('limit', limit);

        const response = await fetch(`${API_BASE}/api/logs?${params.toString()}`);
        const result = await response.json();

        // Ensure logs is an array (handle null/undefined)
        const logs = result.logs || [];

        if (result.success && logs.length > 0) {
            logsContainer.innerHTML = logs.map(log => {
                const levelClass = log.Level.toLowerCase();
                return `
                    <div class="log-entry log-${levelClass}">
                        <span class="log-timestamp">${log.Timestamp}</span>
                        <span class="log-level ${levelClass}">${log.Level}</span>
                        <span class="log-component">[${log.Component}]</span>
                        <span class="log-message">${escapeHtml(log.Message)}</span>
                        <span class="log-file">${log.File}</span>
                    </div>
                `;
            }).join('');

            logsCount.textContent = `${logs.length} log entries`;

            // Auto-scroll to bottom
            logsContainer.scrollTop = logsContainer.scrollHeight;
        } else {
            logsContainer.innerHTML = '<div style="padding: 20px; text-align: center; color: #858585;">No logs available</div>';
            logsCount.textContent = '0 log entries';
        }
    } catch (error) {
        logsContainer.innerHTML = `<div style="padding: 20px; color: #f44336;">Failed to load logs: ${error.message}</div>`;
        logsCount.textContent = 'Error';
    }
}

// Download CMTrace log file
async function downloadLogs() {
    try {
        window.location.href = `${API_BASE}/api/logs/download`;
    } catch (error) {
        alert('Failed to download log file: ' + error.message);
    }
}

// Clear logs
async function clearLogs() {
    if (!confirm('Are you sure you want to clear all logs?')) {
        return;
    }

    try {
        const response = await fetch(`${API_BASE}/api/logs`, {
            method: 'DELETE'
        });

        const result = await response.json();

        if (result.success) {
            alert('Logs cleared successfully!');
            loadLogs();
        } else {
            alert('Failed to clear logs: ' + (result.error || 'Unknown error'));
        }
    } catch (error) {
        alert('Failed to clear logs: ' + error.message);
    }
}

// Escape HTML for log display
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Close modals when clicking outside
window.onclick = function(event) {
    const settingsModal = document.getElementById('settings-modal');
    const packagesModal = document.getElementById('packages-modal');
    const logsModal = document.getElementById('logs-modal');
    const detailsModal = document.getElementById('package-details-modal');

    if (event.target === settingsModal) {
        closeSettings();
    }
    if (event.target === packagesModal) {
        closePackages();
    }
    if (event.target === logsModal) {
        closeLogs();
    }
    if (event.target === detailsModal) {
        closePackageDetails();
    }
}

// Show package details modal
function showPackageDetails(packageData) {
    const modal = document.getElementById('package-details-modal');
    const content = document.getElementById('package-details-content');

    const appNameNoSpaces = packageData.AppName ? packageData.AppName.replace(/ /g, '') : 'App';
    const currentDate = new Date().toLocaleString();

    // Build details HTML
    content.innerHTML = '<div class="success-banner"><h3>✅ Package Created Successfully!</h3><p><strong>' + packageData.PackageName + '</strong></p><p>Your PSADT package is ready for deployment</p></div><div class="details-grid"><div class="details-card"><h3>📦 Package Information</h3><div class="details-row"><span class="details-label">Package Name:</span><span class="details-value">' + packageData.PackageName + '</span></div><div class="details-row"><span class="details-label">Location:</span><span class="details-value" style="font-size: 11px;">' + packageData.PackagePath + '</span></div><div class="details-row"><span class="details-label">Created:</span><span class="details-value">' + currentDate + '</span></div></div><div class="details-card"><h3>🔍 Registry Detection</h3><div class="details-row"><span class="details-label">Registry Path:</span></div><div class="command-block" style="margin-top: 10px;"><button class="copy-btn" onclick="copyToClipboard(this, \'HKLM:\\\\SOFTWARE\\\\' + (packageData.CompanyPrefix || 'MSP') + '_IntuneAppInstall\\\\Apps\\\\' + packageData.PackageName + '\')">📋 Copy</button><pre>HKLM:\\SOFTWARE\\' + (packageData.CompanyPrefix || 'MSP') + '_IntuneAppInstall\\Apps\\' + packageData.PackageName + '</pre></div><div class="details-row" style="margin-top: 10px;"><span class="details-label">Detection Script:</span><span class="details-value">Detect-' + appNameNoSpaces + '.ps1</span></div></div></div><div class="details-card"><h3>⚙️ Installation Commands</h3><strong>Install Command (Interactive):</strong><div class="command-block"><button class="copy-btn" onclick="copyToClipboard(this, \'.\\\\Invoke-AppDeployToolkit.ps1 -DeploymentType Install -DeployMode Interactive\')">📋 Copy</button><pre>.\\Invoke-AppDeployToolkit.ps1 -DeploymentType Install -DeployMode Interactive</pre></div><strong>Install Command (Silent):</strong><div class="command-block"><button class="copy-btn" onclick="copyToClipboard(this, \'.\\\\Invoke-AppDeployToolkit.ps1 -DeploymentType Install -DeployMode Silent\')">📋 Copy</button><pre>.\\Invoke-AppDeployToolkit.ps1 -DeploymentType Install -DeployMode Silent</pre></div><strong>Uninstall Command:</strong><div class="command-block"><button class="copy-btn" onclick="copyToClipboard(this, \'.\\\\Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall -DeployMode Silent\')">📋 Copy</button><pre>.\\Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall -DeployMode Silent</pre></div></div><div class="details-card"><h3>☁️ Microsoft Intune Commands</h3><strong>Install Command:</strong><div class="command-block"><button class="copy-btn" onclick="copyToClipboard(this, \'powershell.exe -ExecutionPolicy Bypass -File \\".\\\\Invoke-AppDeployToolkit.ps1\\" -DeploymentType Install -DeployMode Silent\')">📋 Copy</button><pre>powershell.exe -ExecutionPolicy Bypass -File ".\\Invoke-AppDeployToolkit.ps1" -DeploymentType Install -DeployMode Silent</pre></div><strong>Uninstall Command:</strong><div class="command-block"><button class="copy-btn" onclick="copyToClipboard(this, \'powershell.exe -ExecutionPolicy Bypass -File \\".\\\\Invoke-AppDeployToolkit.ps1\\" -DeploymentType Uninstall -DeployMode Silent\')">📋 Copy</button><pre>powershell.exe -ExecutionPolicy Bypass -File ".\\Invoke-AppDeployToolkit.ps1" -DeploymentType Uninstall -DeployMode Silent</pre></div><strong>Detection Script:</strong><div class="command-block"><button class="copy-btn" onclick="copyToClipboard(this, \'Detect-' + appNameNoSpaces + '.ps1\')">📋 Copy</button><pre>Detect-' + appNameNoSpaces + '.ps1</pre></div></div><div class="details-card"><h3>📁 Package Structure</h3><div class="file-tree"><div class="file-tree-item folder">📦 ' + packageData.PackageName + '/</div><div class="file-tree-item file" style="margin-left: 20px;">📄 Invoke-AppDeployToolkit.ps1</div><div class="file-tree-item file" style="margin-left: 20px;">📄 Detect-' + appNameNoSpaces + '.ps1</div><div class="file-tree-item file" style="margin-left: 20px;">📄 README.md</div><div class="file-tree-item folder" style="margin-left: 20px;">📁 Files/</div><div class="file-tree-item file" style="margin-left: 40px;">📄 README.md (Place installers here)</div><div class="file-tree-item folder" style="margin-left: 40px;">📁 Config/</div>' + (packageData.IncludePSADT ? '<div class="file-tree-item folder" style="margin-left: 20px;">📁 PSAppDeployToolkit/ (PSADT 4.1.5)</div>' : '') + '</div></div><div class="details-card"><h3>📋 Next Steps</h3><ol style="margin: 10px 0; padding-left: 20px;"><li>Navigate to the package folder</li><li>Copy your installer to <strong>Files/</strong> directory</li>' + (!packageData.IncludePSADT ? '<li>Add PSAppDeployToolkit 4.1.5 to package</li>' : '') + '<li>Test the package locally with <code>-DeployMode Interactive</code></li><li>Create .intunewin package using IntuneWinAppUtil.exe</li><li>Upload to Microsoft Intune</li></ol></div><div class="quick-actions"><button class="btn btn-primary" onclick="openPackageFolder(\'' + packageData.PackagePath + '\')">📂 Open Package Folder</button><button class="btn btn-secondary" onclick="closePackageDetails()">✅ Done</button><button class="btn btn-secondary" onclick="closePackageDetails(); resetForm();">🔄 Create Another Package</button></div>';

    modal.style.display = 'flex';
}

// Close package details modal
function closePackageDetails() {
    document.getElementById('package-details-modal').style.display = 'none';
}

// Copy text to clipboard
async function copyToClipboard(button, text) {
    try {
        await navigator.clipboard.writeText(text);

        // Visual feedback
        const originalText = button.textContent;
        button.textContent = '✅ Copied!';
        button.classList.add('copied');

        setTimeout(() => {
            button.textContent = originalText;
            button.classList.remove('copied');
        }, 2000);
    } catch (error) {
        alert('Failed to copy: ' + error.message);
    }
}

// Open package folder
function openPackageFolder(path) {
    alert('Package location:\n' + path + '\n\nPlease navigate to this folder in your file explorer.');
}

// Keyboard shortcuts
document.addEventListener('keydown', (event) => {
    // ESC to close modals
    if (event.key === 'Escape') {
        closeSettings();
        closePackages();
        closeLogs();
        closePackageDetails();
    }
});
