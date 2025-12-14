# Fibers Migration Plan

## Current Status

The `fibers` package is listed as a dependency in `package.json` but is **NOT actively used** in the source code.

### Audit Results

✅ **No direct usage found** - Searched entire `src/` directory
- No `require('fibers')` or `import ... from 'fibers'`
- No `Fiber()` constructor calls
- No `.run()` or `.yield()` patterns

### Why Fibers is Present

The `fibers` dependency exists because:

1. **sass-loader peer dependency**: `sass-loader` lists `fibers` as an **optional** peer dependency
   - Location: `node_modules/sass-loader/package.json`
   - Note: It's marked as `"optional": true` in peerDependenciesMeta
   
2. **Legacy from node-sass era**: When this project used `node-sass`, fibers was commonly used for performance optimization in Sass compilation

3. **No longer needed**: Since migrating to `sass` (Dart Sass), fibers is completely unnecessary

## Migration Steps

### Immediate Actions (Node 14.x Compatibility)

**Status: ✅ COMPLETED**
- Updated `.github/workflows/deploy.yml` to use Node.js 14.x
- This provides temporary compatibility while planning removal

### Phase 1: Remove Fibers Dependency

Since fibers is not used in the source code, it can be safely removed:

```bash
npm uninstall fibers
```

**Expected Impact:** None - the package is unused in code

**Risk Level:** ✅ LOW - No code changes required

### Phase 2: Verify Build Process

After removing fibers, verify that:

1. Development build works:
   ```bash
   npm run dev
   ```

2. Production build works:
   ```bash
   npm run build
   ```

3. Tests pass:
   ```bash
   npm test
   ```

### Phase 3: Update to Modern Node.js

Once fibers is removed, the project can upgrade to modern Node.js versions:

1. **Target Node.js 18.x (LTS)** or **20.x (Current LTS)**
2. Update workflow file:
   ```yaml
   node-version: '18.x'  # or '20.x'
   ```

3. Update package.json engines field:
   ```json
   "engines": {
     "node": ">=18.0.0"
   }
   ```

## Technical Background

### Why Fibers is Deprecated

- **Native async/await**: Modern JavaScript has built-in async support
- **Performance issues**: Fibers adds overhead and complexity
- **Maintenance burden**: No longer actively maintained
- **Node.js compatibility**: Breaks with newer V8 engines (Node 16+)

### Sass Compilation Without Fibers

Dart Sass (the `sass` package) does NOT need fibers:
- Uses pure JavaScript/Dart implementation
- Async by default
- Better performance without fibers
- Compatible with all Node.js versions

## Verification Checklist

- [x] Audit complete - no fibers usage in source code
- [x] GitHub Actions workflow updated to Node 14.x
- [ ] Remove fibers from package.json dependencies
- [ ] Verify dev build works without fibers
- [ ] Verify production build works without fibers
- [ ] Run full test suite
- [ ] Update to Node.js 18.x or 20.x
- [ ] Update documentation

## Recommended Timeline

1. **Immediate**: Node 14.x pinning (✅ DONE)
2. **This week**: Remove fibers dependency
3. **Next sprint**: Upgrade to Node.js 18.x/20.x
4. **Ongoing**: Keep dependencies up to date

## Commands to Execute

### Remove Fibers
```bash
npm uninstall fibers
```

### Test After Removal
```bash
npm install
npm run lint
npm run test
npm run build
```

### Update Workflow (Future)
Edit `.github/workflows/deploy.yml`:
```yaml
node-version: '18.x'  # Upgrade from 14.x
```

## Notes

- **No code refactoring needed** - fibers was never used in source
- This is a **dependency cleanup** task, not a code migration
- Safe to proceed immediately with removal
- The dependency likely came from copy-pasted package.json or outdated boilerplate

## References

- [Node.js Release Schedule](https://nodejs.org/en/about/releases/)
- [Dart Sass Documentation](https://sass-lang.com/dart-sass)
- [sass-loader without fibers](https://github.com/webpack-contrib/sass-loader#getting-started)
