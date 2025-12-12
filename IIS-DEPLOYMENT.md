# IIS Deployment Guide for CDS Hooks Sandbox

## Prerequisites
1. Windows Server or Windows 10/11 with IIS installed
2. IIS URL Rewrite Module: https://www.iis.net/downloads/microsoft/url-rewrite
3. iisnode for Node.js applications: https://github.com/Azure/iisnode/releases
4. Node.js installed on the server

## Part 1: Deploy CDS Hooks Sandbox (Static Files)

### Step 1: Build the Production Bundle
```cmd
cd C:\GIT\dcopy\sandbox
npm run build
```
This creates production files in the `build/` folder.

### Step 2: Create IIS Website
1. Open IIS Manager
2. Right-click "Sites" → "Add Website"
3. Configure:
   - Site name: `CDS-Hooks-Sandbox`
   - Physical path: `C:\GIT\dcopy\sandbox\build`
   - Binding: HTTP, Port 80 (or 8080)
   - Host name: `sandbox.local` (optional)

### Step 3: Configure web.config for SPA Routing
The web.config file has been created in the build folder to handle client-side routing.

### Step 4: Set Permissions
1. Right-click the site folder → Properties → Security
2. Add `IIS_IUSRS` and `IUSR` with Read & Execute permissions

---

## Part 2: Deploy Mock CDS Service (Node.js Application)

### Step 1: Install iisnode
Download and install from: https://github.com/Azure/iisnode/releases

### Step 2: Create IIS Website for Node Service
1. Open IIS Manager
2. Right-click "Sites" → "Add Website"
3. Configure:
   - Site name: `CDS-Mock-Service`
   - Physical path: `C:\GIT\dcopy\sandbox\mock-cds-service`
   - Binding: HTTP, Port 3001
   - Host name: `cds-service.local` (optional)

### Step 3: Configure Application Pool
1. Select the Application Pool for `CDS-Mock-Service`
2. Set ".NET CLR version" to "No Managed Code"
3. Set "Pipeline mode" to "Integrated"

### Step 4: Set Permissions
1. Right-click mock-cds-service folder → Properties → Security
2. Add `IIS_IUSRS` with Modify permissions (Node needs write access for logs)

---

## Part 3: Testing

### Test Sandbox
Open browser: `http://localhost` (or your configured port)

### Test Mock Service
```powershell
Invoke-RestMethod -Uri "http://localhost:3001/cds-services" -Method Get
```

### Connect Sandbox to Service
1. In sandbox, click "+" button
2. Enter: `http://localhost:3001/cds-services`
3. Navigate to Rx Sign view

---

## Troubleshooting

### Sandbox Issues
- **404 errors on refresh**: Check web.config URL rewrite rules are present
- **403 Forbidden**: Check IIS_IUSRS has read permissions
- **Static files not loading**: Enable Static Content feature in IIS

### Mock Service Issues
- **500.1001 - iisnode error**: Check Node.js is installed and in PATH
- **Cannot find module**: Run `npm install` in the service folder
- **Port conflicts**: Change port in IIS binding and update sandbox configuration

### CORS Issues
If sandbox and service are on different ports/domains, the service already has CORS enabled in server.js.

---

## Optional: Use Custom Domain

### Edit hosts file (C:\Windows\System32\drivers\etc\hosts):
```
127.0.0.1    sandbox.local
127.0.0.1    cds-service.local
```

### Update IIS bindings to use these hostnames

---

## Production Considerations

1. **HTTPS**: Configure SSL certificates in IIS
2. **Logging**: Configure iisnode logging in web.config
3. **Performance**: Enable compression in IIS
4. **Security**: Restrict access, use authentication
5. **Monitoring**: Set up health checks and monitoring
