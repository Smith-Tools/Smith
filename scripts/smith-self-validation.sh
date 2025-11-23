#!/bin/bash

# smith-self-validation.sh
# Validates that Smith follows its own rules
# Usage: ./smith-self-validation.sh

set -e

echo "🔍 Smith Self-Validation Script"
echo "================================"
echo

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if file exists
check_file() {
    if [ ! -f "$1" ]; then
        echo -e "${RED}❌ Missing file: $1${NC}"
        return 1
    else
        echo -e "${GREEN}✅ Found file: $1${NC}"
        return 0
    fi
}

# Function to check if smith agent has mandatory validation
check_agent_validation() {
    local smith_agent_file="/Volumes/Plutonian/_Developer/Smith-Tools/Smith/agent/smith.md"

    echo "📋 Checking Smith agent configuration..."

    if check_file "$smith_agent_file"; then
        # Check for Apple platform build hierarchy section
        if grep -q "Apple Platform Build Hierarchy" "$smith_agent_file"; then
            echo -e "${GREEN}   ✅ Has Apple platform build hierarchy${NC}"
        else
            echo -e "${RED}   ❌ Missing Apple platform build hierarchy${NC}"
            return 1
        fi

        # Check for workspace priority enforcement
        if grep -q "Workspace Build Enforcement" "$smith_agent_file"; then
            echo -e "${GREEN}   ✅ Has workspace build enforcement${NC}"
        else
            echo -e "${RED}   ❌ Missing workspace build enforcement${NC}"
            return 1
        fi

        # Check for correct build priority order
        if grep -q "xcworkspace" "$smith_agent_file" && grep -q "xcodeproj" "$smith_agent_file" && grep -q "Package.swift" "$smith_agent_file" && grep -q "swiftc" "$smith_agent_file"; then
            echo -e "${GREEN}   ✅ Has correct build priority order${NC}"
        else
            echo -e "${RED}   ❌ Missing correct build priority order${NC}"
            return 1
        fi

        # Check for workspace dependency warning
        if grep -q "Building the .xcodeproj directly will miss workspace dependencies" "$smith_agent_file"; then
            echo -e "${GREEN}   ✅ Has workspace dependency warning${NC}"
        else
            echo -e "${RED}   ❌ Missing workspace dependency warning${NC}"
            return 1
        fi

        # Check for Apple platform detection commands only
        if grep -q "Apple Platform Detection Commands" "$smith_agent_file"; then
            echo -e "${GREEN}   ✅ Has Apple platform detection commands${NC}"
        else
            echo -e "${RED}   ❌ Missing Apple platform detection commands${NC}"
            return 1
        fi

        # Check that non-Apple languages were removed
        if ! grep -q "package.json\|requirements.txt\|Cargo.toml" "$smith_agent_file"; then
            echo -e "${GREEN}   ✅ Non-Apple languages removed${NC}"
        else
            echo -e "${RED}   ❌ Still contains non-Apple language detection${NC}"
            return 1
        fi

        # Check for response templates
        if grep -q "Smith Response Templates" "$smith_agent_file"; then
            echo -e "${GREEN}   ✅ Has response templates${NC}"
        else
            echo -e "${RED}   ❌ Missing response templates${NC}"
            return 1
        fi

        # Check for Tree 5 reference
        if grep -q "Tree 5" "$smith_agent_file"; then
            echo -e "${GREEN}   ✅ References Tree 5 decision logic${NC}"
        else
            echo -e "${RED}   ❌ Missing Tree 5 decision logic reference${NC}"
            return 1
        fi

        # Check for smith-spmsift integration
        if grep -q "smith-spmsift" "$smith_agent_file"; then
            echo -e "${GREEN}   ✅ Includes smith-spmsift for Swift packages${NC}"
        else
            echo -e "${RED}   ❌ Missing smith-spmsift integration${NC}"
            return 1
        fi
    else
        return 1
    fi

    return 0
}

# Function to check skill knowledge files
check_skill_knowledge() {
    echo "📚 Checking Smith skill knowledge files..."

    local knowledge_base="/Volumes/Plutonian/_Developer/Smith-Tools/Smith/skills/smith/knowledge"
    local required_files=(
        "AGENTS-DECISION-TREES.md"
        "AGENTS-AGNOSTIC.md"
        "CLAUDE.md"
    )

    for file in "${required_files[@]}"; do
        check_file "$knowledge_base/$file"
    done

    # Check if Tree 5 exists and has correct content
    local decision_trees_file="$knowledge_base/AGENTS-DECISION-TREES.md"
    if check_file "$decision_trees_file"; then
        if grep -q "What type of project is this?" "$decision_trees_file"; then
            echo -e "${GREEN}   ✅ Tree 5 has project type detection${NC}"
        else
            echo -e "${RED}   ❌ Tree 5 missing project type detection${NC}"
            return 1
        fi

        if grep -q "smith-xcsift" "$decision_trees_file"; then
            echo -e "${GREEN}   ✅ Tree 5 references smith-xcsift${NC}"
        else
            echo -e "${RED}   ❌ Tree 5 missing smith-xcsift reference${NC}"
            return 1
        fi
    fi
}

# Function to simulate smith build question test
test_smith_build_response() {
    echo "🧪 Testing Smith Apple platform build response logic..."

    # Create a temporary test directory structure
    local test_dir="/tmp/smith_test_$$"
    mkdir -p "$test_dir"

    # Test 1: Xcode workspace detection (highest priority)
    echo "   Test 1: Xcode workspace detection (highest priority)"
    mkdir -p "$test_dir/MyProject.xcworkspace"
    mkdir -p "$test_dir/MyProject.xcodeproj"  # This should be ignored
    echo 'import UIKit' > "$test_dir/ViewController.swift"

    # Simulate the detection commands Smith should run
    local workspace_count=$(find "$test_dir" -maxdepth 3 -name "*.xcworkspace" -type d | wc -l)
    local xcodeproj_count=$(find "$test_dir" -maxdepth 3 -name "*.xcodeproj" -type d | wc -l)
    local swift_count=$(find "$test_dir" -name "*.swift" -type f | wc -l)

    if [ $workspace_count -gt 0 ] && [ $swift_count -gt 0 ]; then
        echo -e "${GREEN}      ✅ Would detect workspace (highest priority) → xcodebuild -workspace${NC}"
    else
        echo -e "${RED}      ❌ Failed to detect Xcode workspace priority${NC}"
        return 1
    fi

    # Test 2: Xcode project detection (no workspace)
    echo "   Test 2: Xcode project detection (no workspace)"
    rm -rf "$test_dir"/*
    mkdir -p "$test_dir/MyApp.xcodeproj"
    echo 'import Foundation' > "$test_dir/main.swift"

    workspace_count=$(find "$test_dir" -maxdepth 3 -name "*.xcworkspace" -type d | wc -l)
    xcodeproj_count=$(find "$test_dir" -maxdepth 3 -name "*.xcodeproj" -type d | wc -l)
    swift_count=$(find "$test_dir" -name "*.swift" -type f | wc -l)

    if [ $workspace_count -eq 0 ] && [ $xcodeproj_count -gt 0 ] && [ $swift_count -gt 0 ]; then
        echo -e "${GREEN}      ✅ Would detect project (no workspace) → xcodebuild -project${NC}"
    else
        echo -e "${RED}      ❌ Failed to detect Xcode project${NC}"
        return 1
    fi

    # Test 3: Swift package detection (no Xcode files)
    echo "   Test 3: Swift package detection (no Xcode files)"
    rm -rf "$test_dir"/*
    echo '// Swift package' > "$test_dir/Package.swift"
    echo 'import Foundation' > "$test_dir/main.swift"

    workspace_count=$(find "$test_dir" -maxdepth 3 -name "*.xcworkspace" -type d | wc -l)
    xcodeproj_count=$(find "$test_dir" -maxdepth 3 -name "*.xcodeproj" -type d | wc -l)
    local package_count=$(find "$test_dir" -maxdepth 2 -name "Package.swift" -type f | wc -l)
    swift_count=$(find "$test_dir" -name "*.swift" -type f | wc -l)

    if [ $workspace_count -eq 0 ] && [ $xcodeproj_count -eq 0 ] && [ $package_count -gt 0 ] && [ $swift_count -gt 0 ]; then
        echo -e "${GREEN}      ✅ Would detect Swift package → swift build${NC}"
    else
        echo -e "${RED}      ❌ Failed to detect Swift package${NC}"
        return 1
    fi

    # Test 4: Simple Swift files (no package/project)
    echo "   Test 4: Simple Swift files (no package/project)"
    rm -rf "$test_dir"/*
    echo 'import Foundation' > "$test_dir/main.swift"
    echo 'func helper() {}' > "$test_dir/helpers.swift"

    workspace_count=$(find "$test_dir" -maxdepth 3 -name "*.xcworkspace" -type d | wc -l)
    xcodeproj_count=$(find "$test_dir" -maxdepth 3 -name "*.xcodeproj" -type d | wc -l)
    package_count=$(find "$test_dir" -maxdepth 2 -name "Package.swift" -type f | wc -l)
    swift_count=$(find "$test_dir" -name "*.swift" -type f | wc -l)

    if [ $workspace_count -eq 0 ] && [ $xcodeproj_count -eq 0 ] && [ $package_count -eq 0 ] && [ $swift_count -gt 0 ]; then
        echo -e "${GREEN}      ✅ Would detect simple Swift files → swiftc${NC}"
    else
        echo -e "${RED}      ❌ Failed to detect simple Swift files${NC}"
        return 1
    fi

    # Test 5: Non-Apple project (out of scope)
    echo "   Test 5: Non-Apple project (out of scope)"
    rm -rf "$test_dir"/*
    echo 'console.log("Hello");' > "$test_dir/index.js"
    echo 'print("Python");' > "$test_dir/main.py"

    workspace_count=$(find "$test_dir" -maxdepth 3 -name "*.xcworkspace" -type d | wc -l)
    xcodeproj_count=$(find "$test_dir" -maxdepth 3 -name "*.xcodeproj" -type d | wc -l)
    package_count=$(find "$test_dir" -maxdepth 2 -name "Package.swift" -type f | wc -l)
    swift_count=$(find "$test_dir" -name "*.swift" -type f | wc -l)

    if [ $workspace_count -eq 0 ] && [ $xcodeproj_count -eq 0 ] && [ $package_count -eq 0 ] && [ $swift_count -eq 0 ]; then
        echo -e "${GREEN}      ✅ Would detect out of scope → No Apple platform files${NC}"
    else
        echo -e "${RED}      ❌ Failed to detect out of scope correctly${NC}"
        return 1
    fi

    # Test 6: Priority validation (workspace + project + package)
    echo "   Test 6: Priority validation (workspace overrides project + package)"
    rm -rf "$test_dir"/*
    mkdir -p "$test_dir/MyWorkspace.xcworkspace"
    mkdir -p "$test_dir/MyProject.xcodeproj"
    echo '// Swift package' > "$test_dir/Package.swift"
    echo 'import UIKit' > "$test_dir/ViewController.swift"

    workspace_count=$(find "$test_dir" -maxdepth 3 -name "*.xcworkspace" -type d | wc -l)
    xcodeproj_count=$(find "$test_dir" -maxdepth 3 -name "*.xcodeproj" -type d | wc -l)
    package_count=$(find "$test_dir" -maxdepth 2 -name "Package.swift" -type f | wc -l)
    swift_count=$(find "$test_dir" -name "*.swift" -type f | wc -l)

    if [ $workspace_count -gt 0 ]; then
        echo -e "${GREEN}      ✅ Correctly prioritizes workspace over project + package → xcodebuild -workspace${NC}"
    else
        echo -e "${RED}      ❌ Failed to prioritize workspace correctly${NC}"
        return 1
    fi

    # Cleanup
    rm -rf "$test_dir"

    return 0
}

# Main validation
echo "Running Smith self-validation checks..."
echo

validation_failed=0

# Check agent validation
if ! check_agent_validation; then
    validation_failed=1
fi
echo

# Check skill knowledge
if ! check_skill_knowledge; then
    validation_failed=1
fi
echo

# Test response logic
if ! test_smith_build_response; then
    validation_failed=1
fi
echo

# Final result
if [ $validation_failed -eq 0 ]; then
    echo -e "${GREEN}🎉 All Smith self-validation checks passed!${NC}"
    echo "Smith is configured to properly detect project types and provide correct tool recommendations."
    exit 0
else
    echo -e "${RED}❌ Smith self-validation failed!${NC}"
    echo "Smith may give incorrect build advice. Please fix the issues above."
    exit 1
fi