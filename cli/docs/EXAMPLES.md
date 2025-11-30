# Smith Tools CLI Examples

This document provides real-world examples of using the Smith Tools CLI for various development workflows.

## Quick Start Examples

### 1. First Time Setup

```bash
# Check what Smith tools are available
smith status

# Validate a new Swift package
smith validate ./MyNewPackage

# Get help for specific commands
smith validate --help
smith xcode --help
```

### 2. Analyze Existing Projects

```bash
# Automatically detect and analyze project type
smith smart-analyze

# Analyze specific project types
smith xcode analyze ./MyApp.xcodeproj
smith spm analyze ./MyPackage
smith swift analyze .
```

## Development Workflow Examples

### Daily Development

#### Morning Setup - Check Project Health
```bash
# Quick health check
smith smart-analyze --format summary

# If issues found, get details
smith validate --level standard --verbose

# Check for performance issues
smith analyze --hang-detection --verbose
```

#### Before Commit - Quality Gate
```bash
# Fast validation for quick feedback
smith validate --level critical --quiet

# Check for build issues
smith swift parse < <(swift build 2>&1)

# If working with TCA features
smith tca analyze --complexity --dependencies
```

#### Before Push - Comprehensive Check
```bash
# Full validation suite
smith validate --deep --level comprehensive --format json --output validation-report.json

# Architecture analysis
smith tca trace ./MyFeature --output trace.json

# Performance baseline
smith analyze --hang-detection --cpu-threshold 80 --memory-threshold 2.0
```

### Feature Development

#### TCA Feature Development Workflow
```bash
# 1. Start with architecture analysis
smith tca analyze ./MyNewFeature --complexity --dependencies

# 2. During development, quick checks
smith validate ./MyNewFeature --level critical --format json

# 3. Performance profiling
smith tca trace ./MyNewFeature --memory --complexity

# 4. Compare with baseline
smith tca compare baseline.json current.json --detailed
```

#### Swift Package Development
```bash
# 1. Initial analysis
smith spm analyze --dependencies --circular

# 2. Check dependency tree
smith spm dependencies --tree

# 3. Monitor build performance
swift build | smith swift parse --format detailed

# 4. Validate TCA architecture (if using TCA)
smith validate --level standard
```

#### Xcode Project Development
```bash
# 1. Project analysis
smith xcode analyze --performance --dependencies --json

# 2. Monitor builds
smith xcode monitor --scheme MyApp --eta

# 3. Parse build output
xcodebuild -scheme MyApp | smith xcode parse --format json

# 4. Clean build issues
smith xcode clean --derived-data
```

## CI/CD Integration Examples

### GitHub Actions

#### Basic Validation Workflow
```yaml
name: TCA Validation
on: [push, pull_request]

jobs:
  validate:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Install Smith Tools
      run: |
        brew install smith-validation
        brew install smith-xcsift
        brew install smith-sbsift
    
    - name: Validate TCA Architecture
      run: |
        smith validate --level critical --format json > validation-results.json
        
    - name: Upload Validation Results
      uses: actions/upload-artifact@v3
      with:
        name: validation-results
        path: validation-results.json
        
    - name: Fail on Critical Issues
      run: |
        VIOLATIONS=$(jq '.violations | length' validation-results.json)
        if [ "$VIOLATIONS" -gt 0 ]; then
          echo "TCA validation failed with $VIOLATIONS violations"
          jq '.violations[] | select(.severity == "critical")' validation-results.json
          exit 1
        fi
```

#### Comprehensive Analysis Workflow
```yaml
name: Comprehensive Analysis
on: [push]

jobs:
  analyze:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Environment
      run: |
        # Install all Smith tools
        brew install smith-validation smith-xcsift smith-sbsift smith-spmsift smith-tca-trace
        
    - name: Smart Project Analysis
      run: |
        smith smart-analyze --format json --verbose > analysis-results.json
        
    - name: TCA Architecture Validation
      run: |
        smith validate --deep --level comprehensive --format json > tca-validation.json
        
    - name: Performance Analysis
      run: |
        smith tca trace --json --output performance-trace.json
        
    - name: Dependency Analysis
      run: |
        smith spm analyze --dependencies --circular --json > dependency-analysis.json
        
    - name: Upload All Results
      uses: actions/upload-artifact@v3
      with:
        name: smith-analysis-results
        path: |
          analysis-results.json
          tca-validation.json
          performance-trace.json
          dependency-analysis.json
```

### GitLab CI

#### Multi-Stage Validation
```yaml
stages:
  - validate
  - analyze
  - performance

validate_tca:
  stage: validate
  script:
    - brew install smith-validation
    - smith validate --level critical --format junit > validation-report.xml
  artifacts:
    reports:
      junit: validation-report.xml
    when: always

analyze_project:
  stage: analyze
  script:
    - brew install smith-xcsift smith-sbsift
    - smith smart-analyze --format json > analysis.json
  artifacts:
    paths:
      - analysis.json
    when: always

performance_baseline:
  stage: performance
  script:
    - brew install smith-tca-trace
    - smith tca trace --json --output baseline.json
  artifacts:
    paths:
      - baseline.json
    expire_in: 1 week
```

### Jenkins Pipeline

```groovy
pipeline {
    agent { label 'macos' }
    
    stages {
        stage('Setup') {
            steps {
                sh '''
                    # Install Smith tools
                    brew install smith-validation smith-xcsift smith-sbsift smith-spmsift smith-tca-trace
                '''
            }
        }
        
        stage('Quick Validation') {
            steps {
                sh '''
                    smith validate --level critical --format json > quick-validation.json
                    
                    # Fail fast on critical issues
                    CRITICAL_COUNT=$(jq '[.violations[] | select(.severity == "critical")] | length' quick-validation.json)
                    if [ "$CRITICAL_COUNT" -gt 0 ]; then
                        echo "Found $CRITICAL_COUNT critical TCA violations"
                        jq '.violations[] | select(.severity == "critical")' quick-validation.json
                        exit 1
                    fi
                '''
            }
        }
        
        stage('Full Analysis') {
            steps {
                parallel {
                    'TCA Validation': {
                        sh 'smith validate --deep --level comprehensive --format json > full-validation.json'
                    },
                    'Performance Analysis': {
                        sh 'smith tca trace --json --output performance.json'
                    },
                    'Dependency Analysis': {
                        sh 'smith spm analyze --dependencies --circular --json > dependencies.json'
                    }
                }
            }
        }
        
        stage('Publish Results') {
            steps {
                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: '.',
                    reportFiles: 'full-validation.json,performance.json,dependencies.json',
                    reportName: 'Smith Analysis Results'
                ])
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: '*.json', fingerprint: true
        }
    }
}
```

## Build Monitoring Examples

### Real-time Build Monitoring

#### Xcode Build Monitor
```bash
# Monitor Xcode build with ETA
smith xcode monitor --scheme MyApp --eta --hang-detection

# Monitor specific target
smith xcode monitor --project MyApp.xcodeproj --scheme MyApp --target MyTarget

# Monitor with custom timeout
smith xcode monitor --scheme MyApp --timeout 1800  # 30 minutes
```

#### Swift Package Build Monitor
```bash
# Monitor swift build with progress
swift build | smith swift monitor --eta

# Monitor with hang detection
swift build | smith swift monitor --hang-detection --cpu-threshold 80

# Monitor test execution
swift test | smith swift monitor --resources
```

### Build Output Analysis

#### Continuous Build Log Parsing
```bash
# In a terminal, monitor build output
xcodebuild -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 14' \
    | tee build.log \
    | smith xcode parse --format json --verbose

# Post-build analysis
smith xcode parse --format json < build.log > analysis.json
```

#### Automated Build Health Checks
```bash
#!/bin/bash
# build-health-check.sh

set -e

echo "Starting build health check..."

# 1. Pre-build validation
smith validate --level critical --quiet || {
    echo "❌ Pre-build validation failed"
    exit 1
}

# 2. Start monitoring
smith xcode monitor --scheme MyApp &
MONITOR_PID=$!

# 3. Run build
xcodebuild -scheme MyApp clean build

# 4. Wait for monitoring to complete
wait $MONITOR_PID

echo "✅ Build health check completed"
```

## Performance Analysis Examples

### TCA Performance Profiling

#### Feature Performance Baseline
```bash
# Create performance baseline for a feature
smith tca trace ./MyFeature \
    --memory \
    --complexity \
    --output baseline-feature.json

# After changes, compare performance
smith tca compare baseline-feature.json current-feature.json --detailed
```

#### Application-wide Performance Analysis
```bash
# Analyze entire application
smith tca analyze ./MyApp \
    --complexity \
    --dependencies \
    --antipatterns \
    --format json \
    > app-analysis.json

# Focus on specific modules
smith tca analyze ./MyApp/Core \
    --complexity \
    --format json \
    > core-analysis.json
```

### Build Performance Analysis

#### Swift Package Build Performance
```bash
# Analyze build performance
smith spm analyze --optimize --json > spm-analysis.json

# Check for build bottlenecks
smith swift analyze --file-timing --bottleneck 10

# Monitor build in real-time
swift build | smith swift monitor --eta --resources
```

#### Xcode Build Performance
```bash
# Analyze Xcode project build performance
smith xcode analyze --performance --json > xcode-performance.json

# Monitor builds with hang detection
smith xcode monitor --scheme MyApp --hang-detection

# Clean and rebuild analysis
smith xcode clean --derived-data
smith xcode rebuild --scheme MyApp --performance
```

## Debugging Examples

### Common Issues and Solutions

#### TCA Architecture Issues
```bash
# Identify architectural problems
smith tca analyze ./ProblematicFeature --antipatterns --verbose

# Get specific recommendations
smith validate ./ProblematicFeature --level comprehensive --format json

# Compare with well-architected feature
smith tca compare good-feature.json problematic-feature.json
```

#### Build Performance Issues
```bash
# Identify slow compilation
smith swift analyze --file-timing --bottleneck 20

# Check for circular dependencies
smith spm analyze --circular --dependencies

# Monitor system resources during build
smith analyze --hang-detection --cpu-threshold 90 --memory-threshold 4.0
```

#### Build Failures
```bash
# Parse and analyze build errors
smith swift parse < build-error.log --format detailed

# Get specific recommendations
smith validate --level critical --format json

# Check project configuration
smith detect --verbose
```

### Advanced Debugging

#### Comprehensive Project Audit
```bash
#!/bin/bash
# project-audit.sh

echo "🔍 Starting comprehensive project audit..."

# 1. Project detection and basic info
smith detect --verbose

# 2. TCA architecture validation
smith validate --deep --level comprehensive --format json --output audit-tca.json

# 3. Performance analysis
smith tca trace --json --output audit-performance.json

# 4. Dependency analysis
smith spm analyze --dependencies --circular --optimize --format json --output audit-deps.json

# 5. Build configuration audit
smith xcode analyze --performance --json --output audit-xcode.json

# 6. Generate summary report
cat > audit-summary.md << EOF
# Project Audit Summary

Generated: $(date)

## TCA Architecture
$(jq -r '.summary | "Health Score: \(.healthScore)/100\nViolations: \(.violationsCount)"' audit-tca.json)

## Performance
$(jq -r '.performance | "Average Response Time: \(.averageResponseTime)ms\nMemory Usage: \(.memoryUsage)MB"' audit-performance.json 2>/dev/null || echo "No performance data")

## Dependencies
$(jq -r '.summary | "Total Dependencies: \(.totalCount)\nCircular Dependencies: \(.circularCount)"' audit-deps.json)

## Build Configuration
$(jq -r '.metrics | "Build Time: \(.averageBuildTime)s\nSuccess Rate: \(.successRate)%"' audit-xcode.json 2>/dev/null || echo "No build data")

See individual audit files for detailed analysis.
EOF

echo "✅ Project audit completed. See audit-summary.md"
```

## Automation Examples

### Pre-commit Hook

```bash
#!/bin/sh
# .git/hooks/pre-commit

# Quick TCA validation before commit
echo "🔍 Running pre-commit TCA validation..."

smith validate --level critical --quiet || {
    echo "❌ TCA validation failed. Commit aborted."
    echo "Run 'smith validate' for details or use --no-verify to skip."
    exit 1
}

echo "✅ TCA validation passed"
```

### Daily Health Check Script

```bash
#!/bin/bash
# daily-health-check.sh

DATE=$(date +%Y%m%d)
LOG_DIR="logs/health-check-$DATE"
mkdir -p "$LOG_DIR"

echo "🏥 Running daily project health check..."

# 1. Quick validation
smith validate --level critical --format json > "$LOG_DIR/validation.json"

# 2. Performance baseline
smith tca trace --json --output "$LOG_DIR/performance.json"

# 3. Dependency check
smith spm analyze --dependencies --circular --json > "$LOG_DIR/dependencies.json"

# 4. Generate report
smith smart-analyze --format json --verbose > "$LOG_DIR/analysis.json"

# 5. Check for issues
CRITICAL_ISSUES=$(jq '[.violations[] | select(.severity == "critical")] | length' "$LOG_DIR/validation.json" 2>/dev/null || echo "0")

if [ "$CRITICAL_ISSUES" -gt 0 ]; then
    echo "⚠️  Found $CRITICAL_ISSUES critical issues"
    jq '.violations[] | select(.severity == "critical")' "$LOG_DIR/validation.json"
    
    # Send notification (customize as needed)
    echo "Daily health check found critical issues in project" | \
        mail -s "Project Health Alert" developer@company.com
else
    echo "✅ No critical issues found"
fi

echo "📊 Health check report saved to $LOG_DIR/"
```

### Release Preparation

```bash
#!/bin/bash
# release-prep.sh

echo "🚀 Preparing for release..."

# 1. Comprehensive validation
smith validate --deep --level comprehensive --format json --output release-validation.json

# 2. Performance analysis
smith tca trace --memory --complexity --json --output release-performance.json

# 3. Dependency audit
smith spm analyze --optimize --circular --dependencies --format json --output release-deps.json

# 4. Build test
echo "🧪 Testing release build..."
xcodebuild -scheme MyApp -configuration Release clean build | smith xcode parse --format json --verbose > release-build.json

# 5. Generate release report
cat > RELEASE_NOTES.md << EOF
# Release Validation Report

Date: $(date)

## TCA Architecture Health
- Score: $(jq -r '.summary.healthScore' release-validation.json)/100
- Violations: $(jq -r '.summary.violationsCount' release-validation.json)

## Performance Metrics
- Average Response Time: $(jq -r '.performance.averageResponseTime' release-performance.json 2>/dev/null || echo "N/A")ms
- Memory Usage: $(jq -r '.performance.memoryUsage' release-performance.json 2>/dev/null || echo "N/A")MB

## Dependencies
- Total: $(jq -r '.summary.totalCount' release-deps.json)
- Outdated: $(jq -r '.summary.outdatedCount' release-deps.json)

## Build Success
- Status: $(jq -r '.success' release-build.json)
- Duration: $(jq -r '.duration' release-build.json)s

## Validation Results
$(jq -r '.violations[] | "- \(.severity): \(.message) (\(.file):\(.line))"' release-validation.json 2>/dev/null || echo "No violations")

See attached JSON files for detailed analysis.
EOF

echo "✅ Release preparation completed"
echo "📋 Review RELEASE_NOTES.md before proceeding"
```

## Integration Examples

### Shell Functions

```bash
# Add to ~/.bashrc or ~/.zshrc

# Quick TCA check
tca-check() {
    smith validate --level critical "$@"
}

# Project health overview
project-health() {
    smith smart-analyze --format summary "$@"
}

# Build monitoring wrapper
build-monitor() {
    if [ -f "Package.swift" ]; then
        swift build "$@" | smith swift monitor --eta
    elif [ -f "*.xcodeproj" ] || [ -f "*.xcworkspace" ]; then
        smith xcode monitor --scheme "${1:-MyApp}" "$@"
    else
        echo "❌ No Swift or Xcode project found"
        return 1
    fi
}

# Performance baseline
perf-baseline() {
    local feature=${1:-./CurrentFeature}
    smith tca trace "$feature" --json --output "baseline-$(date +%Y%m%d-%H%M%S).json"
    echo "✅ Performance baseline saved"
}
```

### Alfred Workflow Integration

```bash
#!/bin/bash
# Smith Tools Alfred Workflow

QUERY="$1"
ACTION="$2"

case "$ACTION" in
    "validate")
        smith validate --level critical --format json | jq -r '.violations[] | "\(.file):\(.line) - \(.message)"'
        ;;
    "analyze")
        smith smart-analyze --format summary
        ;;
    "monitor")
        build-monitor
        ;;
    "tca")
        smith tca analyze --format summary
        ;;
    *)
        echo "Usage: smith-alfred {validate|analyze|monitor|tca}"
        ;;
esac
```

These examples demonstrate the versatility and power of the Smith Tools CLI across different development scenarios, from daily development workflows to CI/CD integration and automated monitoring.